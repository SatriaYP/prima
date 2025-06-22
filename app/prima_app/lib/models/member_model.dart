class Member {
  final int id;
  final String ktaNumber;
  final String nik;
  final String name;
  final String gender;
  final String birthPlace;
  final String birthDate;
  final String address;
  final int provinceId;
  final int cityId;
  final int districtId;
  final String phone;
  final String email;
  final String? ktpImageUrl;
  final String? ktaPdfUrl;
  final String registrationDate;
  final String status;
  final int createdBy;

  Member({
    required this.id,
    required this.ktaNumber,
    required this.nik,
    required this.name,
    required this.gender,
    required this.birthPlace,
    required this.birthDate,
    required this.address,
    required this.provinceId,
    required this.cityId,
    required this.districtId,
    required this.phone,
    required this.email,
    this.ktpImageUrl,
    this.ktaPdfUrl,
    required this.registrationDate,
    required this.status,
    required this.createdBy,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      ktaNumber: json['kta_number'],
      nik: json['nik'],
      name: json['name'],
      gender: json['gender'],
      birthPlace: json['birth_place'],
      birthDate: json['birth_date'],
      address: json['address'],
      provinceId: json['province_id'],
      cityId: json['city_id'],
      districtId: json['district_id'],
      phone: json['phone'],
      email: json['email'],
      ktpImageUrl: json['ktp_image_url'],
      ktaPdfUrl: json['kta_pdf_url'],
      registrationDate: json['registration_date'],
      status: json['status'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kta_number': ktaNumber,
      'nik': nik,
      'name': name,
      'gender': gender,
      'birth_place': birthPlace,
      'birth_date': birthDate,
      'address': address,
      'province_id': provinceId,
      'city_id': cityId,
      'district_id': districtId,
      'phone': phone,
      'email': email,
      'ktp_image_url': ktpImageUrl,
      'kta_pdf_url': ktaPdfUrl,
      'registration_date': registrationDate,
      'status': status,
      'created_by': createdBy,
    };
  }

  // Create a copy of this member with modified fields
  Member copyWith({
    int? id,
    String? ktaNumber,
    String? nik,
    String? name,
    String? gender,
    String? birthPlace,
    String? birthDate,
    String? address,
    int? provinceId,
    int? cityId,
    int? districtId,
    String? phone,
    String? email,
    String? ktpImageUrl,
    String? ktaPdfUrl,
    String? registrationDate,
    String? status,
    int? createdBy,
  }) {
    return Member(
      id: id ?? this.id,
      ktaNumber: ktaNumber ?? this.ktaNumber,
      nik: nik ?? this.nik,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      provinceId: provinceId ?? this.provinceId,
      cityId: cityId ?? this.cityId,
      districtId: districtId ?? this.districtId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      ktpImageUrl: ktpImageUrl ?? this.ktpImageUrl,
      ktaPdfUrl: ktaPdfUrl ?? this.ktaPdfUrl,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
