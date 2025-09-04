import Tesseract from "tesseract.js";
import { preprocessImage } from "../../utils/preprocessImage.js";
import path from "path";
import fs from "fs";
import { spawn } from "child_process";

class OCRService {
  //using node.js
  performOCR = async (imagePath) => {
    try {
      const processedPath = await preprocessImage(imagePath);
      const result = await Tesseract.recognize(processedPath, "ind", {
        logger: (m) => console.log(m), // Optional: log progress
        tessedit_pageseg_mode: Tesseract.PSM.AUTO, // atau PSM.SINGLE_BLOCK
        tessedit_ocr_engine_mode: Tesseract.OEM.LSTM_ONLY,
        tessedit_char_whitelist:
          "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,!?-",
        preserve_interword_spaces: "1",
        // Untuk bahasa Indonesia
        user_defined_dpi: "300",
      });

      fs.unlinkSync(processedPath);

      return result.data.text;
    } catch (err) {
      throw new Error("OCR processing failed: " + err.message);
    }
  };

  // using python
  runPythonOCR = (imagePath) => {
    return new Promise((resolve, reject) => {
      const pythonProcess = spawn("python", [
        "src/scripts/ktp_ocr.py",
        imagePath,
      ]);

      let output = "";
      let error = "";

      pythonProcess.stdout.on("data", (data) => (output += data));
      pythonProcess.stderr.on("data", (data) => (error += data));
      //   pythonProcess.stderr.on("data", (data) => {
      //     try {
      //       const result = JSON.parse(data.toString());
      //       resolve(result);
      //     } catch (error) {
      //       console.error("Gagal parse JSON dari Python:", data.toString());
      //       reject({ error: "OCR gagal", detail: data.toString() });
      //     }
      //   });

      pythonProcess.on("close", (code) => {
        console.log("OCR Python output:", output);
        console.log("OCR Python error:", error);
        console.log("OCR exit code:", code);
        // if (code !== 0 || error) return reject(error);
        if (code !== 0) {
          return reject({
            error: "OCR gagal bre",
            detail: error.toString() || `Exited with code ${code}`,
          });
        }
        // if (code !== 0 || error) {
        //   return reject({
        //     error: "OCR gagal bre",
        //     detail: error.toString() || `Exited with code ${code}`,
        //   });
        // }
        try {
          const result = JSON.parse(output);
          resolve(result);
        } catch (err) {
          //   reject("Invalid OCR output: " + err.message);
          reject({ error: "Invalid OCR output", detail: output });
        }
      });
    });
  };
}

export default new OCRService();
