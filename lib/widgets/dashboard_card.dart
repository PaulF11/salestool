import 'package:flutter/material.dart';

import '../models/client.dart';
import '../services/auth_service.dart';
import '../services/client_service.dart';
import '../screens/client_details_screen.dart';
import '../screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = '';
  List<Client> clients = [];
  List<Client> filteredClients = [];

  bool isLoading = true;

  final searchController = TextEditingController();

  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();

    loadDashboard();
    searchController.addListener(filterClients);
  }

  Future<void> loadDashboard() async {
    try {
      final name = await AuthService.getUserName();

      final clientList = await ClientService.getClients();

      if (!mounted) return;

      setState(() {
        userName = name ?? 'Agent';
        clients = clientList;
        filteredClients = clientList;
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

  void filterClients() {
    final search = searchController.text.toLowerCase();

    setState(() {
      filteredClients = clients.where((client) {
        final matchesSearch =
            client.name.toLowerCase().contains(search) ||
            client.phone.toLowerCase().contains(search) ||
            client.company.toLowerCase().contains(search) ||
            client.productInterest.toLowerCase().contains(search);

        final matchesStatus =
            selectedStatus == 'All' || client.status == selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  int countStatus(String status) {
    return clients.where((client) => client.status == status).length;
  }

  Future<void> openClient(Client client) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailsScreen(client: client),
      ),
    );

    if (deleted == true) {
      await loadDashboard();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SalesTool',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: loadDashboard, icon: const Icon(Icons.refresh)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                logout();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
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
                    Text(
                      'Welcome, $userName',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Manage your clients and follow-ups.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: dashboardCard(
                            'Total Clients',
                            clients.length.toString(),
                            Icons.people,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: dashboardCard(
                            'New',
                            countStatus('New').toString(),
                            Icons.person_add,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: dashboardCard(
                            'Interested',
                            countStatus('Interested').toString(),
                            Icons.thumb_up,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: dashboardCard(
                            'Follow-up',
                            countStatus('Follow-up').toString(),
                            Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search clients',
                        hintText: 'Name, phone, company, or product',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController.clear();
                                },
                                icon: const Icon(Icons.clear),
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'New', child: Text('New')),
                        DropdownMenuItem(
                          value: 'Interested',
                          child: Text('Interested'),
                        ),
                        DropdownMenuItem(
                          value: 'Follow-up',
                          child: Text('Follow-up'),
                        ),
                        DropdownMenuItem(
                          value: 'Negotiating',
                          child: Text('Negotiating'),
                        ),
                        DropdownMenuItem(
                          value: 'Closed',
                          child: Text('Closed'),
                        ),
                        DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value ?? 'All';
                        });

                        filterClients();
                      },
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Clients',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${filteredClients.length} client(s)',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (filteredClients.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.people_outline, size: 55),
                                const SizedBox(height: 10),
                                Text(
                                  clients.isEmpty
                                      ? 'No clients yet.'
                                      : 'No matching clients.',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ...filteredClients.map((client) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              child: Text(
                                client.name.isNotEmpty ? client.name[0] : '?',
                              ),
                            ),
                            title: Text(
                              client.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(client.phone),
                                if (client.company.isNotEmpty)
                                  Text(client.company),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.withValues(alpha: 0.15),
                                  ),
                                  child: Text(
                                    client.status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                            ),
                            onTap: () => openClient(client),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget dashboardCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
