import express from "express";
import { checkPhishing } from "../controller/phishController.js";

const router = express.Router();

router.post("/phish", checkPhishing);

export default router;
