import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HotelDialog extends StatefulWidget {
  final CollectionReference hotelsRef;
  final DocumentSnapshot? hotelDoc; // nếu null là thêm, không null là sửa

  const HotelDialog({super.key, required this.hotelsRef, this.hotelDoc});

  @override
  State<HotelDialog> createState() => _HotelDialogState();
}

class _HotelDialogState extends State<HotelDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedBathroomController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewController = TextEditingController();
  final _imageController = TextEditingController();
  final _imageUrlsController = TextEditingController();
  final _vendorController = TextEditingController();
  final _vendorProfessionController = TextEditingController();
  final _vendorProfileController = TextEditingController();
  final _yearOfHostingController = TextEditingController();

  bool _isActive = true;
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.hotelDoc != null) {
      final data = widget.hotelDoc!.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _addressController.text = data['address'] ?? '';
      _bedBathroomController.text = data['bedAndBathroom'] ?? '';
      _priceController.text = (data['price'] ?? '').toString();
      _ratingController.text = (data['rating'] ?? '').toString();
      _reviewController.text = (data['review'] ?? '').toString();
      _imageController.text = data['image'] ?? '';
      _imageUrlsController.text = data['imageUrls'] ?? '';
      _vendorController.text = data['vendor'] ?? '';
      _vendorProfessionController.text = data['vendorProfession'] ?? '';
      _vendorProfileController.text = data['vendorProfile'] ?? '';
      _yearOfHostingController.text = (data['yearOfHosting'] ?? '').toString();
      _isActive = data['isActive'] ?? true;
      if (data['date'] != null) {
        if (data['date'] is Timestamp) {
          _selectedDate = (data['date'] as Timestamp).toDate();
        } else if (data['date'] is String) {
          _selectedDate = DateTime.tryParse(data['date']);
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveHotel() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng chọn ngày")));
      return;
    }

    setState(() => _isSaving = true);

    final hotelData = {
      "title": _titleController.text.trim(),
      "address": _addressController.text.trim(),
      "bedAndBathroom": _bedBathroomController.text.trim(),
      "date": Timestamp.fromDate(_selectedDate!),
      "image": _imageController.text.trim(),
      "imageUrls": _imageUrlsController.text.trim(),
      "isActive": _isActive,
      "latitude": 16.0544,
      "longitude": 108.2022,
      "price": int.tryParse(_priceController.text.trim()) ?? 0,
      "rating": double.tryParse(_ratingController.text.trim()) ?? 0.0,
      "review": int.tryParse(_reviewController.text.trim()) ?? 0,
      "vendor": _vendorController.text.trim(),
      "vendorProfession": _vendorProfessionController.text.trim(),
      "vendorProfile": _vendorProfileController.text.trim(),
      "yearOfHosting": int.tryParse(_yearOfHostingController.text.trim()) ?? 0,
    };

    try {
      if (widget.hotelDoc != null) {
        await widget.hotelsRef.doc(widget.hotelDoc!.id).update(hotelData);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cập nhật khách sạn thành công")));
      } else {
        await widget.hotelsRef.add(hotelData);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thêm khách sạn thành công")));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                  Icon(
                    widget.hotelDoc != null ? Icons.edit : Icons.add_home,
                    color: const Color(0xFF4B5320),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.hotelDoc != null ? "Sửa thông tin khách sạn" : "Thêm khách sạn mới",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5320)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFFE0E0E0), thickness: 1),
              const SizedBox(height: 20),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Thông tin cơ bản
                    _buildSectionHeader("Thông tin cơ bản", Icons.info),
                    const SizedBox(height: 16),
                    _buildTextField(_titleController, "Tên khách sạn", Icons.hotel),
                    const SizedBox(height: 16),
                    _buildTextField(_addressController, "Địa chỉ", Icons.location_on),
                    const SizedBox(height: 16),
                    _buildTextField(_bedBathroomController, "Số phòng & WC", Icons.bed),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker()),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                              _priceController, "Giá", Icons.attach_money, keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Đánh giá & Review
                    _buildSectionHeader("Đánh giá & Review", Icons.star),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(_ratingController, "Đánh giá", Icons.star_rate_rounded,
                              keyboardType: TextInputType.number),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                              _reviewController, "Số lượt review", Icons.reviews,
                              keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Hình ảnh
                    _buildSectionHeader("Hình ảnh", Icons.photo),
                    const SizedBox(height: 16),
                    _buildImagePreview(_imageController, "Hình ảnh khách sạn"),
                    const SizedBox(height: 16),
                    _buildTextField(_imageUrlsController, "URL bản đồ", Icons.map),
                    const SizedBox(height: 24),
                    // Trạng thái
                    _buildSectionHeader("Trạng thái", Icons.toggle_on),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.power_settings_new, color: Color(0xFF4B5320)),
                          const SizedBox(width: 12),
                          const Text("Kích hoạt", style: TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Switch(
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                            activeColor: const Color(0xFFB0C63A),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Hủy", style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveHotel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB0C63A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : Text(widget.hotelDoc != null ? "Cập nhật" : "Lưu",
                                style: const TextStyle(fontSize: 16)),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4B5320), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5320),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B705C)),
        filled: true,
        fillColor: const Color(0xFFF6F8E9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB0C63A), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: Color(0xFF6B705C)),
      ),
      style: const TextStyle(fontSize: 15),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return "Vui lòng nhập $label";
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8E9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: const Color(0xFF6B705C), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                    : "Chọn ngày",
                style: TextStyle(
                  fontSize: 15,
                  color: _selectedDate != null ? Colors.black87 : const Color(0xFF6B705C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(controller, label, Icons.image),
        const SizedBox(height: 10),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: controller.text.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              controller.text,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      SizedBox(height: 8),
                      Text("Không thể tải hình ảnh", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          )
              : Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, color: Colors.grey, size: 40),
                SizedBox(height: 8),
                Text("Chưa có hình ảnh", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
