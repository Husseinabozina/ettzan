import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:etzan_life_coaching/core/design_system/app_assets.dart';
import 'package:etzan_life_coaching/core/design_system/app_colors.dart';
import 'package:etzan_life_coaching/core/design_system/app_tokens.dart';
import 'package:etzan_life_coaching/core/localization/generated/locale_keys.g.dart';
import 'package:etzan_life_coaching/core/navigation/app_routes.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_asset_icon.dart';
import 'package:etzan_life_coaching/core/widgets/etzan_components.dart';
import 'package:etzan_life_coaching/features/auth/presentation/components/auth_layout.dart';
import 'package:etzan_life_coaching/features/auth/presentation/components/auth_message.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:etzan_life_coaching/features/auth/presentation/cubit/auth_state.dart';

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
  bool _signingUp = false;
  bool _guestLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _signingUp = true);
    try {
      await context.read<AuthCubit>().signUp(
            fullName: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
    } finally {
      if (mounted) setState(() => _signingUp = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() => _guestLoading = true);
    try {
      await context.read<AuthCubit>().signInAsGuest();
    } finally {
      if (mounted) setState(() => _guestLoading = false);
    }
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
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authMessage(context, state.message)),
            ),
          );
        }
      },
      builder: (context, state) => AuthLayout(
        title: LocaleKeys.signup.tr(context: context),
        subtitle: LocaleKeys.startJourney.tr(context: context),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: LocaleKeys.fullName.tr(context: context),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: EtzanAssetIcon(AppAssets.iconProfile,
                        color: AppColors.primaryDark),
                  ),
                ),
                validator: (value) => value == null || value.trim().length < 2
                    ? LocaleKeys.fullName.tr(context: context)
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
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
                validator: (value) => value != null && value.length >= 8
                    ? null
                    : LocaleKeys.passwordTooShort.tr(context: context),
              ),
              const SizedBox(height: AppSpacing.lg),
              EtzanPrimaryButton(
                label: _signingUp
                    ? LocaleKeys.creatingAccount.tr(context: context)
                    : LocaleKeys.signup.tr(context: context),
                onPressed: _signingUp ? null : _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                child: Text(LocaleKeys.login.tr(context: context)),
              ),
              TextButton(
                onPressed: _guestLoading ? null : _continueAsGuest,
                child: Text(
                  _guestLoading
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
