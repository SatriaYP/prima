import prisma from "../../lib/prisma.js";

class OfficialService {
  getAllOfficial = async () => {
    return await prisma.official.findMany();
  };

  getOfficialById = async (id) => {
    return await prisma.official.findUnique({ where: { id } });
  };

  createOfficial = async (payload) => {
    return await prisma.official.create({ data: payload });
  };

  updateOfficial = async (id, payload) => {
    return await prisma.official.update({ where: { id }, data: payload });
  };

  deleteOfficial = async (id) => {
    return await prisma.official.delete({ where: { id } });
  };
}

export default new OfficialService();
