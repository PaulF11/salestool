const express = require("express");

const User = require("../models/User");
const Client = require("../models/Client");

const authMiddleware = require("../middleware/authMiddleware");
const adminMiddleware = require("../middleware/adminMiddleware");

const router = express.Router();

// Get all agents
router.get(
  "/agents",
  authMiddleware,
  adminMiddleware,
  async (req, res) => {
    try {
      const agents =
        await User.find({
          role: "agent",
        })
          .select("-password")
          .sort({ createdAt: -1 });

      const agentsWithClientCount =
        await Promise.all(
          agents.map(async (agent) => {
            const clientCount =
              await Client.countDocuments({
                agentId: agent._id,
              });

            return {
              id: agent._id,
              name: agent.name,
              email: agent.email,
              role: agent.role,
              createdAt:
                  agent.createdAt,
              clientCount,
            };
          })
        );

      res.json(
        agentsWithClientCount
      );
    } catch (error) {
      console.error(
        "Get agents error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to get agents",
        error: error.message,
      });
    }
  }
);

// Get all clients
router.get(
  "/clients",
  authMiddleware,
  adminMiddleware,
  async (req, res) => {
    try {
      const clients =
        await Client.find()
          .populate(
            "agentId",
            "name email"
          )
          .sort({ createdAt: -1 });

      res.json(clients);
    } catch (error) {
      console.error(
        "Get all clients error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to get clients",
        error: error.message,
      });
    }
  }
);

// Get admin dashboard summary
router.get(
  "/summary",
  authMiddleware,
  adminMiddleware,
  async (req, res) => {
    try {
      const agentCount =
        await User.countDocuments({
          role: "agent",
        });

      const clientCount =
        await Client.countDocuments();

      const newClients =
        await Client.countDocuments({
          status: "New",
        });

      const interestedClients =
        await Client.countDocuments({
          status: "Interested",
        });

      const followUpClients =
        await Client.countDocuments({
          status: "Follow-up",
        });

      const negotiatingClients =
        await Client.countDocuments({
          status: "Negotiating",
        });

      const closedClients =
        await Client.countDocuments({
          status: "Closed",
        });

      const lostClients =
        await Client.countDocuments({
          status: "Lost",
        });

      res.json({
        agentCount,
        clientCount,
        statuses: {
          new: newClients,
          interested:
              interestedClients,
          followUp:
              followUpClients,
          negotiating:
              negotiatingClients,
          closed:
              closedClients,
          lost:
              lostClients,
        },
      });
    } catch (error) {
      console.error(
        "Get admin summary error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to get admin summary",
        error: error.message,
      });
    }
  }
);

module.exports = router;

