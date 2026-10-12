import 'package:flutter/material.dart';

enum Flavor {
  development,
  staging,
  production,
}

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final String schoolCode;
  final String apiBaseUrl;
  final String authServerUrl;
  final String clientId;
  final String scopes;
  final Color primaryColor;
  final Color secondaryColor;

  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.schoolCode,
    required this.apiBaseUrl,
    required this.authServerUrl,
    this.clientId = 'mh-schoolops-web',
    this.scopes = 'openid profile email roles mh_api offline_access',
    this.primaryColor = const Color(0xFF1E3A8A), // Deep Royal Navy
    this.secondaryColor = const Color(0xFF2563EB), // Vibrant Blue
  });
}
