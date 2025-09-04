import OCRService from "./ocr.service.js";
import { extractKTPData } from "../../utils/extractKTPData.js";
import path from "path";
import fs from "fs";

class OCRController {
  handleOCR = async (req, res) => {
    try {
      const file = req.file;
      if (!file) {
        return res
          .status(400)
          .json({ message: "Only JPEG and PNG images are allowed." });
      }

      const imagePath = file.path;

      const text = await OCRService.performOCR(imagePath);
      const data = extractKTPData(text);
      fs.unlink(imagePath, () => {}); // Hapus file setelah OCR
      res.json({ text, data });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };

  processKtp = async (req, res) => {
    if (!req.file)
      return res.status(400).json({ error: "File gambar tidak ditemukan." });

    try {
      const result = await OCRService.runPythonOCR(req.file.path);
      fs.unlink(req.file.path, () => {}); // Hapus file setelah OCR
      res.json({ success: true, data: result });
    } catch (err) {
      res.status(500).json({
        error: "OCR gagal",
        detail: err.detail || err.message || err.toString(),
      });
    }
  };
}

export default new OCRController();
