import sharp from "sharp";
import path from "path";
import fs from "fs";

export const preprocessImage = async (imagePath) => {
  const outputPath = imagePath.replace(/(\.\w+)$/, "-processed$1");

  try {
    await sharp(imagePath)
      .resize(null, 2000, {
        withoutEnlargement: false,
        kernel: sharp.kernel.lanczos3,
      })
      //   .resize(
      //     { width: 2000 },
      //     {
      //       withoutEnlargement: false,
      //       kernel: sharp.kernel.lanczos3,
      //     }
      //   ) // Resize ke lebar 1000px
      //   .sharpen({ sigma: 2 }) // Pertajam gambar
      .grayscale() // Ubah ke grayscale
      .normalize() // Sesuaikan kontras
      //   .threshold(140)
      .toFile(outputPath);

    return outputPath;
  } catch (error) {
    throw new Error("Image preprocesing failed: " + error.message);
  }
};
