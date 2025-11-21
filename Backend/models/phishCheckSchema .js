import mongoose from "mongoose";

const phishCheckSchema = new mongoose.Schema({
  url: { type: String, required: true },
  is_phishing: { type: Boolean, required: true },
  prediction: { type: Number, required: true },
  confidence: { type: Number, required: true },
  probability: { type: Number, required: true },
  risk_level: { type: String, enum: ["LOW", "MEDIUM", "HIGH"], required: true },
  timestamp: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

export default mongoose.model("PhishCheck", phishCheckSchema);
