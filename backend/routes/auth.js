const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// Register
router.post("/register", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        message: "Name, email, and password are required",
      });
    }

    const cleanName = name.trim();
    const cleanEmail = email.trim().toLowerCase();

    if (!cleanName || !cleanEmail || !password) {
      return res.status(400).json({
        message: "Name, email, and password are required",
      });
    }

    // Check if name is already taken.
    // Case-insensitive: Tony, tony, and TONY are treated as the same name.
    const existingName = await User.findOne({
      name: {
        $regex: `^${escapeRegex(cleanName)}$`,
        $options: "i",
      },
    });

    if (existingName) {
      return res.status(400).json({
        message: "Name is already taken. Please choose another name.",
      });
    }

    // Check if email is already registered.
    const existingEmail = await User.findOne({
      email: cleanEmail,
    });

    if (existingEmail) {
      return res.status(400).json({
        message: "Email is already registered",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name: cleanName,
      email: cleanEmail,
      password: hashedPassword,
      role: "agent",
    });

    res.status(201).json({
      message: "Agent registered successfully",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Registration error:", error);

    // Handle duplicate email/name database errors gracefully.
    if (error.code === 11000) {
      if (error.keyPattern && error.keyPattern.email) {
        return res.status(400).json({
          message: "Email is already registered",
        });
      }

      if (error.keyPattern && error.keyPattern.name) {
        return res.status(400).json({
          message: "Name is already taken. Please choose another name.",
        });
      }

      return res.status(400).json({
        message: "An account with those details already exists.",
      });
    }

    res.status(500).json({
      message: "Registration failed",
      error: error.message,
    });
  }
});

// Login
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password are required",
      });
    }

    const cleanEmail = email.trim().toLowerCase();

    const user = await User.findOne({
      email: cleanEmail,
    });

    if (!user) {
      return res.status(401).json({
        message: "Invalid email or password",
      });
    }

    const passwordMatch = await bcrypt.compare(
      password,
      user.password
    );

    if (!passwordMatch) {
      return res.status(401).json({
        message: "Invalid email or password",
      });
    }

    const token = jwt.sign(
      {
        userId: user._id,
        role: user.role,
      },
      process.env.JWT_SECRET
    );

    res.json({
      message: "Login successful",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("Login error:", error);

    res.status(500).json({
      message: "Login failed",
      error: error.message,
    });
  }
});

// Register FCM token
router.post("/fcm-token", authMiddleware, async (req, res) => {
  try {
    const { token, platform } = req.body;

    if (!token || typeof token !== "string") {
      return res.status(400).json({
        message: "FCM token is required",
      });
    }

    const allowedPlatforms = [
      "android",
      "ios",
      "web",
      "unknown",
    ];

    const normalizedPlatform = allowedPlatforms.includes(platform)
      ? platform
      : "unknown";

    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    const existingTokenIndex = user.pushTokens.findIndex(
      (item) => item.token === token
    );

    if (existingTokenIndex >= 0) {
      user.pushTokens[existingTokenIndex].platform =
        normalizedPlatform;

      user.pushTokens[existingTokenIndex].updatedAt =
        new Date();
    } else {
      user.pushTokens.push({
        token,
        platform: normalizedPlatform,
        updatedAt: new Date(),
      });
    }

    await user.save();

    res.json({
      message: "FCM token registered successfully",
      platform: normalizedPlatform,
    });
  } catch (error) {
    console.error("FCM token registration error:", error);

    res.status(500).json({
      message: "Failed to register FCM token",
      error: error.message,
    });
  }
});

// Remove FCM token
router.delete("/fcm-token", authMiddleware, async (req, res) => {
  try {
    const { token } = req.body;

    if (!token || typeof token !== "string") {
      return res.status(400).json({
        message: "FCM token is required",
      });
    }

    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    user.pushTokens = user.pushTokens.filter(
      (item) => item.token !== token
    );

    await user.save();

    res.json({
      message: "FCM token removed successfully",
    });
  } catch (error) {
    console.error("FCM token removal error:", error);

    res.status(500).json({
      message: "Failed to remove FCM token",
      error: error.message,
    });
  }
});

// Escape special characters before using a name inside a regex.
function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

module.exports = router;