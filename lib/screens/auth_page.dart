import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../app/theme.dart';
import '../services/auth_service.dart';
import '../widgets/main_shell.dart';
import '../widgets/ui/ui.dart';
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

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    if (auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text;
    final password = _passwordController.text;
    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    bool success = false;
    try {
      success = await auth.login(email, password);
      if (!success) {
        setState(() => _error = l10n.invalidCredentials);
      }
    } finally {
      if (mounted) Navigator.of(context).pop();
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.spaceLg),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GradientHero(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.spaceLg,
                        vertical: AppTokens.spaceXl,
                      ),
                      child: Column(
                        children: [
                          Semantics(
                            label: l10n.appTitle,
                            image: true,
                            child: Image.asset(
                              'assets/images/VV_LOGO.webp',
                              height: 120,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AppTokens.space),
                          Semantics(
                            header: true,
                            child: Text(
                              l10n.appTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.spaceLg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: l10n.emailLabel,
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.emailRequired;
                              }
                              final emailRegex =
                                  RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return l10n.invalidEmailFormat;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTokens.spaceMd),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: l10n.passwordLabel,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty
                                    ? l10n.passwordRequired
                                    : null,
                          ),
                          const SizedBox(height: AppTokens.spaceSm),
                          Text(
                            l10n.localPasswordHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppTokens.spaceMd),
                            Text(
                              _error!,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: scheme.error),
                            ),
                          ],
                          const SizedBox(height: AppTokens.spaceLg),
                          FilledButton(
                            onPressed: _submit,
                            child: Text(l10n.loginButton),
                          ),
                          const SizedBox(height: AppTokens.spaceSm),
                          OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ProfilePage(isNewUser: true),
                              ),
                            ),
                            child: Text(l10n.createAccount),
                          ),
                        ],
                      ),
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
}
