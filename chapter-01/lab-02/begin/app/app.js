import express from "express";

const app = express();
app.set("view engine", "ejs");

app.get("/", (req, res) => {
  res.render("hello", {metrics: {synergy: "97.4%", powerpoint: "4 min", maturity: "Bronze+"}});
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Listening on port ${port}`);
});
