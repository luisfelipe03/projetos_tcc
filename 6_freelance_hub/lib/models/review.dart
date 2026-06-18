/// Avaliação dada por uma parte do contrato à outra após a conclusão.
/// Doc ID = `{contractId}_{reviewerId}` — previne 2 avaliações do mesmo
/// reviewer pro mesmo contrato. Bloqueado pra update no firestore.rules
/// (todas as avaliações são imutáveis após enviadas).
class Review {
  const Review({
    required this.id,
    required this.contractId,
    required this.projectId,
    required this.projectTitle,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String contractId;
  final String projectId;
  final String projectTitle;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final int rating;
  final String comment;
  final DateTime createdAt;
}
