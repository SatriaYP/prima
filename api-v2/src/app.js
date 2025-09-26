import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";

// import authRoutes from "./modules/auth/auth.route.js";
// import memberRoutes from "./modules/member/member.route.js";
// import officialRoutes from "./modules/official/official.route.js";
// import regionRoutes from "./modules/region/region.route.js";
// import ocrRoutes from "./routes/ocr.js";
import routes from "./routes/index.js";
import multer from "multer";

dotenv.config();

const app = express();
const port = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

// Serve processed images under /static
app.use("/static", express.static(path.join(process.cwd(), "public")));

app.get("/", (req, res) => {
  res.json({
    message: "PRIMA API v2",
    version: "1.0.0",
    endpoints: {
      auth: "/api/v2/auth",
      member: "/api/v2/members",
      official: "/api/v2/officials",
      regions: "/api/v2/regions",
      ocr: "/api",
    },
  });
});

app.use("/api/v2", routes);

app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res
        .status(400)
        .json({ error: "File too large. Max size is 2MB." });
    }
    return res.status(400).json({ error: err.message });
  } else if (err.message.includes("Only JPEG and PNG")) {
    return res.status(400).json({ error: err.message });
  }
  next(err);
});

// app.use("/api/auth", authRoutes);
// app.use("/api/members", memberRoutes);
// app.use("/api/officials", officialRoutes);
// app.use("/api/regions", regionRoutes);
// app.use("/api", ocrRoutes);

// app.use((err, req, res, next) => {
//   console.error(err);
//   res.status(500).json({
//     status: "error",
//     message: err.message || "Internal Server Error",
//   });
// });

app.listen(port, () => {
  console.log(`✅ PRIMA API v2 running on http://localhost:${port}`);
  console.log("🔍 Route yang tersedia:");
  app._router.stack.forEach((layer) => {
    if (layer.route) {
      console.log(`   ${layer.route.path} (${layer.route.methods})`);
    }
  });
});