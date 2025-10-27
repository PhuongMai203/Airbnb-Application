import 'package:flutter/material.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = [
      {"hotel": "Mường Thanh", "user": "Nguyễn Văn A", "date": "27/10/2025"},
      {"hotel": "Riverside", "user": "Trần Thị B", "date": "28/10/2025"},
      {"hotel": "Sapa Charm", "user": "Lê Văn C", "date": "29/10/2025"},
    ];

    return Container(
      color: const Color(0xFFF7FAE9),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.hotel, color: Color(0xFF4B5320)),
                    title: Text(booking["hotel"] ?? ""),
                    subtitle: Text(
                        "Khách: ${booking["user"]}\nNgày: ${booking["date"]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // TODO: Xóa đơn đặt phòng
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Hủy đơn ${booking["hotel"]}")),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
