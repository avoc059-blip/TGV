import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transport_record.dart';
import '../../services/transport_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../driver/add_record_screen.dart';

class RecordDetailScreen extends StatelessWidget {
  final TransportRecord record;
  final bool canEdit;
  const RecordDetailScreen(
      {super.key, required this.record, this.canEdit = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Détails Transport'),
        actions: canEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddRecordScreen(existingRecord: record),
                    ),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () => _confirmDelete(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoCard(context),
            const SizedBox(height: 16),
            _statusCard(),
            const SizedBox(height: 16),
            _fuelCard(),
            if (record.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _notesCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.local_shipping,
                      color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.destination,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(record.client,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoRow(Icons.calendar_today_outlined, 'Date',
                DateFormat('dd MMMM yyyy', 'fr').format(record.date)),
            const SizedBox(height: 12),
            _infoRow(Icons.person_outline, 'Chauffeur', record.driverName),
            const SizedBox(height: 12),
            _infoRow(Icons.access_time_outlined, 'Enregistré le',
                DateFormat('dd/MM/yyyy à HH:mm').format(record.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statuts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _statusRow('Mazot', record.mazotStatus.label,
                record.mazotStatus == MazotStatus.nouveauPlein
                    ? AppColors.success
                    : AppColors.secondary),
            const Divider(height: 24),
            _statusRow(
                'Bon',
                record.bonStatus.label,
                record.bonStatus == BonStatus.remis
                    ? AppColors.success
                    : AppColors.warning),
            const Divider(height: 24),
            _statusRow(
                'Palette',
                record.paletteStatus.label,
                record.paletteStatus == PaletteStatus.rendue
                    ? AppColors.success
                    : AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _fuelCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_gas_station,
                  color: AppColors.secondary, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consommation carburant',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${record.fuelConsumption.toStringAsFixed(1)} L',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _notesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notes, color: AppColors.textSecondary, size: 18),
                SizedBox(width: 8),
                Text('Notes',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            Text(record.notes,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _statusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
        StatusBadge(label: value, color: color),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce transport?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = TransportService();
              await service.deleteRecord(record.id!);
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
