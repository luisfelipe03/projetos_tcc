/// Conversa entre dois usuários. ID determinístico = uids ordenados
/// concatenados (`{uidA}_{uidB}` com uidA < uidB). Uma única thread por par.
class ChatThread {
  const ChatThread({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessageText,
    required this.lastMessageSenderId,
    required this.lastMessageAt,
  });

  final String id;
  final List<String> participantIds;
  // uid → displayName. Denormalizado no doc da thread pra evitar reads
  // extras ao listar a tab Mensagens.
  final Map<String, String> participantNames;
  final String lastMessageText;
  final String lastMessageSenderId;
  final DateTime? lastMessageAt;

  /// UID da contraparte em relação ao [viewerUid].
  String otherUid(String viewerUid) =>
      participantIds.firstWhere((id) => id != viewerUid, orElse: () => '');

  /// Nome da contraparte em relação ao [viewerUid] (fallback: "Usuário").
  String otherName(String viewerUid) {
    final id = otherUid(viewerUid);
    final name = participantNames[id] ?? '';
    return name.isEmpty ? 'Usuário' : name;
  }
}
