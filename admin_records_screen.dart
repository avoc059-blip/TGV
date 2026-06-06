import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transport_record.dart';
import '../../services/auth_service.dart';
import '../../services/transport_service.dart';
import '../../widgets/record_tile.dart';
import '../../utils/app_theme.dart';
import '../driver/record_detail_screen.dart';

class AdminRecordsScreen extends StatefulWidget {
  const AdminRecordsScreen({super.key});

  @override
  State<AdminRecordsScreen> createState() => _AdminRecordsScreenState();
}

class _AdminRecordsScreenState extends State<AdminRecordsScreen> {
  final TransportService _service = TransportService();
  final AuthService _authService = AuthService();

  String _searchQuery = '';
  String? _selectedClient;
  String? _selectedDestination;
  String? _selectedDriver;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  final _searchController = TextEditingController();

  List<String> _clients = [];
  List<String> _destinations = [];
  List<Map<String, String>> _drivers = [];

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    final clients = await _service.getUniqueClients();
    final destinations = await _service.getUniqueDestinations();
    final drivers = await _authService.getAllDrivers();
    if (mounted) {
      setState(() {
        _clients = clients;
        _destinations = destinations;
        _drivers = drivers
            .map((d) => {'id': d.uid, 'name': d.name})
            .toList();
      });
    }
  }

  bool get _hasFilters =>
      _selectedClient != null ||
      _selectedDestination != null ||
      _selectedDriver != null ||
      _dateFrom != null ||
      _dateTo != null;

  void _clearFilters() {
    setState(() {
      _selectedClient = null;
      _selectedDestination = null;
      _selectedDriver = null;
      _dateFrom = null;
      _dateTo = null;
    });
  }

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
        title: const Text('Tous les Transports'),
        automaticallyImplyLeading: false,
        actions: [
          if (_hasFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Effacer',
                  style: TextStyle(color: Colors.white70)),
            ),
          IconButton(
            icon: Badge(
              isLabelVisible: _hasFilters,
              child: const Icon(Icons.filter_list, color: Colors.white),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Rechercher destination, client, chauffeur...',
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
          if (_hasFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _filterChips(),
            ),
          Expanded(
            child: StreamBuilder<List<TransportRecord>>(
              stream: _service.streamAllRecords(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData) {
                  return const Center(child: Text('Aucun transport'));
                }

                var records = snap.data!;

                // Apply local filters
                if (_selectedClient != null) {
                  records = records
                      .where((r) => r.client == _selectedClient)
                      .toList();
                }
                if (_selectedDestination != null) {
                  records = records
                      .where((r) => r.destination == _selectedDestination)
                      .toList();
                }
                if (_selectedDriver != null) {
                  records = records
                      .where((r) => r.driverId == _selectedDriver)
                      .toList();
                }
                if (_dateFrom != null) {
                  records = records
                      .where((r) =>
                          r.date.isAfter(_dateFrom!.subtract(const Duration(days: 1))))
                      .toList();
                }
                if (_dateTo != null) {
                  records = records
                      .where((r) =>
                          r.date.isBefore(_dateTo!.add(const Duration(days: 1))))
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  records = records
                      .where((r) =>
                          r.destination.toLowerCase().contains(_searchQuery) ||
                          r.client.toLowerCase().contains(_searchQuery) ||
                          r.driverName.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.4)),
                        const SizedBox(height: 16),
                        const Text('Aucun résultat',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Text('${records.length} résultat(s)',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: records.length,
                        itemBuilder: (ctx, i) => RecordTile(
                          record: records[i],
                          showDriver: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordDetailScreen(
                                  record: records[i], canEdit: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (_selectedClient != null)
            _chip('Client: $_selectedClient',
                () => setState(() => _selectedClient = null)),
          if (_selectedDestination != null)
            _chip('Dest: $_selectedDestination',
                () => setState(() => _selectedDestination = null)),
          if (_selectedDriver != null)
            _chip(
                'Chauffeur: ${_drivers.firstWhere((d) => d['id'] == _selectedDriver, orElse: () => {'name': _selectedDriver!})['name']}',
                () => setState(() => _selectedDriver = null)),
          if (_dateFrom != null)
            _chip(
                'De: ${DateFormat('dd/MM/yy').format(_dateFrom!)}',
                () => setState(() => _dateFrom = null)),
          if (_dateTo != null)
            _chip(
                'À: ${DateFormat('dd/MM/yy').format(_dateTo!)}',
                () => setState(() => _dateTo = null)),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close,
                size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FilterSheet(
        clients: _clients,
        destinations: _destinations,
        drivers: _drivers,
        selectedClient: _selectedClient,
        selectedDestination: _selectedDestination,
        selectedDriver: _selectedDriver,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        onApply: (client, dest, driver, from, to) {
          setState(() {
            _selectedClient = client;
            _selectedDestination = dest;
            _selectedDriver = driver;
            _dateFrom = from;
            _dateTo = to;
          });
        },
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<String> clients;
  final List<String> destinations;
  final List<Map<String, String>> drivers;
  final String? selectedClient;
  final String? selectedDestination;
  final String? selectedDriver;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Function(String?, String?, String?, DateTime?, DateTime?) onApply;

  const _FilterSheet({
    required this.clients,
    required this.destinations,
    required this.drivers,
    this.selectedClient,
    this.selectedDestination,
    this.selectedDriver,
    this.dateFrom,
    this.dateTo,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _client;
  String? _destination;
  String? _driver;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    _client = widget.selectedClient;
    _destination = widget.selectedDestination;
    _driver = widget.selectedDriver;
    _from = widget.dateFrom;
    _to = widget.dateTo;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('Filtres',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _client = null;
                    _destination = null;
                    _driver = null;
                    _from = null;
                    _to = null;
                  });
                },
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _dropdown('Client', widget.clients, _client,
              (v) => setState(() => _client = v)),
          const SizedBox(height: 12),
          _dropdown('Destination', widget.destinations, _destination,
              (v) => setState(() => _destination = v)),
          const SizedBox(height: 12),
          _driverDropdown(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _dateTile('De',
                      _from, (d) => setState(() => _from = d))),
              const SizedBox(width: 12),
              Expanded(
                  child: _dateTile('À', _to,
                      (d) => setState(() => _to = d))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_client, _destination, _driver, _from, _to);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Appliquer les filtres',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, List<String> options, String? value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text('Tous les $label${label.toLowerCase().endsWith('e') ? 's' : ''}'),
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem(
            value: null,
            child: Text('Tous',
                style:
                    const TextStyle(color: AppColors.textSecondary))),
        ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
      ],
      onChanged: onChanged,
    );
  }

  Widget _driverDropdown() {
    return DropdownButtonFormField<String>(
      value: _driver,
      hint: const Text('Tous les chauffeurs'),
      decoration: const InputDecoration(labelText: 'Chauffeur'),
      items: [
        const DropdownMenuItem(
            value: null,
            child: Text('Tous',
                style: TextStyle(color: AppColors.textSecondary))),
        ...widget.drivers.map((d) =>
            DropdownMenuItem(value: d['id'], child: Text(d['name']!))),
      ],
      onChanged: (v) => setState(() => _driver = v),
    );
  }

  Widget _dateTile(String label, DateTime? date, ValueChanged<DateTime?> onChange) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) onChange(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date == null
                    ? label
                    : DateFormat('dd/MM/yy').format(date),
                style: TextStyle(
                  fontSize: 13,
                  color:
                      date == null ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: () => onChange(null),
                child: const Icon(Icons.close, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}
