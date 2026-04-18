/// ✅ Validators cho form
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    final regex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập tên';
    if (value.length < 2) return 'Tên phải có ít nhất 2 ký tự';
    if (value.length > 30) return 'Tên không được quá 30 ký tự';
    return null;
  }

  static String? notEmpty(String? value, {String field = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) return '$field không được rỗng';
    return null;
  }
}