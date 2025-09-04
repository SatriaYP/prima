import prisma from "../../lib/prisma.js";

class AuditLogService {
  getAuditLogs = async () => {
    return await prisma.auditLog.findMany({
      orderBy: { createdAt: "desc" },
      include: { user: { select: { id: true, email: true, role: true } } },
    });
  };

  createAuditLog = async (payload) => {
    const {
      userId,
      action,
      entityType,
      entityId,
      details,
      ipAddress,
      userAgent,
    } = payload;
    return await prisma.auditLog.create({
      data: {
        userId,
        action,
        entityType,
        entityId,
        details,
        ipAddress,
        userAgent,
      },
    });
  };

  deleteAuditLog = async (id) => {
    return await prisma.auditLog.delete({ where: { id } });
  };
}

export default new AuditLogService();
