import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? currentUser;
  bool _loading = false;

  bool get loading => _loading;

  /// 🔹 Login with email & password
  Future<bool> login(String username, String password) async {
    _loading = true;
    notifyListeners();

    try {
      final user = await _authService.login(username, password);
      if (user != null) {
        currentUser = user;
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔹 Login with phone number (for Patient)
  Future<void> loginByPhone(String phone,
      {required Function(String verificationId) codeSent,
      required Function(String error) onError}) async {
    _loading = true;
    notifyListeners();

    try {
      await _authService.loginByPhone(
        phone,
        codeSent: (verificationId) {
          _loading = false;
          notifyListeners();
          codeSent(verificationId);
        },
        onError: (error) {
          _loading = false;
          notifyListeners();
          onError(error);
        },
      );
    } catch (e) {
      _loading = false;
      notifyListeners();
      onError(e.toString());
    }
  }

  /// 🔹 Verify OTP after phone login
  Future<bool> verifyOtp(String verificationId, String smsCode) async {
    _loading = true;
    notifyListeners();

    try {
      final user = await _authService.verifyOtp(verificationId, smsCode);
      if (user != null) {
        currentUser = user;
        _loading = false;
        notifyListeners();
        return true;
      }
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔹 Logout
  Future<void> logout() async {
    await _authService.signOut();
    currentUser = null;
    notifyListeners();
  }
}
