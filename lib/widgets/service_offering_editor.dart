import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/service_offering.dart';
import '../models/service_type.dart';
import '../utils/service_type_utils.dart';

/// Editor widget for managing a list of [ServiceOffering] items.
///
/// Provides fields for selecting the service type, name and price along with
/// controls to add or remove offerings. Changes are reported via [onChanged].
class ServiceOfferingEditor extends StatefulWidget {
  /// Current offerings to display.
  final List<ServiceOffering> offerings;

  /// Callback invoked when the offerings change.
  final ValueChanged<List<ServiceOffering>> onChanged;

  const ServiceOfferingEditor({
    super.key,
    required this.offerings,
    required this.onChanged,
  });

  @override
  ServiceOfferingEditorState createState() => ServiceOfferingEditorState();
}

class ServiceOfferingEditorState extends State<ServiceOfferingEditor> {
  late List<ServiceOffering> _offerings;

  @override
  void initState() {
    super.initState();
    _offerings = [...widget.offerings];
  }

  @override
  void didUpdateWidget(covariant ServiceOfferingEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offerings != widget.offerings) {
      _offerings = [...widget.offerings];
    }
  }

  void _notify() => widget.onChanged(List.unmodifiable(_offerings));

  /// Validates all fields within the surrounding [Form].
  bool validate() => Form.of(context)?.validate() ?? false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        for (int i = 0; i < _offerings.length; i++)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ServiceType>(
                  value: _offerings[i].type,
                  decoration:
                      InputDecoration(labelText: l10n.serviceLabel),
                  items: ServiceType.values
                      .map(
                        (s) => DropdownMenuItem<ServiceType>(
                          value: s,
                          child: Text(serviceTypeLabel(context, s)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _offerings[i] = _offerings[i].copyWith(type: value);
                    });
                    _notify();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: _offerings[i].name,
                  decoration: InputDecoration(labelText: l10n.nameLabel),
                  onChanged: (val) {
                    setState(() {
                      _offerings[i] = _offerings[i].copyWith(name: val);
                    });
                    _notify();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: _offerings[i].price.toString(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    final parsed = double.tryParse(val);
                    setState(() {
                      _offerings[i] = _offerings[i]
                          .copyWith(price: parsed ?? _offerings[i].price);
                    });
                    _notify();
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.priceRequired;
                    }
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed <= 0) {
                      return l10n.invalidPrice;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: l10n.priceLabel,
                    hintText: l10n.priceExampleHint,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: _offerings[i].duration.inMinutes.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.durationMinutesLabel,
                    hintText: l10n.durationExampleHint,
                    helperText: l10n.durationHelperText,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    setState(() {
                      _offerings[i] = _offerings[i].copyWith(
                        duration: parsed != null
                            ? Duration(minutes: parsed)
                            : _offerings[i].duration,
                      );
                    });
                    _notify();
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.durationRequired;
                    }
                    final parsed = int.tryParse(val);
                    if (parsed == null || parsed <= 0) {
                      return l10n.invalidDuration;
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () {
                  setState(() {
                    _offerings.removeAt(i);
                  });
                  _notify();
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
                    type: ServiceType.values.first, name: '', price: 0));
              });
              _notify();
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.addButton),
          ),
        ),
      ],
    );
  }
}

