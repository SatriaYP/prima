import { authenticate } from "./auth.middleware.js";
import { auditLog } from "./auditlog.middleware.js";

export const middlewares = { authenticate, auditLog };
