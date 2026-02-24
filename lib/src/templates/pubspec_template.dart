const pubspecTemplate = '''
name: {{project_name}}
description: {{description}}
version: 1.0.0+1
publish_to: none

environment:
  sdk: ^3.9.0

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  bloc: ^9.2.0
  flutter_bloc: ^9.1.1
  equatable: ^2.0.8

  # Networking
  dio: ^5.9.1
  http: ^1.6.0

  # Local Storage
  hive_ce: ^2.19.3
  hive_ce_flutter: ^2.3.4

  # Dependency Injection
  get_it: ^9.2.1

  # Routing
  go_router: ^17.1.0

  # Firebase
  firebase_core: ^4.4.0
  firebase_auth: ^6.1.4
  firebase_messaging: ^16.1.1
  firebase_remote_config: ^6.1.4
  cloud_firestore: ^6.1.2
  firebase_storage: ^13.0.6

  # Auth Providers
  google_sign_in: ^7.2.0
  sign_in_with_apple: ^7.0.1

  # Localization
  intl: any

  # UI
  flutter_svg: ^2.2.3
  cached_network_image: ^3.4.1
  lottie: ^3.3.2
  shimmer: ^3.0.0
  smooth_page_indicator: ^2.0.1
  blur: ^4.0.2
  flutter_swipe_button: ^2.1.3

  # Media
  camera: ^0.11.4
  image_picker: ^1.2.1
  video_player: ^2.11.0

  # Utilities
  logger: ^2.6.2
  toastification: ^3.0.3
  package_info_plus: ^9.0.0
  url_launcher: ^6.3.2
  flutter_phoenix: ^1.1.1
  permission_handler: ^12.0.1
  device_info_plus: ^12.3.0
  flutter_local_notifications: ^20.1.0
  flutter_native_splash: ^2.4.7
  crypto: ^3.0.7
  purchases_flutter: ^9.12.2

  # Debug
  chucker_flutter: ^1.9.1
  device_preview: ^1.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  bloc_test: ^10.0.0
  intl_utils: ^2.8.14
  hive_ce_generator: ^1.11.1
  very_good_analysis: ^10.2.0
  build_runner: ^2.11.1

flutter:
  uses-material-design: true
  generate: true

  assets:
    - assets/
    - assets/vectors/
    - assets/images/
    - assets/animation/
    - assets/fonts/

  fonts:
    - family: BBBPoppins
      fonts:
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-DisplayRegular.ttf
          weight: 400
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-DisplayRegularItalic.ttf
          weight: 400
          style: italic
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-TextRegular.ttf
          weight: 400
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-TextRegularItalic.ttf
          weight: 400
          style: italic
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-TextSemiBold.ttf
          weight: 600
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-TextSemiBoldItalic.ttf
          weight: 600
          style: italic
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-DisplaySemiBold.ttf
          weight: 600
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-DisplaySemiBoldItalic.ttf
          weight: 600
          style: italic
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-TextBold.ttf
          weight: 700
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-TextBoldItalic.ttf
          weight: 700
          style: italic
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-DisplayBold.ttf
          weight: 700
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-DisplayBoldItalic.ttf
          weight: 700
          style: italic
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-TextBlack.ttf
          weight: 900
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-TextBlackItalic.ttf
          weight: 900
          style: italic
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-DisplayBlack.ttf
          weight: 900
        - asset: assets/fonts/bbb-poppins/BBBPoppinsTN-DisplayBlackItalic.ttf
          weight: 900
          style: italic
    - family: SFProRounded
      fonts:
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Thin.otf
          weight: 100
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Ultralight.otf
          weight: 200
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Light.otf
          weight: 300
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Regular.otf
          weight: 400
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Medium.otf
          weight: 500
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Semibold.otf
          weight: 600
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Bold.otf
          weight: 700
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Heavy.otf
          weight: 800
        - asset: assets/fonts/sf-pro-rounded/SF-Pro-Rounded-Black.otf
          weight: 900

flutter_native_splash:
  color: "#0D0B2E"
  fullscreen: true
  image: assets/images/splash-with-logo.png
  android_12:
    color: "#0D0B2E"
    image: assets/images/splash-with-logo.png
''';
