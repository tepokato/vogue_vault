import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../models/service_type.dart';
import '../models/service_offering.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../services/role_provider.dart';
import '../utils/image_picking.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  TextEditingController? _nicknameController;

  Uint8List? _photoBytes;
  late String _userId;
  late Set<UserRole> _roles;
  late List<ServiceOffering> _offerings;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    final service = context.read<AppointmentService>();
    final roleProvider = context.read<RoleProvider>();
    _userId = auth.currentUser ?? DateTime.now().millisecondsSinceEpoch.toString();
    final user = service.getUser(_userId);
    _firstNameController.text = user?.firstName ?? '';
    _lastNameController.text = user?.lastName ?? '';
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
    _photoBytes = user?.photoBytes;
    _roles = {...(user?.roles ?? roleProvider.roles)};
    _offerings = [...(user?.offerings ?? <ServiceOffering>[])];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nicknameController?.dispose();
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
    if (_roles.contains(UserRole.professional) && _offerings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.selectAtLeastOneService),
        ),
      );
      return;
    }
    final service = context.read<AppointmentService>();
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
      offerings:
          _roles.contains(UserRole.professional) ? _offerings : <ServiceOffering>[],
    );
    await service.updateUser(user);
    if (mounted) {
      Navigator.pop(context);
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

  String _roleLabel(UserRole role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case UserRole.customer:
        return l10n.customerRole;
      case UserRole.professional:
        return l10n.professionalRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
      ),
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
                          label:
                              AppLocalizations.of(context)!.userPhotoLabel,
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
                          labelText:
                              AppLocalizations.of(context)!.firstNameLabel,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? AppLocalizations.of(context)!.firstNameRequired
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.lastNameLabel,
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? AppLocalizations.of(context)!.lastNameRequired
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nicknameController,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.nicknameLabel,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.rolesTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<UserRole>(
                segments: UserRole.values
                    .map((role) => ButtonSegment(
                        value: role, label: Text(_roleLabel(role))))
                    .toList(),
                multiSelectionEnabled: true,
                selected: _roles,
                onSelectionChanged: (selection) {
                  setState(() => _roles = selection);
                },
              ),
              const SizedBox(height: 24),
              if (_roles.contains(UserRole.professional)) ...[
                Text(AppLocalizations.of(context)!.servicesTitle,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Column(
                  children: [
                    for (int i = 0; i < _offerings.length; i++)
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<ServiceType>(
                              value: _offerings[i].type,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .serviceLabel),
                              items: ServiceType.values
                                  .map(
                                    (s) => DropdownMenuItem<ServiceType>(
                                      value: s,
                                      child: Text(s.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _offerings[i] =
                                      _offerings[i].copyWith(type: value);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: _offerings[i].name,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .nameLabel),
                              onChanged: (val) {
                                setState(() {
                                  _offerings[i] =
                                      _offerings[i].copyWith(name: val);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: _offerings[i].price.toString(),
                              decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.priceLabel),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (val) {
                                setState(() {
                                  _offerings[i] = _offerings[i].copyWith(
                                      price: double.tryParse(val) ?? 0);
                                });
                              },
                              validator: (val) => val == null ||
                                      double.tryParse(val) == null
                                  ? AppLocalizations.of(context)!.invalidPrice
                                  : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () {
                              setState(() {
                                _offerings.removeAt(i);
                              });
                            },
                          ),
                        ],
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _offerings.add(ServiceOffering(
                                type: ServiceType.values.first,
                                name: '',
                                price: 0));
                          });
                        },
                        icon: const Icon(Icons.add),
                        label:
                            Text(AppLocalizations.of(context)!.addButton),
                      ),
                    ),
                  ],
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

