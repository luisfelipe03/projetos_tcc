import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger, setGlobalOptions } from "firebase-functions/v2";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

initializeApp();
setGlobalOptions({ region: "us-central1" });

/**
 * Trigger disparado ao criar um doc em proposals/{proposalId}.
 * Incrementa atomicamente o proposalCount do projeto correspondente.
 *
 * Por que server-side: as rules do Firestore impedem o cliente de mexer em
 * proposalCount diretamente (sem isso, qualquer freelancer podia inflar o
 * contador). O trigger roda com privilégios admin e bypassa rules.
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
