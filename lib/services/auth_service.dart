import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// 🔐 Service xử lý xác thực Firebase
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// User hiện tại
  User? get currentUser => _auth.currentUser;

  /// Đăng ký tài khoản mới
  Future<UserModel?> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException {
        rethrow;
      } catch (e) {
        // Bỏ qua bug Pigeon của firebase_auth — kiểm tra lại currentUser
        if (_auth.currentUser == null) rethrow;
      }

      final user = _auth.currentUser;
      if (user == null) return null;

      try {
        await user.updateDisplayName(displayName);
      } catch (_) {
        // Bỏ qua lỗi update display name (Pigeon bug tương tự)
      }

      final newUser = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        totalCoins: 100, // Quà chào mừng
        hearts: 5,
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Đã có lỗi xảy ra: $e';
    }
  }

  /// Đăng nhập
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException {
        rethrow;
      } catch (e) {
        // Bỏ qua bug Pigeon của firebase_auth — kiểm tra lại currentUser
        if (_auth.currentUser == null) rethrow;
      }

      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc);

      // Tài khoản có trên Auth nhưng chưa có document Firestore → tạo mới
      final fallback = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName ?? '',
        totalCoins: 100,
        hearts: 5,
      );
      await _firestore.collection('users').doc(user.uid).set(fallback.toMap());
      return fallback;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Đã có lỗi xảy ra: $e';
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Reset mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Xử lý lỗi auth sang tiếng Việt
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
      case 'network-request-failed':
        return 'Không có kết nối mạng';
      default:
        return 'Lỗi: ${e.message}';
    }
  }
}