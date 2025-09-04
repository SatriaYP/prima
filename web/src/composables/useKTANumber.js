export const useKtaNumber = () => {
  const generateKtaNumber = () => {
    const currentYear = new Date().getFullYear().toString();

    // Ambil data dari localStorage
    const rawData = localStorage.getItem("ktaSequence");
    let sequence = rawData ? JSON.parse(rawData) : {};

    // Ambil nomor urut tahun ini, default 1
    if (!sequence[currentYear]) {
      sequence[currentYear] = 1;
    }

    // Format nomor urut ke 4 digit (0001, 0002, dst)
    const paddedNumber = String(sequence[currentYear]).padStart(4, "0");

    // Buat KTA number
    const ktaNumber = `KTA-${currentYear}${paddedNumber}`;

    // Simpan urutan berikutnya
    sequence[currentYear] += 1;
    localStorage.setItem("ktaSequence", JSON.stringify(sequence));

    return ktaNumber;
  };

  return {
    generateKtaNumber,
  };
};
