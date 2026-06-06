import 'package:cloud_firestore/cloud_firestore.dart';

enum MazotStatus { nouveauPlein, enPlein }
enum BonStatus { enAttente, remis }
enum PaletteStatus { rendue, enAttente }

extension MazotStatusExt on MazotStatus {
  String get label {
    switch (this) {
      case MazotStatus.nouveauPlein: return 'Nouveau plein';
      case MazotStatus.enPlein: return 'En plein';
    }
  }
  static MazotStatus fromString(String s) {
    return MazotStatus.values.firstWhere((e) => e.name == s, orElse: () => MazotStatus.nouveauPlein);
  }
}

extension BonStatusExt on BonStatus {
  String get label {
    switch (this) {
      case BonStatus.enAttente: return 'En attente';
      case BonStatus.remis: return 'Remis';
    }
  }
  static BonStatus fromString(String s) {
    return BonStatus.values.firstWhere((e) => e.name == s, orElse: () => BonStatus.enAttente);
  }
}

extension PaletteStatusExt on PaletteStatus {
  String get label {
    switch (this) {
      case PaletteStatus.rendue: return 'Rendue';
      case PaletteStatus.enAttente: return 'En attente';
    }
  }
  static PaletteStatus fromString(String s) {
    return PaletteStatus.values.firstWhere((e) => e.name == s, orElse: () => PaletteStatus.enAttente);
  }
}

class TransportRecord {
  final String? id;
  final String driverId;
  final String driverName;
  final DateTime date;
  final String destination;
  final String client;
  final MazotStatus mazotStatus;
  final BonStatus bonStatus;
  final PaletteStatus paletteStatus;
  final double fuelConsumption;
  final String notes;
  final DateTime createdAt;

  TransportRecord({
    this.id,
    required this.driverId,
    required this.driverName,
    required this.date,
    required this.destination,
    required this.client,
    required this.mazotStatus,
    required this.bonStatus,
    required this.paletteStatus,
    required this.fuelConsumption,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'date': Timestamp.fromDate(date),
      'destination': destination,
      'client': client,
      'mazotStatus': mazotStatus.name,
      'bonStatus': bonStatus.name,
      'paletteStatus': paletteStatus.name,
      'fuelConsumption': fuelConsumption,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TransportRecord.fromMap(Map<String, dynamic> map, String id) {
    return TransportRecord(
      id: id,
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      destination: map['destination'] ?? '',
      client: map['client'] ?? '',
      mazotStatus: MazotStatusExt.fromString(map['mazotStatus'] ?? ''),
      bonStatus: BonStatusExt.fromString(map['bonStatus'] ?? ''),
      paletteStatus: PaletteStatusExt.fromString(map['paletteStatus'] ?? ''),
      fuelConsumption: (map['fuelConsumption'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory TransportRecord.fromDocument(DocumentSnapshot doc) {
    return TransportRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  TransportRecord copyWith({
    String? id,
    String? driverId,
    String? driverName,
    DateTime? date,
    String? destination,
    String? client,
    MazotStatus? mazotStatus,
    BonStatus? bonStatus,
    PaletteStatus? paletteStatus,
    double? fuelConsumption,
    String? notes,
    DateTime? createdAt,
  }) {
    return TransportRecord(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      date: date ?? this.date,
      destination: destination ?? this.destination,
      client: client ?? this.client,
      mazotStatus: mazotStatus ?? this.mazotStatus,
      bonStatus: bonStatus ?? this.bonStatus,
      paletteStatus: paletteStatus ?? this.paletteStatus,
      fuelConsumption: fuelConsumption ?? this.fuelConsumption,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
