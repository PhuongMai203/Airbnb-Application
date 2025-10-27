import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: usersRef.orderBy("updatedAt", descending: true).snapshots(),
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

                  final users = snapshot.data?.docs ?? [];
                  if (users.isEmpty) {
                    return const Center(
                      child: Text(
                        "Chưa có người dùng nào",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final data = users[index].data() as Map<String, dynamic>;
                      final displayName = data['displayName'] ?? 'Không có tên';
                      final email = data['email'] ?? 'Không có email';
                      final birthYear = data['birthYear'] ?? 'Không rõ';
                      final photoURL = data['photoURL'];

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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFFF7FBE1),
                            backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                            child: photoURL == null
                                ? const Icon(Icons.person, color: Color(0xFF4B5320), size: 28)
                                : null,
                          ),
                          title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("$email\nNăm sinh: $birthYear", style: const TextStyle(height: 1.4)),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                            onPressed: () async {
                              final docId = users[index].id;
                              await usersRef.doc(docId).delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Đã xóa người dùng: $displayName")),
                              );
                            },
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
                backgroundColor: const Color(0xFFF3F6E3),
                foregroundColor: Color(0xFF4B5320),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddUserDialog(usersRef: usersRef),
                );
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Thêm người dùng mới", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final CollectionReference usersRef;
  const AddUserDialog({super.key, required this.usersRef});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthYearController = TextEditingController();

  File? _selectedImage;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) setState(() => _selectedImage = File(picked.path));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh mới'),
                onTap: () async {
                  final picked = await _picker.pickImage(source: ImageSource.camera);
                  if (picked != null) setState(() => _selectedImage = File(picked.path));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = "users/${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint("❌ Lỗi upload ảnh: $e");
      return null;
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    String? photoURL;
    if (_selectedImage != null) photoURL = await _uploadImage(_selectedImage!);

    await widget.usersRef.add({
      "displayName": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "birthYear": _birthYearController.text.trim(),
      "photoURL": photoURL,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm người dùng thành công")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Thêm người dùng mới", style: TextStyle(color: Color(0xFF4B5320), fontSize: 20, fontWeight: FontWeight.w500),),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Tên người dùng"),
              const SizedBox(height: 10),
              _buildTextField(_emailController, "Email", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildTextField(_birthYearController, "Năm sinh", keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    _selectedImage != null
                        ? CircleAvatar(radius: 50, backgroundImage: FileImage(_selectedImage!))
                        : const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFF3F6E4),
                      child: Icon(Icons.camera_alt, color: Color(0xFF4B5320), size: 30),
                    ),
                    const SizedBox(height: 8),
                    const Text("Chọn ảnh đại diện", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF4F8DD),
            foregroundColor: Color(0xFF4B5320),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isSaving ? null : _saveUser,
          child: _isSaving
              ? const SizedBox(
              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Lưu"),
        ),
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
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null || value.trim().isEmpty) ? "Vui lòng nhập $label" : null,
    );
  }
}
