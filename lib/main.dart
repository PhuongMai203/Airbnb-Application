import 'package:airbnb_app_ui/Provider/favorite_provider.dart';
import 'package:airbnb_app_ui/view/login_screen.dart';
import 'package:airbnb_app_ui/view/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Đảm bảo Firebase được khởi tạo trước khi ứng dụng bắt đầu
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Kiểm tra trạng thái kết nối và lỗi trong StreamBuilder
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Có lỗi xảy ra!'));
            }

            // Nếu có người dùng đăng nhập
            if (snapshot.hasData) {
              return const AppMainScreen();
            } else {
              // Nếu chưa đăng nhập, hiển thị màn hình login
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
