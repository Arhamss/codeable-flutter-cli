import 'package:test_app/exports.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Welcome',
                style: context.h1,
              ),
              const SizedBox(height: 8),
              Text(
                'Log in to continue',
                style: context.b1.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              SocialAuthButton(
                text: 'Sign in with Google',
                onPressed: () {
                  // TODO: Implement Google sign-in
                },
              ),
              const SizedBox(height: 16),
              SocialAuthButton(
                text: 'Sign in with Apple',
                onPressed: () {
                  // TODO: Implement Apple sign-in
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
