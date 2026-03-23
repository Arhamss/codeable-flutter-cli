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

const envDevTemplate = """
import 'package:envied/envied.dart';

part 'env_dev.g.dart';

@Envied(path: 'env/.env.development')
abstract class EnvDev {
  @EnviedField(varName: 'BASE_URL')
  static const String baseUrl = _EnvDev.baseUrl;

  @EnviedField(varName: 'API_VERSION')
  static const String apiVersion = _EnvDev.apiVersion;

  @EnviedField(varName: 'MAPBOX_API_KEY', obfuscate: true)
  static final String mapboxApiKey = _EnvDev.mapboxApiKey;

  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY', obfuscate: true)
  static final String stripePublishableKey = _EnvDev.stripePublishableKey;

  @EnviedField(varName: 'GOOGLE_CLIENT_ID')
  static const String googleClientId = _EnvDev.googleClientId;

  @EnviedField(varName: 'SOCKET_URL')
  static const String socketUrl = _EnvDev.socketUrl;
}
""";

const envStgTemplate = """
import 'package:envied/envied.dart';

part 'env_stg.g.dart';

@Envied(path: 'env/.env.staging')
abstract class EnvStg {
  @EnviedField(varName: 'BASE_URL')
  static const String baseUrl = _EnvStg.baseUrl;

  @EnviedField(varName: 'API_VERSION')
  static const String apiVersion = _EnvStg.apiVersion;

  @EnviedField(varName: 'MAPBOX_API_KEY', obfuscate: true)
  static final String mapboxApiKey = _EnvStg.mapboxApiKey;

  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY', obfuscate: true)
  static final String stripePublishableKey = _EnvStg.stripePublishableKey;

  @EnviedField(varName: 'GOOGLE_CLIENT_ID')
  static const String googleClientId = _EnvStg.googleClientId;

  @EnviedField(varName: 'SOCKET_URL')
  static const String socketUrl = _EnvStg.socketUrl;
}
""";

const envProdTemplate = """
import 'package:envied/envied.dart';

part 'env_prod.g.dart';

@Envied(path: 'env/.env.production')
abstract class EnvProd {
  @EnviedField(varName: 'BASE_URL')
  static const String baseUrl = _EnvProd.baseUrl;

  @EnviedField(varName: 'API_VERSION')
  static const String apiVersion = _EnvProd.apiVersion;

  @EnviedField(varName: 'MAPBOX_API_KEY', obfuscate: true)
  static final String mapboxApiKey = _EnvProd.mapboxApiKey;

  @EnviedField(varName: 'STRIPE_PUBLISHABLE_KEY', obfuscate: true)
  static final String stripePublishableKey = _EnvProd.stripePublishableKey;

  @EnviedField(varName: 'GOOGLE_CLIENT_ID')
  static const String googleClientId = _EnvProd.googleClientId;

  @EnviedField(varName: 'SOCKET_URL')
  static const String socketUrl = _EnvProd.socketUrl;
}
""";

const appEnvTemplate = """
import 'package:{{project_name}}/config/env/env_dev.dart';
import 'package:{{project_name}}/config/env/env_prod.dart';
import 'package:{{project_name}}/config/env/env_stg.dart';
import 'package:{{project_name}}/config/flavor_config.dart';

class AppEnv {
  AppEnv._();

  static String get baseUrl => switch (FlavorConfig.currentFlavor) {
    Flavor.development => EnvDev.baseUrl,
    Flavor.staging => EnvStg.baseUrl,
    Flavor.production => EnvProd.baseUrl,
  };

  static String get apiVersion => switch (FlavorConfig.currentFlavor) {
    Flavor.development => EnvDev.apiVersion,
    Flavor.staging => EnvStg.apiVersion,
    Flavor.production => EnvProd.apiVersion,
  };

  static String get mapboxApiKey => switch (FlavorConfig.currentFlavor) {
    Flavor.development => EnvDev.mapboxApiKey,
    Flavor.staging => EnvStg.mapboxApiKey,
    Flavor.production => EnvProd.mapboxApiKey,
  };

  static String get stripePublishableKey => switch (FlavorConfig.currentFlavor) {
    Flavor.development => EnvDev.stripePublishableKey,
    Flavor.staging => EnvStg.stripePublishableKey,
    Flavor.production => EnvProd.stripePublishableKey,
  };

  static String get googleClientId => switch (FlavorConfig.currentFlavor) {
    Flavor.development => EnvDev.googleClientId,
    Flavor.staging => EnvStg.googleClientId,
    Flavor.production => EnvProd.googleClientId,
  };

  static String get socketUrl => switch (FlavorConfig.currentFlavor) {
    Flavor.development => EnvDev.socketUrl,
    Flavor.staging => EnvStg.socketUrl,
    Flavor.production => EnvProd.socketUrl,
  };
}
""";

const dotEnvTemplate = '''
BASE_URL=https://api.example.com/
API_VERSION=v1
MAPBOX_API_KEY=YOUR_MAPBOX_API_KEY
STRIPE_PUBLISHABLE_KEY=YOUR_STRIPE_PUBLISHABLE_KEY
GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID
SOCKET_URL=wss://api.example.com/ws
''';

const remoteConfigTemplate = '''
/// Firebase Remote Config wrapper
///
/// TODO: Configure your remote config keys here.
class RemoteConfigService {
  RemoteConfigService._();
}
''';
