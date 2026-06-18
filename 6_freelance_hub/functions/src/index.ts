import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger, setGlobalOptions } from "firebase-functions/v2";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();
setGlobalOptions({ region: "us-central1" });

/**
 * Envia push para todos os tokens registrados em users/{uid}.fcmTokens.
 * Tokens inválidos (messaging/registration-token-not-registered) são removidos
 * automaticamente do array. Falhas não derrubam o caller.
 */
async function sendPushToUser(
  uid: string,
  notification: { title: string; body: string },
  data: Record<string, string> = {}
): Promise<void> {
  try {
    const db = getFirestore();
    const userSnap = await db.collection("users").doc(uid).get();
    if (!userSnap.exists) return;
    const tokens = (userSnap.data()?.fcmTokens as string[] | undefined) ?? [];
    if (tokens.length === 0) return;

    const messaging = getMessaging();
    const invalidTokens: string[] = [];

    await Promise.all(
      tokens.map(async (token) => {
        try {
          await messaging.send({
            token,
            notification,
            data,
            android: { priority: "high" },
          });
        } catch (err: unknown) {
          const code = (err as { code?: string })?.code;
          if (
            code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-registration-token"
          ) {
            invalidTokens.push(token);
          } else {
            logger.warn("Falha ao enviar push", { uid, token, error: err });
          }
        }
      })
    );

    if (invalidTokens.length > 0) {
      await db.collection("users").doc(uid).update({
        fcmTokens: FieldValue.arrayRemove(...invalidTokens),
      });
      logger.info("Tokens inválidos removidos", {
        uid,
        count: invalidTokens.length,
      });
    }
  } catch (err) {
    logger.error("sendPushToUser falhou", { uid, error: err });
  }
}

/**
 * Trigger disparado ao criar um doc em proposals/{proposalId}.
 * Incrementa atomicamente o proposalCount do projeto correspondente.
 */
export const onProposalCreated = onDocumentCreated(
  "proposals/{proposalId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn("Evento onProposalCreated sem snapshot", {
        params: event.params,
      });
      return;
    }

    const proposal = snapshot.data();
    const projectId = proposal.projectId as string | undefined;
    if (!projectId) {
      logger.error("Proposta sem projectId", {
        proposalId: event.params.proposalId,
      });
      return;
    }

    const db = getFirestore();
    const projectRef = db.collection("projects").doc(projectId);

    try {
      await projectRef.update({
        proposalCount: FieldValue.increment(1),
      });
      logger.info("proposalCount incrementado", {
        projectId,
        proposalId: event.params.proposalId,
      });
    } catch (err) {
      logger.error("Falha ao incrementar proposalCount", {
        projectId,
        proposalId: event.params.proposalId,
        error: err,
      });
    }

    // Push para o cliente avisando da proposta nova.
    const clientId = proposal.clientId as string | undefined;
    const freelancerName = (proposal.freelancerName as string) || "Freelancer";
    const projectTitle = (proposal.projectTitle as string) || "seu projeto";
    if (clientId) {
      await sendPushToUser(
        clientId,
        {
          title: "Nova proposta recebida",
          body: `${freelancerName} enviou uma proposta para "${projectTitle}".`,
        },
        {
          type: "proposalCreated",
          projectId: projectId,
          proposalId: event.params.proposalId,
        }
      );
    }
  }
);

/**
 * Callable: cliente aceita uma proposta.
 *
 * Operação atômica (transaction):
 *  1. Valida que caller é o clientId da proposta.
 *  2. Valida que a proposta está em status `pending`.
 *  3. Status da proposta → `accepted`.
 *  4. Outras propostas pending do mesmo projeto → `rejected`.
 *  5. Status do projeto → `active`.
 *  6. Cria doc em `contracts/` com referência cruzada.
 *
 * Retorna { contractId }.
 */
export const acceptProposal = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login necessário.");
  }
  const proposalId = request.data?.proposalId;
  if (typeof proposalId !== "string" || !proposalId) {
    throw new HttpsError("invalid-argument", "proposalId é obrigatório.");
  }

  const db = getFirestore();
  const proposalRef = db.collection("proposals").doc(proposalId);
  const contractRef = db.collection("contracts").doc(); // auto ID

  const callerUid = request.auth.uid;

  const result = await db.runTransaction(async (tx) => {
    const proposalSnap = await tx.get(proposalRef);
    if (!proposalSnap.exists) {
      throw new HttpsError("not-found", "Proposta não encontrada.");
    }
    const proposal = proposalSnap.data()!;

    if (proposal.clientId !== callerUid) {
      throw new HttpsError(
        "permission-denied",
        "Apenas o cliente do projeto pode aceitar."
      );
    }
    if (proposal.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "Proposta não está mais pendente."
      );
    }

    const projectId = proposal.projectId as string;
    const projectRef = db.collection("projects").doc(projectId);
    const projectSnap = await tx.get(projectRef);
    if (!projectSnap.exists) {
      throw new HttpsError("not-found", "Projeto não encontrado.");
    }
    const project = projectSnap.data()!;
    const clientName = (project.clientName as string | undefined) ?? "";

    const otherPendingSnap = await tx.get(
      db
        .collection("proposals")
        .where("projectId", "==", projectId)
        .where("status", "==", "pending")
    );

    tx.update(proposalRef, { status: "accepted" });

    for (const doc of otherPendingSnap.docs) {
      if (doc.id !== proposalId) {
        tx.update(doc.ref, { status: "rejected" });
      }
    }

    tx.update(projectRef, { status: "active" });

    tx.set(contractRef, {
      projectId,
      projectTitle: proposal.projectTitle,
      clientId: proposal.clientId,
      clientName,
      freelancerId: proposal.freelancerId,
      freelancerName: proposal.freelancerName,
      value: proposal.value,
      daysEstimate: proposal.daysEstimate,
      isHourly: proposal.isHourly,
      acceptedProposalId: proposalId,
      status: "active",
      createdAt: FieldValue.serverTimestamp(),
    });

    return { contractId: contractRef.id };
  });

  logger.info("Proposta aceita", {
    proposalId,
    contractId: result.contractId,
    callerUid,
  });
  return result;
});

/**
 * Callable: cliente rejeita uma proposta.
 * Simples: valida caller e status, troca status pra `rejected`.
 */
export const rejectProposal = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login necessário.");
  }
  const proposalId = request.data?.proposalId;
  if (typeof proposalId !== "string" || !proposalId) {
    throw new HttpsError("invalid-argument", "proposalId é obrigatório.");
  }

  const db = getFirestore();
  const proposalRef = db.collection("proposals").doc(proposalId);
  const snap = await proposalRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Proposta não encontrada.");
  }
  const proposal = snap.data()!;

  if (proposal.clientId !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "Apenas o cliente do projeto pode rejeitar."
    );
  }
  if (proposal.status !== "pending") {
    throw new HttpsError(
      "failed-precondition",
      "Proposta não está mais pendente."
    );
  }

  await proposalRef.update({ status: "rejected" });
  logger.info("Proposta rejeitada", {
    proposalId,
    callerUid: request.auth.uid,
  });
  return { ok: true };
});

/**
 * Callable: freelancer marca o contrato como entregue.
 * Valida caller == freelancerId e status atual == active.
 * Aceita lista opcional de URLs de fotos da entrega (Firebase Storage).
 */
export const markContractDelivered = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login necessário.");
  }
  const contractId = request.data?.contractId;
  if (typeof contractId !== "string" || !contractId) {
    throw new HttpsError("invalid-argument", "contractId é obrigatório.");
  }

  const rawPhotoUrls = request.data?.photoUrls;
  let photoUrls: string[] = [];
  if (rawPhotoUrls !== undefined && rawPhotoUrls !== null) {
    if (!Array.isArray(rawPhotoUrls)) {
      throw new HttpsError("invalid-argument", "photoUrls deve ser um array.");
    }
    if (rawPhotoUrls.length > 10) {
      throw new HttpsError("invalid-argument", "Máximo de 10 fotos por entrega.");
    }
    for (const u of rawPhotoUrls) {
      if (typeof u !== "string" || !u.startsWith("https://")) {
        throw new HttpsError("invalid-argument", "Cada photoUrl deve ser uma URL https.");
      }
    }
    photoUrls = rawPhotoUrls as string[];
  }

  const db = getFirestore();
  const contractRef = db.collection("contracts").doc(contractId);
  const snap = await contractRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Contrato não encontrado.");
  }
  const contract = snap.data()!;
  if (contract.freelancerId !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "Apenas o freelancer pode marcar como entregue."
    );
  }
  if (contract.status !== "active") {
    throw new HttpsError(
      "failed-precondition",
      "Contrato não está em andamento."
    );
  }

  await contractRef.update({
    status: "delivered",
    deliveryPhotoUrls: photoUrls,
    deliveredAt: FieldValue.serverTimestamp(),
  });
  logger.info("Contrato marcado como entregue", {
    contractId,
    callerUid: request.auth.uid,
    photoCount: photoUrls.length,
  });
  return { ok: true };
});

/**
 * Callable: cliente aprova a entrega.
 * Valida caller == clientId e status atual == delivered.
 * Transaction: contract → completed, project → completed.
 */
export const acceptContractDelivery = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login necessário.");
  }
  const contractId = request.data?.contractId;
  if (typeof contractId !== "string" || !contractId) {
    throw new HttpsError("invalid-argument", "contractId é obrigatório.");
  }

  const db = getFirestore();
  const contractRef = db.collection("contracts").doc(contractId);
  const callerUid = request.auth.uid;

  await db.runTransaction(async (tx) => {
    const contractSnap = await tx.get(contractRef);
    if (!contractSnap.exists) {
      throw new HttpsError("not-found", "Contrato não encontrado.");
    }
    const contract = contractSnap.data()!;

    if (contract.clientId !== callerUid) {
      throw new HttpsError(
        "permission-denied",
        "Apenas o cliente pode aprovar a entrega."
      );
    }
    if (contract.status !== "delivered") {
      throw new HttpsError(
        "failed-precondition",
        "Contrato não está em status entregue."
      );
    }

    const projectId = contract.projectId as string;
    const projectRef = db.collection("projects").doc(projectId);
    const projectSnap = await tx.get(projectRef);
    if (!projectSnap.exists) {
      throw new HttpsError("not-found", "Projeto não encontrado.");
    }

    tx.update(contractRef, { status: "completed" });
    tx.update(projectRef, { status: "completed" });
  });

  logger.info("Entrega aprovada e contrato concluído", {
    contractId,
    callerUid,
  });
  return { ok: true };
});

/**
 * Callable: cliente solicita revisão da entrega.
 * Valida caller == clientId, status atual == delivered, motivo presente.
 * Status do contrato → revision_requested. Não mexe no project status — o
 * trabalho continua "ativo" na visão do projeto, só o contrato muda.
 */
export const requestContractRevision = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login necessário.");
  }
  const contractId = request.data?.contractId;
  if (typeof contractId !== "string" || !contractId) {
    throw new HttpsError("invalid-argument", "contractId é obrigatório.");
  }
  const rawReason = request.data?.reason;
  if (typeof rawReason !== "string") {
    throw new HttpsError("invalid-argument", "Motivo é obrigatório.");
  }
  const reason = rawReason.trim();
  if (reason.length < 10) {
    throw new HttpsError(
      "invalid-argument",
      "Descreva o motivo com pelo menos 10 caracteres."
    );
  }
  if (reason.length > 500) {
    throw new HttpsError(
      "invalid-argument",
      "Motivo limitado a 500 caracteres."
    );
  }

  const db = getFirestore();
  const contractRef = db.collection("contracts").doc(contractId);
  const snap = await contractRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Contrato não encontrado.");
  }
  const contract = snap.data()!;
  if (contract.clientId !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "Apenas o cliente pode solicitar revisão."
    );
  }
  if (contract.status !== "delivered") {
    throw new HttpsError(
      "failed-precondition",
      "Contrato não está aguardando aprovação."
    );
  }

  await contractRef.update({
    status: "revision_requested",
    revisionReason: reason,
    revisionRequestedAt: FieldValue.serverTimestamp(),
    revisionCount: FieldValue.increment(1),
  });
  logger.info("Revisão solicitada", {
    contractId,
    callerUid: request.auth.uid,
  });
  return { ok: true };
});

/**
 * Callable: freelancer reenvia a entrega após revisão.
 * Valida caller == freelancerId, status atual == revision_requested.
 * Status do contrato → delivered. Substitui as fotos (nova entrega).
 */
export const resubmitContractDelivery = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login necessário.");
  }
  const contractId = request.data?.contractId;
  if (typeof contractId !== "string" || !contractId) {
    throw new HttpsError("invalid-argument", "contractId é obrigatório.");
  }

  const rawPhotoUrls = request.data?.photoUrls;
  let photoUrls: string[] = [];
  if (rawPhotoUrls !== undefined && rawPhotoUrls !== null) {
    if (!Array.isArray(rawPhotoUrls)) {
      throw new HttpsError("invalid-argument", "photoUrls deve ser um array.");
    }
    if (rawPhotoUrls.length > 10) {
      throw new HttpsError(
        "invalid-argument",
        "Máximo de 10 fotos por entrega."
      );
    }
    for (const u of rawPhotoUrls) {
      if (typeof u !== "string" || !u.startsWith("https://")) {
        throw new HttpsError(
          "invalid-argument",
          "Cada photoUrl deve ser uma URL https."
        );
      }
    }
    photoUrls = rawPhotoUrls as string[];
  }

  const db = getFirestore();
  const contractRef = db.collection("contracts").doc(contractId);
  const snap = await contractRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "Contrato não encontrado.");
  }
  const contract = snap.data()!;
  if (contract.freelancerId !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "Apenas o freelancer pode reenviar a entrega."
    );
  }
  if (contract.status !== "revision_requested") {
    throw new HttpsError(
      "failed-precondition",
      "Contrato não está em revisão."
    );
  }

  await contractRef.update({
    status: "delivered",
    deliveryPhotoUrls: photoUrls,
    deliveredAt: FieldValue.serverTimestamp(),
  });
  logger.info("Entrega reenviada", {
    contractId,
    callerUid: request.auth.uid,
    photoCount: photoUrls.length,
  });
  return { ok: true };
});

/**
 * Trigger: proposta atualizada. Notifica o freelancer quando o cliente aceita
 * ou rejeita (status pending → accepted/rejected). Outras transições são
 * ignoradas.
 */
export const onProposalStatusChanged = onDocumentUpdated(
  "proposals/{proposalId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;
    if (before.status !== "pending") return;

    const freelancerId = after.freelancerId as string | undefined;
    const projectTitle = (after.projectTitle as string) || "seu projeto";
    if (!freelancerId) return;

    let title: string;
    let body: string;
    if (after.status === "accepted") {
      title = "Proposta aceita!";
      body = `Sua proposta para "${projectTitle}" foi aceita. Você tem um novo contrato.`;
    } else if (after.status === "rejected") {
      title = "Proposta recusada";
      body = `Sua proposta para "${projectTitle}" não foi selecionada desta vez.`;
    } else {
      return;
    }

    await sendPushToUser(
      freelancerId,
      { title, body },
      {
        type: `proposal_${after.status}`,
        proposalId: event.params.proposalId,
      }
    );
  }
);

/**
 * Trigger: contrato atualizado. Notifica o cliente quando o freelancer marca
 * como entregue (active → delivered) e o freelancer quando o cliente aprova
 * a entrega (delivered → completed).
 */
export const onContractStatusChanged = onDocumentUpdated(
  "contracts/{contractId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const projectTitle = (after.projectTitle as string) || "seu projeto";
    const freelancerName =
      (after.freelancerName as string) || "O freelancer";

    if (before.status === "active" && after.status === "delivered") {
      const clientId = after.clientId as string | undefined;
      if (!clientId) return;
      await sendPushToUser(
        clientId,
        {
          title: "Entrega recebida",
          body: `${freelancerName} marcou "${projectTitle}" como entregue. Toque para revisar.`,
        },
        {
          type: "contract_delivered",
          contractId: event.params.contractId,
        }
      );
      return;
    }

    if (before.status === "delivered" && after.status === "completed") {
      const freelancerId = after.freelancerId as string | undefined;
      if (!freelancerId) return;
      await sendPushToUser(
        freelancerId,
        {
          title: "Contrato concluído!",
          body: `O cliente aprovou a entrega de "${projectTitle}".`,
        },
        {
          type: "contract_completed",
          contractId: event.params.contractId,
        }
      );
      return;
    }

    if (
      before.status === "delivered" &&
      after.status === "revision_requested"
    ) {
      const freelancerId = after.freelancerId as string | undefined;
      if (!freelancerId) return;
      const reason = (after.revisionReason as string) || "";
      const reasonPreview =
        reason.length > 80 ? `${reason.substring(0, 80)}…` : reason;
      await sendPushToUser(
        freelancerId,
        {
          title: "Revisão solicitada",
          body: `O cliente pediu ajustes em "${projectTitle}"${
            reasonPreview ? `: ${reasonPreview}` : "."
          }`,
        },
        {
          type: "contract_revision_requested",
          contractId: event.params.contractId,
        }
      );
      return;
    }

    if (
      before.status === "revision_requested" &&
      after.status === "delivered"
    ) {
      const clientId = after.clientId as string | undefined;
      if (!clientId) return;
      await sendPushToUser(
        clientId,
        {
          title: "Entrega reenviada",
          body: `${freelancerName} reenviou "${projectTitle}". Toque para revisar.`,
        },
        {
          type: "contract_redelivered",
          contractId: event.params.contractId,
        }
      );
      return;
    }
  }
);


/**
 * Callable: envia mensagem de chat para outro usuário.
 *
 * Idempotência da thread: id determinístico = uids ordenados (uidA_uidB).
 * Cria thread se não existir (lendo nomes dos 2 users pra denormalizar),
 * grava message na subcollection, atualiza lastMessage* atomicamente.
 * Push notification pro receiver com preview do texto.
 */
export const sendMessage = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login necessário.");
  }
  const senderUid = request.auth.uid;
  const receiverId = request.data?.receiverId;
  const rawText = request.data?.text;

  if (typeof receiverId !== "string" || !receiverId) {
    throw new HttpsError("invalid-argument", "receiverId é obrigatório.");
  }
  if (receiverId === senderUid) {
    throw new HttpsError(
      "invalid-argument",
      "Você não pode enviar mensagem pra si mesmo."
    );
  }
  if (typeof rawText !== "string") {
    throw new HttpsError("invalid-argument", "Texto é obrigatório.");
  }
  const text = rawText.trim();
  if (text.length === 0) {
    throw new HttpsError("invalid-argument", "Mensagem vazia.");
  }
  if (text.length > 2000) {
    throw new HttpsError(
      "invalid-argument",
      "Mensagem limitada a 2000 caracteres."
    );
  }

  const db = getFirestore();
  const sorted = [senderUid, receiverId].sort();
  const threadId = `${sorted[0]}_${sorted[1]}`;
  const threadRef = db.collection("threads").doc(threadId);
  const messageRef = threadRef.collection("messages").doc();

  // Nome do sender e do receiver — lidos do users/ pra denormalizar.
  // Lookup fora da transaction porque transactions não permitem reads em
  // collections diferentes da escrita E os nomes são imutáveis na prática.
  const [senderSnap, receiverSnap] = await Promise.all([
    db.collection("users").doc(senderUid).get(),
    db.collection("users").doc(receiverId).get(),
  ]);
  if (!receiverSnap.exists) {
    throw new HttpsError("not-found", "Destinatário não encontrado.");
  }
  const senderName =
    (senderSnap.data()?.displayName as string | undefined) ?? "";
  const receiverName =
    (receiverSnap.data()?.displayName as string | undefined) ?? "";

  await db.runTransaction(async (tx) => {
    const threadSnap = await tx.get(threadRef);
    if (!threadSnap.exists) {
      tx.set(threadRef, {
        participantIds: sorted,
        participantNames: {
          [senderUid]: senderName,
          [receiverId]: receiverName,
        },
        lastMessageText: text,
        lastMessageSenderId: senderUid,
        lastMessageAt: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
      });
    } else {
      tx.update(threadRef, {
        lastMessageText: text,
        lastMessageSenderId: senderUid,
        lastMessageAt: FieldValue.serverTimestamp(),
      });
    }
    tx.set(messageRef, {
      senderId: senderUid,
      text,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  // Push pro receiver. Preview truncado pra caber na notificação.
  const preview = text.length > 100 ? `${text.substring(0, 100)}…` : text;
  const senderLabel = senderName || "Nova mensagem";
  await sendPushToUser(
    receiverId,
    {
      title: senderLabel,
      body: preview,
    },
    {
      type: "chat_message",
      threadId,
      senderId: senderUid,
      senderName: senderName || "",
    }
  );

  logger.info("Mensagem enviada", {
    threadId,
    senderUid,
    receiverId,
    length: text.length,
  });
  return { threadId };
});

/**
 * Trigger: usuário editou o perfil. Propaga o `displayName` novo pras
 * denormalizações em outras coleções:
 *  - threads onde uid ∈ participantIds → participantNames[uid]
 *  - contracts onde clientId == uid    → clientName
 *  - contracts onde freelancerId == uid → freelancerName
 *  - proposals onde freelancerId == uid → freelancerName
 *
 * photoUrl NÃO é denormalizado em nenhuma coleção (foto é lida via 1 read
 * direto do doc do user na ChatView). Mudança só em photoUrl é no-op.
 *
 * Custo de write é proporcional ao histórico do user. Batches de 500 docs
 * cobrem 99% dos casos; se algum dia user tiver >500 docs de um tipo, o
 * código abaixo loopa em lotes.
 */
export const onUserUpdated = onDocumentUpdated(
  "users/{uid}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const oldName = (before.displayName as string) || "";
    const newName = (after.displayName as string) || "";
    if (oldName === newName) {
      // Mudança só em photoUrl ou fcmTokens — nada a propagar.
      return;
    }

    const uid = event.params.uid;
    const db = getFirestore();
    logger.info("Propagando displayName novo", { uid, oldName, newName });

    await Promise.all([
      propagateInThreads(db, uid, newName),
      propagateInContracts(db, uid, newName),
      propagateInProposals(db, uid, newName),
    ]);
  }
);

async function commitInBatches(
  db: FirebaseFirestore.Firestore,
  refs: FirebaseFirestore.DocumentReference[],
  data: Record<string, unknown>
) {
  const chunkSize = 400;
  for (let i = 0; i < refs.length; i += chunkSize) {
    const slice = refs.slice(i, i + chunkSize);
    const batch = db.batch();
    for (const ref of slice) {
      batch.update(ref, data);
    }
    await batch.commit();
  }
}

async function propagateInThreads(
  db: FirebaseFirestore.Firestore,
  uid: string,
  newName: string
) {
  const snap = await db
    .collection("threads")
    .where("participantIds", "array-contains", uid)
    .get();
  if (snap.empty) return;
  const refs = snap.docs.map((d) => d.ref);
  await commitInBatches(db, refs, {
    [`participantNames.${uid}`]: newName,
  });
  logger.info("Threads atualizadas", { uid, count: refs.length });
}

async function propagateInContracts(
  db: FirebaseFirestore.Firestore,
  uid: string,
  newName: string
) {
  const asClient = await db
    .collection("contracts")
    .where("clientId", "==", uid)
    .get();
  if (!asClient.empty) {
    await commitInBatches(
      db,
      asClient.docs.map((d) => d.ref),
      { clientName: newName }
    );
    logger.info("Contracts (cliente) atualizados", {
      uid,
      count: asClient.size,
    });
  }
  const asFreelancer = await db
    .collection("contracts")
    .where("freelancerId", "==", uid)
    .get();
  if (!asFreelancer.empty) {
    await commitInBatches(
      db,
      asFreelancer.docs.map((d) => d.ref),
      { freelancerName: newName }
    );
    logger.info("Contracts (freelancer) atualizados", {
      uid,
      count: asFreelancer.size,
    });
  }
}

async function propagateInProposals(
  db: FirebaseFirestore.Firestore,
  uid: string,
  newName: string
) {
  const snap = await db
    .collection("proposals")
    .where("freelancerId", "==", uid)
    .get();
  if (snap.empty) return;
  await commitInBatches(
    db,
    snap.docs.map((d) => d.ref),
    { freelancerName: newName }
  );
  logger.info("Proposals (freelancer) atualizadas", {
    uid,
    count: snap.size,
  });
}
