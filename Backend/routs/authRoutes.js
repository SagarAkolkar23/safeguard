import express from "express";

import { authenticate } from "../middleware/authenticate.js";
import { Login, Logout, Register } from "../controller/authController.js";

const authRoute = express.Router();

authRoute.post("/register", Register);
authRoute.post("/login", Login);
authRoute.get("/logout", authenticate, Logout);

export default authRoute;