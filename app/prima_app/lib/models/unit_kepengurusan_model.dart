import 'tingkat_kepengurusan_model.dart';

class UnitKepengurusan {
  final int id;
  final String name;
  final String code;
  final int? parentId;
  final int tingkatId;
  final TingkatKepengurusan? tingkat;
  final UnitKepengurusan? parent;
  List<UnitKepengurusan> children;

  UnitKepengurusan({
    required this.id,
    required this.name,
    required this.code,
    this.parentId,
    required this.tingkatId,
    this.tingkat,
    this.parent,
    this.children = const [],
  });

  factory UnitKepengurusan.fromJson(Map<String, dynamic> json) {
    return UnitKepengurusan(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      parentId: json['parent_id'],
      tingkatId: json['tingkat_id'],
      tingkat: json['tingkat'] != null 
          ? TingkatKepengurusan.fromJson(json['tingkat']) 
          : null,
      parent: json['parent'] != null 
          ? UnitKepengurusan.fromJson(json['parent']) 
          : null,
      children: json['children'] != null 
          ? List<UnitKepengurusan>.from(
              json['children'].map((x) => UnitKepengurusan.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'parent_id': parentId,
      'tingkat_id': tingkatId,
      'tingkat': tingkat?.toJson(),
      'parent': parent?.toJson(),
      'children': children.map((child) => child.toJson()).toList(),
    };
  }

  // Mendapatkan semua unit kepengurusan di bawahnya (rekursif)
  List<UnitKepengurusan> getAllChildren() {
    List<UnitKepengurusan> allChildren = [];
    for (var child in children) {
      allChildren.add(child);
      allChildren.addAll(child.getAllChildren());
    }
    return allChildren;
  }

  // Mendapatkan jalur dari root ke unit ini
  List<UnitKepengurusan> getPath() {
    List<UnitKepengurusan> path = [];
    UnitKepengurusan? current = this;
    while (current != null) {
      path.insert(0, current);
      current = current.parent;
    }
    return path;
  }

  // Memeriksa apakah unit ini adalah anak dari unit lain
  bool isChildOf(UnitKepengurusan other) {
    UnitKepengurusan? current = parent;
    while (current != null) {
      if (current.id == other.id) {
        return true;
      }
      current = current.parent;
    }
    return false;
  }

  @override
  String toString() => name;
}
