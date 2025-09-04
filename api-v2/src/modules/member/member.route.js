import { Router } from "express";
import MemberController from "./member.controller.js";
// import { authenticate } from "../../middleware/auth.middleware.js";
import { middlewares } from "../../middleware/index.js";

const router = Router();

router.use(middlewares.authenticate);
router.get("/", MemberController.getAll);
router.get("/:id", MemberController.getById);
router.get("/kta/last-num", MemberController.getKTAByPrefix);
router.post(
  "/",
  middlewares.auditLog("create", "member"),
  MemberController.create
);
router.put(
  "/:id",
  middlewares.auditLog("update", "member"),
  MemberController.update
);
router.delete(
  "/:id",
  middlewares.auditLog("delete", "member"),
  MemberController.remove
);

export default router;
