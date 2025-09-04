import prisma from "../../lib/prisma.js";
import { comparePassword } from "../../utils/passwordHandler.js";
import { signToken } from "../../utils/jwt.js";

class AuthService {
  login = async ({ username, password }) => {
    const user = await prisma.user.findUnique({ where: { username } });
    if (!user) throw new Error("User not found");

    const isMatch = await comparePassword(password, user.password);
    if (!isMatch) throw new Error("Invalid credentials");

    return {
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
      },
      token: signToken({
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
      }),
    };
  };
}

export default new AuthService();
