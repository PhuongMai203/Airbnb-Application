import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login và trả về role
  static Future<String> login(String email, String password) async {
    try {
      final userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      if (uid == null) return "Lỗi: không tìm thấy user";

      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (!snapshot.exists) return "Không tìm thấy dữ liệu người dùng";

      final role = snapshot.data()?['role'] ?? 'user';
      return role;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Lỗi đăng nhập";
    }
  }

  // Đặt role cho user
  static Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set({
      'role': role,
    }, SetOptions(merge: true)); // merge: true để không ghi đè email
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Lấy role của user hiện tại
  static Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) return null;

    return snapshot.data()?['role'];
  }
}
