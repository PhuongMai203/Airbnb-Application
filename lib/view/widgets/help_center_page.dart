import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> faqs = [
    {
      "question": "Làm sao để thay đổi mật khẩu?",
      "answer":
      "Vào mục 'Đăng nhập & bảo mật' trong Hồ sơ, sau đó chọn 'Đặt lại mật khẩu'."
    },
    {
      "question": "Tôi không nhận được email xác nhận?",
      "answer":
      "Hãy kiểm tra hộp thư rác. Nếu chưa thấy, quay lại trang Hồ sơ và chọn 'Gửi lại email xác nhận'."
    },
    {
      "question": "Làm sao để hủy đặt phòng?",
      "answer":
      "Vào phần 'Đặt phòng của tôi', chọn chuyến đi muốn hủy và nhấn 'Hủy đặt phòng'."
    },
    {
      "question": "Tôi muốn liên hệ với chủ nhà?",
      "answer":
      "Trong chi tiết đặt phòng, chọn 'Liên hệ chủ nhà' để nhắn tin trực tiếp."
    },
  ];

  List<Map<String, String>> filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    filteredFaqs = faqs;
  }

  void _search(String query) {
    setState(() {
      filteredFaqs = faqs
          .where((item) =>
          item["question"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
          "Trung tâm trợ giúp",
          style: TextStyle(
            color: Color(0xFF566107),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ô tìm kiếm
            TextField(
              controller: _searchController,
              onChanged: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm kiếm câu hỏi...",
                filled: true,
                fillColor: Color(0xFFF2F6D8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách FAQ
            Expanded(
              child: filteredFaqs.isEmpty
                  ? const Center(
                child: Text(
                  "Không tìm thấy kết quả phù hợp.",
                  style: TextStyle(color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: filteredFaqs.length,
                itemBuilder: (context, index) {
                  final item = filteredFaqs[index];
                  return Card(
                    elevation: 0,
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      iconColor: Colors.blueAccent,
                      title: Text(
                        item["question"]!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            item["answer"]!,
                            style: const TextStyle(
                                color: Colors.black87, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
