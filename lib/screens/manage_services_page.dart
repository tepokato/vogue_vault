import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../l10n/app_localizations.dart';
import '../models/service_offering.dart';
import '../services/appointment_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/service_offering_editor.dart';
import '../widgets/ui/ui.dart';

/// Page allowing professionals to manage their service offerings.
class ManageServicesPage extends StatefulWidget {
  const ManageServicesPage({super.key, required this.userId});

  final String userId;

  @override
  State<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  final _formKey = GlobalKey<FormState>();
  final _editorKey = GlobalKey<ServiceOfferingEditorState>();
  late List<ServiceOffering> _offerings;
  late String _userId;

  @override
  void initState() {
    super.initState();
    final service = context.read<AppointmentService>();
    _userId = widget.userId;
    final user = service.getUser(_userId);
    _offerings = [...(user?.offerings ?? <ServiceOffering>[])];
  }

  Future<void> _save() async {
    if (!(_editorKey.currentState?.validate() ?? false)) return;
    final service = context.read<AppointmentService>();
    final user = service.getUser(_userId);
    if (user != null) {
      await service.updateUser(user.copyWith(offerings: _offerings));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.manageServicesTitle,
      showProfileButton: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.space,
          AppTokens.spaceSm,
          AppTokens.space,
          AppTokens.spaceXl,
        ),
        children: [
          AppCard(
            child: Form(
              key: _formKey,
              child: ServiceOfferingEditor(
                key: _editorKey,
                offerings: _offerings,
                onChanged: (list) => setState(() => _offerings = list),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          FilledButton(
            onPressed: _save,
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    );
  }
}
