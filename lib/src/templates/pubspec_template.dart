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
  bloc: ^9.0.1
  flutter_bloc: ^9.1.0
  equatable: ^2.0.7

  # Networking
  dio: ^5.8.0+1
  http: ^1.3.0

  # Local Storage
  hive_ce: ^2.19.1
  hive_ce_flutter: ^2.1.0

  # Dependency Injection
  get_it: ^8.0.3

  # Routing
  go_router: ^14.8.1

  # Firebase
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  firebase_messaging: ^15.2.5
  firebase_remote_config: ^5.3.1
  cloud_firestore: ^5.6.7
  firebase_storage: ^12.4.7

  # Auth Providers
  google_sign_in: ^6.2.2
  sign_in_with_apple: ^6.1.4

  # Localization
  intl: any

  # UI
  flutter_svg: ^2.0.17
  cached_network_image: ^3.4.1
  lottie: ^3.3.1
  shimmer: ^3.0.0
  smooth_page_indicator: ^1.2.0+3
  blur: ^4.0.2
  flutter_swipe_button: ^2.1.3

  # Media
  camera: ^0.11.1
  image_picker: ^1.1.2
  video_player: ^2.9.3

  # Utilities
  logger: ^2.5.0
  toastification: ^2.3.0
  package_info_plus: ^8.1.3
  url_launcher: ^6.3.1
  flutter_phoenix: ^1.1.1
  permission_handler: ^11.3.1
  device_info_plus: ^11.3.3
  flutter_local_notifications: ^20.0.0
  flutter_native_splash: ^2.4.6
  crypto: ^3.0.6
  purchases_flutter: ^8.4.3

  # Debug
  chucker_flutter: ^1.9.1
  device_preview: ^1.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4
  bloc_test: ^10.0.0
  intl_utils: ^2.8.8
  hive_ce_generator: ^1.10.0
  very_good_analysis: ^9.0.0
  build_runner: ^2.4.0

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
