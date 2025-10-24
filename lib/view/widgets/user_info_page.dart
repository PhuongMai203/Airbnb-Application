import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _nameController.text = user.displayName ?? "";
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      _birthYearController.text = doc.data()?['birthYear'] ?? "";
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF566107)),
              title: const Text("Chọn từ thư viện"),
              onTap: () async {
                final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (picked != null) setState(() => _imageFile = File(picked.path));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF566107)),
              title: const Text("Chụp ảnh mới"),
              onTap: () async {
                final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (picked != null) setState(() => _imageFile = File(picked.path));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadImageToStorage(File image) async {
    final storageRef = FirebaseStorage.instance.ref().child('user_avatars/${user.uid}.jpg');
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await user.updateDisplayName(_nameController.text);

      String? photoUrl = user.photoURL;
      if (_imageFile != null) {
        photoUrl = await _uploadImageToStorage(_imageFile!);
        await user.updatePhotoURL(photoUrl);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': _nameController.text,
        'birthYear': _birthYearController.text,
        'photoURL': photoUrl,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã lưu thông tin cá nhân thành công!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF566107)),
        title: const Text(
          "Thông tin cá nhân",
          style: TextStyle(
            color: Color(0xFF566107),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Ảnh đại diện
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFECEFD3),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (user.photoURL != null
                        ? NetworkImage(user.photoURL!) as ImageProvider
                        : null),
                    child: user.photoURL == null && _imageFile == null
                        ? const Icon(Icons.person, size: 60, color: Color(0xFF566107))
                        : null,
                  ),

                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE4EAB7),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.edit, color: Color(0xFF566107), size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Tên người dùng",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _birthYearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Năm sinh",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProfile,
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.save, color: Color(0xFF566107)),
                label: Text(
                  _isLoading ? "Đang lưu..." : "Lưu thay đổi",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF566107)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCE3AD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
