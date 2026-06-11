enum ContractStatus {
  active,
  delivered,
  revisionRequested,
  completed,
  disputed,
}

class Contract {
  const Contract({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.clientName,
    required this.freelancerId,
    required this.freelancerName,
    required this.value,
    required this.daysEstimate,
    required this.isHourly,
    required this.acceptedProposalId,
    required this.status,
    required this.createdAt,
    required this.deliveryPhotoUrls,
    required this.revisionReason,
    required this.revisionCount,
  });

  final String id;
  final String projectId;
  final String projectTitle;
  final String clientId;
  final String clientName;
  final String freelancerId;
  final String freelancerName;
  final double value;
  final int daysEstimate;
  final bool isHourly;
  final String acceptedProposalId;
  final ContractStatus status;
  final DateTime createdAt;
  final List<String> deliveryPhotoUrls;
  final String revisionReason;
  final int revisionCount;
}
