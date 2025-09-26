import { Router } from 'express';
import { createSuratAndGeneratePDF, saveSurat, getSurat } from './controllers/surat.controller.js';

const router = Router();

router.post('/generate', createSuratAndGeneratePDF);
router.post('/save', saveSurat);     // ← Ini akan ambil dari controller
router.get('/:id', getSurat);

export default router;