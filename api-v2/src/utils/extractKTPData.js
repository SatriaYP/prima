export const extractKTPData = (text) => {
  const cleanText = text
    .replace(/[“”—|:;_=]+/g, " ") // hapus simbol aneh
    .replace(/\s{2,}/g, " ") // ganti spasi ganda
    .replace(/[^a-zA-Z0-9\s,.\-\/]/g, "") // buang simbol tidak penting
    .toUpperCase(); // samakan huruf kapital semua

  return {
    nik: (cleanText.match(/\b\d{16}\b/) || [])[0] || null,
    nama: (cleanText.match(/NAMA\s+([A-Z\s]+)/) || [])[1]?.trim() || null,
    tempat_tgl_lahir:
      (cleanText.match(/LAHIR\s+([A-Z\s]+,\s*\d{2}-\d{2}-\d{4})/) || [])[1] ||
      null,
    jenis_kelamin:
      (cleanText.match(/JENIS KELAMIN\s+(LAKI-LAKI|PEREMPUAN)/) || [])[1] ||
      null,
    alamat:
      (cleanText.match(/ALAMAT\s+([A-Z0-9\s,.]+)/) || [])[1]?.trim() || null,
    rt_rw: (cleanText.match(/\bRT\/RW\s*(\d{3}\/\d{3})/) || [])[1] || null,
    kel_desa:
      (cleanText.match(/KEL\/DESA\s*:?([A-Z\s]+)/) || [])[1]?.trim() || null,
    kecamatan:
      (cleanText.match(/KECAMATAN\s*:?([A-Z\s]+)/) || [])[1]?.trim() || null,
    status:
      (cleanText.match(
        /STATUS PERKAWINAN\s*:?([A-Z\s]+)(\d{2}-\d{2}-\d{4})?/
      ) || [])[1]?.trim() || null,
    pekerjaan:
      (cleanText.match(/PEKERJAAN\s*:?([A-Z\s]+)/) || [])[1]?.trim() || null,
    kewarganegaraan:
      (cleanText.match(/KEWARGANEGARAAN\s*:?([A-Z]+)/) || [])[1]?.trim() ||
      null,
    berlaku_hingga:
      (cleanText.match(/BERLAKU HINGGA\s*:?(\d{2}-\d{2}-\d{4})/) || [])[1] ||
      null,
  };
  //   const result = {};

  //   result.nik = (text.match(/NIK\s*[:\-]?\s*(\d{16})/) || [])[1] || null;
  //   result.nama =
  //     (text.match(/Nama\s*[:\-]?\s*(.+)/i) || [])[1]?.split("\n")[0] || null;
  //   result.tempat_tgl_lahir =
  //     (text.match(/Tempat\/Tgl\s*Lahir\s*[:\-]?\s*(.+)/i) || [])[1]?.split(
  //       "\n"
  //     )[0] || null;
  //   result.jenis_kelamin =
  //     (text.match(/Jenis\s*Kelamin\s*[:\-]?\s*(\w+)/i) || [])[1] || null;
  //   result.alamat =
  //     (text.match(/Alamat\s*[:\-]?\s*(.+)/i) || [])[1]?.split("\n")[0] || null;
  //   result.rt_rw =
  //     (text.match(/RT\/RW\s*[:\-]?\s*(\d{3}\/\d{3})/) || [])[1] || null;
  //   result.kel_desa =
  //     (text.match(/Kel\/Desa\s*[:\-]?\s*(.+)/i) || [])[1]?.split("\n")[0] || null;
  //   result.kecamatan =
  //     (text.match(/Kecamatan\s*[:\-]?\s*(.+)/i) || [])[1]?.split("\n")[0] || null;
  //   result.agama = (text.match(/Agama\s*[:\-]?\s*(\w+)/i) || [])[1] || null;
  //   result.status =
  //     (text.match(/Status\s*Perkawinan\s*[:\-]?\s*(.+)/i) ||
  //       text.match(/Status\s*[:\-]?\s*(.+)/i) ||
  //       [])[1]?.split("\n")[0] || null;
  //   result.pekerjaan =
  //     (text.match(/Pekerjaan\s*[:\-]?\s*(.+)/i) || [])[1]?.split("\n")[0] || null;
  //   result.kewarganegaraan =
  //     (text.match(/Kewarganegaraan\s*[:\-]?\s*(\w+)/i) || [])[1] || null;

  //   return result;
};
