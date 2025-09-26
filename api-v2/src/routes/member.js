import express from 'express';
import {
    getMembers,
    getMember,
    createMember,
    updateMember,
    deleteMember,
    checkNikUniqueness,
    cropKtp,
    getKTAByPrefix,
} from '../controllers/member.js';

const router = express.Router();

router.get('/', getMembers);
router.get('/:id', getMember);
router.post('/', createMember);
router.put('/:id', updateMember);
router.delete('/:id', deleteMember);
router.get('/check-nik', checkNikUniqueness);
router.get("/kta/last-num", getKTAByPrefix);
router.post("/crop-ktp", cropKtp);
export default router;