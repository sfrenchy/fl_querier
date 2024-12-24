import 'package:querier/api/api_client.dart';
import 'package:flutter/material.dart';

class WizardService {
  final ApiClient _apiClient;

  WizardService(String baseUrl, NavigatorState navigator)
      : _apiClient = ApiClient(baseUrl, navigator);

  Future<bool> setup({
    required String name,
    required String firstName,
    required String email,
    required String password,
    required String smtpHost,
    required int smtpPort,
    required String smtpUsername,
    required String smtpPassword,
    required bool useSSL,
    required senderEmail,
    required senderName,
  }) async {
    try {
      return await _apiClient.setup(
        name: name,
        firstName: firstName,
        email: email,
        password: password,
        smtpHost: smtpHost,
        smtpPort: smtpPort,
        smtpUsername: smtpUsername,
        smtpPassword: smtpPassword,
        useSSL: useSSL,
        senderEmail: senderEmail,
        senderName: senderName,
      );
    } catch (e) {
      throw Exception('Failed to setup: ${e.toString()}');
    }
  }
}
