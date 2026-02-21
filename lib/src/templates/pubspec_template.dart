const pubspecTemplate = '''
name: {{project_name}}
description: {{description}}
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=3.6.0 <4.0.0"
  flutter: ^3.35.0

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  bloc: ^9.1.0
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7

  # Networking
  dio: ^5.9.0

  # Local Storage
  hive_flutter: ^1.1.0
  hive: ^2.2.3

  # Dependency Injection
  get_it: ^9.2.0

  # Routing
  go_router: ^17.0.1

  # Firebase
  firebase_core: ^4.3.0
  firebase_auth: ^6.1.3
  firebase_messaging: ^16.1.0
  firebase_remote_config: ^6.1.3

  # Auth Providers
  google_sign_in: ^7.2.0
  sign_in_with_apple: ^7.0.1

  # Localization
  intl: ^0.20.2

  # UI
  flutter_svg: ^2.2.3
  cached_network_image: ^3.4.1
  google_fonts: ^6.3.3
  lottie: ^3.3.2
  shimmer: ^3.0.0
  carousel_slider: ^5.1.1
  smooth_page_indicator: ^2.0.1
  flutter_switch: ^0.3.2
  flutter_slidable: ^4.0.3

  # Utilities
  logger: ^2.6.2
  toastification: ^3.0.3
  package_info_plus: ^9.0.0
  url_launcher: ^6.3.2
  flutter_phoenix: ^1.1.1
  permission_handler: ^12.0.1
  image_picker: ^1.2.1
  photo_manager: ^3.8.3
  flutter_local_notifications: ^19.5.0
  flutter_native_splash: ^2.4.6

  # Debug
  chucker_flutter: ^1.9.1
  device_preview: ^1.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  intl_utils: ^2.8.8
  hive_generator: ^2.0.1
  very_good_analysis: ^9.0.0
  build_runner: ^2.4.0

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/
    - assets/vectors/
    - assets/images/
    - assets/lottie/

flutter_native_splash:
  color: "#FFFFFF"
  android_12:
    color: "#FFFFFF"
  android: true
  ios: true
''';
