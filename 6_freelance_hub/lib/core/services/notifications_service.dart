import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../views/chat_view.dart';
import '../../views/my_contracts_view.dart';
import '../../views/my_proposals_view.dart';
import '../../views/received_proposals_view.dart';

/// Handler de mensagens recebidas em background. Precisa ser top-level (não
/// pode ser método de classe) porque é executado num isolate separado pelo
/// plugin firebase_messaging.
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // Sem trabalho a fazer no MVP: o sistema operacional já exibe a notificação
  // automaticamente quando o payload tem `notification`. Esse handler existe
  // só pra inicializar o isolate; deixar vazio é correto.
}

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _tapSub;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  /// Chamado após o usuário logar. Pede permissão, pega o token e persiste em
  /// `users/{uid}.fcmTokens` (arrayUnion). Idempotente — chamar 2x não duplica
  /// listeners nem tokens.
  ///
  /// O [messengerKey] permite mostrar SnackBars in-app quando uma mensagem
  /// chega com o app em foreground. Sem ele, ainda persistimos o token, só
  /// sem feedback visual.
  ///
  /// O [navigatorKey] habilita deep link: tocar a notificação abre a tela
  /// relevante (chat → ChatView, contrato → MyContractsView, etc).
  Future<void> initialize({
    required String uid,
    GlobalKey<ScaffoldMessengerState>? messengerKey,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    if (_initialized) return;

    // iOS sem APNs configurado retorna null no token. Não dá pra completar
    // o setup nesse caso — pula silenciosamente.
    if (Platform.isIOS) {
      try {
        final apns = await _messaging.getAPNSToken();
        if (apns == null) {
          if (kDebugMode) {
            debugPrint(
              '[NotificationsService] iOS sem APNs configurado — '
              'push notifications desabilitadas (precisa Apple Dev Account).',
            );
          }
          return;
        }
      } catch (_) {
        return;
      }
    }

    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(uid: uid, token: token);
    }

    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
      _saveToken(uid: uid, token: newToken);
    });

    _navigatorKey = navigatorKey;

    // Deep link: app em background → user toca push → app volta pra foreground.
    _tapSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Deep link cold start: app estava terminated → push abriu o app.
    // getInitialMessage retorna a msg que abriu o app (ou null se foi abertura
    // normal). Roteia DEPOIS do primeiro frame pra garantir Navigator montado.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initial);
      });
    }

    if (messengerKey != null) {
      _foregroundSub = FirebaseMessaging.onMessage.listen((msg) {
        final n = msg.notification;
        if (n == null) return;
        // Em foreground o sistema não mostra a notificação; usamos SnackBar
        // in-app. Action "Abrir" reaproveita o handler de tap pra cobrir o caso
        // de o user querer pular pra tela relevante mesmo com app aberto.
        final hasDeepLink = msg.data['type'] != null;
        messengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF3B309E),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (n.title != null)
                    Text(
                      n.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  if (n.body != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        n.body!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              action: hasDeepLink
                  ? SnackBarAction(
                      label: 'Abrir',
                      textColor: Colors.white,
                      onPressed: () => _handleNotificationTap(msg),
                    )
                  : null,
            ),
          );
      });
    }

    _initialized = true;
  }

  /// Remove o token atual do doc do user. Chamar antes de signOut pra evitar
  /// receber push depois.
  Future<void> dispose(String uid) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
    } catch (_) {
      // Mesmo se falhar, segue o signOut. Token órfão será limpo no próximo
      // envio que falhar com `registration-token-not-registered`.
    }
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _tapSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundSub = null;
    _tapSub = null;
    _navigatorKey = null;
    _initialized = false;
  }

  /// Roteia o tap de uma push notification pra tela relevante.
  /// Os tipos correspondem aos `data.type` enviados pelo Cloud Functions:
  ///  - `proposalCreated`               → ReceivedProposalsView (cliente)
  ///  - `proposal_accepted|rejected`    → MyProposalsView (freelancer)
  ///  - `contract_*` (4 variantes)      → MyContractsView (ambos)
  ///  - `chat_message`                  → ChatView(senderId, senderName)
  void _handleNotificationTap(RemoteMessage msg) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    final type = msg.data['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'proposalCreated':
        navigator.push(MaterialPageRoute(
          builder: (_) => const ReceivedProposalsView(),
        ));
      case 'proposal_accepted':
      case 'proposal_rejected':
        navigator.push(MaterialPageRoute(
          builder: (_) => const MyProposalsView(),
        ));
      case 'contract_delivered':
      case 'contract_redelivered':
      case 'contract_completed':
      case 'contract_revision_requested':
        navigator.push(MaterialPageRoute(
          builder: (_) => const MyContractsView(),
        ));
      case 'chat_message':
        final senderId = msg.data['senderId'] as String? ?? '';
        final senderName = msg.data['senderName'] as String? ?? '';
        if (senderId.isEmpty) return;
        navigator.push(MaterialPageRoute(
          builder: (_) => ChatView(
            otherUid: senderId,
            otherName: senderName,
          ),
        ));
    }
  }

  Future<void> _saveToken({required String uid, required String token}) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }
}
