import AuthService from "./auth.service.js";

class AuthController {
  login = async (req, res) => {
    try {
      const { user, token } = await AuthService.login(req.body);

      return res.json({
        status: "success",
        data: {
          user,
          token,
        },
      });
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  };
}

export default new AuthController();
