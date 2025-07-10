import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserPreferences {
  static const String _keyPhoneNumber = 'user_phone_number';
  static const String _keyPassword = 'user_password';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastLoginTime = 'last_login_time';

  // Singleton pattern
  static UserPreferences? _instance;
  static SharedPreferences? _preferences;

  static Future<UserPreferences> getInstance() async {
    _instance ??= UserPreferences._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  UserPreferences._();

  // Store phone number and password
  Future<bool> saveCredentials({
    required String phoneNumber,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      await _preferences?.setString(_keyPhoneNumber, phoneNumber);
      
      // Only store password if user wants to be remembered
      if (rememberMe) {
        // For security, you might want to encrypt the password
        String encryptedPassword = _encryptPassword(password);
        await _preferences?.setString(_keyPassword, encryptedPassword);
      } else {
        await _preferences?.remove(_keyPassword);
      }
      
      await _preferences?.setBool(_keyRememberMe, rememberMe);
      await _preferences?.setBool(_keyIsLoggedIn, true);
      await _preferences?.setString(_keyLastLoginTime, DateTime.now().toIso8601String());
      
      return true;
    } catch (e) {
      print('Error saving credentials: $e');
      return false;
    }
  }

  // Get phone number
  String? getPhoneNumber() {
    return _preferences?.getString(_keyPhoneNumber);
  }

  // Get password (if remember me was enabled)
  String? getPassword() {
    String? encryptedPassword = _preferences?.getString(_keyPassword);
    if (encryptedPassword != null) {
      return _decryptPassword(encryptedPassword);
    }
    return null;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _preferences?.getBool(_keyIsLoggedIn) ?? false;
  }

  // Check if remember me is enabled
  bool isRememberMeEnabled() {
    return _preferences?.getBool(_keyRememberMe) ?? false;
  }

  // Get last login time
  DateTime? getLastLoginTime() {
    String? timeString = _preferences?.getString(_keyLastLoginTime);
    if (timeString != null) {
      return DateTime.tryParse(timeString);
    }
    return null;
  }

  // Clear all user data (logout)
  Future<bool> clearUserData() async {
    try {
      await _preferences?.remove(_keyPhoneNumber);
      await _preferences?.remove(_keyPassword);
      await _preferences?.setBool(_keyIsLoggedIn, false);
      await _preferences?.remove(_keyRememberMe);
      await _preferences?.remove(_keyLastLoginTime);
      return true;
    } catch (e) {
      print('Error clearing user data: $e');
      return false;
    }
  }

  // Clear only password (for security)
  Future<bool> clearPassword() async {
    try {
      await _preferences?.remove(_keyPassword);
      return true;
    } catch (e) {
      print('Error clearing password: $e');
      return false;
    }
  }

  // Update login status
  Future<bool> setLoginStatus(bool isLoggedIn) async {
    try {
      await _preferences?.setBool(_keyIsLoggedIn, isLoggedIn);
      if (isLoggedIn) {
        await _preferences?.setString(_keyLastLoginTime, DateTime.now().toIso8601String());
      }
      return true;
    } catch (e) {
      print('Error updating login status: $e');
      return false;
    }
  }

  // Get user credentials as a map
  Map<String, dynamic> getUserCredentials() {
    return {
      'phoneNumber': getPhoneNumber(),
      'password': getPassword(),
      'isLoggedIn': isLoggedIn(),
      'rememberMe': isRememberMeEnabled(),
      'lastLoginTime': getLastLoginTime()?.toIso8601String(),
    };
  }

  // Simple encryption for password (for demo purposes)
  // In production, use proper encryption libraries like encrypt package
  String _encryptPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return base64.encode(utf8.encode(password + digest.toString().substring(0, 8)));
  }

  // Simple decryption for password (for demo purposes)
  String _decryptPassword(String encryptedPassword) {
    try {
      String decoded = utf8.decode(base64.decode(encryptedPassword));
      // Remove the hash part (last 8 characters of sha256)
      return decoded.substring(0, decoded.length - 8);
    } catch (e) {
      print('Error decrypting password: $e');
      return '';
    }
  }

  // Check if credentials exist
  bool hasStoredCredentials() {
    return getPhoneNumber() != null && getPassword() != null;
  }

  // Validate stored credentials (check if they're not empty)
  bool validateStoredCredentials() {
    String? phoneNumber = getPhoneNumber();
    String? password = getPassword();
    return phoneNumber != null && phoneNumber.isNotEmpty && 
           password != null && password.isNotEmpty;
  }

  // Phone number validation helper
  bool isValidPhoneNumber(String phoneNumber) {
    // Basic phone number validation (customize based on your requirements)
    // This example checks for digits and common phone number patterns
    RegExp phoneRegExp = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  // Format phone number for display
  String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Basic formatting for display (customize based on your locale)
    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    }
    return phoneNumber; // Return original if formatting fails
  }
}

// Extension class for additional utility methods
extension UserPreferencesExtension on UserPreferences {
  // Auto-login check
  bool shouldAutoLogin() {
    return isLoggedIn() && isRememberMeEnabled() && hasStoredCredentials();
  }

  // Check if session is expired (example: 30 days)
  bool isSessionExpired({int daysToExpire = 30}) {
    DateTime? lastLogin = getLastLoginTime();
    if (lastLogin == null) return true;
    
    DateTime expiryDate = lastLogin.add(Duration(days: daysToExpire));
    return DateTime.now().isAfter(expiryDate);
  }

  // Get formatted last login time
  String getFormattedLastLoginTime() {
    DateTime? lastLogin = getLastLoginTime();
    if (lastLogin == null) return 'Never';
    
    Duration difference = DateTime.now().difference(lastLogin);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  // Get formatted phone number for display
  String getFormattedPhoneNumber() {
    String? phoneNumber = getPhoneNumber();
    if (phoneNumber == null) return '';
    return formatPhoneNumber(phoneNumber);
  }
}