import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../momo_payment_page.dart';


class PriceAndReserve extends StatelessWidget {
  final dynamic place;
  final String formattedDate;

  const PriceAndReserve({
    super.key,
    required this.place,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          // Giá và ngày
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: "${currencyFormat.format(place['price'])} ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    children: const [
                      TextSpan(
                        text: "/ đêm",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),

          // Nút đặt ngay
          InkWell(
            onTap: () => _showBookingBottomSheet(context, place),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EFAD),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Đặt ngay",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF718104),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingBottomSheet(BuildContext context, dynamic place) {
    String? paymentMethod;
    DateTimeRange? selectedRange;
    int totalNights = 0;
    double totalPrice = 0;

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final user = FirebaseAuth.instance.currentUser;
        final String userId = user?.uid ?? '';
        final String userName = user?.displayName ?? 'Khách';

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Xác nhận đặt phòng",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Chọn ngày
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          locale: const Locale('vi', 'VN'),
                        );

                        if (picked != null) {
                          final nights = picked.end.difference(picked.start).inDays;
                          final price = double.tryParse(place['price'].toString()) ?? 0.0;
                          final total = nights * price;

                          setState(() {
                            selectedRange = picked;
                            totalNights = nights;
                            totalPrice = total;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        selectedRange == null
                            ? "Chọn ngày đến - ngày đi"
                            : "${DateFormat('dd/MM/yyyy').format(selectedRange!.start)} → ${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    if (selectedRange != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 15),
                        child: Text(
                          "$totalNights đêm x ${currencyFormat.format(double.tryParse(place['price'].toString()) ?? 0.0)} = ${currencyFormat.format(totalPrice)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                    // Phương thức thanh toán
                    const Divider(height: 30),
                    const Text(
                      "Phương thức thanh toán",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    RadioListTile<String>(
                      title: const Text("Ví điện tử Momo"),
                      value: "e_wallet",
                      groupValue: paymentMethod,
                      onChanged: (value) => setState(() => paymentMethod = value),
                    ),
                    RadioListTile<String>(
                      title: const Text("Thanh toán khi nhận phòng"),
                      value: "cash",
                      groupValue: paymentMethod,
                      onChanged: (value) => setState(() => paymentMethod = value),
                    ),

                    // Tổng tiền
                    if (selectedRange != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Tổng cộng: ${currencyFormat.format(totalPrice)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8FAF01),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (selectedRange == null || paymentMethod == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Vui lòng chọn ngày và phương thức thanh toán!"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          if (paymentMethod == "e_wallet") {
                            if (paymentMethod == "e_wallet") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MomoPaymentPage(
                                    place: place,
                                    totalPrice: totalPrice,
                                    selectedRange: selectedRange!,
                                    totalNights: totalNights,
                                    userId: userId,
                                    userName: userName,
                                  ),
                                ),
                              );
                              return;
                            }

                            return;
                          }

                          // Thanh toán khi nhận phòng lưu trực tiếp Firestore
                          await FirebaseFirestore.instance.collection('UserTrips').add({
                            'title': place['title'],
                            'address': place['address'],
                            'image': place['image'],
                            'price': place['price'],
                            'vendor': place['vendor'],
                            'rating': place['rating'],
                            'review': place['review'],
                            'checkIn': DateFormat('dd/MM/yyyy').format(selectedRange!.start),
                            'checkOut': DateFormat('dd/MM/yyyy').format(selectedRange!.end),
                            'nights': totalNights,
                            'totalPrice': totalPrice,
                            'paymentMethod': paymentMethod,
                            'userId': userId,
                            'userName': userName,
                            'date': FieldValue.serverTimestamp(),
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đặt phòng thành công!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text(
                          "Xác nhận đặt phòng",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
