import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
  bool _initialized = false;

  /// Chamado após o usuário logar. Pede permissão, pega o token e persiste em
  /// `users/{uid}.fcmTokens` (arrayUnion). Idempotente — chamar 2x não duplica
  /// listeners nem tokens.
  ///
  /// O [messengerKey] permite mostrar SnackBars in-app quando uma mensagem
  /// chega com o app em foreground. Sem ele, ainda persistimos o token, só
  /// sem feedback visual.
  Future<void> initialize({
    required String uid,
    GlobalKey<ScaffoldMessengerState>? messengerKey,
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

    if (messengerKey != null) {
      _foregroundSub = FirebaseMessaging.onMessage.listen((msg) {
        final n = msg.notification;
        if (n == null) return;
        messengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF3B309E),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
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
    _tokenRefreshSub = null;
    _foregroundSub = null;
    _initialized = false;
  }

  Future<void> _saveToken({required String uid, required String token}) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }
}
