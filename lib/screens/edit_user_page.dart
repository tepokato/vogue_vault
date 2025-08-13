import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../services/role_provider.dart';
import '../utils/image_picking.dart';

class EditUserPage extends StatelessWidget {
  const EditUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().selectedRole;
    final service = context.watch<AppointmentService>();
    final users = service.users;

    if (role != UserRole.professional) {
      return Scaffold(
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.professionalsOnlyMessage,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.usersTooltip),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final roleText = user.roles.map((r) => r.name).join(', ');
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user.photoBytes != null
                  ? MemoryImage(user.photoBytes!)
                  : null,
              child: user.photoBytes == null || user.photoBytes!.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(user.name),
            subtitle: Text(roleText),
            onTap: () => _showUserDialog(context, user: user),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => service.deleteUser(user.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showUserDialog(BuildContext context, {UserProfile? user}) async {
    final nameController = TextEditingController(text: user?.name ?? '');
    final formKey = GlobalKey<FormState>();
    Uint8List? photoBytes = user?.photoBytes;
    final roles = <UserRole>{...user?.roles ?? {}};
    final selectedServices = <ServiceType>{...user?.services ?? {}};

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(user == null
                ? AppLocalizations.of(context)!.newUserTitle
                : AppLocalizations.of(context)!.editUserTitle),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!isImagePickerSupported) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AppLocalizations.of(context)!
                                    .imageSelectionUnsupported),
                          ),
                        );
                        return;
                      }
                      final bytes = await pickImageBytes();
                      if (bytes != null) {
                        setState(() => photoBytes = bytes);
                      }
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: photoBytes != null
                          ? MemoryImage(photoBytes!)
                          : null,
                      child: photoBytes == null || photoBytes!.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context)!.nameLabel),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? AppLocalizations.of(context)!.nameRequired
                        : null,
                  ),
                  CheckboxListTile(
                    value: roles.contains(UserRole.customer),
                    title: Text(AppLocalizations.of(context)!.customerRole),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          roles.add(UserRole.customer);
                        } else {
                          roles.remove(UserRole.customer);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    value: roles.contains(UserRole.professional),
                    title: Text(AppLocalizations.of(context)!.professionalRole),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          roles.add(UserRole.professional);
                        } else {
                          roles.remove(UserRole.professional);
                        }
                      });
                    },
                  ),
                  if (roles.contains(UserRole.professional))
                    ...ServiceType.values.map(
                      (s) => CheckboxListTile(
                        value: selectedServices.contains(s),
                        title: Text(s.name),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedServices.add(s);
                            } else {
                              selectedServices.remove(s);
                            }
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate() || roles.isEmpty) return;
                  if (roles.contains(UserRole.professional) &&
                      selectedServices.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .selectAtLeastOneService),
                        ),
                      );
                    return;
                  }
                  final service = context.read<AppointmentService>();
                  final id = user?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString();
                  final newUser = UserProfile(
                    id: id,
                    name: nameController.text,
                    photoBytes: photoBytes,
                    roles: roles,
                    services: roles.contains(UserRole.professional)
                        ? selectedServices
                        : <ServiceType>{},
                  );
                  if (user == null) {
                    await service.addUser(newUser);
                  } else {
                    await service.updateUser(newUser);
                  }
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.saveButton),
              ),
            ],
          );
        },
      ),
    );
    nameController.dispose();
  }
}
