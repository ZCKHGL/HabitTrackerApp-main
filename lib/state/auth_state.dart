import 'dart:async';
import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';

class AuthState extends ChangeNotifier {
  final LocalAuthService _auth = LocalAuthService.I;

  LocalUser? _user;
  LocalUser? get user => _user;
  bool get isLoggedIn => _user != null;
  String get userId => _user?.id ?? 'guest';
  String get displayName => _user?.displayName ?? 'Guest';
  String? get email => _user?.email;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _initialized = false;
  bool get initialized => _initialized;

  AuthState() {
    _init();
  }

  Future<void> _init() async {
    _user = await _auth.getCurrentUser();
    _initialized = true;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _auth.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Just create the account, don't set as current user
      await _auth.signUp(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final exists = await _auth.emailExists(email);
      _isLoading = false;
      if (!exists) {
        _error = _getErrorMessage('user-not-found');
        notifyListeners();
        return false;
      }
      // For local auth, we can't actually reset password via email
      // Just show success message and let user know it's a local account
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      default:
        return 'Authentication failed: $code';
    }
  }
}
