import { Router } from "express";
import LiaisonOfficerConroller from "./official.controller.js";
import { middlewares } from "../../middleware/index.js";

const router = Router();

router.use(middlewares.authenticate);
router.get("/", LiaisonOfficerConroller.getAll);
router.get("/:id", LiaisonOfficerConroller.getById);
router.post(
  "/",
  middlewares.auditLog("create", "liaisonOfficer"),
  LiaisonOfficerConroller.create
);
router.put(
  "/:id",
  middlewares.auditLog("update", "liaisonOfficer"),
  LiaisonOfficerConroller.update
);
router.delete(
  "/:id",
  middlewares.auditLog("delete", "liaisonOfficer"),
  LiaisonOfficerConroller.remove
);

export default router;
