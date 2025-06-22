const wilayahService = require('../services/wilayah');

/**
 * Controller untuk endpoint API wilayah Indonesia
 */
class WilayahController {
  /**
   * Mendapatkan semua provinsi
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getProvinces(req, res, next) {
    try {
      const provinces = await wilayahService.getProvinces();
      res.json({
        status: 'success',
        data: provinces
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mendapatkan detail provinsi berdasarkan ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getProvinceById(req, res, next) {
    try {
      const { id } = req.params;
      const province = await wilayahService.getProvinceById(id);
      
      if (!province) {
        return res.status(404).json({
          status: 'error',
          message: `Provinsi dengan ID ${id} tidak ditemukan`
        });
      }
      
      res.json({
        status: 'success',
        data: province
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mendapatkan semua kabupaten/kota
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getAllRegencies(req, res, next) {
    try {
      const regencies = await wilayahService.getAllRegencies();
      res.json({
        status: 'success',
        data: regencies
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mendapatkan kabupaten/kota berdasarkan ID provinsi
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getRegenciesByProvinceId(req, res, next) {
    try {
      const { id } = req.params;
      const province = await wilayahService.getProvinceById(id);
      
      if (!province) {
        return res.status(404).json({
          status: 'error',
          message: `Provinsi dengan ID ${id} tidak ditemukan`
        });
      }
      
      const regencies = await wilayahService.getRegenciesByProvinceId(id);
      res.json({
        status: 'success',
        data: regencies
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mendapatkan detail kabupaten/kota berdasarkan ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getRegencyById(req, res, next) {
    try {
      const { id } = req.params;
      const regency = await wilayahService.getRegencyById(id);
      
      if (!regency) {
        return res.status(404).json({
          status: 'error',
          message: `Kabupaten/kota dengan ID ${id} tidak ditemukan`
        });
      }
      
      res.json({
        status: 'success',
        data: regency
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mendapatkan kecamatan berdasarkan ID kabupaten/kota
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getDistrictsByRegencyId(req, res, next) {
    try {
      const { id } = req.params;
      const regency = await wilayahService.getRegencyById(id);
      
      if (!regency) {
        return res.status(404).json({
          status: 'error',
          message: `Kabupaten/kota dengan ID ${id} tidak ditemukan`
        });
      }
      
      const districts = await wilayahService.getDistrictsByRegencyId(id);
      res.json({
        status: 'success',
        data: districts
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mendapatkan detail kecamatan berdasarkan ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getDistrictById(req, res, next) {
    try {
      const { id } = req.params;
      const district = await wilayahService.getDistrictById(id);
      
      if (!district) {
        return res.status(404).json({
          status: 'error',
          message: `Kecamatan dengan ID ${id} tidak ditemukan`
        });
      }
      
      res.json({
        status: 'success',
        data: district
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mendapatkan kelurahan/desa berdasarkan ID kecamatan
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getVillagesByDistrictId(req, res, next) {
    try {
      const { id } = req.params;
      const district = await wilayahService.getDistrictById(id);
      
      if (!district) {
        return res.status(404).json({
          status: 'error',
          message: `Kecamatan dengan ID ${id} tidak ditemukan`
        });
      }
      
      const villages = await wilayahService.getVillagesByDistrictId(id);
      res.json({
        status: 'success',
        data: villages
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mendapatkan detail kelurahan/desa berdasarkan ID
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   * @param {Function} next - Express next middleware function
   */
  async getVillageById(req, res, next) {
    try {
      const { id } = req.params;
      const village = await wilayahService.getVillageById(id);
      
      if (!village) {
        return res.status(404).json({
          status: 'error',
          message: `Kelurahan/desa dengan ID ${id} tidak ditemukan`
        });
      }
      
      res.json({
        status: 'success',
        data: village
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new WilayahController();
