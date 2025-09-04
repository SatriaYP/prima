import { Router } from "express";
import authRoutes from "../modules/auth/auth.route.js";
import memberRoutes from "../modules/member/member.route.js";
import officialRoutes from "../modules/official/official.route.js";
import regionRoutes from "../modules/region/region.route.js";
import ocrRoutes from "../modules/ocr/ocr.route.js";
import auditLogRoutes from "../modules/auditlog/auditlog.route.js";

const router = Router();

router.use("/auth", authRoutes);
router.use("/members", memberRoutes);
router.use("/officials", officialRoutes);
router.use("/regions", regionRoutes);
router.use("/ocr", ocrRoutes);
router.use("/audit", auditLogRoutes);

export default router;
