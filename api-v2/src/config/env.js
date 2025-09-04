import dotenv from "dotenv";
dotenv.config();

export const env = {
  PORT: process.env.PORT || 3000,
  DB_URL: process.env.DATABASE_URL || "",
  JWT_SECRET: process.env.JWT_SECRET || "secret_token",
  JWT_SECRET_REFRESH_TOKEN:
    process.env.JWT_SECRET_REFRESH_TOKEN || "refresh_secret_token",
  JWT_ACCESS_TOKEN_EXPIRED: process.env.JWT_ACCESS_TOKEN_EXPIRED || "1d",
  JWT_REFRESH_TOKEN_EXPIRED: process.env.JWT_REFRESH_TOKEN_EXPIRED || "7d",
};
