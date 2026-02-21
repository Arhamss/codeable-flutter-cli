import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/features/onboarding/domain/repository/onboarding_repository.dart';
import 'package:test_app/features/onboarding/presentation/cubit/state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required this.repository})
      : super(const OnboardingState());

  final OnboardingRepository repository;

  // TODO: Add cubit methods (login, register, etc.)
}
