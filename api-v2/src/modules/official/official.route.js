import { Router } from "express";
import OfficialController from "./official.controller.js";
// import { authenticate } from "../../middleware/auth.middleware.js";
import { middlewares } from "../../middleware/index.js";

const router = Router();

router.use(middlewares.authenticate);
router.get("/", OfficialController.getAll);
router.get("/:id", OfficialController.getById);
router.post(
  "/",
  middlewares.auditLog("create", "official"),
  OfficialController.create
);
router.put(
  "/:id",
  middlewares.auditLog("update", "official"),
  OfficialController.update
);
router.delete(
  "/:id",
  middlewares.auditLog("delete", "official"),
  OfficialController.remove
);

export default router;
