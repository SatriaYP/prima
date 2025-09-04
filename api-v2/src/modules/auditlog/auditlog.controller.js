import BaseController from "../../controllers/base.controller.js";
import AuditlogService from "./auditlog.service.js";

class AuditLogController extends BaseController {
  constructor() {
    super({
      getAll: AuditlogService.getAuditLogs,
      remove: AuditlogService.deleteAuditLog,
    });
  }

  create = async (logData) => {
    return await AuditlogService.createAuditLog(logData);
  };
}

export default new AuditLogController();
