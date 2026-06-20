/// Tipos de transação que aparecem no histórico da carteira.
enum WalletTransactionType {
  /// Depósito simulado (sem gateway real) — credita availableBalance.
  deposit,

  /// Cliente aceitou proposta → debita availableBalance, credita escrowBalance.
  escrowLock,

  /// Cliente aprovou entrega → debita escrowBalance do cliente e credita
  /// availableBalance do freelancer (cada lado tem sua própria transaction).
  escrowRelease,
}

WalletTransactionType _parseTransactionType(String? raw) {
  switch (raw) {
    case 'deposit':
      return WalletTransactionType.deposit;
    case 'escrow_lock':
      return WalletTransactionType.escrowLock;
    case 'escrow_release':
      return WalletTransactionType.escrowRelease;
    default:
      return WalletTransactionType.deposit;
  }
}

String walletTransactionTypeName(WalletTransactionType t) {
  switch (t) {
    case WalletTransactionType.deposit:
      return 'deposit';
    case WalletTransactionType.escrowLock:
      return 'escrow_lock';
    case WalletTransactionType.escrowRelease:
      return 'escrow_release';
  }
}

/// Estado atual da carteira de um usuário. Doc em `wallets/{uid}`.
class Wallet {
  const Wallet({
    required this.uid,
    required this.availableBalance,
    required this.escrowBalance,
    required this.updatedAt,
  });

  factory Wallet.empty(String uid) => Wallet(
        uid: uid,
        availableBalance: 0,
        escrowBalance: 0,
        updatedAt: DateTime.now(),
      );

  /// uid do dono da carteira (= id do doc).
  final String uid;

  /// Saldo livre — pode ser usado pra aceitar propostas.
  final double availableBalance;

  /// Saldo bloqueado em contratos ativos. Sai de `availableBalance` quando o
  /// cliente aceita uma proposta e vira `availableBalance` do freelancer
  /// quando o cliente aprova a entrega.
  final double escrowBalance;

  final DateTime updatedAt;

  double get totalBalance => availableBalance + escrowBalance;
}

/// Movimentação imutável no histórico. Doc em `transactions/{auto-id}`.
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceDelta,
    required this.createdAt,
    this.contractId = '',
    this.projectTitle = '',
    this.counterpartyName = '',
  });

  final String id;
  final String userId;
  final WalletTransactionType type;

  /// Valor absoluto (sempre positivo).
  final double amount;

  /// Sinal aplicado ao saldo do `userId` — pode ser usado pra exibir +/− nos
  /// cards sem o cliente ter que inferir do `type`. Server preenche.
  final int balanceDelta;

  final DateTime createdAt;
  final String contractId;
  final String projectTitle;
  final String counterpartyName;
}

/// Formata R$ 3.000,00 (BRL com 2 casas, separador de milhar).
String formatCurrencyBrl(double value) {
  final negative = value < 0;
  final abs = value.abs();
  final intPart = abs.truncate();
  final cents = ((abs - intPart) * 100).round().toString().padLeft(2, '0');
  final intStr = intPart.toString();
  final buf = StringBuffer();
  for (var i = 0; i < intStr.length; i++) {
    if (i > 0 && (intStr.length - i) % 3 == 0) buf.write('.');
    buf.write(intStr[i]);
  }
  final prefix = negative ? '-R\$ ' : 'R\$ ';
  return '$prefix${buf.toString()},$cents';
}

/// Helper para deserializar wallets do Firestore (mantém o parsing num só lugar).
Wallet walletFromMap(String uid, Map<String, dynamic> data) {
  return Wallet(
    uid: uid,
    availableBalance: (data['availableBalance'] as num?)?.toDouble() ?? 0,
    escrowBalance: (data['escrowBalance'] as num?)?.toDouble() ?? 0,
    updatedAt: _parseTimestamp(data['updatedAt']),
  );
}

WalletTransaction walletTransactionFromMap(
  String id,
  Map<String, dynamic> data,
) {
  return WalletTransaction(
    id: id,
    userId: data['userId'] as String? ?? '',
    type: _parseTransactionType(data['type'] as String?),
    amount: (data['amount'] as num?)?.toDouble() ?? 0,
    balanceDelta: (data['balanceDelta'] as num?)?.toInt() ?? 0,
    createdAt: _parseTimestamp(data['createdAt']),
    contractId: data['contractId'] as String? ?? '',
    projectTitle: data['projectTitle'] as String? ?? '',
    counterpartyName: data['counterpartyName'] as String? ?? '',
  );
}

DateTime _parseTimestamp(Object? raw) {
  if (raw == null) return DateTime.now();
  // Cloud Firestore Timestamp tem método toDate().
  // Não importamos cloud_firestore aqui pra manter o model puro — o caller
  // pode passar tanto Timestamp.toDate() quanto DateTime quanto null.
  try {
    return (raw as dynamic).toDate() as DateTime;
  } catch (_) {
    if (raw is DateTime) return raw;
    return DateTime.now();
  }
}
