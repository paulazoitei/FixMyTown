// lib/services/notification_service.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      print("✅ FCM Token: $token");

      final prefs = await SharedPreferences.getInstance();
      final jwtToken = prefs.getString('jwtToken');

      if (jwtToken != null && token != null) {
        final response = await http.post(
          Uri.parse("http://10.0.2.2:8081/api/v1/user/fcm-token"),
          headers: {
            "Authorization": "Bearer $jwtToken",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"token": token}),
        );
        print("🔁 Token sent to backend: ${response.statusCode}");
      }
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: true,
            builder: (context) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      message.notification!.title ?? "Notification",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message.notification!.body ?? "You received a notification.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      });

    } else {
      print("❌ Not authorized to receive notifications.");
    }
  }
}
