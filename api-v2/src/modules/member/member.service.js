import prisma from "../../lib/prisma.js";

class MemberService {
  // getMembers = async () => {
  //   return await prisma.member.findMany();
  // };

  getMembers = async (page = 1, limit = 15) => {
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      prisma.member.findMany({
        skip,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          province: {
            select: { id: true, name: true, code: true },
          },
          city: {
            select: { id: true, name: true, code: true },
          },
          district: {
            select: { id: true, name: true, code: true },
          },
          village: {
            select: { id: true, name: true, code: true },
          },
          registeredBy: {
            select: { id: true, name: true, role: true },
          },
        },
      }),
      prisma.member.count(),
    ]);
    console.log(data, total);

    return {
      data,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  };

  getMemberById = async (id) => {
    return await prisma.member.findUnique({ where: { id } });
  };

  createMember = async (payload) => {
    return await prisma.member.create({ data: payload });
  };

  updateMember = async (id, payload) => {
    return await prisma.member.update({ where: { id }, data: payload });
  };

  deleteMember = async (id) => {
    return await prisma.member.delete({ where: { id } });
  };

  /**
   * Ambil nomor KTA terakhir berdasarkan prefix wilayah
   * @param {string} prefix - Kode wilayah (misal "320101")
   * @returns {string|null} Nomor KTA terakhir atau null jika belum ada
   */
  getLastKtaByPrefix = async (prefix) => {
    // console.log(prefix);
    const last = await prisma.member.findFirst({
      where: { ktaNumber: { startsWith: prefix } },
      orderBy: { ktaNumber: "desc" },
      select: { ktaNumber: true },
    });
    return { lastNumber: last?.ktaNumber || null, prefix };
  };

  /**
   * Cek apakah KTA sudah digunakan
   * @param {string} ktaNumber - Nomor KTA yang ingin dicek
   * @returns {boolean}
   */
  isKtaExists = async (ktaNumber) => {
    const count = await prisma.member.count({
      where: { ktaNumber },
    });
    return { countKTA: count > 0 || null };
  };
}

export default new MemberService();
