import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tham chiếu tới collection UserTrips
    final tripsRef = FirebaseFirestore.instance.collection('UserTrips');

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAE9),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: tripsRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4B5320),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Color(0xFF4B5320),
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4B5320),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            final trips = snapshot.data?.docs ?? [];

            if (trips.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hotel_outlined,
                      color: Color(0xFF4B5320).withOpacity(0.5),
                      size: 80,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có đặt phòng nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4B5320).withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tất cả đơn đặt phòng sẽ hiển thị tại đây',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index].data() as Map<String, dynamic>;
                final docId = trips[index].id;

                final title = trip['title'] ?? '';
                final address = trip['address'] ?? '';
                final date = trip['date'] is Timestamp
                    ? (trip['date'] as Timestamp).toDate()
                    : DateTime.tryParse(trip['date'] ?? '');
                final imageUrl = trip['image'] ?? '';
                final price = trip['price'] ?? 0;
                final rating = trip['rating'] ?? 0.0;
                final review = trip['review'] ?? 0;
                final vendor = trip['vendor'] ?? '';
                final userId = trip['userId'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header với thông tin khách sạn
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hình ảnh
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 80,
                                      height: 80,
                                      color: const Color(0xFFE8F0D1),
                                      child: const Icon(
                                        Icons.hotel,
                                        color: Color(0xFF4B5320),
                                        size: 32,
                                      ),
                                    ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: const Color(0xFFE8F0D1),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: const Color(0xFF4B5320),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Thông tin chính
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4B5320),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: const Color(0xFF4B5320).withOpacity(0.7),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          address,
                                          style: TextStyle(
                                            color: const Color(0xFF4B5320).withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.reviews_outlined,
                                        color: const Color(0xFF4B5320).withOpacity(0.7),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$review lượt',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: const Color(0xFF4B5320).withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      const Divider(height: 1, color: Color(0xFFE8F0D1)),

                      // Thông tin chi tiết
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _buildInfoItem(
                                  Icons.calendar_today_outlined,
                                  date != null
                                      ? "${date.day}/${date.month}/${date.year}"
                                      : "Chưa có ngày",
                                ),
                                const SizedBox(width: 16),
                                _buildInfoItem(
                                  Icons.attach_money_outlined,
                                  '${price.toString()} VNĐ',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildInfoItem(
                                  Icons.person_outline,
                                  vendor.isNotEmpty ? vendor : "Chưa có vendor",
                                ),
                                const SizedBox(width: 16),
                                _buildInfoItem(
                                  Icons.person_pin_outlined,
                                  userId.isNotEmpty ? userId : "Chưa có ID",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      const Divider(height: 1, color: Color(0xFFE8F0D1)),

                      // Footer với nút hành động
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                // Xác nhận xóa
                                final confirmed = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xác nhận hủy'),
                                    content: Text('Bạn có chắc muốn hủy đặt phòng "$title"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Không'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Có, hủy đặt phòng'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  // Xóa booking
                                  await tripsRef.doc(docId).delete();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Đã hủy đặt phòng $title"),
                                        backgroundColor: const Color(0xFFB0C63A),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text(
                                'Hủy đặt phòng',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF4B5320).withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFF4B5320).withOpacity(0.8),
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}