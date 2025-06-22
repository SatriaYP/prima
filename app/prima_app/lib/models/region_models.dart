class Province {
  final int id;
  final String name;
  final String code;

  Province({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
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

class City {
  final int id;
  final int provinceId;
  final String name;
  final String code;

  City({
    required this.id,
    required this.provinceId,
    required this.name,
    required this.code,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      provinceId: json['province_id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province_id': provinceId,
      'name': name,
      'code': code,
    };
  }
}

class District {
  final int id;
  final int cityId;
  final String name;
  final String code;

  District({
    required this.id,
    required this.cityId,
    required this.name,
    required this.code,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      cityId: json['city_id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'name': name,
      'code': code,
    };
  }
}

class Village {
  final int id;
  final int districtId;
  final String name;
  final String code;

  Village({
    required this.id,
    required this.districtId,
    required this.name,
    required this.code,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'],
      districtId: json['district_id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district_id': districtId,
      'name': name,
      'code': code,
    };
  }
}

class RegionData {
  final List<Province> provinces;
  final List<City> cities;
  final List<District> districts;
  final List<Village> villages;

  RegionData({
    required this.provinces,
    required this.cities,
    required this.districts,
    this.villages = const [],
  });

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      provinces: (json['provinces'] as List)
          .map((province) => Province.fromJson(province))
          .toList(),
      cities: (json['cities'] as List)
          .map((city) => City.fromJson(city))
          .toList(),
      districts: (json['districts'] as List)
          .map((district) => District.fromJson(district))
          .toList(),
      villages: json.containsKey('villages') && json['villages'] is List
          ? (json['villages'] as List)
              .map((village) => Village.fromJson(village))
              .toList()
          : [],
    );
  }

  // Helper methods to filter regions
  List<City> getCitiesByProvinceId(int provinceId) {
    return cities.where((city) => city.provinceId == provinceId).toList();
  }

  List<District> getDistrictsByCityId(int cityId) {
    return districts.where((district) => district.cityId == cityId).toList();
  }
  
  List<Village> getVillagesByDistrictId(int districtId) {
    return villages.where((village) => village.districtId == districtId).toList();
  }

  // Find region names by ID
  String getProvinceNameById(int id) {
    final province = provinces.firstWhere(
      (province) => province.id == id,
      orElse: () => Province(id: 0, name: 'Unknown', code: '00'),
    );
    return province.name;
  }

  String getCityNameById(int id) {
    final city = cities.firstWhere(
      (city) => city.id == id,
      orElse: () => City(id: 0, provinceId: 0, name: 'Unknown', code: '00'),
    );
    return city.name;
  }

  String getDistrictNameById(int id) {
    final district = districts.firstWhere(
      (district) => district.id == id,
      orElse: () => District(id: 0, cityId: 0, name: 'Unknown', code: '00'),
    );
    return district.name;
  }
  
  String getVillageNameById(int id) {
    final village = villages.firstWhere(
      (village) => village.id == id,
      orElse: () => Village(id: 0, districtId: 0, name: 'Unknown', code: '00'),
    );
    return village.name;
  }
}
