import 'dart:convert';

class ApiConfiguration {
  final String scheme;
  final String host;
  final int port;
  final String allowedHosts;
  final String allowedOrigins;
  final String allowedMethods;
  final String allowedHeaders;
  final int resetPasswordTokenValidity;
  final int emailConfirmationTokenValidity;
  final bool requireDigit;
  final bool requireLowercase;
  final bool requireNonAlphanumeric;
  final bool requireUppercase;
  final int requiredLength;
  final int requiredUniqueChars;
  final String smtpHost;
  final int smtpPort;
  final String smtpUsername;
  final String smtpPassword;
  final bool smtpUseSSL;
  final String smtpSenderEmail;
  final String smtpSenderName;
  final bool smtpRequireAuth;
  final bool redisEnabled;
  final String redisHost;
  final int redisPort;

  ApiConfiguration({
    required this.scheme,
    required this.host,
    required this.port,
    required this.allowedHosts,
    required this.allowedOrigins,
    required this.allowedMethods,
    required this.allowedHeaders,
    required this.resetPasswordTokenValidity,
    required this.emailConfirmationTokenValidity,
    required this.requireDigit,
    required this.requireLowercase,
    required this.requireNonAlphanumeric,
    required this.requireUppercase,
    required this.requiredLength,
    required this.requiredUniqueChars,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpUsername,
    required this.smtpPassword,
    required this.smtpUseSSL,
    required this.smtpSenderEmail,
    required this.smtpSenderName,
    required this.smtpRequireAuth,
    required this.redisEnabled,
    required this.redisHost,
    required this.redisPort,
  });

  factory ApiConfiguration.fromJson(Map<String, dynamic> json) {
    return ApiConfiguration(
      scheme: json['Scheme'] ?? '',
      host: json['Host'] ?? '',
      port: json['Port'] ?? 0,
      allowedHosts: json['AllowedHosts'] ?? '',
      allowedOrigins: json['AllowedOrigins'] ?? '',
      allowedMethods: json['AllowedMethods'] ?? '',
      allowedHeaders: json['AllowedHeaders'] ?? '',
      resetPasswordTokenValidity: json['ResetPasswordTokenValidity'] ?? 15,
      emailConfirmationTokenValidity:
          json['EmailConfirmationTokenValidity'] ?? 2,
      requireDigit: json['RequireDigit'] ?? true,
      requireLowercase: json['RequireLowercase'] ?? true,
      requireNonAlphanumeric: json['RequireNonAlphanumeric'] ?? true,
      requireUppercase: json['RequireUppercase'] ?? true,
      requiredLength: json['RequiredLength'] ?? 12,
      requiredUniqueChars: json['RequiredUniqueChars'] ?? 1,
      smtpHost: json['SmtpHost'] ?? '',
      smtpPort: json['SmtpPort'] ?? 587,
      smtpUsername: json['SmtpUsername'] ?? '',
      smtpPassword: json['SmtpPassword'] ?? '',
      smtpUseSSL: json['SmtpUseSSL'] ?? true,
      smtpSenderEmail: json['SmtpSenderEmail'] ?? '',
      smtpSenderName: json['SmtpSenderName'] ?? '',
      smtpRequireAuth: json['SmtpRequireAuth'] ?? true,
      redisEnabled: json['RedisEnabled'] ?? false,
      redisHost: json['RedisHost'] ?? '',
      redisPort: json['RedisPort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'Scheme': scheme,
        'Host': host,
        'Port': port,
        'AllowedHosts': allowedHosts,
        'AllowedOrigins': allowedOrigins,
        'AllowedMethods': allowedMethods,
        'AllowedHeaders': allowedHeaders,
        'ResetPasswordTokenValidity': resetPasswordTokenValidity,
        'EmailConfirmationTokenValidity': emailConfirmationTokenValidity,
        'RequireDigit': requireDigit,
        'RequireLowercase': requireLowercase,
        'RequireNonAlphanumeric': requireNonAlphanumeric,
        'RequireUppercase': requireUppercase,
        'RequiredLength': requiredLength,
        'RequiredUniqueChars': requiredUniqueChars,
        'SmtpHost': smtpHost,
        'SmtpPort': smtpPort,
        'SmtpUsername': smtpUsername,
        'SmtpPassword': smtpPassword,
        'SmtpUseSSL': smtpUseSSL,
        'SmtpSenderEmail': smtpSenderEmail,
        'SmtpSenderName': smtpSenderName,
        'SmtpRequireAuth': smtpRequireAuth,
        'RedisEnabled': redisEnabled,
        'RedisHost': redisHost,
        'RedisPort': redisPort,
      };
}
