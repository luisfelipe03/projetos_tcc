import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../models/wallet.dart';

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get _walletsCollection =>
      _firestore.collection('wallets');

  CollectionReference<Map<String, dynamic>> get _txCollection =>
      _firestore.collection('transactions');

  /// Stream do saldo do usuário. Emite [Wallet.empty(uid)] enquanto o doc
  /// ainda não foi criado (corner case raro: signup → user navega antes do
  /// trigger onUserCreated terminar).
  Stream<Wallet> streamWallet(String uid) {
    return _walletsCollection.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return Wallet.empty(uid);
      return walletFromMap(uid, snap.data()!);
    });
  }

  /// Histórico imutável de transações do usuário, ordem desc por createdAt.
  Stream<List<WalletTransaction>> streamTransactions(String uid) {
    return _txCollection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => walletTransactionFromMap(d.id, d.data())).toList());
  }

  /// Depósito simulado (sem gateway real). Server valida amount > 0 e
  /// <= R$ 50.000 (cap defensivo), credita availableBalance e cria uma
  /// transaction type=deposit atomicamente.
  Future<void> simulateDeposit(double amount) async {
    final callable = _functions.httpsCallable('simulateDeposit');
    await callable.call<Map<String, dynamic>>({'amount': amount});
  }
}
