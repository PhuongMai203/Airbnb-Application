import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

    try {
      await widget.hotelsRef.doc(widget.docId).update({
        "title": _titleController.text.trim(),
        "address": _addressController.text.trim(),
        "price": int.tryParse(_priceController.text.trim()) ?? 0,
        "rating": double.tryParse(_ratingController.text.trim()) ?? 0.0,
        "review": int.tryParse(_reviewController.text.trim()) ?? 0,
        "image": _imageController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Cập nhật khách sạn thành công"),
            backgroundColor: const Color(0xFFB0C63A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0D1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.hotel, color: Color(0xFF4B5320), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Chỉnh sửa khách sạn",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B5320),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0D1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.close, color: Color(0xFF4B5320), size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(color: Color(0xFFD8DFC1), thickness: 1),
              const SizedBox(height: 20),

              // Form content
              Column(
                children: [
                  _buildTextField(_titleController, "Tên khách sạn", Icons.hotel_outlined),
                  const SizedBox(height: 16),

                  _buildTextField(_addressController, "Địa chỉ", Icons.location_on_outlined),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_priceController, "Giá", Icons.attach_money_outlined,
                            keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(_ratingController, "Đánh giá", Icons.star_outline,
                            keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(_reviewController, "Số lượt review", Icons.reviews_outlined,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),

                  _buildImagePreview(),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4B5320),
                        side: const BorderSide(color: Color(0xFFD8DFC1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined, size: 18),
                          SizedBox(width: 8),
                          Text("Hủy", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _updateHotel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB0C63A),
                        foregroundColor: const Color(0xFF4B5320),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Color(0xFF4B5320),
                          strokeWidth: 2,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_alt, size: 18),
                          SizedBox(width: 8),
                          Text("Lưu thay đổi",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4B5320)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB0C63A), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Color(0xFF4B5320)),
      ),
      style: const TextStyle(fontSize: 15, color: Color(0xFF4B5320)),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_imageController, "URL hình ảnh", Icons.image_outlined,
            keyboardType: TextInputType.url),
        const SizedBox(height: 10),

        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD8DFC1), width: 1),
          ),
          child: _imageController.text.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _imageController.text,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE8F0D1),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Color(0xFF4B5320), size: 40),
                      SizedBox(height: 8),
                      Text("Không thể tải hình ảnh",
                          style: TextStyle(color: Color(0xFF4B5320))),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFFE8F0D1),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      color: const Color(0xFF4B5320),
                    ),
                  ),
                );
              },
            ),
          )
              : Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0D1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, color: Color(0xFF4B5320), size: 40),
                SizedBox(height: 8),
                Text("Chưa có hình ảnh", style: TextStyle(color: Color(0xFF4B5320))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}