import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:test_app/core/app_preferences/app_preferences.dart';
import 'package:test_app/core/di/injector.dart';
import 'package:test_app/exports.dart';
import 'package:test_app/utils/helpers/logger_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  void _navigate() {
    final authToken = Injector.resolve<AppPreferences>().getAuthToken();
    FlutterNativeSplash.remove();

    if ((authToken ?? '').isEmpty) {
      context.goNamed(AppRouteNames.loginScreen);
    } else {
      AppLogger.info('Auth token found');
      context.goNamed(AppRouteNames.homeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
    );
  }
}
