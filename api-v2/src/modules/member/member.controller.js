import BaseController from "../../controllers/base.controller.js";
import MemberService from "./member.service.js";

class MemberController extends BaseController {
  constructor() {
    super({
      getAll: MemberService.getMembers,
      getById: MemberService.getMemberById,
      create: MemberService.createMember,
      update: MemberService.updateMember,
      delete: MemberService.deleteMember,
    });
  }

  getKTAByPrefix = async (req, res) => {
    try {
      const { prefix } = req.query;
      if (!prefix) {
        return res.status(400).json({ message: "Prefix is required" });
      }
      const result = await MemberService.getLastKtaByPrefix(prefix);
      if (!result) return res.status(404).json({ message: "Not found" });
      res.json(result);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };

  isKtaExists = (req, res) => {
    try {
      const { ktaNumber } = req.body;
      const result = MemberService.isKtaExists(ktaNumber);
      if (!result) return res.status(404).json({ message: "Not found" });
      res.json(result);
    } catch (error) {
      res.status(500).json({ message: err.message });
    }
  };
}

export default new MemberController();
