import api from "./api.service";

class MemberService {
  async getMembers(params = {}) {
    try {
      const response = await api.get("/members", { params });
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  async getMemberById(id) {
    try {
      const response = await api.get(`/members/${id}`);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  async createMember(payload) {
    try {
      const response = await api.post("/members", payload);
      return response.data;
    } catch (error) {
      throw (
        error.response?.data ||
        error.message ||
        "Terjadi kesalahan saat menyimpan data"
      );
    }
  }

  async updateMember(id, payload) {
    try {
      const response = await api.put(`/members/${id}`, payload);
      return response.data;
    } catch (error) {
      throw (
        error.response?.data ||
        error.message ||
        "Terjadi kesalahan saat update data"
      );
    }
  }

  async deleteMember(id) {
    try {
      const response = await api.delete(`/members/${id}`);
      if (response.status) {
        return { status: response.status, message: "Delete data berhasil!" };
      }
    } catch (error) {
      throw (
        error.response?.data ||
        error.message ||
        "Terjadi kesalahan saat delete data"
      );
    }
  }
  async checkNikUniqueness(nik) {
    try {
      const response = await api.get(`/members/check-nik`, {
        params: { nik } // Kirim NIK sebagai query parameter
      });
      return response.data; // { exists: true/false, message: "..." }
    } catch (error) {
      throw (
        error.response?.data ||
        error.message ||
        "Gagal memeriksa NIK. Silakan coba lagi."
      );
    }
  }

}

export default new MemberService();
