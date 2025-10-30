import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";
import mongoose from "mongoose";
import authRoute from "./routs/authRoutes.js";
import phishRoute from "./routs/phishRoutes.js"
dotenv.config();

const PORT = process.env.PORT;
const app = express();

app.use(cookieParser());
app.use(express.json());
app.use(
  cors({
    origin: "*",
    credentials: true,
  })
);

app.use("/auth", authRoute);
app.use("/phish", phishRoute);

mongoose
  .connect(process.env.MONGODB_CONN, { dbName: "BlogIt" })
  .then(() => {
    console.log("Database connected");
  })
  .catch((err) => console.log("Database connection failed:", err));


app.listen(PORT, () => {
  const backendUrl = `http://localhost:${PORT}`;
  console.log(`🚀 Server running at: ${backendUrl}`);
});

app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal server error";
  res.status(statusCode).json({
    success: false,
    statusCode,
    message,
  });
});