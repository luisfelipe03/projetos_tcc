import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../models/chat_message.dart';
import '../../models/chat_thread.dart';

class MessagesService {
  MessagesService._();
  static final MessagesService instance = MessagesService._();

  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get _threadsCollection =>
      _firestore.collection('threads');

  /// ID determinístico da thread entre 2 users — uids ordenados
  /// alfabeticamente. Mesmo par sempre cai no mesmo doc.
  static String threadIdFor(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Stream<List<ChatThread>> streamThreadsByUser(String uid) {
    return _threadsCollection
        .where('participantIds', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_threadFromDoc).toList());
  }

  Stream<List<ChatMessage>> streamMessages(String threadId) {
    return _threadsCollection
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_messageFromDoc).toList());
  }

  /// Envia mensagem via Cloud Function: cria a thread (se não existir) com
  /// nomes denormalizados, posta msg na subcollection e atualiza lastMessage
  /// na thread atomicamente. Server também dispara push.
  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final callable = _functions.httpsCallable('sendMessage');
    await callable.call<Map<String, dynamic>>({
      'receiverId': receiverId,
      'text': text,
    });
  }

  ChatThread _threadFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatThread(
      id: doc.id,
      participantIds: (data['participantIds'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const <String>[],
      participantNames: (data['participantNames'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String? ?? '')) ??
          const <String, String>{},
      lastMessageText: data['lastMessageText'] as String? ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] as String? ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  ChatMessage _messageFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
