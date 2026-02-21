import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/constants/app_colors.dart';
import 'package:test_app/core/locale/cubit/locale_cubit.dart';
import 'package:test_app/go_router/exports.dart';
import 'package:test_app/l10n/gen/app_localizations.dart';
import 'package:toastification/toastification.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return ToastificationWrapper(
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            child: MaterialApp.router(
              routerConfig: AppRouter.router,
              theme: ThemeData(
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                scaffoldBackgroundColor: AppColors.backgroundPrimary,
                useMaterial3: true,
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: AppColors.primary,
                  selectionColor:
                      AppColors.primary.withValues(alpha: 0.25),
                  selectionHandleColor: AppColors.primary,
                ),
              ),
              locale: DevicePreview.locale(context) ?? state.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              builder: DevicePreview.appBuilder,
            ),
          ),
        );
      },
    );
  }
}
