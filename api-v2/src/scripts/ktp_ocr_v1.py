import re
from paddleocr import PaddleOCR
from difflib import SequenceMatcher
import sys
import os
import json

ocr = PaddleOCR(use_angle_cls=True, lang='en')

def fuzzy_match(text, keyword, threshold=0.7):
    """Return True if text is similar to keyword based on threshold"""
    return SequenceMatcher(None, text.lower(), keyword.lower()).ratio() >= threshold

def normalize_text(text):
    """Optional correction for common OCR errors"""
    corrections = {
        "bertaku hingge": "berlaku hingga",
        "bertaku hingga": "berlaku hingga",
        "lakieaki": "laki-laki",
        "gol darah": "gol. darah",
        "alamat.": "alamat",
        "nama.": "nama",
        "tempattgl": "tempat/tgl",
        "nikk": "nik",
    }
    text = text.lower()
    for wrong, correct in corrections.items():
        text = text.replace(wrong, correct)
    return text.strip()

def extract_data_from_text(lines):
    data = {
        "nik": None,
        "nama": None,
        "ttl": None,
        "alamat": None,
        "berlaku": None,
        "raw": lines
    }

    for i, raw_line in enumerate(lines):
        line = normalize_text(raw_line)

        # NIK
        if not data["nik"]:
            match = re.search(r'\b\d{16}\b', line)
            if match:
                data["nik"] = match.group()

        # Nama
        if not data["nama"] and (fuzzy_match(line, "nama") or line.startswith("nama")):
            next_line = lines[i + 1] if i + 1 < len(lines) else ""
            data["nama"] = next_line.strip() if next_line else re.sub(r'nama[:\s]*', '', line, flags=re.IGNORECASE)

        # TTL
        if not data["ttl"] and any(fuzzy_match(line, key) for key in ["tempat/tgl lahir", "tempattgl lahir", "lahir", "ttl"]):
            next_line = lines[i + 1] if i + 1 < len(lines) else ""
            data["ttl"] = next_line.strip() if next_line else re.sub(r'[:\s]*', '', line)

        # Alamat
        if not data["alamat"] and fuzzy_match(line, "alamat"):
            alamat_lines = []
            for j in range(1, 3):  # ambil 2 baris setelahnya
                if i + j < len(lines):
                    alamat_lines.append(lines[i + j].strip())
            data["alamat"] = " ".join(alamat_lines)

        # Berlaku Hingga
        if not data["berlaku"] and fuzzy_match(line, "berlaku hingga"):
            next_line = lines[i + 1] if i + 1 < len(lines) else ""
            data["berlaku"] = next_line.strip()

    return data

def ocr_ktp_image(image_path):
    result = ocr.predict(image_path)
    lines = [line[1][0] for block in result for line in block]  # ambil teks saja
    extracted = extract_data_from_text(lines)
    return {
        "success": True,
        "data": extracted
    }

try:
    image_path = sys.argv[1]
    if not os.path.exists(image_path):
        print(f"File not found: {image_path}", file=sys.stderr)
        exit(1)
    data = ocr_ktp_image(image_path)

    # reader = easyocr.Reader(['id'], gpu=False)
    # results = reader.readtext(image_path, detail=0)
    # lines = [line.strip() for line in results if line.strip()]
    # data = extract_data(lines)

    print(json.dumps(data, ensure_ascii=False, indent=2))

except Exception as e:
    print(f"Error during OCR: {e}", file=sys.stderr)
    exit(1)
