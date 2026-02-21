const flavorConfigTemplate = '''
/// App Flavors
enum Flavor { development, staging, production }

/// Flavor Configuration Singleton
class FlavorConfig {
  factory FlavorConfig({required Flavor flavor}) =>
      _instance ??= FlavorConfig._internal(flavor);

  FlavorConfig._internal(this.flavor);

  final Flavor flavor;

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception(
        'FlavorConfig is not initialized. Call FlavorConfig(flavor: <Flavor>) first.',
      );
    }
    return _instance!;
  }

  static bool isProd() => instance.flavor == Flavor.production;

  static bool isStaging() => instance.flavor == Flavor.staging;

  static bool isDev() => instance.flavor == Flavor.development;

  static Flavor get currentFlavor => instance.flavor;
}
''';

const apiEnvironmentTemplate = '''
import 'package:{{project_name}}/config/flavor_config.dart';

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
''';

const remoteConfigTemplate = '''
/// Firebase Remote Config wrapper
///
/// TODO: Configure your remote config keys here.
class RemoteConfigService {
  RemoteConfigService._();
}
''';
