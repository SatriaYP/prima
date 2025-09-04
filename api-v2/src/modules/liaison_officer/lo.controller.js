import BaseController from "../../controllers/base.controller.js";
import LiaisonOfficerSercive from "./lo.service.js";

class LiaisonOfficerConroller {
  constructor() {
    super({
      getAll: LiaisonOfficerSercive.getAllLiaisonOfficer,
      getById: LiaisonOfficerSercive.getLiaisonOfficerById,
      create: LiaisonOfficerSercive.createLiaisonOfficer,
      update: LiaisonOfficerSercive.updateLiaisonOfficer,
      delete: LiaisonOfficerSercive.deleteLiaisonOfficers,
    });
  }
}

export default new LiaisonOfficerConroller();
