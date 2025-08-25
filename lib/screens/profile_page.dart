import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../models/service_offering.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../utils/image_picking.dart';
import '../widgets/app_scaffold.dart';
import 'appointments_page.dart';
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
          content: Text(
            AppLocalizations.of(context)!.imageSelectionUnsupported,
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final service = context.read<AppointmentService>();
    final auth = context.read<AuthService>();
    final email = _emailController.text.trim();

    if (widget.isNewUser) {
      if (_newPwdController.text != _confirmPwdController.text) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
            ),
          );
        }
        return;
      }
      try {
        await auth.register(email, _newPwdController.text);
        _userId = email;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
        return;
      }
    } else {
      if (email != _userId) {
        try {
          await auth.changeEmail(_userId, email);
          await service.renameUserId(_userId, email);
          _userId = email;
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
          return;
        }
      }
      if (_newPwdController.text.isNotEmpty ||
          _confirmPwdController.text.isNotEmpty ||
          _currentPwdController.text.isNotEmpty) {
        if (_newPwdController.text != _confirmPwdController.text) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.passwordsDoNotMatch,
                ),
              ),
            );
          }
          return;
        }
        try {
          await auth.changePassword(
            _userId,
            _currentPwdController.text,
            _newPwdController.text,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
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
    if (mounted) {
      if (widget.isNewUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppointmentsPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.changesSaved)),
        );
        Navigator.pop(context);
      }
    }
  }

  String get _initials {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    if (first.isEmpty && last.isEmpty) return '?';
    final firstInitial = first.isNotEmpty ? first[0] : '';
    final lastInitial = last.isNotEmpty ? last[0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppLocalizations.of(context)!.profileTitle,
      showProfileButton: false,
      showHomeButton: !widget.isNewUser,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Semantics(
                          label: AppLocalizations.of(context)!.userPhotoLabel,
                          image: true,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: _photoBytes != null
                                ? MemoryImage(_photoBytes!)
                                : null,
                            child: _photoBytes == null || _photoBytes!.isEmpty
                                ? Text(_initials)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.firstNameLabel,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? AppLocalizations.of(context)!.firstNameRequired
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.lastNameLabel,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? AppLocalizations.of(context)!.lastNameRequired
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.nicknameLabel,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.emailLabel,
                        ),
                        validator: (value) =>
                            value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')
                            ? AppLocalizations.of(context)!.invalidEmail
                            : null,
                      ),
                      const SizedBox(height: 16),
                      if (!widget.isNewUser) ...[
                        TextFormField(
                          controller: _currentPwdController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.currentPasswordLabel,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showCurrentPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => _showCurrentPassword =
                                    !_showCurrentPassword,
                              ),
                            ),
                          ),
                          obscureText: !_showCurrentPassword,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _newPwdController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.newPasswordLabel,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _showNewPassword = !_showNewPassword,
                            ),
                          ),
                        ),
                        obscureText: !_showNewPassword,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPwdController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.confirmPasswordLabel,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () =>
                                  _showConfirmPassword = !_showConfirmPassword,
                            ),
                          ),
                        ),
                        obscureText: !_showConfirmPassword,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!widget.isNewUser) ...[
                ListTile(
                  title: Text(AppLocalizations.of(context)!.servicesTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageServicesPage(userId: _userId),
                      ),
                    );
                    final service = context.read<AppointmentService>();
                    setState(() {
                      _offerings =
                          [...?service.getUser(_userId)?.offerings];
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(AppLocalizations.of(context)!.saveButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
