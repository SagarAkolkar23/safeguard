// controller/phishController.js
import axios from "axios";
import { handleError } from "../utils/error.js";
import PhishCheck from "../models/phishCheckSchema .js";

const AI_BASE_URL = process.env.AI_BASE_URL || "http://127.0.0.1:8000";

/**
 * @desc Forward a URL to FastAPI backend and store prediction in MongoDB
 * @route POST /api/phish/check
 */
export const checkPhishing = async (req, res, next) => {
  try {
    const { url } = req.body;

    if (!url) {
      return next(handleError(400, "URL is required"));
    }

    console.log("🌐 Forwarding URL to AI backend:", url);

    // Call the FastAPI model
    const response = await axios.post(`${AI_BASE_URL}/predict`, { url });
    const aiData = response.data;

    console.log("🤖 AI Model Response:", aiData);

    // ✅ Save the response in MongoDB
    const record = await PhishCheck.create({
      url: aiData.url,
      is_phishing: aiData.is_phishing,
      prediction: aiData.prediction,
      confidence: aiData.confidence,
      probability: aiData.probability,
      risk_level: aiData.risk_level,
      timestamp: aiData.timestamp,
    });

    console.log("💾 Saved to database:", record._id);

    return res.status(201).json({
      success: true,
      message: "Prediction stored successfully",
      data: record,
    });
  } catch (error) {
    console.error("❌ Error connecting to AI backend:", error.message);

    if (error.response) {
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
