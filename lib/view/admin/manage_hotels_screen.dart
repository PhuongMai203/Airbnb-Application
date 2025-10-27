import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageHotelsScreen extends StatelessWidget {
  const ManageHotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hotelsRef = FirebaseFirestore.instance.collection('myAppCpollection');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F0F0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: hotelsRef.orderBy('date', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4B5320)),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Lỗi khi tải dữ liệu: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final hotels = snapshot.data?.docs ?? [];
                  if (hotels.isEmpty) {
                    return const Center(
                      child: Text(
                        "Chưa có khách sạn nào",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: hotels.length,
                    itemBuilder: (context, index) {
                      final doc = hotels[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final title = data['title'] ?? 'Không có tên';
                      final address = data['address'] ?? '';
                      final price = data['price'] ?? 0;
                      final rating = data['rating'] ?? 0.0;
                      final review = data['review'] ?? 0;
                      final image = data['image'] ?? 'https://via.placeholder.com/150';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(address),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('$rating ($review reviews)'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Giá: ${price.toString()} VND'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => EditHotelDialog(
                                      hotelsRef: hotelsRef,
                                      docId: doc.id,
                                      data: data,
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Xóa khách sạn"),
                                      content: const Text(
                                          "Bạn có chắc muốn xóa khách sạn này?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Hủy"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Xóa"),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await hotelsRef.doc(doc.id).delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                            Text("Xóa khách sạn thành công")));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6F8E9),
                foregroundColor: const Color(0xFF4B5320),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddHotelDialog(hotelsRef: hotelsRef),
                );
              },
              icon: const Icon(Icons.add),
              label:
              const Text("Thêm khách sạn mới", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- DIALOG THÊM KHÁCH SẠN -------------------
class AddHotelDialog extends StatefulWidget {
  final CollectionReference hotelsRef;
  const AddHotelDialog({super.key, required this.hotelsRef});

  @override
  State<AddHotelDialog> createState() => _AddHotelDialogState();
}

class _AddHotelDialogState extends State<AddHotelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewController = TextEditingController();
  final _imageController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    await widget.hotelsRef.add({
      "title": _titleController.text.trim(),
      "address": _addressController.text.trim(),
      "price": int.tryParse(_priceController.text.trim()) ?? 0,
      "rating": double.tryParse(_ratingController.text.trim()) ?? 0.0,
      "review": int.tryParse(_reviewController.text.trim()) ?? 0,
      "image": _imageController.text.trim(),
      "date": FieldValue.serverTimestamp(),
    });

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm khách sạn thành công")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Thêm khách sạn mới"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_titleController, "Tên khách sạn"),
              const SizedBox(height: 8),
              _buildTextField(_addressController, "Địa chỉ"),
              const SizedBox(height: 8),
              _buildTextField(_priceController, "Giá", keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              _buildTextField(_ratingController, "Đánh giá", keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              _buildTextField(_reviewController, "Số lượt review", keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              _buildTextField(_imageController, "URL hình ảnh", keyboardType: TextInputType.url),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(onPressed: _isSaving ? null : _saveHotel, child: const Text("Lưu")),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Vui lòng nhập $label";
        return null;
      },
    );
  }
}

// ------------------- DIALOG CHỈNH SỬA KHÁCH SẠN -------------------
class EditHotelDialog extends StatefulWidget {
  final CollectionReference hotelsRef;
  final String docId;
  final Map<String, dynamic> data;
  const EditHotelDialog({super.key, required this.hotelsRef, required this.docId, required this.data});

  @override
  State<EditHotelDialog> createState() => _EditHotelDialogState();
}

class _EditHotelDialogState extends State<EditHotelDialog> {
  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _ratingController;
  late TextEditingController _reviewController;
  late TextEditingController _imageController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data['title']);
    _addressController = TextEditingController(text: widget.data['address']);
    _priceController = TextEditingController(text: widget.data['price'].toString());
    _ratingController = TextEditingController(text: widget.data['rating'].toString());
    _reviewController = TextEditingController(text: widget.data['review'].toString());
    _imageController = TextEditingController(text: widget.data['image']);
  }

  Future<void> _updateHotel() async {
    setState(() => _isSaving = true);
    await widget.hotelsRef.doc(widget.docId).update({
      "title": _titleController.text.trim(),
      "address": _addressController.text.trim(),
      "price": int.tryParse(_priceController.text.trim()) ?? 0,
      "rating": double.tryParse(_ratingController.text.trim()) ?? 0.0,
      "review": int.tryParse(_reviewController.text.trim()) ?? 0,
      "image": _imageController.text.trim(),
    });
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật khách sạn thành công")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Chỉnh sửa khách sạn"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(_titleController, "Tên khách sạn"),
            const SizedBox(height: 8),
            _buildTextField(_addressController, "Địa chỉ"),
            const SizedBox(height: 8),
            _buildTextField(_priceController, "Giá", keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            _buildTextField(_ratingController, "Đánh giá", keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            _buildTextField(_reviewController, "Số lượt review", keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            _buildTextField(_imageController, "URL hình ảnh", keyboardType: TextInputType.url),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(onPressed: _isSaving ? null : _updateHotel, child: const Text("Lưu")),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
