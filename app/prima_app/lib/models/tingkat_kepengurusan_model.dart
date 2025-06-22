class TingkatKepengurusan {
  final int id;
  final String name;
  final int sequence;

  TingkatKepengurusan({
    required this.id,
    required this.name,
    required this.sequence,
  });

  factory TingkatKepengurusan.fromJson(Map<String, dynamic> json) {
    return TingkatKepengurusan(
      id: json['id'],
      name: json['name'],
      sequence: json['sequence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sequence': sequence,
    };
  }

  @override
  String toString() => name;
}
