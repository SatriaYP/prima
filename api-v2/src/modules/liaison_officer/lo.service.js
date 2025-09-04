import prisma from "../../lib/prisma.js";

class LiaisonOfficerSercive {
  getAllLiaisonOfficer = async () => {
    return await prisma.liaisonOfficer.findMany();
  };

  getLiaisonOfficerById = async (id) => {
    return await prisma.liaisonOfficer.findUnique({ where: { id } });
  };

  createLiaisonOfficer = async (payload) => {
    return await prisma.liaisonOfficer.create({ data: payload });
  };

  updateLiaisonOfficer = async (id, payload) => {
    return await prisma.liaisonOfficer.update({ where: { id }, data: payload });
  };

  deleteLiaisonOfficers = async (id) => {
    return await prisma.liaisonOfficer.delete({ where: { id } });
  };
}

export default new LiaisonOfficerSercive();
