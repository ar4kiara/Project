enum DebtFlowType { pinjam, bayar }

class DebtEntry {
  const DebtEntry({
    required this.id,
    required this.contactName,
    required this.nominal,
    required this.flow,
    this.keterangan,
    this.jatuhTempo,
    required this.dibuatPada,
    this.diperbaruiPada,
  });

  final String id;
  final String contactName;
  final int nominal;
  final DebtFlowType flow;
  final String? keterangan;
  final DateTime? jatuhTempo;
  final DateTime dibuatPada;
  final DateTime? diperbaruiPada;

  bool get isPinjam => flow == DebtFlowType.pinjam;
  bool get isBayar => flow == DebtFlowType.bayar;

  DebtEntry copyWith({
    String? id,
    String? contactName,
    int? nominal,
    DebtFlowType? flow,
    String? keterangan,
    DateTime? jatuhTempo,
    DateTime? dibuatPada,
    DateTime? diperbaruiPada,
  }) {
    return DebtEntry(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      nominal: nominal ?? this.nominal,
      flow: flow ?? this.flow,
      keterangan: keterangan ?? this.keterangan,
      jatuhTempo: jatuhTempo ?? this.jatuhTempo,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactName': contactName,
      'nominal': nominal,
      'flow': flow.name,
      'keterangan': keterangan,
      'jatuhTempo': jatuhTempo?.millisecondsSinceEpoch,
      'dibuatPada': dibuatPada.millisecondsSinceEpoch,
      'diperbaruiPada': diperbaruiPada?.millisecondsSinceEpoch,
    };
  }

  factory DebtEntry.fromMap(Map<String, dynamic> map) {
    return DebtEntry(
      id: map['id'] as String,
      contactName: map['contactName'] as String,
      nominal: map['nominal'] as int,
      flow: DebtFlowType.values.firstWhere(
        (element) => element.name == map['flow'],
        orElse: () => DebtFlowType.pinjam,
      ),
      keterangan: map['keterangan'] as String?,
      jatuhTempo: map['jatuhTempo'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['jatuhTempo'] as int),
      dibuatPada:
          DateTime.fromMillisecondsSinceEpoch(map['dibuatPada'] as int),
      diperbaruiPada: map['diperbaruiPada'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['diperbaruiPada'] as int),
    );
  }
}

