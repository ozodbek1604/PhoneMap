import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthService() { _checkCurrentUser(); }

  void _checkCurrentUser() {
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

  String? get userId => _user?.uid;
  String? get userName => _user?.displayName ?? 'Foydalanuvchi';
  String? get userPhone => _user?.phoneNumber;
}