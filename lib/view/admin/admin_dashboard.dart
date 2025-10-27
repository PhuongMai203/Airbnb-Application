import 'package:flutter/material.dart';

import 'manage_bookings_screen.dart';
import 'manage_hotels_screen.dart';
import 'manage_users_screen.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  late final List<Widget> pages; // Dùng late để đảm bảo an toàn

  @override
  void initState() {
    super.initState();
    pages = [
      const ManageUsersScreen(),
      const ManageHotelsScreen(),
      const ManageBookingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAE9),
        title: const Text(
          "Trang quản trị",
          style: TextStyle(
            color: Color(0xFF4B5320),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF4B5320)),
            onPressed: () {
              // TODO: Thêm chức năng đăng xuất
              Navigator.pop(context); // Tạm thời quay lại trang trước
            },
          )
        ],
      ),
      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF4B5320),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index >= 0 && index < pages.length) {
            setState(() => selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Người dùng",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work_rounded),
            label: "Khách sạn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: "Đặt phòng",
          ),
        ],
      ),
    );
  }
}
