import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/proposal.dart';

class ProposalsService {
  ProposalsService._();
  static final ProposalsService instance = ProposalsService._();

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('proposals');

  /// Doc ID determinístico previne duplicatas: 1 proposta por (projeto, freelancer).
  /// Segunda tentativa cai em rule de update (negada).
  String _docId(String projectId, String freelancerId) =>
      '${projectId}_$freelancerId';

  Future<void> createProposal({
    required String projectId,
    required String projectTitle,
    required String freelancerId,
    required String freelancerName,
    required String clientId,
    required double value,
    required int daysEstimate,
    required bool isHourly,
    required String message,
  }) async {
    final id = _docId(projectId, freelancerId);
    await _collection.doc(id).set({
      'projectId': projectId,
      'projectTitle': projectTitle,
      'freelancerId': freelancerId,
      'freelancerName': freelancerName,
      'clientId': clientId,
      'value': value,
      'daysEstimate': daysEstimate,
      'isHourly': isHourly,
      'message': message,
      'status': ProposalStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Proposal>> streamProposalsForProject(String projectId) {
    return _collection
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Stream<List<Proposal>> streamProposalsByFreelancer(String freelancerId) {
    return _collection
        .where('freelancerId', isEqualTo: freelancerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  /// Todas as propostas dos projetos publicados por um cliente.
  /// Usado na tab "Projetos" (Cliente) — agrupa por projectId na UI.
  Stream<List<Proposal>> streamProposalsByClient(String clientId) {
    return _collection
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Proposal _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Proposal(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      projectTitle: data['projectTitle'] as String? ?? '',
      freelancerId: data['freelancerId'] as String? ?? '',
      freelancerName: data['freelancerName'] as String? ?? '',
      clientId: data['clientId'] as String? ?? '',
      value: (data['value'] as num?)?.toDouble() ?? 0,
      daysEstimate: (data['daysEstimate'] as num?)?.toInt() ?? 0,
      isHourly: data['isHourly'] as bool? ?? false,
      message: data['message'] as String? ?? '',
      status: ProposalStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ProposalStatus.pending,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
