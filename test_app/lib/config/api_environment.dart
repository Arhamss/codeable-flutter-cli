import 'package:test_app/config/flavor_config.dart';

/// API Environments & Configurations
enum ApiEnvironment {
  production(
    baseUrl: 'https://api.example.com/api',
    apiVersion: 'v1',
    serverClientId: 'YOUR_SERVER_CLIENT_ID',
  ),
  staging(
    baseUrl: 'https://staging-api.example.com/api',
    apiVersion: 'v1',
    serverClientId: 'YOUR_SERVER_CLIENT_ID',
  ),
  development(
    baseUrl: 'https://dev-api.example.com/api',
    apiVersion: 'v1',
    serverClientId: 'YOUR_SERVER_CLIENT_ID',
  );

  const ApiEnvironment({
    required this.baseUrl,
    required this.apiVersion,
    required this.serverClientId,
  });

  final String baseUrl;
  final String apiVersion;
  final String serverClientId;

  /// Get API Environment based on current flavor
  static ApiEnvironment get current {
    switch (FlavorConfig.instance.flavor) {
      case Flavor.production:
        return ApiEnvironment.production;
      case Flavor.staging:
        return ApiEnvironment.staging;
      case Flavor.development:
        return ApiEnvironment.development;
    }
  }
}
