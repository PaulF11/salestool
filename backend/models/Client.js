const mongoose = require("mongoose");

const contactHistorySchema = new mongoose.Schema(
  {
    contactDate: {
      type: Date,
      default: Date.now,
    },

    contactMethod: {
      type: String,
      default: "Call",
    },

    result: {
      type: String,
      default: "",
    },

    notes: {
      type: String,
      default: "",
    },
  },
  {
    timestamps: true,
  }
);

const clientSchema = new mongoose.Schema(
  {
    agentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    name: {
      type: String,
      required: true,
    },

    phone: {
      type: String,
      required: true,
    },

    email: {
      type: String,
      default: "",
    },

    company: {
      type: String,
      default: "",
    },

    address: {
      type: String,
      default: "",
    },

    productInterest: {
      type: String,
      default: "",
    },

    productModel: {
      type: String,
      default: "",
    },

    budget: {
      type: String,
      default: "",
    },

    paymentType: {
      type: String,
      default: "",
    },

    status: {
      type: String,
      default: "New",
    },

    leadSource: {
      type: String,
      default: "",
    },

    followUpDate: {
      type: Date,
      default: null,
    },

    followUpTime: {
      type: String,
      default: "",
    },

    followUpReason: {
      type: String,
      default: "",
    },

    estimatedDealValue: {
      type: String,
      default: "",
    },

    lastContactDate: {
      type: Date,
      default: null,
    },

    lastContactResult: {
      type: String,
      default: "",
    },

    notes: {
      type: String,
      default: "",
    },

    contactHistory: {
      type: [contactHistorySchema],
      default: [],
    },
  },
  {
    timestamps: true,
  }
);

module.exports =
  mongoose.model("Client", clientSchema);