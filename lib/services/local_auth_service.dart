import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUser {
  final String id;
  final String email;
  final String displayName;

  LocalUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
      };

  factory LocalUser.fromJson(Map<String, dynamic> json) => LocalUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
      );
}

class LocalAuthService {
  LocalAuthService._();
  static final LocalAuthService I = LocalAuthService._();

  static const _currentUserKey = 'current_user';
  static const _usersKey = 'registered_users';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Hash password using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate unique user ID from email
  String _generateUserId(String email) {
    final bytes = utf8.encode(email.toLowerCase());
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Get current logged in user
  Future<LocalUser?> getCurrentUser() async {
    final prefs = await _preferences;
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    try {
      return LocalUser.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  /// Get all registered users
  Future<Map<String, Map<String, dynamic>>> _getUsers() async {
    final prefs = await _preferences;
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return {};
    try {
      final decoded = jsonDecode(usersJson) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as Map<String, dynamic>));
    } catch (_) {
      return {};
    }
  }

  /// Save users to storage
  Future<void> _saveUsers(Map<String, Map<String, dynamic>> users) async {
    final prefs = await _preferences;
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// Sign in with email and password
  Future<LocalUser> signIn(String email, String password) async {
    final users = await _getUsers();
    final userId = _generateUserId(email);
    final user = users[userId];

    if (user == null) {
      throw AuthException('user-not-found', 'No user found with this email');
    }

    final hashedPassword = _hashPassword(password);
    if (user['password'] != hashedPassword) {
      throw AuthException('wrong-password', 'Incorrect password');
    }

    final localUser = LocalUser(
      id: userId,
      email: email.toLowerCase(),
      displayName: user['displayName'] as String,
    );

    // Save current user
    final prefs = await _preferences;
    await prefs.setString(_currentUserKey, jsonEncode(localUser.toJson()));

    return localUser;
  }

  /// Create new account (does NOT auto-login)
  Future<LocalUser> signUp(String email, String password) async {
    if (password.length < 6) {
      throw AuthException('weak-password', 'Password must be at least 6 characters');
    }

    if (!email.contains('@') || !email.contains('.')) {
      throw AuthException('invalid-email', 'Invalid email address');
    }

    final users = await _getUsers();
    final userId = _generateUserId(email);

    if (users.containsKey(userId)) {
      throw AuthException('email-already-in-use', 'Email is already registered');
    }

    final hashedPassword = _hashPassword(password);
    final displayName = email.split('@').first;

    users[userId] = {
      'email': email.toLowerCase(),
      'password': hashedPassword,
      'displayName': displayName,
    };

    await _saveUsers(users);

    final localUser = LocalUser(
      id: userId,
      email: email.toLowerCase(),
      displayName: displayName,
    );

    // Do NOT save as current user - user must login after registration
    return localUser;
  }

  /// Sign out
  Future<void> signOut() async {
    final prefs = await _preferences;
    await prefs.remove(_currentUserKey);
  }

  /// Check if email exists (for password reset simulation)
  Future<bool> emailExists(String email) async {
    final users = await _getUsers();
    final userId = _generateUserId(email);
    return users.containsKey(userId);
  }

  /// Change password (requires current password)
  Future<void> changePassword(String email, String currentPassword, String newPassword) async {
    if (newPassword.length < 6) {
      throw AuthException('weak-password', 'Password must be at least 6 characters');
    }

    final users = await _getUsers();
    final userId = _generateUserId(email);
    final user = users[userId];

    if (user == null) {
      throw AuthException('user-not-found', 'No user found with this email');
    }

    final hashedCurrent = _hashPassword(currentPassword);
    if (user['password'] != hashedCurrent) {
      throw AuthException('wrong-password', 'Current password is incorrect');
    }

    user['password'] = _hashPassword(newPassword);
    await _saveUsers(users);
  }
}

class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => message;
}
