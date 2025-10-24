import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference tripsRef =
    FirebaseFirestore.instance.collection('UserTrips');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          "Chuyến đi của tôi",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tripsRef.orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi khi tải dữ liệu!"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Bạn chưa có chuyến đi nào",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final trips = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index].data() as Map<String, dynamic>;

              // === GIÁ ĐÃ LÀ TIỀN VIỆT TRONG FIRESTORE ===
              final double priceVnd = (trip['price'] ?? 0).toDouble();
              final double totalVnd = (trip['totalPrice'] ?? 0).toDouble();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        trip["image"] ?? "",
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                    ),

                    // Thông tin
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip["title"] ?? "Không có tiêu đề",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            trip["address"] ?? "Không có địa chỉ",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                "${trip['checkIn']} - ${trip['checkOut']}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // === Hiển thị tiền Việt có dấu ₫ ===
                          Row(
                            children: [
                              const Icon(Icons.attach_money,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                "Giá: ${NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: '₫',
                                ).format(priceVnd)} / đêm",
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.payments,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                "Tổng cộng: ${NumberFormat.currency(
                                  locale: 'vi_VN',
                                  symbol: '₫',
                                ).format(totalVnd)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.payment,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                "Thanh toán: ${_getPaymentMethod(trip['paymentMethod'])}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 5),
                              Text(
                                "${(trip['rating'] ?? 0).toStringAsFixed(1)} (${trip['review']} đánh giá)",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
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
    );
  }

  /// Chuyển phương thức thanh toán sang tiếng Việt
  static String _getPaymentMethod(String? code) {
    switch (code) {
      case "cash":
        return "Tiền mặt khi nhận phòng";
      case "e_wallet":
        return "Ví điện tử Momo";
      case "credit_card":
        return "Thẻ tín dụng / Ghi nợ";
      default:
        return "Không xác định";
    }
  }
}
