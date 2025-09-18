import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Stream of authentication state
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  /// 🔹 Sign in with email & password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 Wrapper for old code compatibility
  Future<User?> login(String email, String password) {
    return signInWithEmail(email, password);
  }

  /// 🔹 Sign in with phone number (OTP flow)
  Future<void> signInWithPhone(
    String phoneNumber, {
    required Function(String verificationId) codeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? "Phone login failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// 🔹 Wrapper for old code compatibility
  Future<void> loginByPhone(
    String phone, {
    required Function(String verificationId) codeSent,
    required Function(String error) onError,
  }) {
    return signInWithPhone(phone, codeSent: codeSent, onError: onError);
  }

  /// 🔹 Verify OTP (for phone login)
  Future<User?> verifyOtp(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 Register new user (Doctor/Patient/ASHA/Admin)
  Future<User?> registerUser({
    required String email,
    required String password,
    required String role, // patient / asha / doctor / admin
    required Map<String, dynamic> extraData,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await _db.collection("users").doc(user.uid).set({
          "email": email,
          "role": role,
          ...extraData,
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 Fetch user role
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection("users").doc(uid).get();
      return doc['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// 🔹 Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
