import axios from "axios";
import { handleError } from "../utils/error.js"; // adjust if you have a global error handler

const AI_BASE_URL = process.env.AI_BASE_URL || "http://127.0.0.1:8000";

export const checkPhishing = async (req, res, next) => {
  try {
    const { url } = req.body;

    if (!url) {
      return next(handleError(400, "URL is required"));
    }

    console.log("🌐 Forwarding URL to AI backend:", url);

    // Forward the URL to FastAPI backend
    const response = await axios.post(`${AI_BASE_URL}/predict`, { url });

    console.log("🤖 AI Model Response:", response.data);

    return res.status(200).json({
      success: true,
      message: "AI prediction fetched successfully",
      data: response.data,
    });
  } catch (error) {
    console.error("❌ Error connecting to AI backend:", error.message);

    if (error.response) {
      // AI backend returned an error
      return next(
        handleError(
          error.response.status,
          error.response.data.detail || "AI backend error"
        )
      );
    }

    return next(handleError(500, "Failed to connect to AI backend"));
  }
};
