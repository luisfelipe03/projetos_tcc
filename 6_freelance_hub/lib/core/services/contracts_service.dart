import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../models/contract.dart';

class ContractsService {
  ContractsService._();
  static final ContractsService instance = ContractsService._();

  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;

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

  /// Freelancer marca contrato como entregue (status active → delivered).
  /// [photoUrls] são URLs https do Firebase Storage com as fotos do trabalho.
  Future<void> markDelivered(
    String contractId, {
    List<String> photoUrls = const [],
  }) async {
    final callable = _functions.httpsCallable('markContractDelivered');
    await callable.call<Map<String, dynamic>>({
      'contractId': contractId,
      'photoUrls': photoUrls,
    });
  }

  /// Cliente aprova entrega (status delivered → completed; project também).
  Future<void> acceptDelivery(String contractId) async {
    final callable = _functions.httpsCallable('acceptContractDelivery');
    await callable.call<Map<String, dynamic>>({'contractId': contractId});
  }

  Contract _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Contract(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      projectTitle: data['projectTitle'] as String? ?? '',
      clientId: data['clientId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
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
      deliveryPhotoUrls: (data['deliveryPhotoUrls'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const <String>[],
    );
  }
}
