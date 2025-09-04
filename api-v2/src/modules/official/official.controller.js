import BaseController from "../../controllers/base.controller.js";
import OfficialService from "./official.service.js";

class OfficialController extends BaseController {
  constructor() {
    super({
      getAll: OfficialService.getAllOfficial,
      getById: OfficialService.getOfficialById,
      create: OfficialService.createOfficial,
      update: OfficialService.updateOfficial,
      delete: OfficialService.deleteOfficial,
    });
  }
}
// class OfficialController {
//   async getAll(_req, res) {
//     try {
//       const official = await OfficialService.getAllOfficial();
//       res.json(official);
//     } catch (err) {
//       res.status(500).json({ message: err.message });
//     }
//   }

//   async getById(req, res) {
//     try {
//       const ofc = await OfficialService.getOfficialById(req.params.id);
//       if (!ofc) return res.status(404).json({ message: "Not found" });
//       res.json(ofc);
//     } catch (err) {
//       res.status(500).json({ message: err.message });
//     }
//   }

//   async create(req, res) {
//     try {
//       const official = await OfficialService.createOfficial(req.body);
//       res.status(201).json(official);
//     } catch (error) {
//       res.status(500).json({ message: err.message });
//     }
//   }

//   async update(req, res) {
//     try {
//       const official = await OfficialService.updateOfficial(
//         req.params.id,
//         req.body
//       );
//       res.json(official);
//     } catch (err) {
//       res.status(500).json({ message: err.message });
//     }
//   }

//   async remove(req, res) {
//     try {
//       await OfficialService.deleteOfficial(req.params.id);
//       res.status(204).send();
//     } catch (err) {
//       res.status(500).json({ message: err.message });
//     }
//   }
// }

export default new OfficialController();
