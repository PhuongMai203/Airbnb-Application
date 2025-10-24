import 'package:airbnb_app/view/widgets/user_info_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'widgets/help_center_page.dart';
import 'widgets/feedback_page.dart';
import 'widgets/security_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề trang
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Hồ sơ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Color(0xFF566107),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Thông tin người dùng
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserInfoPage()),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFFF2F6D8),
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person, size: 40, color: Color(
                            0xFF798815),)
                            : null,
                      ),
                      SizedBox(width: size.width * 0.05),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? "Tên người dùng",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Xem hồ sơ",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.black12),

                // Cài đặt
                const SizedBox(height: 20),
                const Text(
                  "Cài đặt",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, color: Color(0xFF566107)),
                ),
                const SizedBox(height: 15),
                profileOption(
                  context,
                  Icons.person_outline,
                  "Thông tin cá nhân",
                  const UserInfoPage(),
                ),
                profileOption(
                  context,
                  Icons.security,
                  "Đăng nhập & bảo mật",
                  const ChangePasswordPage(),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Hỗ trợ",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, color: Color(0xFF566107)),
                ),
                const SizedBox(height: 15),
                profileOption(
                  context,
                  Icons.help_outline,
                  "Trung tâm trợ giúp",
                  const HelpCenterPage(),
                ),
                profileOption(
                  context,
                  Icons.feedback_outlined,
                  "Phản hồi",
                  const FeedbackPage(),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleAuthScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        "Đăng xuất",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileOption(
      BuildContext context,
      IconData icon,
      String title,
      Widget destination,
      ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: Colors.black54),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontSize: 17)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.black12),
        ],
      ),
    );
  }
}
