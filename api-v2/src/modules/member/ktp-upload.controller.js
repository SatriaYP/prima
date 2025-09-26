import multer from "multer";
import path from "path";
import fs from "fs/promises";

const storage = multer.diskStorage({
    destination: async (req, file, cb) => {
        const uploadDir = path.join(
            process.cwd(),
            "public",
            "uploads",
            "member",
            "ktp"
        );
        try {
            await fs.mkdir(uploadDir, { recursive: true });
            cb(null, uploadDir);
        } catch (err) {
            cb(err, null);
        }
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        const ext = path.extname(file.originalname);
        cb(null, `ktp_${uniqueSuffix}${ext}`);
    },
});

const upload = multer({ storage });

export async function uploadKtp(req, res) {
    if (!req.file) {
        return res.status(400).json({
            success: false,
            message: "Tidak ada file yang diunggah.",
        });
    }

    const fileUrl = `/static/uploads/member/ktp/${req.file.filename}`;

    res.json({
        success: true,
        file_url: fileUrl,
        message: "File KTP berhasil disimpan.",
    });
}