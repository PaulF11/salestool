const User = require("../models/User");

const adminMiddleware = async (
  req,
  res,
  next
) => {
  try {
    if (!req.userId) {
      return res.status(401).json({
        message: "Authentication required",
      });
    }

    const user = await User.findById(
      req.userId
    );

    if (!user) {
      return res.status(401).json({
        message: "User not found",
      });
    }

    if (user.role !== "admin") {
      return res.status(403).json({
        message:
          "Admin access required",
      });
    }

    req.userRole = user.role;

    next();
  } catch (error) {
    console.error(
      "Admin middleware error:",
      error
    );

    res.status(500).json({
      message:
        "Failed to verify admin access",
    });
  }
};

module.exports = adminMiddleware;
