enum ProposalStatus { pending, accepted, rejected, withdrawn }

class Proposal {
  const Proposal({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.freelancerId,
    required this.freelancerName,
    required this.clientId,
    required this.value,
    required this.daysEstimate,
    required this.isHourly,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String projectTitle;
  final String freelancerId;
  final String freelancerName;
  final String clientId;
  final double value;
  final int daysEstimate;
  final bool isHourly;
  final String message;
  final ProposalStatus status;
  final DateTime createdAt;
}
