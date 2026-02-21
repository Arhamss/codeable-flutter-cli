const flavorConfigTemplate = '''
/// App Flavors
enum Flavor { development, production }

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

  static bool isDev() => instance.flavor == Flavor.development;

  static Flavor get currentFlavor => instance.flavor;
}
''';

const apiEnvironmentTemplate = '''
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:{{project_name}}/config/flavor_config.dart';

/// API Environments & Configurations
enum ApiEnvironment {
  production(
    baseUrl: 'https://api.example.com/api',
    apiVersion: 'v1',
    androidGoogleClientId: 'YOUR_ANDROID_GOOGLE_CLIENT_ID',
    iosGoogleClientId: 'YOUR_IOS_GOOGLE_CLIENT_ID',
    googleServerClientId: 'YOUR_GOOGLE_SERVER_CLIENT_ID',
  ),
  development(
    baseUrl: 'https://dev-api.example.com/api',
    apiVersion: 'v1',
    androidGoogleClientId: 'YOUR_ANDROID_GOOGLE_CLIENT_ID',
    iosGoogleClientId: 'YOUR_IOS_GOOGLE_CLIENT_ID',
    googleServerClientId: 'YOUR_GOOGLE_SERVER_CLIENT_ID',
  );

  const ApiEnvironment({
    required this.baseUrl,
    required this.apiVersion,
    required this.androidGoogleClientId,
    required this.iosGoogleClientId,
    required this.googleServerClientId,
  });

  final String baseUrl;
  final String apiVersion;
  final String androidGoogleClientId;
  final String iosGoogleClientId;
  final String googleServerClientId;

  /// Get platform-specific Google Client ID
  String get platformGoogleClientId {
    if (kIsWeb) {
      return googleServerClientId;
    } else if (Platform.isAndroid) {
      return androidGoogleClientId;
    } else if (Platform.isIOS) {
      return iosGoogleClientId;
    }
    return '';
  }

  /// Get API Environment based on current flavor
  static ApiEnvironment get current {
    switch (FlavorConfig.instance.flavor) {
      case Flavor.production:
        return ApiEnvironment.production;
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
