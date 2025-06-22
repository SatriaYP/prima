const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const cache = require('../utils/cache');

/**
 * Service untuk mengelola data wilayah Indonesia
 */
class WilayahService {
  /**
   * Mendapatkan semua provinsi
   * @returns {Promise<Array>} Daftar provinsi
   */
  async getProvinces() {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = 'provinces';
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      // Jika tidak ada di cache, ambil dari database
      const provinces = await prisma.province.findMany({
        orderBy: {
          name: 'asc'
        }
      });
      
      // Simpan ke cache
      cache.set(cacheKey, provinces);
      
      return provinces;
    } catch (error) {
      console.error('Error getting provinces:', error);
      throw error;
    }
  }

  /**
   * Mendapatkan detail provinsi berdasarkan ID
   * @param {string} id - ID provinsi
   * @returns {Promise<Object>} Detail provinsi
   */
  async getProvinceById(id) {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = `province_${id}`;
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      const province = await prisma.province.findUnique({
        where: { id }
      });
      
      if (province) {
        // Simpan ke cache
        cache.set(cacheKey, province);
      }
      
      return province;
    } catch (error) {
      console.error(`Error getting province with id ${id}:`, error);
      throw error;
    }
  }

  /**
   * Mendapatkan semua kabupaten/kota
   * @returns {Promise<Array>} Daftar semua kabupaten/kota
   */
  async getAllRegencies() {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = 'all_regencies';
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      // Jika tidak ada di cache, ambil dari database
      const regencies = await prisma.regency.findMany({
        orderBy: {
          name: 'asc'
        }
      });
      
      // Simpan ke cache
      cache.set(cacheKey, regencies);
      
      return regencies;
    } catch (error) {
      console.error('Error getting all regencies:', error);
      throw error;
    }
  }

  /**
   * Mendapatkan kabupaten/kota berdasarkan ID provinsi
   * @param {string} provinceId - ID provinsi
   * @returns {Promise<Array>} Daftar kabupaten/kota
   */
  async getRegenciesByProvinceId(provinceId) {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = `regencies_by_province_${provinceId}`;
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      const regencies = await prisma.regency.findMany({
        where: { provinceId },
        orderBy: {
          name: 'asc'
        }
      });
      
      // Simpan ke cache
      cache.set(cacheKey, regencies);
      
      return regencies;
    } catch (error) {
      console.error(`Error getting regencies for province ${provinceId}:`, error);
      throw error;
    }
  }

  /**
   * Mendapatkan detail kabupaten/kota berdasarkan ID
   * @param {string} id - ID kabupaten/kota
   * @returns {Promise<Object>} Detail kabupaten/kota
   */
  async getRegencyById(id) {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = `regency_${id}`;
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      const regency = await prisma.regency.findUnique({
        where: { id }
      });
      
      if (regency) {
        // Simpan ke cache
        cache.set(cacheKey, regency);
      }
      
      return regency;
    } catch (error) {
      console.error(`Error getting regency with id ${id}:`, error);
      throw error;
    }
  }

  /**
   * Mendapatkan kecamatan berdasarkan ID kabupaten/kota
   * @param {string} regencyId - ID kabupaten/kota
   * @returns {Promise<Array>} Daftar kecamatan
   */
  async getDistrictsByRegencyId(regencyId) {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = `districts_by_regency_${regencyId}`;
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      const districts = await prisma.district.findMany({
        where: { regencyId },
        orderBy: {
          name: 'asc'
        }
      });
      
      // Simpan ke cache
      cache.set(cacheKey, districts);
      
      return districts;
    } catch (error) {
      console.error(`Error getting districts for regency ${regencyId}:`, error);
      throw error;
    }
  }

  /**
   * Mendapatkan detail kecamatan berdasarkan ID
   * @param {string} id - ID kecamatan
   * @returns {Promise<Object>} Detail kecamatan
   */
  async getDistrictById(id) {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = `district_${id}`;
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      const district = await prisma.district.findUnique({
        where: { id }
      });
      
      if (district) {
        // Simpan ke cache
        cache.set(cacheKey, district);
      }
      
      return district;
    } catch (error) {
      console.error(`Error getting district with id ${id}:`, error);
      throw error;
    }
  }

  /**
   * Mendapatkan kelurahan/desa berdasarkan ID kecamatan
   * @param {string} districtId - ID kecamatan
   * @returns {Promise<Array>} Daftar kelurahan/desa
   */
  async getVillagesByDistrictId(districtId) {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = `villages_by_district_${districtId}`;
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      const villages = await prisma.village.findMany({
        where: { districtId },
        orderBy: {
          name: 'asc'
        }
      });
      
      // Simpan ke cache
      cache.set(cacheKey, villages);
      
      return villages;
    } catch (error) {
      console.error(`Error getting villages for district ${districtId}:`, error);
      throw error;
    }
  }

  /**
   * Mendapatkan detail kelurahan/desa berdasarkan ID
   * @param {string} id - ID kelurahan/desa
   * @returns {Promise<Object>} Detail kelurahan/desa
   */
  async getVillageById(id) {
    try {
      // Cek cache terlebih dahulu
      const cacheKey = `village_${id}`;
      const cachedData = cache.get(cacheKey);
      
      if (cachedData) {
        return cachedData;
      }
      
      const village = await prisma.village.findUnique({
        where: { id }
      });
      
      if (village) {
        // Simpan ke cache
        cache.set(cacheKey, village);
      }
      
      return village;
    } catch (error) {
      console.error(`Error getting village with id ${id}:`, error);
      throw error;
    }
  }
}

module.exports = new WilayahService();
