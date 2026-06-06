import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transport_record.dart';
import '../utils/app_theme.dart';
import 'stat_card.dart';

class RecordTile extends StatelessWidget {
  final TransportRecord record;
  final VoidCallback? onTap;
  final bool showDriver;

  const RecordTile({
    super.key,
    required this.record,
    this.onTap,
    this.showDriver = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.destination,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.client,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy', 'fr').format(record.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${record.fuelConsumption.toStringAsFixed(1)} L',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statusBadge(record),
                  const SizedBox(width: 8),
                  _bonBadge(record),
                  const SizedBox(width: 8),
                  _paletteBadge(record),
                ],
              ),
              if (showDriver) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      record.driverName,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
              if (record.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.notes,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        record.notes,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(TransportRecord r) {
    final color = r.mazotStatus == MazotStatus.nouveauPlein
        ? AppColors.success
        : AppColors.secondary;
    return StatusBadge(
        label: r.mazotStatus.label, color: color);
  }

  Widget _bonBadge(TransportRecord r) {
    final color = r.bonStatus == BonStatus.remis
        ? AppColors.success
        : AppColors.warning;
    return StatusBadge(label: r.bonStatus.label, color: color);
  }

  Widget _paletteBadge(TransportRecord r) {
    final color = r.paletteStatus == PaletteStatus.rendue
        ? AppColors.success
        : AppColors.accent;
    return StatusBadge(label: r.paletteStatus.label, color: color);
  }
}
