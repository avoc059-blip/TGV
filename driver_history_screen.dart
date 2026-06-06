import 'package:flutter/material.dart';
import '../../models/transport_record.dart';
import '../../services/transport_service.dart';
import '../../widgets/record_tile.dart';
import '../../utils/app_theme.dart';
import 'add_record_screen.dart';
import 'record_detail_screen.dart';

class DriverHistoryScreen extends StatefulWidget {
  final String driverId;
  const DriverHistoryScreen({super.key, required this.driverId});

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  final TransportService _service = TransportService();
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mon Historique'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Rechercher destination, client...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TransportRecord>>(
              stream: _service.streamDriverRecords(widget.driverId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.isEmpty) {
                  return _emptyState();
                }

                var records = snap.data!;
                if (_searchQuery.isNotEmpty) {
                  records = records
                      .where((r) =>
                          r.destination.toLowerCase().contains(_searchQuery) ||
                          r.client.toLowerCase().contains(_searchQuery) ||
                          r.notes.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (records.isEmpty) {
                  return Center(
                    child: Text('Aucun résultat pour "$_searchQuery"',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: records.length,
                  itemBuilder: (ctx, i) => RecordTile(
                    record: records[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RecordDetailScreen(record: records[i], canEdit: true),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_outlined,
              size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'Aucun transport enregistré',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre premier transport\nen cliquant sur le bouton +',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
