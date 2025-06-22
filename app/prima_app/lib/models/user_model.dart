import 'unit_kepengurusan_model.dart';

class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final int unitKepengurusanId;
  final UnitKepengurusan? unitKepengurusan;
  
  // Legacy fields untuk backward compatibility
  final String? level;
  final String? regionCode;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    required this.unitKepengurusanId,
    this.unitKepengurusan,
    this.level,
    this.regionCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('User.fromJson called with: $json');
    
    // Check for null or missing values
    if (json['id'] == null) print('Warning: id is null');
    if (json['username'] == null) print('Warning: username is null');
    if (json['email'] == null) print('Warning: email is null');
    if (json['role'] == null) print('Warning: role is null');
    if (json['unit_kepengurusan_id'] == null) print('Warning: unit_kepengurusan_id is null');
    if (json['is_active'] == null) print('Warning: is_active is null');
    
    // Print the types of each field
    print('id type: ${json['id']?.runtimeType}');
    print('username type: ${json['username']?.runtimeType}');
    print('email type: ${json['email']?.runtimeType}');
    print('role type: ${json['role']?.runtimeType}');
    print('unit_kepengurusan_id type: ${json['unit_kepengurusan_id']?.runtimeType}');
    print('is_active type: ${json['is_active']?.runtimeType}');
    
    try {
      return User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        role: json['role'],
        unitKepengurusanId: json['unit_kepengurusan_id'] ?? 0,
        unitKepengurusan: json['unit_kepengurusan'] != null 
            ? UnitKepengurusan.fromJson(json['unit_kepengurusan']) 
            : null,
        // Legacy fields
        level: json['level'],
        regionCode: json['region_code'],
        isActive: json['is_active'] ?? false, // Provide default value for isActive
      );
    } catch (e) {
      print('Error creating User object: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'unit_kepengurusan_id': unitKepengurusanId,
      'unit_kepengurusan': unitKepengurusan?.toJson(),
      // Legacy fields
      'level': level,
      'region_code': regionCode,
      'is_active': isActive,
    };
  }

  // Check if user has admin privileges
  bool get isAdmin => role == 'admin';

  // Check if user is an operator
  bool get isOperator => role == 'operator';

  // Mendapatkan tingkat kepengurusan
  String? get tingkatName => unitKepengurusan?.tingkat?.name ?? level;

  // Check if user is at DPP level
  bool get isDpp => tingkatName == 'DPP' || (unitKepengurusan?.tingkat?.sequence == 4);

  // Check if user is at DPW level
  bool get isDpw => tingkatName == 'DPW' || (unitKepengurusan?.tingkat?.sequence == 3);

  // Check if user is at DPD level
  bool get isDpd => tingkatName == 'DPD' || (unitKepengurusan?.tingkat?.sequence == 2);

  // Check if user is at DPK level
  bool get isDpk => tingkatName == 'DPK' || (unitKepengurusan?.tingkat?.sequence == 1);

  // Check if user can create members
  bool get canCreateMembers => isAdmin || isOperator;

  // Check if user can edit members
  bool get canEditMembers => isAdmin || isOperator;

  // Check if user can delete members
  bool get canDeleteMembers => isAdmin;

  // Check if user can view all members (across regions)
  bool get canViewAllMembers => isDpp;

  // Check if user can view members in their region and below
  bool get canViewRegionalMembers => unitKepengurusan != null;

  // Check if user can approve new operators
  bool get canApproveOperators => isAdmin && (isDpp || isDpw);
  
  // Mendapatkan kode unit kepengurusan
  String get unitCode => unitKepengurusan?.code ?? regionCode ?? '';
  
  // Mendapatkan nama unit kepengurusan
  String get unitName => unitKepengurusan?.name ?? '';
}
