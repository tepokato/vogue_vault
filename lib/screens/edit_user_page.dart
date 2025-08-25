import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vogue_vault/l10n/app_localizations.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../services/appointment_service.dart';
import '../services/auth_service.dart';
import '../utils/image_picking.dart';
import 'profile_page.dart';

class EditUserPage extends StatelessWidget {
  const EditUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppointmentService>();
    final users = service.users;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.usersTooltip),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final currentUser = context.watch<AuthService>().currentUser;
          final roleText =
              AppLocalizations.of(context)!.professionalRole;
          final isSelf = user.id == currentUser;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user.photoBytes != null
                  ? MemoryImage(user.photoBytes!)
                  : null,
              child: user.photoBytes == null || user.photoBytes!.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(user.fullName),
            subtitle: Text(roleText),
            onTap: () => _showUserDialog(context, user: user),
            trailing: isSelf
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: null,
                    tooltip: AppLocalizations.of(context)!
                        .cannotDeleteSelfTooltip,
                  )
                : IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        await service.deleteUser(user.id);
                        await context.read<AuthService>().deleteUser(user.id);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!
                                  .deleteUserFailed,
                            ),
                          ),
                        );
                      }
                    },
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
    final firstNameController =
        TextEditingController(text: user?.firstName ?? '');
    final lastNameController =
        TextEditingController(text: user?.lastName ?? '');
    final nicknameController =
        TextEditingController(text: user?.nickname ?? '');
    final formKey = GlobalKey<FormState>();
    Uint8List? photoBytes = user?.photoBytes;

    try {
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
                child: SingleChildScrollView(
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
                        controller: firstNameController,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.firstNameLabel),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? AppLocalizations.of(context)!
                                    .firstNameRequired
                                : null,
                      ),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.lastNameLabel),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? AppLocalizations.of(context)!
                                    .lastNameRequired
                                : null,
                      ),
                      TextFormField(
                        controller: nicknameController,
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.nicknameLabel),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfilePage(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.servicesTitle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancelButton),
                ),
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    final service = context.read<AppointmentService>();
                    final id =
                        user?.id ?? const Uuid().v4();
                    final newUser = UserProfile(
                      id: id,
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      nickname: nicknameController.text.trim().isEmpty
                          ? null
                          : nicknameController.text.trim(),
                      photoBytes: photoBytes,
                      roles: const {UserRole.professional},
                      offerings: user?.offerings,
                    );
                    if (user == null) {
                      await service.addUser(newUser);
                    } else {
                      await service.updateUser(newUser);
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.saveButton),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      firstNameController.dispose();
      lastNameController.dispose();
      nicknameController.dispose();
    }
  }

}
