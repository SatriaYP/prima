import express from 'express';
import * as regionController from '../controllers/regionController.js';

const router = express.Router();

// Routes untuk wilayah
router.get('/provinces', regionController.getProvinces);
router.get('/regencies', regionController.getRegencies);
router.get('/districts', regionController.getDistricts);
router.get('/villages', regionController.getVillages);

export default router;
