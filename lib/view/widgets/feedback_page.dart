import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  int _selectedRating = 0;
  bool _isSending = false;

  Future<void> _sendFeedback() async {
    if (_controller.text.trim().isEmpty || _selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập phản hồi và chọn đánh giá")),
      );
      return;
    }

    setState(() => _isSending = true);

    await Future.delayed(const Duration(seconds: 1)); // mô phỏng gửi

    setState(() => _isSending = false);
    _controller.clear();
    _selectedRating = 0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cảm ơn bạn đã gửi phản hồi!")),
    );
  }

  Widget _buildRatingIcon(int value, IconData icon) {
    final isSelected = _selectedRating == value;
    return IconButton(
      onPressed: () => setState(() => _selectedRating = value),
      icon: Icon(
        icon,
        color: isSelected ? Colors.amber : Colors.grey.shade400,
        size: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF566107),
        ),
        title: const Text(
          "Phản hồi",
          style: TextStyle(
            color: Color(0xFF566107),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chúng tôi luôn lắng nghe ý kiến của bạn 💬",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 15),
              const Text(
                "Hãy chia sẻ trải nghiệm của bạn với ứng dụng để chúng tôi có thể cải thiện tốt hơn.",
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 25),

              // Đánh giá
              const Text("Mức độ hài lòng của bạn:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRatingIcon(1, Icons.sentiment_very_dissatisfied),
                  _buildRatingIcon(2, Icons.sentiment_dissatisfied),
                  _buildRatingIcon(3, Icons.sentiment_neutral),
                  _buildRatingIcon(4, Icons.sentiment_satisfied),
                  _buildRatingIcon(5, Icons.sentiment_very_satisfied),
                ],
              ),
              const SizedBox(height: 25),

              // Nội dung phản hồi
              TextField(
                controller: _controller,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Nhập phản hồi của bạn tại đây...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),

              // Nút gửi
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE6EFA9),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSending ? null : _sendFeedback,
                  icon: _isSending
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.send, color: Color(0xFF718104),),
                  label: Text(
                    _isSending ? "Đang gửi..." : "Gửi phản hồi",
                    style: const TextStyle(fontSize: 16, color: Color(0xFF718104)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
