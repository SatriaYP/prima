import easyocr
import re
from rapidfuzz import fuzz, process
from PIL import Image
import cv2
import os
import sys
import json

# Fungsi preprocessing gambar
def preprocess_image(image_path):
    img = cv2.imread(image_path)
    if img is None:
        raise FileNotFoundError(f"Gagal membaca file: {image_path}")
    
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray = cv2.bilateralFilter(gray, 11, 17, 17)  # reduce noise
    # _, thresh = cv2.threshold(gray, 180, 255, cv2.THRESH_BINARY)
    thresh = cv2.adaptiveThreshold(
        gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C, cv2.THRESH_BINARY, 15, 15
    )
    processed_path = "processed_easyocr.jpg"
    cv2.imwrite(processed_path, thresh)
    return processed_path

# Fungsi fuzzy matching + regex
def extract_field(text_lines, label_keywords, regex_pattern=None):
    match = process.extractOne(
        query=' '.join(label_keywords).lower(),
        choices=[line.lower() for line in text_lines],
        scorer=fuzz.partial_ratio
    )
    if match and match[1] > 70:
        for line in text_lines:
            if any(keyword.lower() in line.lower() for keyword in label_keywords):
                if regex_pattern:
                    result = re.search(regex_pattern, line)
                    return result.group(1) if result else None
                return line.split(":")[-1].strip()
    return None

# Jalankan EasyOCR
def run_easyocr_on_ktp(image_path):
    processed_path = preprocess_image(image_path)

    reader = easyocr.Reader(['id'])
    result = reader.readtext(processed_path, detail=0)
    lines = [line.strip() for line in result if line.strip()]

    return {
        "nik": extract_field(lines, ["NIK"], r"(\d{16})"),
        "nama": extract_field(lines, ["Nama"]),
        "ttl": extract_field(lines, ["Tempat", "Tanggal", "Lahir"]),
        "alamat": extract_field(lines, ["Alamat"]),
        "berlaku": extract_field(lines, ["Berlaku", "Hingga"], r"(\d{2}-\d{2}-\d{4}|\d{2}/\d{2}/\d{4}|SEUMUR HIDUP)"),
        "raw": lines
    }

# Panggil fungsi
try:
    image_path = sys.argv[1]
    if not os.path.exists(image_path):
        print(f"File not found: {image_path}", file=sys.stderr)
        exit(1)
    data = run_easyocr_on_ktp(image_path)
    # print(data)
    print(json.dumps(data, ensure_ascii=False, indent=2))
except Exception as e:
    print(f"Error during OCR: {e}", file=sys.stderr)
    exit(1)



# import sys
# import easyocr
# import json
# import re
# import os

# def extract_data(lines):
#     data = {
#         "nik": None,
#         "nama": None,
#         "tempat_lahir": None,
#         "tanggal_lahir": None,
#         "jenis_kelamin": None,
#         "gol_darah": None,
#         "alamat": "",
#         "rt": None,
#         "rw": None,
#         "kelurahan": None,
#         "kecamatan": None,
#         "agama": None,
#         "status_perkawinan": None,
#         "pekerjaan": None,
#         "kewarganegaraan": None,
#         "berlaku_hingga": None,
#         "raw": lines
#     }

#     i = 0
#     while i < len(lines):
#         line = lines[i].lower().strip()

#         if not data["nik"]:
#             nik_match = re.match(r'(\d{16})', lines[i])
#             if nik_match:
#                 data["nik"] = nik_match.group(1)

#         elif "nama" in line and not data["nama"]:
#             data["nama"] = lines[i + 1].strip()
#             i += 1

#         elif "lahir" in line and (not data["tempat_lahir"] or not data["tanggal_lahir"]):
#             value = lines[i + 1]
#             parts = re.split(r'[;,]', value)
#             if len(parts) >= 2:
#                 data["tempat_lahir"] = parts[0].strip()
#                 data["tanggal_lahir"] = re.sub(r'\s+', '-', parts[1].strip().replace(" ", "-"))
#             else:
#                 data["tempat_lahir"] = value.strip()
#             i += 1

#         elif "kelamin" in line and not data["jenis_kelamin"]:
#             data["jenis_kelamin"] = lines[i + 1].strip().replace("LAKIEAKI", "LAKI-LAKI")
#             i += 1

#         elif "gol darah" in line and not data["gol_darah"]:
#             data["gol_darah"] = lines[i + 1].strip()
#             i += 1

#         elif "alamat" in line and not data["alamat"]:
#             alamat = lines[i + 1].strip()
#             if i + 2 < len(lines):
#                 alamat2 = lines[i + 2].strip()
#                 # tambahkan jika bukan label
#                 if not re.search(r'rt|rw|kel|desa|kec|agama', alamat2.lower()):
#                     alamat += " " + alamat2
#                     i += 1
#             data["alamat"] = alamat
#             i += 1

#         elif "rt" in line or "rw" in line:
#             if i + 2 < len(lines):
#                 data["rt"] = lines[i + 1].strip()
#                 data["rw"] = lines[i + 2].strip()
#                 i += 2

#         elif "kel" in line or "desa" in line:
#             data["kelurahan"] = lines[i + 1].strip()
#             i += 1

#         elif "kec" in line:
#             data["kecamatan"] = lines[i + 1].strip()
#             i += 1

#         elif "agama" in line and not data["agama"]:
#             data["agama"] = lines[i + 1].strip()
#             i += 1

#         elif "status" in line and not data["status_perkawinan"]:
#             data["status_perkawinan"] = lines[i + 1].strip()
#             i += 1

#         elif "pekerjaan" in line and not data["pekerjaan"]:
#             data["pekerjaan"] = lines[i + 1].strip()
#             i += 1

#         elif "kewarganegaraan" in line and not data["kewarganegaraan"]:
#             data["kewarganegaraan"] = lines[i + 1].strip()
#             i += 1

#         elif "berlaku" in line and not data["berlaku_hingga"]:
#             data["berlaku_hingga"] = lines[i + 1].strip()
#             i += 1

#         i += 1

#     return data


# try:
#     image_path = sys.argv[1]
#     if not os.path.exists(image_path):
#         print(f"File not found: {image_path}", file=sys.stderr)
#         exit(1)

#     reader = easyocr.Reader(['id'], gpu=False)
#     results = reader.readtext(image_path, detail=0)
#     lines = [line.strip() for line in results if line.strip()]
#     data = extract_data(lines)

#     print(json.dumps(data, ensure_ascii=False, indent=2))

# except Exception as e:
#     print(f"Error during OCR: {e}", file=sys.stderr)
#     exit(1)


# # # scripts/ktp_ocr.py
# # import sys
# # import easyocr
# # import json
# # import re
# # import os

# # try:
# #     image_path = sys.argv[1]
# #     if not os.path.exists(image_path):
# #         print(f"File not found: {image_path}", file=sys.stderr)
# #         exit(1)
# #     # reader = easyocr.Reader(['id'], gpu=False,verbose=False)
# #     reader = easyocr.Reader(['id'], gpu=False)
# #     results = reader.readtext(image_path, detail=0)
# #     lines = [line.strip() for line in results if line.strip()]

# #     data = {
# #         "nik": None,
# #         "nama": None,
# #         "ttl": None,
# #         "alamat": None,
# #         "raw": lines
# #     }

# #     for line in lines:
# #         if not data["nik"]:
# #             match = re.search(r'(\d{16})', line)
# #             if match:
# #                 data["nik"] = match.group(1)

# #         if not data["nama"] and line.lower().startswith("nama") or "nama" in line.lower():
# #             nama = re.sub(r'nama[:\s]*', '', line, flags=re.IGNORECASE)
# #             data["nama"] = nama.strip()

# #         if not data["ttl"] and ("lahir" in line.lower() or "ttl" in line.lower()):
# #             data["ttl"] = re.sub(r'tempat/tgl lahir[:\s]*', '', line, flags=re.IGNORECASE)

# #         if not data["alamat"] and "alamat" in line.lower():
# #             alamat = re.sub(r'alamat[:\s]*', '', line, flags=re.IGNORECASE)
# #             data["alamat"] = alamat.strip()

# #     print(json.dumps(data, ensure_ascii=False))

# # except Exception as e:
# #     print(f"Error during OCR: {e}", file=sys.stderr)
# #     exit(1)
