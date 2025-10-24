import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MomoPaymentPage extends StatefulWidget {
  final dynamic place;
  final double totalPrice;
  final DateTimeRange selectedRange;
  final int totalNights;
  final String userId;
  final String userName;

  const MomoPaymentPage({
    super.key,
    required this.place,
    required this.totalPrice,
    required this.selectedRange,
    required this.totalNights,
    required this.userId,
    required this.userName,
  });

  @override
  State<MomoPaymentPage> createState() => _MomoPaymentPageState();
}

class _MomoPaymentPageState extends State<MomoPaymentPage> {
  bool _isPaying = false;
  String? _orderId;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final Color momoColor = const Color(0xFFD82B7E); // màu hồng Momo
  Future<void> _startPayment() async {
    setState(() => _isPaying = true);

    try {
      final response = await http.post(
        Uri.parse('https://00963c21a214.ngrok-free.app/payment'), // nhớ đổi sang HTTPS ngrok
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": widget.userId,
          "userName": widget.userName,
          "hotelTitle": widget.place['title'],        // tên khách sạn
          "address": widget.place['address'],        // địa chỉ
          "checkIn": widget.place['checkIn'],        // ngày check-in
          "checkOut": widget.place['checkOut'],      // ngày check-out
          "nights": widget.totalNights,              // số đêm
          "price": widget.totalPrice,                // tổng tiền
          "image": widget.place['image'],            // ảnh khách sạn
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payUrl = data['payUrl'];
        _orderId = data['orderId']; // lưu orderId để kiểm tra trạng thái

        if (await canLaunch(payUrl)) {
          await launch(payUrl); // mở link MoMo
          _checkTransactionStatus(); // kiểm tra trạng thái khi quay lại
        } else {
          throw 'Không mở được MoMo';
        }
      } else {
        final data = jsonDecode(response.body);
        throw data['message'] ?? 'Không tạo được thanh toán MoMo';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi thanh toán: $e")),
        );
      }
    } finally {
      setState(() => _isPaying = false);
    }
  }

  Future<void> _checkTransactionStatus() async {
    if (_orderId == null) return;

    try {
      final response = await http.post(
        Uri.parse('https://00963c21a214.ngrok-free.app/check-status-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"orderId": _orderId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // resultCode = 0 nghĩa là thanh toán thành công
        if (data['resultCode'] == 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Thanh toán Momo thành công!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Thanh toán thất bại hoặc chưa hoàn tất"),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi kiểm tra trạng thái: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thanh toán với Momo"),
        backgroundColor: momoColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: momoColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet, color: momoColor, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              "Thanh toán qua Ví điện tử Momo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Khách sạn: ${widget.place['title']}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    "Ngày: ${DateFormat('dd/MM/yyyy').format(widget.selectedRange.start)} → ${DateFormat('dd/MM/yyyy').format(widget.selectedRange.end)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text("Số đêm: ${widget.totalNights}", style: const TextStyle(fontSize: 16)),
                  const Divider(height: 20),
                  Text(
                    "Tổng tiền: ${currencyFormat.format(widget.totalPrice)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: momoColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: _isPaying ? null : _startPayment,
                child: _isPaying
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Thanh toán ngay",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
