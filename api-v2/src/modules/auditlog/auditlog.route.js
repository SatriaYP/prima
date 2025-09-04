import { Router } from "express";
import AuditlogController from "./auditlog.controller.js";
import { authenticate } from "../../middleware/auth.middleware.js";

const router = Router();

router.use(authenticate);
router.get("/", AuditlogController.getAll);
// router.post("/", AuditlogController.create);
router.delete("/:auditId", AuditlogController.remove);

export default router;
