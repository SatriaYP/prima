const express = require('express');
const router = express.Router();
const wilayahController = require('../controllers/wilayah');

/**
 * Routes untuk API wilayah Indonesia
 */

// Provinsi
router.get('/provinsi', wilayahController.getProvinces);
router.get('/provinsi/:id', wilayahController.getProvinceById);
router.get('/provinsi/:id/kabupaten', wilayahController.getRegenciesByProvinceId);

// Kabupaten/Kota
router.get('/kabupaten', wilayahController.getAllRegencies);
router.get('/kabupaten/:id', wilayahController.getRegencyById);
router.get('/kabupaten/:id/kecamatan', wilayahController.getDistrictsByRegencyId);

// Kecamatan
router.get('/kecamatan/:id', wilayahController.getDistrictById);
router.get('/kecamatan/:id/kelurahan', wilayahController.getVillagesByDistrictId);

// Kelurahan/Desa
router.get('/kelurahan/:id', wilayahController.getVillageById);

module.exports = router;
