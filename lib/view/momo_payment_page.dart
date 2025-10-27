import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

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
  bool _paymentSuccess = false;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final Color momoColor = const Color(0xFFD82B7E);

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  // Lắng nghe callback khi người dùng quay lại từ MoMo
  void _initUniLinks() {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null &&
          uri.scheme == "airbnbapp" &&
          uri.host == "momo-callback") {
        // Gọi kiểm tra giao dịch khi nhận được callback
        _checkTransactionStatus();
      }
    }, onError: (err) {
      debugPrint("Lỗi khi nhận deep link: $err");
    });
  }

  Future<void> _startPayment() async {
    setState(() => _isPaying = true);

    try {
      final response = await http.post(
        Uri.parse('https://82f55bb7c8c8.ngrok-free.app/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": widget.userId,
          "userName": widget.userName,
          "hotelTitle": widget.place['title'],
          "address": widget.place['address'],
          "checkIn": widget.selectedRange.start.toIso8601String(),
          "checkOut": widget.selectedRange.end.toIso8601String(),
          "nights": widget.totalNights,
          "price": widget.totalPrice,
          "image": widget.place['image'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payUrl = data['payUrl'];
        _orderId = data['orderId'];

        if (payUrl != null) {
          final Uri momoUri = Uri.parse(payUrl);
          if (!await launchUrl(
            momoUri,
            mode: LaunchMode.externalApplication,
          )) {
            throw Exception('Không thể mở MoMo trên thiết bị.');
          }
        } else {
          throw Exception('Không nhận được link thanh toán MoMo.');
        }
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Không tạo được thanh toán MoMo');
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
        Uri.parse('https://82f55bb7c8c8.ngrok-free.app/check-status-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"orderId": _orderId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['resultCode'] == 0) {
          _showSuccessMessage();
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

  void _showSuccessMessage() {
    setState(() => _paymentSuccess = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thanh toán MoMo thành công!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thanh toán với MoMo"),
        backgroundColor: momoColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            if (_paymentSuccess)
              Column(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 70),
                  SizedBox(height: 10),
                  Text(
                    "Thanh toán thành công!",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            if (!_paymentSuccess) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: momoColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                Icon(Icons.account_balance_wallet, color: momoColor, size: 60),
              ),
              const SizedBox(height: 20),
              const Text(
                "Thanh toán qua Ví điện tử Momo",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
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
                    Text("Khách sạn: ${widget.place['title']}",
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      "Ngày: ${DateFormat('dd/MM/yyyy').format(widget.selectedRange.start)} → ${DateFormat('dd/MM/yyyy').format(widget.selectedRange.end)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text("Số đêm: ${widget.totalNights}",
                        style: const TextStyle(fontSize: 16)),
                    const Divider(height: 20),
                    Text(
                      "Tổng tiền: ${currencyFormat.format(widget.totalPrice)}",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  onPressed: _isPaying ? null : _startPayment,
                  child: _isPaying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Thanh toán ngay",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
