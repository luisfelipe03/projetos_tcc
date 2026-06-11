import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/contract.dart';

class ContractsService {
  ContractsService._();
  static final ContractsService instance = ContractsService._();

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('contracts');

  Stream<List<Contract>> streamContractsByClient(String clientId) {
    return _collection
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Stream<List<Contract>> streamContractsByFreelancer(String freelancerId) {
    return _collection
        .where('freelancerId', isEqualTo: freelancerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Contract _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Contract(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      projectTitle: data['projectTitle'] as String? ?? '',
      clientId: data['clientId'] as String? ?? '',
      freelancerId: data['freelancerId'] as String? ?? '',
      freelancerName: data['freelancerName'] as String? ?? '',
      value: (data['value'] as num?)?.toDouble() ?? 0,
      daysEstimate: (data['daysEstimate'] as num?)?.toInt() ?? 0,
      isHourly: data['isHourly'] as bool? ?? false,
      acceptedProposalId: data['acceptedProposalId'] as String? ?? '',
      status: ContractStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ContractStatus.active,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
