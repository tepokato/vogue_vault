import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../models/service_type.dart';
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
  final _nameController = TextEditingController();

  Uint8List? _photoBytes;
  late String _userId;
  late Set<UserRole> _roles;
  late Set<ServiceType> _services;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    final service = context.read<AppointmentService>();
    final roleProvider = context.read<RoleProvider>();
    _userId = auth.currentUser ?? DateTime.now().millisecondsSinceEpoch.toString();
    final user = service.getUser(_userId);
    _nameController.text = user?.name ?? '';
    _photoBytes = user?.photoBytes;
    _roles = {...(user?.roles ?? roleProvider.roles)};
    _services = {...(user?.services ?? <ServiceType>{})};
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    final user = UserProfile(
      id: _userId,
      name: _nameController.text,
      photoBytes: _photoBytes,
      roles: _roles,
      services: _services,
    );
    await service.updateUser(user);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
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
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.nameLabel),
                        onChanged: (_) => setState(() {}),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? AppLocalizations.of(context)!.nameRequired
                            : null,
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
                        value: role, label: Text(role.name)))
                    .toList(),
                multiSelectionEnabled: true,
                selected: _roles,
                onSelectionChanged: (selection) {
                  setState(() => _roles = selection);
                },
              ),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.servicesTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ServiceType.values
                    .map((service) => FilterChip(
                          label: Text(service.name),
                          selected: _services.contains(service),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _services.add(service);
                              } else {
                                _services.remove(service);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
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

