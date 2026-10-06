const mongoose = require("mongoose");

const pushTokenSchema = new mongoose.Schema(
  {
    token: {
      type: String,
      required: true,
    },

    platform: {
      type: String,
      enum: ["android", "ios", "web", "unknown"],
      default: "unknown",
    },

    updatedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    _id: false,
  }
);

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    role: {
      type: String,
      enum: ["agent", "admin"],
      default: "agent",
    },

    pushTokens: {
      type: [pushTokenSchema],
      default: [],
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("User", userSchema);