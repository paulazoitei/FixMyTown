import 'package:flutter/material.dart';
import 'package:licenta_frontend/screens/my_reports_admin_screen.dart';
import 'package:licenta_frontend/screens/notifications_screen.dart';
import 'package:licenta_frontend/services/notification_service.dart';
import 'screens/home_user_screen.dart';
import 'screens/home_admin_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/report_screen.dart';
import 'screens/my_reports_user_screen.dart';
import 'screens/reports_map_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:licenta_frontend/screens/notifications_screen.dart';
import 'package:licenta_frontend/screens/my_reports_map.dart';
import 'package:licenta_frontend/screens/admin_notifications.dart';
import 'package:licenta_frontend/screens/profile_admin_screen.dart';
import 'package:licenta_frontend/screens/profile_user_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().init(navigatorKey);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'FixMyTown',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home-user': (context) => const HomeUserScreen(),
        '/home-admin': (context) => const HomeAdminScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/report': (_) => const ReportScreen(),
        '/myReportsUser': (context) => const MyReportsUserScreen(),
        '/myReportsAdmin': (context) => const MyReportsAdminScreen(),
        '/reports-map': (context) => const ReportsMapScreen(),
        '/notifications':(context)=> const NotificationsScreen(),
        '/my-reports-map': (context) => const MyReportsMapScreen(),
        '/admin-notifications':(context)=> const AdminNotificationsScreen(),
        '/profile-admin':(context)=>const ProfileAdminScreen(),
        '/profile-user':(context)=> const ProfileUserScreen()

      },
    );
  }
}
