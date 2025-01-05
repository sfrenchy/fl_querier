import 'package:flutter/material.dart';
import 'package:querier/api/api_client.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  String? _token;
  List<String> _userRoles = [];
  String? _userEmail;
  String? _firstName;
  String? _lastName;

  AuthProvider(this._apiClient);

  List<String> get userRoles => _userRoles;
  String? get token => _token;
  String? get userEmail => _userEmail;
  bool get isAuthenticated => _token != null;
  String? get firstName => _firstName;
  String? get lastName => _lastName;

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _apiClient.signIn(email, password);
      if (response.statusCode == 200) {
        _token = response.data['Token'];
        _userRoles = List<String>.from(response.data['Roles'] ?? []);
        _userEmail = email;
        _firstName = response.data['FirstName'];
        _lastName = response.data['LastName'];
        if (_token != null) {
          _apiClient.setAuthToken(_token!);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error in signIn: $e');
      _userRoles = [];
      return false;
    }
  }

  void updateFromAuthResponse(Map<String, dynamic> authResponse) {
    _token = authResponse['Token'];
    _userRoles = List<String>.from(authResponse['Roles'] ?? []);
    _userEmail = authResponse['Email'];
    _firstName = authResponse['FirstName'];
    _lastName = authResponse['LastName'];
    if (_token != null) {
      _apiClient.setAuthToken(_token!);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _apiClient.signOut();
    } finally {
      _token = null;
      _userRoles = [];
      _userEmail = null;
      _apiClient.clearAuthToken();
      notifyListeners();
    }
  }

  void updateToken(String newToken, List<String> roles) {
    _token = newToken;
    _userRoles = roles;
    if (_token != null) {
      _apiClient.setAuthToken(_token!);
    }
    notifyListeners();
  }
}
