import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../models/review.dart';

class ReviewsService {
  ReviewsService._();
  static final ReviewsService instance = ReviewsService._();

  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('reviews');

  /// Doc ID determinístico — qualquer parte do app monta o mesmo id pra
  /// checar/buscar review específico.
  static String reviewIdFor({
    required String contractId,
    required String reviewerId,
  }) =>
      '${contractId}_$reviewerId';

  /// Envia avaliação via Cloud Function callable. Server valida que caller é
  /// parte do contrato, contrato em status `completed`, rating 1..5,
  /// comment <= 500 chars. Server agrega ratingTotal/ratingCount no doc do
  /// revieweeId atomicamente e dispara push.
  Future<void> submitReview({
    required String contractId,
    required int rating,
    required String comment,
  }) async {
    final callable = _functions.httpsCallable('submitReview');
    await callable.call<Map<String, dynamic>>({
      'contractId': contractId,
      'rating': rating,
      'comment': comment,
    });
  }

  /// Stream das reviews recebidas por um user (pra perfil público + Perfil tab).
  /// Ordem decrescente por createdAt.
  Stream<List<Review>> streamReviewsByUser(String revieweeId) {
    return _collection
        .where('revieweeId', isEqualTo: revieweeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  /// Busca a review específica que [reviewerId] deu sobre [contractId].
  /// Retorna null se ainda não avaliou. Single doc read, sem subscription.
  Future<Review?> getMyReview({
    required String contractId,
    required String reviewerId,
  }) async {
    final id = reviewIdFor(contractId: contractId, reviewerId: reviewerId);
    final snap = await _collection.doc(id).get();
    if (!snap.exists) return null;
    return _fromMap(snap.id, snap.data()!);
  }

  Review _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      _fromMap(doc.id, doc.data());

  Review _fromMap(String id, Map<String, dynamic> data) {
    return Review(
      id: id,
      contractId: data['contractId'] as String? ?? '',
      projectId: data['projectId'] as String? ?? '',
      projectTitle: data['projectTitle'] as String? ?? '',
      reviewerId: data['reviewerId'] as String? ?? '',
      reviewerName: data['reviewerName'] as String? ?? '',
      revieweeId: data['revieweeId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
