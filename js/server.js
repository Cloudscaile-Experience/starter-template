const express = require("express");

const app = express();
const PORT = process.env.PORT || 8000;

app.get("/open/init", (_req, res) => {
  res.json({
    message: "Response from backend",
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
