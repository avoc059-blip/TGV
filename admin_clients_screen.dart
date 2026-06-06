import 'package:flutter/material.dart';
import '../../models/transport_record.dart';
import '../../services/transport_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/record_tile.dart';
import '../driver/record_detail_screen.dart';

class AdminClientsScreen extends StatefulWidget {
  const AdminClientsScreen({super.key});

  @override
  State<AdminClientsScreen> createState() => _AdminClientsScreenState();
}

class _AdminClientsScreenState extends State<AdminClientsScreen> {
  final TransportService _service = TransportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
          title: const Text('Clients'), automaticallyImplyLeading: false),
      body: StreamBuilder<List<TransportRecord>>(
        stream: _service.streamAllRecords(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snap.data!;
          // Group by client
          final Map<String, List<TransportRecord>> clientMap = {};
          for (var r in records) {
            clientMap.putIfAbsent(r.client, () => []).add(r);
          }
          final clients = clientMap.keys.toList()..sort();

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text('Aucun client',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (ctx, i) {
              final client = clients[i];
              final recs = clientMap[client]!;
              final totalFuel = recs.fold<double>(
                  0, (sum, r) => sum + r.fuelConsumption);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.business,
                        color: AppColors.secondary),
                  ),
                  title: Text(client,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: Text(
                      '${recs.length} livraison(s) • ${totalFuel.toStringAsFixed(0)}L carburant',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  children: recs
                      .map((r) => Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            child: RecordTile(
                              record: r,
                              showDriver: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RecordDetailScreen(record: r),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
