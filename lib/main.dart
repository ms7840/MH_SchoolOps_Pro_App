import 'package:flutter/material.dart';
import 'app/bootstrap.dart';
import 'core/config/flavor_config.dart';

void main() {
  const config = FlavorConfig(
    flavor: Flavor.development,
    appName: 'MH SchoolOps Pro',
    schoolCode: 'DEFAULT',
    apiBaseUrl: 'https://localhost:7112',
    authServerUrl: 'https://localhost:7112',
    clientId: 'mh-schoolops-web',
    scopes: 'openid profile email roles mh_api offline_access',
    primaryColor: Color(0xFF1B365D),
    secondaryColor: Color(0xFF2563EB),
  );

  bootstrap(config);
}
