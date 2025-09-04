import { Router } from "express";
import RegionController from "./region.controller.js";

const router = Router();

router.get("/provinces", RegionController.getProvinces);
router.get("/cities/:provinceId", RegionController.getCities);
router.get("/districts/:cityId", RegionController.getDistricts);
router.get("/villages/:districtId", RegionController.getVillages);

export default router;
