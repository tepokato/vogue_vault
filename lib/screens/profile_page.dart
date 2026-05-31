import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../app/theme.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../models/service_offering.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../utils/image_picking.dart';
import '../utils/service_type_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/main_shell.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/ui/ui.dart';
import 'auth_page.dart';
import 'manage_services_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.isNewUser = false});

  final bool isNewUser;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  TextEditingController? _nicknameController;
  late TextEditingController _emailController;
  final _currentPwdController = TextEditingController();
  final _newPwdController = TextEditingController();
  final _confirmPwdController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  Uint8List? _photoBytes;
  late String _userId;
  late Set<UserRole> _roles;
  late List<ServiceOffering> _offerings;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    final service = context.read<AppointmentService>();
    if (widget.isNewUser) {
      _userId = '';
      _emailController = TextEditingController();
      _nicknameController = TextEditingController(text: '');
      _photoBytes = null;
      _roles = {UserRole.professional};
      _offerings = <ServiceOffering>[];
    } else {
      _userId =
          auth.currentUser ?? DateTime.now().millisecondsSinceEpoch.toString();
      _emailController = TextEditingController(text: _userId);
      final user = service.getUser(_userId);
      _firstNameController.text = user?.firstName ?? '';
      _lastNameController.text = user?.lastName ?? '';
      _nicknameController = TextEditingController(text: user?.nickname ?? '');
      _photoBytes = user?.photoBytes;
      _roles = {UserRole.professional};
      _offerings = [...(user?.offerings ?? <ServiceOffering>[])];
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController?.dispose();
    _emailController.dispose();
    _currentPwdController.dispose();
    _newPwdController.dispose();
    _confirmPwdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final bytes = await pickImageBytes();
    if (bytes != null) {
      setState(() => _photoBytes = bytes);
    } else if (!isImagePickerSupported && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.imageSelectionUnsupported),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final service = context.read<AppointmentService>();
    final auth = context.read<AuthService>();
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (widget.isNewUser) {
      if (_newPwdController.text != _confirmPwdController.text) {
        if (mounted) _toast(l10n.passwordsDoNotMatch);
        return;
      }
      try {
        await auth.register(email, _newPwdController.text);
        _userId = email;
      } catch (e) {
        if (mounted) _toast(e.toString());
        return;
      }
    } else {
      if (email != _userId) {
        try {
          await auth.changeEmail(_userId, email);
          await service.renameUserId(_userId, email);
          _userId = email;
        } catch (e) {
          if (mounted) _toast(e.toString());
          return;
        }
      }
      if (_newPwdController.text.isNotEmpty ||
          _confirmPwdController.text.isNotEmpty ||
          _currentPwdController.text.isNotEmpty) {
        if (_newPwdController.text != _confirmPwdController.text) {
          if (mounted) _toast(l10n.passwordsDoNotMatch);
          return;
        }
        try {
          await auth.changePassword(
            _userId,
            _currentPwdController.text,
            _newPwdController.text,
          );
        } catch (e) {
          if (mounted) _toast(e.toString());
          return;
        }
      }
    }

    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final nicknameText = _nicknameController?.text.trim() ?? '';
    final user = UserProfile(
      id: _userId,
      firstName: first,
      lastName: last,
      nickname: nicknameText.isEmpty ? null : nicknameText,
      photoBytes: _photoBytes,
      roles: _roles,
      offerings: _roles.contains(UserRole.professional)
          ? _offerings
          : <ServiceOffering>[],
    );
    if (widget.isNewUser) {
      await service.addUser(user);
    } else {
      await service.updateUser(user);
    }
    if (!mounted) return;
    if (widget.isNewUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      _toast(l10n.changesSaved);
      Navigator.pop(context);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String get _initials {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (first.isEmpty && last.isEmpty) return '?';
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return (f + l).toUpperCase();
  }

  ServiceType? get _serviceType =>
      _offerings.isNotEmpty ? _offerings.first.type : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      title: l10n.profileTitle,
      showProfileButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: l10n.logoutTooltip,
          onPressed: () {
            context.read<AuthService>().logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthPage()),
              (route) => false,
            );
          },
        ),
      ],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.space,
            AppTokens.spaceSm,
            AppTokens.space,
            AppTokens.spaceXl,
          ),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Semantics(
                  label: l10n.userPhotoLabel,
                  image: true,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: scheme.primary.withOpacity(0.14),
                        backgroundImage: _photoBytes != null
                            ? MemoryImage(_photoBytes!)
                            : null,
                        child: _photoBytes == null || _photoBytes!.isEmpty
                            ? Text(
                                _initials,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: scheme.primary,
                                ),
                              )
                            : null,
                      ),
                      if (_serviceType != null)
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: serviceTypeColor(_serviceType!),
                            child: ImageIcon(
                              AssetImage(serviceTypeIcon(_serviceType!)),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: -2,
                        left: -2,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: scheme.primary,
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.spaceLg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        InputDecoration(labelText: l10n.firstNameLabel),
                    onChanged: (_) => setState(() {}),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.firstNameRequired
                        : null,
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: l10n.lastNameLabel),
                    onChanged: (_) => setState(() {}),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? l10n.lastNameRequired
                        : null,
                  ),
                  const SizedBox(height: AppTokens.spaceMd),
                  TextFormField(
                    controller: _nicknameController,
                    decoration: InputDecoration(labelText: l10n.nicknameLabel),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (v) => v == null ||
                            v.trim().isEmpty ||
                            !v.contains('@')
                        ? l10n.invalidEmail
                        : null,
                  ),
                  if (!widget.isNewUser) ...[
                    const SizedBox(height: AppTokens.spaceMd),
                    TextFormField(
                      controller: _currentPwdController,
                      obscureText: !_showCurrentPassword,
                      decoration: InputDecoration(
                        labelText: l10n.currentPasswordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_showCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() =>
                              _showCurrentPassword = !_showCurrentPassword),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTokens.spaceMd),
                  TextFormField(
                    controller: _newPwdController,
                    obscureText: !_showNewPassword,
                    decoration: InputDecoration(
                      labelText: l10n.newPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_showNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _showNewPassword = !_showNewPassword),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  PasswordStrengthIndicator(password: _newPwdController.text),
                  const SizedBox(height: AppTokens.spaceMd),
                  TextFormField(
                    controller: _confirmPwdController,
                    obscureText: !_showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isNewUser) ...[
              const SizedBox(height: AppTokens.space),
              AppCard(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageServicesPage(userId: _userId),
                    ),
                  );
                  if (!mounted) return;
                  final service = context.read<AppointmentService>();
                  setState(() {
                    _offerings = [...?service.getUser(_userId)?.offerings];
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.design_services_outlined, color: scheme.primary),
                    const SizedBox(width: AppTokens.spaceMd),
                    Expanded(
                      child: Text(l10n.servicesTitle,
                          style: theme.textTheme.titleSmall),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppTokens.spaceLg),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}
