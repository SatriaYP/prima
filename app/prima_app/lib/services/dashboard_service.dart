import '../models/member_model.dart';
import '../api/api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  // Fetch dashboard statistics
  Future<Map<String, dynamic>> getStatistics() async {
    // In a real app, this would fetch statistics from the API
    // For now, we'll use mock data
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'total_members': 2,
      'gender_distribution': {'male': 1, 'female': 1},
      'regional_distribution': {
        '31': {
          'total': 2,
          'cities': {
            '3171': {
              'total': 2,
              'districts': {
                '317101': 2,
              },
            },
          },
        },
      },
    };
  }

  // Fetch members with optional filters
  Future<List<Member>> getMembers({
    String? searchQuery,
    String? provinceFilter,
    String? cityFilter,
    String? districtFilter,
    String? villageFilter,
    String? statusFilter,
  }) async {
    // In a real app, this would fetch members from the API with filters
    // For now, we'll use mock data
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Create mock data
    final members = [
      Member(
        id: 1,
        ktaNumber: '3171010001',
        nik: '3171012345678901',
        name: 'John Doe',
        gender: 'male',
        birthPlace: 'Jakarta',
        birthDate: '1990-01-01',
        address: 'Jl. Sudirman No. 123',
        provinceId: 31,
        cityId: 3171,
        districtId: 317101,
        phone: '081234567890',
        email: 'john.doe@example.com',
        registrationDate: '2023-01-01',
        status: 'active',
        createdBy: 1,
      ),
      Member(
        id: 2,
        ktaNumber: '3171010002',
        nik: '3171012345678902',
        name: 'Jane Smith',
        gender: 'female',
        birthPlace: 'Jakarta',
        birthDate: '1992-05-15',
        address: 'Jl. Thamrin No. 456',
        provinceId: 31,
        cityId: 3171,
        districtId: 317101,
        phone: '081234567891',
        email: 'jane.smith@example.com',
        registrationDate: '2023-01-15',
        status: 'active',
        createdBy: 1,
      ),
    ];
    
    // Apply filters (in a real app, these would be applied in the API call)
    return members.where((member) {
      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!member.name.toLowerCase().contains(query) &&
            !member.nik.toLowerCase().contains(query) &&
            !member.ktaNumber.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Apply province filter (supports both legacy and new API IDs)
      if (provinceFilter != null && provinceFilter.isNotEmpty) {
        // Handle numeric provinceId (legacy) or string ID (new API)
        bool isNumeric = int.tryParse(provinceFilter) != null;
        if (isNumeric) {
          // Legacy filter - numeric ID
          if (member.provinceId.toString() != provinceFilter) {
            return false;
          }
        } else {
          // New API filter - string ID
          // For mock data, we'll just allow it to pass
          // In a real implementation, member model would need to be updated
          // to include new API IDs or a mapping would be needed
        }
      }
      
      // Apply city/kabupaten filter (supports both legacy and new API IDs)
      if (cityFilter != null && cityFilter.isNotEmpty) {
        // Handle numeric cityId (legacy) or string ID (new API)
        bool isNumeric = int.tryParse(cityFilter) != null;
        if (isNumeric) {
          // Legacy filter - numeric ID
          if (member.cityId.toString() != cityFilter) {
            return false;
          }
        } else {
          // New API filter - string ID
          // For mock data, we'll just allow it to pass
        }
      }
      
      // Apply district/kecamatan filter (supports both legacy and new API IDs)
      if (districtFilter != null && districtFilter.isNotEmpty) {
        // Handle numeric districtId (legacy) or string ID (new API)
        bool isNumeric = int.tryParse(districtFilter) != null;
        if (isNumeric) {
          // Legacy filter - numeric ID
          if (member.districtId.toString() != districtFilter) {
            return false;
          }
        } else {
          // New API filter - string ID
          // For mock data, we'll just allow it to pass
        }
      }
      
      // Apply village/kelurahan filter (new API only)
      if (villageFilter != null && villageFilter.isNotEmpty) {
        // In the mock data, we don't have villageId
        // In a real implementation, this would filter by village ID
        // For now, we'll just allow it to pass
      }
      
      // Apply status filter
      if (statusFilter != null && statusFilter.isNotEmpty) {
        if (member.status != statusFilter) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  // Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    // In a real app, this would fetch activities from the API
    // For now, we'll use mock data
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      {
        'icon': 'person_add',
        'title': 'Anggota Baru Ditambahkan',
        'subtitle': 'Jane Smith ditambahkan oleh Admin',
        'time_ago': '2 jam yang lalu',
      },
      {
        'icon': 'edit',
        'title': 'Informasi Anggota Diperbarui',
        'subtitle': 'Informasi John Doe telah diperbarui',
        'time_ago': '1 hari yang lalu',
      },
    ];
  }
}
