import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transport_record.dart';

class TransportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference get _collection =>
      _firestore.collection('transport_records');

  // Create
  Future<String> addRecord(TransportRecord record) async {
    final docRef = await _collection.add(record.toMap());
    return docRef.id;
  }

  // Update
  Future<void> updateRecord(TransportRecord record) async {
    if (record.id == null) throw Exception('Record ID is required for update');
    await _collection.doc(record.id).update(record.toMap());
  }

  // Delete
  Future<void> deleteRecord(String id) async {
    await _collection.doc(id).delete();
  }

  // Get single record
  Future<TransportRecord?> getRecord(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return TransportRecord.fromDocument(doc);
  }

  // Stream all records (admin)
  Stream<List<TransportRecord>> streamAllRecords() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TransportRecord.fromDocument(d)).toList());
  }

  // Stream records by driver
  Stream<List<TransportRecord>> streamDriverRecords(String driverId) {
    return _collection
        .where('driverId', isEqualTo: driverId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TransportRecord.fromDocument(d)).toList());
  }

  // Get records with filters
  Future<List<TransportRecord>> getFilteredRecords({
    String? clientFilter,
    String? destinationFilter,
    String? driverFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    Query query = _collection.orderBy('date', descending: true);

    if (clientFilter != null && clientFilter.isNotEmpty) {
      query = query.where('client', isEqualTo: clientFilter);
    }
    if (destinationFilter != null && destinationFilter.isNotEmpty) {
      query = query.where('destination', isEqualTo: destinationFilter);
    }
    if (driverFilter != null && driverFilter.isNotEmpty) {
      query = query.where('driverId', isEqualTo: driverFilter);
    }
    if (dateFrom != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dateFrom));
    }
    if (dateTo != null) {
      query = query.where('date',
          isLessThanOrEqualTo: Timestamp.fromDate(dateTo));
    }

    final snap = await query.get();
    return snap.docs.map((d) => TransportRecord.fromDocument(d)).toList();
  }

  // Dashboard stats
  Future<DashboardStats> getDashboardStats({String? driverId}) async {
    Query query = _collection;
    if (driverId != null) {
      query = query.where('driverId', isEqualTo: driverId);
    }

    final snap = await query.get();
    final records =
        snap.docs.map((d) => TransportRecord.fromDocument(d)).toList();

    final totalDeliveries = records.length;
    final clients = records.map((r) => r.client).toSet();
    final totalClients = clients.length;
    final totalFuel =
        records.fold<double>(0, (sum, r) => sum + r.fuelConsumption);
    final pendingVouchers =
        records.where((r) => r.bonStatus == BonStatus.enAttente).length;
    final pendingPalettes =
        records.where((r) => r.paletteStatus == PaletteStatus.enAttente).length;

    return DashboardStats(
      totalDeliveries: totalDeliveries,
      totalClients: totalClients,
      totalFuelConsumption: totalFuel,
      pendingVouchers: pendingVouchers,
      pendingPalettes: pendingPalettes,
    );
  }

  // Get unique clients
  Future<List<String>> getUniqueClients() async {
    final snap = await _collection.get();
    final clients = snap.docs
        .map((d) => (d.data() as Map<String, dynamic>)['client'] as String? ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    clients.sort();
    return clients;
  }

  // Get unique destinations
  Future<List<String>> getUniqueDestinations() async {
    final snap = await _collection.get();
    final destinations = snap.docs
        .map((d) =>
            (d.data() as Map<String, dynamic>)['destination'] as String? ?? '')
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    destinations.sort();
    return destinations;
  }
}

class DashboardStats {
  final int totalDeliveries;
  final int totalClients;
  final double totalFuelConsumption;
  final int pendingVouchers;
  final int pendingPalettes;

  DashboardStats({
    required this.totalDeliveries,
    required this.totalClients,
    required this.totalFuelConsumption,
    required this.pendingVouchers,
    required this.pendingPalettes,
  });
}
