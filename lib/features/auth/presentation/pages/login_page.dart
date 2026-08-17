import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/auth/presentation/components/auth_layout.dart';
import 'package:etzan_life_coaching/features/auth/presentation/components/auth_message.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_state.dart';

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
  bool _signingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _signingIn = true);
    try {
      await context.read<AuthCubit>().signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _continueAsGuest() => context.read<AuthCubit>().signInAsGuest();

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.enterEmailFirst.tr(context: context)),
        ),
      );
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
            SnackBar(
              content: Text(authMessage(context, state.message)),
            ),
          );
        } else if (state is AuthPasswordResetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(LocaleKeys.passwordResetLinkSent.tr(context: context)),
            ),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authMessage(context, state.message)),
            ),
          );
        }
      },
      builder: (context, state) => AuthLayout(
        title: LocaleKeys.welcomeBack.tr(context: context),
        subtitle: LocaleKeys.tagline.tr(context: context),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: LocaleKeys.email.tr(context: context),
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : LocaleKeys.email.tr(context: context),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: LocaleKeys.password.tr(context: context),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? LocaleKeys.password.tr(context: context)
                    : null,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: state is AuthLoading ? null : _resetPassword,
                  child: Text(
                    LocaleKeys.forgotPassword.tr(context: context),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              EtzanPrimaryButton(
                label: _signingIn
                    ? LocaleKeys.signingIn.tr(context: context)
                    : LocaleKeys.login.tr(context: context),
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
