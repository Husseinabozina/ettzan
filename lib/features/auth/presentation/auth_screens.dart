import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/di/injection.dart';
import 'package:etzan_life_coaching/features/auth/domain/repositories/auth_repository.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/responsive/responsive.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_asset_icon.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_logo.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final user = getIt<AuthRepository>().currentUser;
      Navigator.of(context).pushReplacementNamed(
          user != null ? AppRoutes.home : AppRoutes.onboardingGoals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Stack(
            children: [
              const PositionedDirectional(
                start: -70,
                top: -70,
                child: _SoftOrb(size: 190, color: AppColors.secondary),
              ),
              const PositionedDirectional(
                end: -85,
                bottom: 30,
                child: _SoftOrb(size: 230, color: AppColors.lavender),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const EtzanLogo(size: 112),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.tr('tagline'),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: AppColors.primaryDark),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        height: 190,
                        width: 420,
                        child: SvgPicture.asset(AppAssets.calmLandscape,
                            fit: BoxFit.contain),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingGoalsScreen extends StatelessWidget {
  const OnboardingGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingLayout(
      title: context.tr('growTitle'),
      body: context.tr('growBody'),
      illustrationAsset: AppAssets.onboardingGoals,
      pageIndex: 0,
      onNext: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingCoach),
    );
  }
}

class OnboardingCoachScreen extends StatelessWidget {
  const OnboardingCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingLayout(
      title: context.tr('coachTitle'),
      body: context.tr('coachBody'),
      illustrationAsset: AppAssets.onboardingCoach,
      pageIndex: 1,
      onNext: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.signUp),
    );
  }
}

class _OnboardingLayout extends StatelessWidget {
  const _OnboardingLayout({
    required this.title,
    required this.body,
    required this.illustrationAsset,
    required this.pageIndex,
    required this.onNext,
  });

  final String title;
  final String body;
  final String illustrationAsset;
  final int pageIndex;
  final VoidCallback onNext;

  Future<void> _continueAsGuest(BuildContext context) async {
    try {
      await getIt<AuthRepository>().signInAsGuest();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.guestSignInError.tr(context: context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final illustrationHeight = screenHeight < 700 ? 245.0 : 315.0;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: ResponsiveCenter(
            child: Padding(
              padding: Responsive.pagePadding(context),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.signUp),
                      child: Text(context.tr('skip')),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: screenHeight - 230, maxWidth: 620),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            EtzanHeroIllustration(
                                asset: illustrationAsset,
                                height: illustrationHeight),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: Text(
                                body,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppColors.inkMuted),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) => AnimatedContainer(
                        duration: AppDurations.normal,
                        width: index == pageIndex ? 34 : 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index == pageIndex
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  EtzanPrimaryButton(
                    label: LocaleKeys.next.tr(context: context),
                    iconAsset: AppAssets.iconArrow,
                    onPressed: onNext,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: () => _continueAsGuest(context),
                    child:
                        Text(LocaleKeys.continueAsGuest.tr(context: context)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<AuthCubit>().signUp(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _continueAsGuest() => context.read<AuthCubit>().signInAsGuest();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else if (state is AuthExternalSignInStarted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_authMessage(context, state.message))));
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_authMessage(context, state.message))));
        }
      },
      builder: (context, state) => _AuthLayout(
        title: context.tr('signup'),
        subtitle: context.tr('startJourney'),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: context.tr('fullName'),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: EtzanAssetIcon(AppAssets.iconProfile,
                        color: AppColors.primaryDark),
                  ),
                ),
                validator: (value) => value == null || value.trim().length < 2
                    ? context.tr('fullName')
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: context.tr('email'),
                    prefixIcon: const Icon(Icons.alternate_email_rounded)),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : context.tr('email'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: context.tr('password'),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (value) => value != null && value.length >= 8
                    ? null
                    : context.tr('passwordTooShort'),
              ),
              const SizedBox(height: AppSpacing.lg),
              EtzanPrimaryButton(
                label: state is AuthLoading
                    ? context.tr('creatingAccount')
                    : context.tr('signup'),
                onPressed: state is AuthLoading ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                child: Text(LocaleKeys.login.tr(context: context)),
              ),
              TextButton(
                onPressed: state is AuthLoading ? null : _continueAsGuest,
                child: Text(
                  state is AuthLoading
                      ? LocaleKeys.continuingAsGuest.tr(context: context)
                      : LocaleKeys.continueAsGuest.tr(context: context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<AuthCubit>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _continueAsGuest() => context.read<AuthCubit>().signInAsGuest();

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.tr('enterEmailFirst'))));
      return;
    }
    await context.read<AuthCubit>().sendPasswordReset(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        } else if (state is AuthExternalSignInStarted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_authMessage(context, state.message))));
        } else if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('passwordResetLinkSent'))),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_authMessage(context, state.message))));
        }
      },
      builder: (context, state) => _AuthLayout(
        title: context.tr('welcomeBack'),
        subtitle: context.tr('tagline'),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: context.tr('email'),
                    prefixIcon: const Icon(Icons.alternate_email_rounded)),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : context.tr('email'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: context.tr('password'),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? context.tr('password')
                    : null,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                    onPressed: state is AuthLoading ? null : _resetPassword,
                    child: Text(context.tr('forgotPassword'))),
              ),
              const SizedBox(height: AppSpacing.sm),
              EtzanPrimaryButton(
                label: state is AuthLoading
                    ? context.tr('signingIn')
                    : context.tr('login'),
                onPressed: state is AuthLoading ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.signUp),
                child: Text(LocaleKeys.signup.tr(context: context)),
              ),
              TextButton(
                onPressed: state is AuthLoading ? null : _continueAsGuest,
                child: Text(
                  state is AuthLoading
                      ? LocaleKeys.continuingAsGuest.tr(context: context)
                      : LocaleKeys.continueAsGuest.tr(context: context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _authMessage(BuildContext context, String message) {
  return switch (message) {
    LocaleKeys.authSessionRefreshError ||
    LocaleKeys.unexpectedAuthError ||
    LocaleKeys.completeGoogleSignIn ||
    LocaleKeys.googleSignInStartError ||
    LocaleKeys.guestSignInError ||
    LocaleKeys.authSignUpFailed ||
    LocaleKeys.authSignUpLoginFailed ||
    LocaleKeys.authSignInFailed ||
    LocaleKeys.googleOpenError ||
    LocaleKeys.authTimeout ||
    LocaleKeys.signupTimeout ||
    LocaleKeys.googleTimeout =>
      message.tr(context: context),
    _ => message,
  };
}

class _AuthLayout extends StatelessWidget {
  const _AuthLayout(
      {required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final form = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const EtzanLogo(size: 72),
            const SizedBox(height: AppSpacing.md),
            Text(title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.inkMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            EtzanCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ],
        ),
      ),
    );

    return EtzanPage(
      child: Responsive.isPhone(context)
          ? form
          : Row(
              children: [
                const Expanded(
                    child: EtzanHeroIllustration(
                        asset: AppAssets.onboardingCoach, height: 460)),
                const SizedBox(width: AppSpacing.xxl),
                Expanded(child: Center(child: form)),
              ],
            ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .18),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: .16),
              blurRadius: 45,
              spreadRadius: 12),
        ],
      ),
    );
  }
}
