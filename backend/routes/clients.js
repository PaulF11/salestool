const express = require("express");
const Client = require("../models/Client");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

// Get only the logged-in agent's clients
router.get("/", authMiddleware, async (req, res) => {
  try {
    const clients = await Client.find({
      agentId: req.userId,
    }).sort({ createdAt: -1 });

    res.json(clients);
  } catch (error) {
    console.error(
      "Get clients error:",
      error.message
    );

    res.status(500).json({
      message: "Failed to get clients",
      error: error.message,
    });
  }
});

// Add a new client
router.post("/", authMiddleware, async (req, res) => {
  try {
    const {
      name,
      phone,
      email,
      company,
      address,
      productInterest,
      productModel,
      budget,
      paymentType,
      status,
      leadSource,
      followUpDate,
      followUpTime,
      followUpReason,
      estimatedDealValue,
      lastContactDate,
      lastContactResult,
      notes,
    } = req.body;

    if (!name || !phone) {
      return res.status(400).json({
        message: "Name and phone are required",
      });
    }

    const client = await Client.create({
      agentId: req.userId,
      name,
      phone,
      email,
      company,
      address,
      productInterest,
      productModel,
      budget,
      paymentType,
      status,
      leadSource,
      followUpDate:
        followUpDate || null,
      followUpTime,
      followUpReason,
      estimatedDealValue,
      lastContactDate:
        lastContactDate || null,
      lastContactResult,
      notes,
    });

    res.status(201).json({
      message: "Client added successfully",
      client,
    });
  } catch (error) {
    console.error(
      "ADD CLIENT ERROR:",
      error
    );

    res.status(500).json({
      message: "Failed to add client",
      error: error.message,
    });
  }
});

// Update a client
router.put(
  "/:id",
  authMiddleware,
  async (req, res) => {
    try {
      const {
        name,
        phone,
        email,
        company,
        address,
        productInterest,
        productModel,
        budget,
        paymentType,
        status,
        leadSource,
        followUpDate,
        followUpTime,
        followUpReason,
        estimatedDealValue,
        lastContactDate,
        lastContactResult,
        notes,
      } = req.body;

      const client =
        await Client.findOne({
          _id: req.params.id,
          agentId: req.userId,
        });

      if (!client) {
        return res.status(404).json({
          message: "Client not found",
        });
      }

      client.name = name;
      client.phone = phone;
      client.email = email;
      client.company = company;
      client.address = address;
      client.productInterest =
        productInterest;
      client.productModel = productModel;
      client.budget = budget;
      client.paymentType = paymentType;
      client.status = status;
      client.leadSource = leadSource;
      client.followUpDate =
        followUpDate || null;
      client.followUpTime =
        followUpTime;
      client.followUpReason =
        followUpReason;
      client.estimatedDealValue =
        estimatedDealValue;
      client.lastContactDate =
        lastContactDate || null;
      client.lastContactResult =
        lastContactResult;
      client.notes = notes;

      await client.save();

      res.json({
        message:
          "Client updated successfully",
        client,
      });
    } catch (error) {
      console.error(
        "UPDATE CLIENT ERROR:",
        error
      );

      res.status(500).json({
        message:
          "Failed to update client",
        error: error.message,
      });
    }
  }
);

// Add contact history
router.post(
  "/:id/contact-history",
  authMiddleware,
  async (req, res) => {
    try {
      const {
        contactDate,
        contactMethod,
        result,
        notes,
      } = req.body;

      const client =
        await Client.findOne({
          _id: req.params.id,
          agentId: req.userId,
        });

      if (!client) {
        return res.status(404).json({
          message: "Client not found",
        });
      }

      client.contactHistory.push({
        contactDate:
          contactDate || new Date(),
        contactMethod:
          contactMethod || "Call",
        result: result || "",
        notes: notes || "",
      });

      client.lastContactDate =
        contactDate || new Date();

      client.lastContactResult =
        result || "";

      await client.save();

      res.status(201).json({
        message:
          "Contact history added successfully",
        contact:
          client.contactHistory[
            client.contactHistory.length - 1
          ],
      });
    } catch (error) {
      console.error(
        "ADD CONTACT HISTORY ERROR:",
        error
      );

      res.status(500).json({
        message:
          "Failed to add contact history",
        error: error.message,
      });
    }
  }
);

// Get contact history
router.get(
  "/:id/contact-history",
  authMiddleware,
  async (req, res) => {
    try {
      const client =
        await Client.findOne({
          _id: req.params.id,
          agentId: req.userId,
        });

      if (!client) {
        return res.status(404).json({
          message: "Client not found",
        });
      }

      res.json(
        client.contactHistory || []
      );
    } catch (error) {
      console.error(
        "GET CONTACT HISTORY ERROR:",
        error
      );

      res.status(500).json({
        message:
          "Failed to get contact history",
        error: error.message,
      });
    }
  }
);

// Delete a client
router.delete(
  "/:id",
  authMiddleware,
  async (req, res) => {
    try {
      const client =
        await Client.findOne({
          _id: req.params.id,
          agentId: req.userId,
        });

      if (!client) {
        return res.status(404).json({
          message: "Client not found",
        });
      }

      await Client.deleteOne({
        _id: req.params.id,
        agentId: req.userId,
      });

      res.json({
        message:
          "Client deleted successfully",
      });
    } catch (error) {
      console.error(
        "DELETE CLIENT ERROR:",
        error
      );

      res.status(500).json({
        message:
          "Failed to delete client",
        error: error.message,
      });
    }
  }
);

module.exports = router;