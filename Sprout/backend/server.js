// server.js  (Albert)
// Main Express server and route registration
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import connectDB from "./db/connect.js";

// route imports
import scanIngredientsRoutes from "./routes/scanIngredients.js";
import scanMenuRoutes from "./routes/scanMenu.js";
import scanReceiptRoutes from "./routes/scanReceipt.js";
import veganizeRoutes from "./routes/veganize.js";
import cookRoutes from "./routes/cookWithThis.js";
import impactRoutes from "./routes/impact.js";
import groceryListRoutes from "./routes/groceryList.js";
import recipeRoutes from "./routes/recipes.js";
import profileRoutes from "./routes/profile.js";
import onboardingRoutes from "./routes/onboarding.js";
import homeRoutes from "./routes/home.js";
import alternativeProductRoutes from "./routes/alternativeProduct.js";
import chatRoutes from "./routes/chat.js";

dotenv.config();

await connectDB(); // connect to MongoDB

const app = express();
app.use(cors());
app.use(express.json({ limit: "2mb" }));

// health
app.get("/", (req, res) => res.json({ ok: true, msg: "Veganify backend (Albert focus) running" }));

// register routes
app.use("/scan/ingredients", scanIngredientsRoutes);
app.use("/scan/menu", scanMenuRoutes);
app.use("/scan/receipt", scanReceiptRoutes);
app.use("/recipes/veganize", veganizeRoutes);
app.use("/recipes/from-ingredients", cookRoutes);
app.use("/recipes", recipeRoutes);
app.use("/impact", impactRoutes);
app.use("/grocery-list", groceryListRoutes);
app.use("/profile", profileRoutes);
app.use("/onboarding", onboardingRoutes);
app.use("/home", homeRoutes);
app.use("/progress", homeRoutes); // Reuse home routes for progress endpoints
app.use("/scan/alternative-product", alternativeProductRoutes);
app.use("/chat", chatRoutes);

// basic error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message || "Internal Server Error" });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Server listening on ${PORT}`));
 
