import express from 'express';
import { getOfficials, getOfficial, createOfficial, updateOfficial, deleteOfficial } from '../controllers/official.js';
const router = express.Router();

router.get('/', getOfficials);
router.get('/:id', getOfficial);
router.post('/', createOfficial);
router.put('/:id', updateOfficial);
router.delete('/:id', deleteOfficial);

export default router;
