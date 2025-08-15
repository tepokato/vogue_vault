import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../utils/color_palette.dart';
import 'role_selection_page.dart';
import 'profile_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    if (auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text;
    final password = _passwordController.text;
    final auth = context.read<AuthService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    bool success = false;
    try {
      success = await auth.login(email, password);
      if (!success) {
        setState(() =>
            _error = AppLocalizations.of(context)!.invalidCredentials);
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Vogue Vault',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontFamily: 'LibertinusSans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                  const SizedBox(height: 16),
                  Image.asset('assets/images/VV_LOGO.webp', height: 200),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    style:
                        const TextStyle(color: AppColors.primary),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.emailLabel,
                      prefixIcon:
                          const Icon(Icons.email, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emailRequired;
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style:
                        const TextStyle(color: AppColors.primary),
                    cursorColor: AppColors.primary,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.passwordLabel,
                      prefixIcon:
                          const Icon(Icons.lock, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.passwordRequired;
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.loginButton),
                  ),
                  const SizedBox(height: 12),
                  // Use the primary brand color so the button stands out on
                  // the cream background.
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfilePage(isNewUser: true),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        Text(AppLocalizations.of(context)!.createAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

