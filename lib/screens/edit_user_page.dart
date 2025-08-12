import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../models/service_type.dart';
import '../services/appointment_service.dart';
import '../services/role_provider.dart';

class EditUserPage extends StatelessWidget {
  const EditUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<RoleProvider>().selectedRole;
    final service = context.watch<AppointmentService>();
    final users = service.users;

    if (role != UserRole.professional) {
      return const Scaffold(
        body: Center(child: Text('Available only for professionals')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final roleText = user.roles.map((r) => r.name).join(', ');
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? FileImage(File(user.photoUrl!))
                  : null,
              child: user.photoUrl == null || user.photoUrl!.isEmpty
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
    String? photoUrl = user?.photoUrl;
    final picker = ImagePicker();
    final roles = <UserRole>{...user?.roles ?? {}};
    final selectedServices = <ServiceType>{...user?.services ?? {}};

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(user == null ? 'New User' : 'Edit User'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() => photoUrl = picked.path);
                      }
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                          ? FileImage(File(photoUrl!))
                          : null,
                      child: photoUrl == null || photoUrl!.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),
                  CheckboxListTile(
                    value: roles.contains(UserRole.customer),
                    title: const Text('Customer'),
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
                    title: const Text('Professional'),
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
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate() || roles.isEmpty) return;
                  if (roles.contains(UserRole.professional) &&
                      selectedServices.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one service'),
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
                    photoUrl: photoUrl,
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
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    nameController.dispose();
  }
}
