import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/client.dart';
import '../services/auth_service.dart';
import '../services/client_service.dart';
import 'add_client_screen.dart';
import 'client_details_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color spaceBlack = Color(0xFF000000);
  static const Color panelBlack = Color(0xFF050505);
  static const Color panelLight = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFF4F7FA);
  static const Color mutedWhite = Color(0xFF9BA7B5);
  static const Color electricBlue = Color(0xFF00A8FF);
  static const Color dangerRed = Color(0xFFFF304F);
  static const Color warningAmber = Color(0xFFFFB020);
  static const Color successGreen = Color(0xFF20E080);

  List<Client> clients = [];

  bool isLoading = true;

  String searchText = '';
  String selectedStatus = 'All';

  final List<String> statuses = [
    'All',
    'New',
    'Contacted',
    'Interested',
    'Follow-up',
    'Negotiating',
    'Won',
    'Lost',
  ];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final loadedClients = await ClientService.getClients();

      if (!mounted) return;

      setState(() {
        clients = loadedClients;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dangerRed,
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.oxanium(color: white, fontSize: 12),
          ),
        ),
      );
    }
  }

  Future<void> openClientDetails(Client client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailsScreen(client: client),
      ),
    );

    if (!mounted) return;

    if (result == 'deleted' || result is Client) {
      await loadDashboard();
    }
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

  List<Client> get filteredClients {
    final search = searchText.toLowerCase().trim();

    return clients.where((client) {
      final matchesSearch =
          client.name.toLowerCase().contains(search) ||
          client.phone.toLowerCase().contains(search) ||
          client.company.toLowerCase().contains(search);

      final matchesStatus =
          selectedStatus == 'All' || client.status == selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  DateTime? getFollowUpDate(Client client) {
    if (client.followUpDate.isEmpty) {
      return null;
    }

    return DateTime.tryParse(client.followUpDate);
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isOverdue(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final followUpDay = DateTime(date.year, date.month, date.day);

    return followUpDay.isBefore(today);
  }

  bool isUpcoming(DateTime date) {
    return !isToday(date) && !isOverdue(date);
  }

  List<Client> get todayFollowUps {
    return clients.where((client) {
      final date = getFollowUpDate(client);
      return date != null && isToday(date);
    }).toList();
  }

  List<Client> get overdueFollowUps {
    return clients.where((client) {
      final date = getFollowUpDate(client);
      return date != null && isOverdue(date);
    }).toList();
  }

  List<Client> get upcomingFollowUps {
    return clients.where((client) {
      final date = getFollowUpDate(client);
      return date != null && isUpcoming(date);
    }).toList();
  }

  String formatDate(String date) {
    final parsed = DateTime.tryParse(date);

    if (parsed == null) {
      return date;
    }

    return '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'won':
      case 'closed':
        return successGreen;

      case 'lost':
        return dangerRed;

      case 'follow-up':
        return warningAmber;

      case 'interested':
      case 'negotiating':
        return electricBlue;

      case 'contacted':
        return const Color(0xFF66D9FF);

      default:
        return mutedWhite;
    }
  }

  Widget hudPanel({required Widget child, Color borderColor = white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelBlack,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    Color color = electricBlue,
  }) {
    return hudPanel(
      borderColor: color,
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.oxanium(
                    color: mutedWhite,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.oxanium(
                    color: white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBadge(Client client) {
    final color = statusColor(client.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        client.status.toUpperCase(),
        style: GoogleFonts.oxanium(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget clientCard(Client client) {
    final color = statusColor(client.status);

    return GestureDetector(
      onTap: () => openClientDetails(client),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panelBlack,
          border: Border(
            left: BorderSide(color: color, width: 3),
            top: const BorderSide(color: white),
            right: const BorderSide(color: white),
            bottom: const BorderSide(color: white),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: panelLight,
                border: Border.all(color: color),
              ),
              child: Text(
                client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                style: GoogleFonts.oxanium(
                  color: color,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.oxanium(
                      color: white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client.phone,
                    style: GoogleFonts.oxanium(color: mutedWhite, fontSize: 10),
                  ),
                  if (client.company.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      client.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.oxanium(
                        color: mutedWhite,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            statusBadge(client),
          ],
        ),
      ),
    );
  }

  Widget followUpCard({required Client client, required bool overdue}) {
    final date = getFollowUpDate(client);
    final color = overdue ? dangerRed : warningAmber;

    return GestureDetector(
      onTap: () => openClientDetails(client),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panelBlack,
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(
              overdue ? Icons.warning_amber_rounded : Icons.calendar_today,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: GoogleFonts.oxanium(
                      color: white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (date != null)
                    Text(
                      'DATE: ${formatDate(client.followUpDate)}',
                      style: GoogleFonts.oxanium(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (client.followUpTime.isNotEmpty)
                    Text(
                      'TIME: ${client.followUpTime}',
                      style: GoogleFonts.oxanium(
                        color: mutedWhite,
                        fontSize: 10,
                      ),
                    ),
                  if (client.followUpReason.isNotEmpty)
                    Text(
                      'REASON: ${client.followUpReason}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.oxanium(
                        color: mutedWhite,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget followUpSection({
    required String title,
    required IconData icon,
    required List<Client> items,
    required bool overdue,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final color = overdue ? dangerRed : warningAmber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.oxanium(
                  color: white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(border: Border.all(color: color)),
              child: Text(
                items.length.toString(),
                style: GoogleFonts.oxanium(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map(
          (client) => followUpCard(client: client, overdue: overdue),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget filterPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelBlack,
        border: Border.all(color: white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt_outlined,
                color: electricBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'CLIENT FILTER',
                style: GoogleFonts.oxanium(
                  color: white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            style: GoogleFonts.oxanium(color: white, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'SEARCH CLIENT...',
              hintStyle: GoogleFonts.oxanium(color: mutedWhite, fontSize: 10),
              prefixIcon: const Icon(Icons.search, color: mutedWhite),
              filled: true,
              fillColor: panelLight,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: mutedWhite),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: mutedWhite),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: electricBlue, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: selectedStatus,
            isExpanded: true,
            dropdownColor: panelLight,
            style: GoogleFonts.oxanium(
              color: white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: electricBlue),
            decoration: InputDecoration(
              labelText: 'STATUS',
              labelStyle: GoogleFonts.oxanium(
                color: mutedWhite,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              floatingLabelStyle: GoogleFonts.oxanium(
                color: electricBlue,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              filled: true,
              fillColor: panelLight,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: mutedWhite),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: mutedWhite),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: electricBlue, width: 1.5),
              ),
            ),
            items: statuses.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.oxanium(
                    color: white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedStatus = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleClients = filteredClients;

    return Scaffold(
      backgroundColor: spaceBlack,
      appBar: AppBar(
        backgroundColor: spaceBlack,
        foregroundColor: white,
        elevation: 0,
        title: Text(
          'SALES//TOOL',
          style: GoogleFonts.oxanium(
            color: white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: white.withValues(alpha: 0.7)),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: electricBlue,
        foregroundColor: spaceBlack,
        elevation: 0,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientScreen()),
          );

          if (!mounted) return;

          if (result is Client) {
            await loadDashboard();
          }
        },
        icon: const Icon(Icons.person_add),
        label: Text(
          'ADD CLIENT',
          style: GoogleFonts.oxanium(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: electricBlue))
          : RefreshIndicator(
              onRefresh: loadDashboard,
              color: electricBlue,
              backgroundColor: panelBlack,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  FutureBuilder<String?>(
                    future: AuthService.getUserName(),
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? 'Agent';

                      return hudPanel(
                        borderColor: electricBlue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SYSTEM ONLINE',
                              style: GoogleFonts.oxanium(
                                color: electricBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'WELCOME, ${name.toUpperCase()}',
                              style: GoogleFonts.oxanium(
                                color: white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: dashboardCard(
                          title: 'Total Clients',
                          value: clients.length.toString(),
                          icon: Icons.people,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: dashboardCard(
                          title: 'Today',
                          value: todayFollowUps.length.toString(),
                          icon: Icons.today,
                          color: warningAmber,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: dashboardCard(
                          title: 'Upcoming',
                          value: upcomingFollowUps.length.toString(),
                          icon: Icons.event,
                          color: electricBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: dashboardCard(
                          title: 'Overdue',
                          value: overdueFollowUps.length.toString(),
                          icon: Icons.warning,
                          color: dangerRed,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  followUpSection(
                    title: 'Today\'s Follow-ups',
                    icon: Icons.today,
                    items: todayFollowUps,
                    overdue: false,
                  ),

                  followUpSection(
                    title: 'Overdue Follow-ups',
                    icon: Icons.warning,
                    items: overdueFollowUps,
                    overdue: true,
                  ),

                  followUpSection(
                    title: 'Upcoming Follow-ups',
                    icon: Icons.event,
                    items: upcomingFollowUps,
                    overdue: false,
                  ),

                  const SizedBox(height: 4),

                  filterPanel(),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Text(
                        'CLIENTS',
                        style: GoogleFonts.oxanium(
                          color: white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${visibleClients.length}',
                        style: GoogleFonts.oxanium(
                          color: electricBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (visibleClients.isEmpty)
                    hudPanel(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'NO CLIENTS FOUND',
                            style: GoogleFonts.oxanium(
                              color: mutedWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...visibleClients.map(clientCard),
                ],
              ),
            ),
    );
  }
}
