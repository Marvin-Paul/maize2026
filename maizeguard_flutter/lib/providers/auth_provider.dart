import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _username;
  bool _isLoading = false;

  String? get username => _username;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _username != null;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    // Standalone Mock Auth: Accept any username/password for now
    await Future.delayed(const Duration(seconds: 1));
    _username = username;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username!);
    
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _username = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    debugPrint('Attempting auto-login...');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('username')) {
        _username = prefs.getString('username');
        debugPrint('Auto-login successful for user: $_username');
        notifyListeners();
      } else {
        debugPrint('No saved session found for auto-login.');
      }
    } catch (e) {
      debugPrint('Error during auto-login: $e');
    }
  }
}
