import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:test_app/app/view/app_view.dart';
import 'package:test_app/core/locale/cubit/locale_cubit.dart';
import 'package:test_app/exports.dart';
import 'package:test_app/features/onboarding/data/repository/onboarding_repository_impl.dart';
import 'package:test_app/features/onboarding/presentation/cubit/cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocaleCubit(context: context),
          ),
          BlocProvider(
            create: (context) => OnboardingCubit(
              repository: OnboardingRepositoryImpl(),
            ),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}
