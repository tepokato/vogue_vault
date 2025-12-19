import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../widgets/password_strength_indicator.dart';
import 'appointments_page.dart';
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
  bool _showPassword = false;

  bool _passwordMeetsRequirements(String password) {
    final hasMinLength = password.length >= 8;
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSymbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
    return hasMinLength && hasNumber && hasSymbol;
  }

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    if (auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppointmentsPage()),
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
        setState(
          () => _error = AppLocalizations.of(context)!.invalidCredentials,
        );
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppointmentsPage()),
      );
    }
  }

  Future<void> _showForgotPasswordSheet() async {
    final resetFormKey = GlobalKey<FormState>();
    final emailController =
        TextEditingController(text: _emailController.text.trim());
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final insets = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, insets + 24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: resetFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.resetPasswordTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!
                          .resetPasswordDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.emailLabel,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.emailRequired;
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return AppLocalizations.of(context)!
                              .invalidEmailFormat;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: !showNewPassword,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.newPasswordLabel,
                        helperText: AppLocalizations.of(context)!
                            .passwordRequirementsHint,
                        prefixIcon: const Icon(Icons.lock_reset),
                        suffixIcon: IconButton(
                          icon: Icon(showNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setModalState(
                            () => showNewPassword = !showNewPassword,
                          ),
                        ),
                      ),
                      onChanged: (_) => setModalState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.passwordRequired;
                        }
                        if (!_passwordMeetsRequirements(value)) {
                          return AppLocalizations.of(context)!
                              .passwordRequirementsHint;
                        }
                        return null;
                      },
                    ),
                    PasswordStrengthIndicator(
                      password: newPasswordController.text,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !showConfirmPassword,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.confirmPasswordLabel,
                        prefixIcon: const Icon(Icons.check),
                        suffixIcon: IconButton(
                          icon: Icon(showConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setModalState(
                            () => showConfirmPassword = !showConfirmPassword,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.passwordRequired;
                        }
                        if (value != newPasswordController.text) {
                          return AppLocalizations.of(context)!
                              .passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (!resetFormKey.currentState!.validate()) {
                          return;
                        }
                        final auth = context.read<AuthService>();
                        final email = emailController.text.trim();
                        final newPassword = newPasswordController.text;
                        final updated =
                            await auth.resetPassword(email, newPassword);
                        if (context.mounted) {
                          Navigator.of(context).pop(updated);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.resetPasswordButton,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (!mounted || success == null) return;
    if (success) {
      setState(() => _error = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.resetPasswordSuccessMessage),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.resetPasswordErrorMessage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              AppLocalizations.of(context)!.appTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Semantics(
                            label: AppLocalizations.of(context)!.appTitle,
                            image: true,
                            child: Image.asset(
                              'assets/images/VV_LOGO.webp',
                              height: 200,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.emailLabel,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.emailRequired;
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return AppLocalizations.of(context)!
                              .invalidEmailFormat;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.passwordLabel,
                        helperText: AppLocalizations.of(context)!
                            .passwordRequirementsHint,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.passwordRequired;
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordSheet,
                        child: Text(
                          AppLocalizations.of(context)!.forgotPasswordButton,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(AppLocalizations.of(context)!.loginButton),
                    ),
                    const SizedBox(height: 12),
                    // Style the button with the theme's primary color for
                    // contrast against the cream background.
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(isNewUser: true),
                          ),
                        );
                      },
                      child:
                          Text(AppLocalizations.of(context)!.createAccount),
                    ),
                  ],
                ),
              ),
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
