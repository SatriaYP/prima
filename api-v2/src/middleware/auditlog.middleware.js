import AuditLogController from "../modules/auditlog/auditlog.controller.js";

export const auditLog = (action, entityType) => {
  return async (req, res, next) => {
    const oriSend = res.send;

    let responseData = null;

    res.send = (body) => {
      try {
        responseData = typeof body === "string" ? JSON.parse(body) : body;
      } catch {
        responseData = body;
      }
      return oriSend.call(res, body);
    };

    res.on("finish", async () => {
      try {
        // const status = res?.statusCode || 0;
        if (res.statusCode >= 200 && res.statusCode < 300) {
          const user = req.user || {};
          const entityId =
            responseData && typeof responseData === "object" && responseData?.id
              ? responseData.id
              : req.params?.id || null;

          await AuditLogController.create({
            userId: user.id || "unknown",
            action,
            entityType,
            entityId,
            details: `${action.toUpperCase()} ${entityType}`,
            ipAddress:
              req.ip ||
              req.headers["x-forwarded-for"] ||
              req.socket?.remoteAddress,
            //   req.connection.remoteAddress,
            userAgent: req.headers["user-agent"] || null,
          });
        }
      } catch (error) {
        console.error("[AuditLog ERROR]", error?.message || error);
        console.log("[DEBUG]", {
          statusCode: res.statusCode,
          responseData,
          oriSend,
        });
      }
    });

    next();
  };
};
