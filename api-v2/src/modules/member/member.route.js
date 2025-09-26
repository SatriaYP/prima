import { Router } from "express";
import MemberController from "./member.controller.js";
import { uploadKtp } from "./ktp-upload.controller.js";
// import { authenticate } from "../../middleware/auth.middleware.js";
import { middlewares } from "../../middleware/index.js";
import multer from "multer";
const upload = multer({ dest: "src/modules/member/uploads/ktp/" });
const router = Router();

router.use(middlewares.authenticate);
router.get("/", MemberController.getAll);
router.get('/check-nik', MemberController.checkNikUniqueness);
router.get("/kta/last-num", MemberController.getKTAByPrefix);
router.post("/upload-ktp", upload.single("image"), uploadKtp);
router.post("/crop-ktp", MemberController.cropKtp);
router.get("/:id", MemberController.getById);
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
