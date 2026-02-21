import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class FirebaseNotificationService {
  factory FirebaseNotificationService() {
    return _instance;
  }

  FirebaseNotificationService._internal();

  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final StreamController<Map<String, dynamic>> navigationStreamController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get navigationStream =>
      navigationStreamController.stream;

  Future<String?> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: \$token');
      return token;
    } catch (e) {
      debugPrint('Error fetching FCM token: \$e');
      return null;
    }
  }

  Future<bool> deleteFCMToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      return true;
    } catch (e) {
      debugPrint('Error deleting FCM token: \$e');
      return false;
    }
  }

  Future<void> initialize() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    navigationStreamController.add(message.data);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: \${message.data}');
    // TODO: Handle foreground notifications (show local notification)
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: \${message.data}');
}
