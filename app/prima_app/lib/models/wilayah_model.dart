import 'dart:convert';

class Provinsi {
  final String id;
  final String name;
  final String code;

  Provinsi({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Provinsi.fromJson(Map<String, dynamic> json) {
    return Provinsi(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

class Kabupaten {
  final String id;
  final String provinsiId;
  final String name;
  final String code;

  Kabupaten({
    required this.id,
    required this.provinsiId,
    required this.name,
    required this.code,
  });

  factory Kabupaten.fromJson(Map<String, dynamic> json) {
    return Kabupaten(
      id: json['id'],
      provinsiId: json['provinsi_id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provinsi_id': provinsiId,
      'name': name,
      'code': code,
    };
  }
}

class Kecamatan {
  final String id;
  final String kabupatenId;
  final String name;
  final String code;

  Kecamatan({
    required this.id,
    required this.kabupatenId,
    required this.name,
    required this.code,
  });

  factory Kecamatan.fromJson(Map<String, dynamic> json) {
    return Kecamatan(
      id: json['id'],
      kabupatenId: json['kabupaten_id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kabupaten_id': kabupatenId,
      'name': name,
      'code': code,
    };
  }
}

class Kelurahan {
  final String id;
  final String kecamatanId;
  final String name;
  final String code;

  Kelurahan({
    required this.id,
    required this.kecamatanId,
    required this.name,
    required this.code,
  });

  factory Kelurahan.fromJson(Map<String, dynamic> json) {
    return Kelurahan(
      id: json['id'],
      kecamatanId: json['kecamatan_id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kecamatan_id': kecamatanId,
      'name': name,
      'code': code,
    };
  }
}
