import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transport_record.dart';
import '../../services/auth_provider.dart';
import '../../services/transport_service.dart';
import '../../utils/app_theme.dart';

class AddRecordScreen extends StatefulWidget {
  final TransportRecord? existingRecord;
  const AddRecordScreen({super.key, this.existingRecord});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _clientController = TextEditingController();
  final _fuelController = TextEditingController();
  final _notesController = TextEditingController();
  final _service = TransportService();

  DateTime _selectedDate = DateTime.now();
  MazotStatus _mazotStatus = MazotStatus.nouveauPlein;
  BonStatus _bonStatus = BonStatus.enAttente;
  PaletteStatus _paletteStatus = PaletteStatus.enAttente;
  bool _isLoading = false;

  bool get isEditing => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final r = widget.existingRecord!;
      _destinationController.text = r.destination;
      _clientController.text = r.client;
      _fuelController.text = r.fuelConsumption.toString();
      _notesController.text = r.notes;
      _selectedDate = r.date;
      _mazotStatus = r.mazotStatus;
      _bonStatus = r.bonStatus;
      _paletteStatus = r.paletteStatus;
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _clientController.dispose();
    _fuelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser!;
      final fuel = double.tryParse(_fuelController.text) ?? 0.0;

      if (isEditing) {
        final updated = widget.existingRecord!.copyWith(
          date: _selectedDate,
          destination: _destinationController.text.trim(),
          client: _clientController.text.trim(),
          mazotStatus: _mazotStatus,
          bonStatus: _bonStatus,
          paletteStatus: _paletteStatus,
          fuelConsumption: fuel,
          notes: _notesController.text.trim(),
        );
        await _service.updateRecord(updated);
      } else {
        final record = TransportRecord(
          driverId: user.uid,
          driverName: user.name,
          date: _selectedDate,
          destination: _destinationController.text.trim(),
          client: _clientController.text.trim(),
          mazotStatus: _mazotStatus,
          bonStatus: _bonStatus,
          paletteStatus: _paletteStatus,
          fuelConsumption: fuel,
          notes: _notesController.text.trim(),
        );
        await _service.addRecord(record);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isEditing ? 'Transport modifié !' : 'Transport enregistré !'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier Transport' : 'Nouveau Transport'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _section('Informations générales', [
                _datePicker(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Destination requise' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clientController,
                  decoration: const InputDecoration(
                    labelText: 'Client',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Client requis' : null,
                ),
              ]),
              const SizedBox(height: 20),
              _section('Statuts', [
                _radioGroup<MazotStatus>(
                  label: 'Statut Mazot',
                  value: _mazotStatus,
                  options: MazotStatus.values,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _mazotStatus = v!),
                ),
                const SizedBox(height: 16),
                _radioGroup<BonStatus>(
                  label: 'Statut Bon',
                  value: _bonStatus,
                  options: BonStatus.values,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _bonStatus = v!),
                ),
                const SizedBox(height: 16),
                _radioGroup<PaletteStatus>(
                  label: 'Statut Palette',
                  value: _paletteStatus,
                  options: PaletteStatus.values,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _paletteStatus = v!),
                ),
              ]),
              const SizedBox(height: 20),
              _section('Carburant & Notes', [
                TextFormField(
                  controller: _fuelController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Consommation carburant (L)',
                    prefixIcon: Icon(Icons.local_gas_station_outlined),
                    suffixText: 'L',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requis';
                    if (double.tryParse(v) == null) return 'Nombre invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
              ]),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          isEditing ? 'Enregistrer modifications' : 'Enregistrer Transport',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd MMMM yyyy', 'fr').format(_selectedDate),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _radioGroup<T>({
    required String label,
    required T value,
    required List<T> options,
    required String Function(T) labelOf,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final selected = value == opt;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(opt),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.secondary.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.secondary : AppColors.divider,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selected
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          labelOf(opt),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
