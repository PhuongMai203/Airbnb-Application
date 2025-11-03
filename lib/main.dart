import 'package:airbnb_app/Provider/favorite_provider.dart';
import 'package:airbnb_app/view/admin/admin_dashboard.dart';
import 'package:airbnb_app/view/login_screen.dart';
import 'package:airbnb_app/view/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  // Đảm bảo Firebase được khởi tạo trước khi ứng dụng bắt đầu
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', 'VN'), // Tiếng Việt
          Locale('en', 'US'), // Tiếng Anh
        ],

        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Có lỗi xảy ra!'));
            }

            final user = snapshot.data;
            if (user == null) {
              // Chưa đăng nhập
              return const SimpleAuthScreen();
            }

            // ✨ Lấy role từ Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (roleSnapshot.hasError) {
                  return const Center(child: Text('Lỗi lấy dữ liệu người dùng'));
                }

                final data = roleSnapshot.data?.data() as Map<String, dynamic>?;
                final role = data?['role'] ?? 'user';

                if (role == 'admin') {
                  return const AdminDashboard();
                } else {
                  return const AppMainScreen();
                }
              },
            );
          },
        ),

      ),
    );
  }
}
