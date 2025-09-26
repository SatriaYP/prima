import BaseController from "../../controllers/base.controller.js";
import MemberService from "./member.service.js";
// const multer = require("multer");
// const path = require("path");
// const fs = require("fs").promises;
// const docscanner = require("docscanner");

// const upload = multer({
//   dest: "src/modules/member/uploads/ktp/", // Folder sementara
// });
import multer from "multer";
import path from "path";
import fs from "fs/promises";
import sharp from "sharp";
const upload = multer({
  dest: "src/modules/member/uploads/ktp/", // Folder sementara
});
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

  cropKtp = async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "Tidak ada gambar yang diunggah." });
      }

      const allowedTypes = ["image/jpeg", "image/jpg", "image/png"];
      if (!allowedTypes.includes(req.file.mimetype)) {
        await fs.unlink(req.file.path);
        return res.status(400).json({ error: "Format file hanya boleh JPG atau PNG." });
      }

      const imagePath = req.file.path;

      // Gunakan Sharp untuk deteksi dan crop KTP
      // Sharp tidak punya fungsi auto-detect dokumen seperti docscanner
      // Jadi kita akan gunakan pendekatan sederhana: potong bagian tengah 80% sebagai asumsi KTP

      // Baca metadata gambar
      const metadata = await sharp(imagePath).metadata();

      if (!metadata.width || !metadata.height) {
        await fs.unlink(imagePath);
        return res.status(400).json({ error: "Gambar tidak valid." });
      }

      // Asumsikan KTP berada di tengah gambar, lebar ~70%, tinggi ~60%
      const width = metadata.width;
      const height = metadata.height;

      // Tentukan ukuran crop (asumsi KTP sekitar 85mm x 54mm → rasio 1.57)
      // Rasio KTP ≈ 1.57 → jadi kita cari area dengan rasio mirip
      const cropWidth = Math.floor(width * 0.7);
      const cropHeight = Math.floor(cropWidth / 1.57);

      // Pusatkan crop di tengah gambar
      const left = Math.floor((width - cropWidth) / 2);
      const top = Math.floor((height - cropHeight) / 2);

      // Crop dan konversi ke JPEG
      const outputImagePath = path.join(
        __dirname,
        "..",
        "..",
        "..",
        "..",
        "public",
        "uploads",
        "member",
        "ktp",
        `ktp_cropped_${Date.now()}.jpg`
      );

      const outputDir = path.dirname(outputImagePath);
      await fs.mkdir(outputDir, { recursive: true });

      await sharp(imagePath)
        .extract({
          left,
          top,
          width: cropWidth,
          height: cropHeight,
        })
        .jpeg({ quality: 90 })
        .toFile(outputImagePath);

      // Hapus file sementara
      await fs.unlink(imagePath);

      // Kirim URL public
      const imageUrl = `/static/uploads/member/ktp/${path.basename(outputImagePath)}`;

      res.json({
        success: true,
        processed_image_url: imageUrl,
        message: "KTP berhasil diproses dan dipotong.",
      });
    } catch (error) {
      console.error("Error cropping KTP with sharp:", error);

      if (req.file) {
        await fs.unlink(req.file.path).catch(() => { });
      }

      res.status(500).json({
        error: "Gagal memproses KTP. Pastikan gambar jelas dan berformat JPG/PNG.",
      });
    }
  };

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

  checkNikUniqueness = async (req, res) => {
    try {
      const { nik } = req.query;

      const result = await MemberService.checkNikUniqueness(nik);
      res.json(result);
    } catch (err) {
      if (err.message.includes("NIK harus terdiri dari 16 digit")) {
        return res.status(400).json({ error: err.message });
      }
      res.status(500).json({ message: err.message });
    }
  };


  // isKtaExists = (req, res) => {
  //   try {
  //     const { ktaNumber } = req.body;
  //     const result = MemberService.isKtaExists(ktaNumber);
  //     if (!result) return res.status(404).json({ message: "Not found" });
  //     res.json(result);
  //   } catch (error) {
  //     res.status(500).json({ message: err.message });
  //   }
  // };
}

export default new MemberController();
