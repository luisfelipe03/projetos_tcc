import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger, setGlobalOptions } from "firebase-functions/v2";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

initializeApp();
setGlobalOptions({ region: "us-central1" });

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
