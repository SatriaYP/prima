import { verifyToken } from "../utils/jwt.js";

export const authenticate = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "Unauthorized: No token provided" });
  }

  try {
    const payload = verifyToken(token);

    if (!payload) {
      return res
        .status(403)
        .json({ message: "Forbidden: Invalid or expired token" });
    }

    req.user = payload;
    next();
  } catch (error) {
    return res.status(403).json({ message: "Invalid token" });
  }
};
