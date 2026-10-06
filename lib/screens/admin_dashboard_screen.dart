import 'package:flutter/material.dart';

import '../services/admin_service.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isLoading = true;

  int agentCount = 0;
  int clientCount = 0;

  int newClients = 0;
  int interestedClients = 0;
  int followUpClients = 0;
  int negotiatingClients = 0;
  int closedClients = 0;
  int lostClients = 0;

  Future<void> loadDashboard() async {
    try {
      final data = await AdminService.getSummary();

      if (!mounted) return;

      setState(() {
        agentCount = data['agentCount'] ?? 0;

        clientCount = data['clientCount'] ?? 0;

        final statuses = data['statuses'] ?? {};

        newClients = statuses['new'] ?? 0;

        interestedClients = statuses['interested'] ?? 0;

        followUpClients = statuses['followUp'] ?? 0;

        negotiatingClients = statuses['negotiating'] ?? 0;

        closedClients = statuses['closed'] ?? 0;

        lostClients = statuses['lost'] ?? 0;

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> logout() async {
    await AdminService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: loadDashboard, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: summaryCard(
                            'Agents',
                            agentCount,
                            Icons.people,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: summaryCard(
                            'Clients',
                            clientCount,
                            Icons.business_center,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Client Status',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    statusCard('New', newClients, Icons.person_add),

                    statusCard('Interested', interestedClients, Icons.thumb_up),

                    statusCard(
                      'Follow-up',
                      followUpClients,
                      Icons.calendar_today,
                    ),

                    statusCard(
                      'Negotiating',
                      negotiatingClients,
                      Icons.handshake,
                    ),

                    statusCard('Closed', closedClients, Icons.check_circle),

                    statusCard('Lost', lostClients, Icons.cancel),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Agent management will be added next.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people),
                        label: const Text(
                          'MANAGE AGENTS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Client management will be added next.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.business_center),
                        label: const Text(
                          'VIEW ALL CLIENTS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget summaryCard(String title, int value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 12),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget statusCard(String title, int value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
