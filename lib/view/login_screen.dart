import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main_screen.dart';

class SimpleAuthScreen extends StatefulWidget {
  const SimpleAuthScreen({super.key});

  @override
  State<SimpleAuthScreen> createState() => _SimpleAuthScreenState();
}

class _SimpleAuthScreenState extends State<SimpleAuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool isValidEmail(String email) {
    // Kiểm tra định dạng email cơ bản
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> handleAuth({required bool isLogin}) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackBar("Vui lòng điền đầy đủ thông tin!");
      return;
    }

    if (!isValidEmail(email)) {
      showSnackBar("Email không hợp lệ!");
      return;
    }

    if (!isLogin) {
      final confirmPassword = confirmPasswordController.text.trim();
      if (password != confirmPassword) {
        showSnackBar("Mật khẩu xác nhận không khớp!");
        return;
      }
    }

    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        // Chuyển sang AppMainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppMainScreen()),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await _auth.signOut();
        showSnackBar("Đăng ký thành công! Vui lòng đăng nhập.");
        _tabController.animateTo(0);
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(e.message ?? "Lỗi xác thực");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Đăng nhập hoặc đăng ký",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5320)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Color(0xFF4B5320),
                    unselectedLabelColor: Colors.black87,
                    labelStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.normal),
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(width: 4.0, color: Color(
                          0xFFB0C63A)),
                      insets: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    tabs: const [
                      Tab(text: "Đăng nhập"),
                      Tab(text: "Đăng ký"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 450,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      authForm(isLogin: true),
                      authForm(isLogin: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget authForm({required bool isLogin}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Email",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Mật khẩu",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          if (!isLogin) ...[
            const SizedBox(height: 15),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Xác nhận lại mật khẩu",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => handleAuth(isLogin: isLogin),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD7E691),
              padding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isLogin ? "Đăng nhập" : "Đăng ký",
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4B5320)),
            ),
          ),
        ],
      ),
    );
  }
}
