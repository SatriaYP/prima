import api from "./api.service";
import { tokenHelper } from "@/utils/token.helper";

class AuthService {
  async login(username, password) {
    try {
      const response = await api.post("/auth/login", {
        username,
        password,
      });
      // console.log(response.data);
      const { user, token } = response.data.data;
      console.log(user, token);
      tokenHelper.saveToken(token);
      tokenHelper.saveUser(user);
      return { user, token };
    } catch (error) {
      throw new Error("Fail");
    }
  }

  async logout() {
    try {
      const token = tokenHelper.getToken();
      const user = tokenHelper.getUser();

      tokenHelper.removeToken(token);
      tokenHelper.removeUser(user);
    } catch (error) {
      console.log(error);
    }
  }
}

export default new AuthService();
