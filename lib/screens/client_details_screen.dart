import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/client.dart';
import '../services/client_service.dart';
import 'edit_client_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  final Client client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  static const Color spaceBlack = Color(0xFF000000);
  static const Color panelBlack = Color(0xFF050505);
  static const Color panelLight = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFF4F7FA);
  static const Color mutedWhite = Color(0xFF9BA7B5);
  static const Color electricBlue = Color(0xFF00A8FF);
  static const Color dangerRed = Color(0xFFFF304F);
  static const Color warningAmber = Color(0xFFFFB020);
  static const Color successGreen = Color(0xFF20E080);

  late Client client;

  List<Map<String, dynamic>> contactHistory = [];

  bool isLoadingHistory = true;
  bool isSavingContact = false;

  @override
  void initState() {
    super.initState();

    client = widget.client;

    loadContactHistory();
  }

  Future<void> loadContactHistory() async {
    try {
      final history = await ClientService.getContactHistory(client.id);

      if (!mounted) return;

      setState(() {
        contactHistory = history;
        isLoadingHistory = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        contactHistory = client.contactHistory;
        isLoadingHistory = false;
      });
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'closed':
        return successGreen;

      case 'lost':
        return dangerRed;

      case 'follow-up':
        return warningAmber;

      case 'interested':
        return electricBlue;

      case 'contacted':
        return const Color(0xFF66D9FF);

      default:
        return mutedWhite;
    }
  }

  String formatDate(String value) {
    if (value.isEmpty) {
      return 'NOT SET';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatDateTime(dynamic value) {
    if (value == null) {
      return 'UNKNOWN DATE';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    final local = date.toLocal();

    return '${local.month.toString().padLeft(2, '0')}/'
        '${local.day.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  Widget cornerLine({bool top = true, bool left = true}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: SizedBox(
        width: 25,
        height: 25,
        child: CustomPaint(
          painter: CornerPainter(color: white, top: top, left: left),
        ),
      ),
    );
  }

  Widget hudPanel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    Color borderColor = white,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: panelBlack,
            border: Border.all(color: borderColor.withOpacity(0.75)),
          ),
          child: child,
        ),
        cornerLine(),
        cornerLine(top: true, left: false),
        cornerLine(top: false, left: true),
        cornerLine(top: false, left: false),
      ],
    );
  }

  Widget sectionLabel(String title, {required Color color, IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          title.toUpperCase(),
          style: GoogleFonts.oxanium(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: color.withOpacity(0.4))),
      ],
    );
  }

  Widget infoRow(
    String label,
    String value, {
    Color valueColor = white,
    IconData? icon,
  }) {
    if (value.trim().isEmpty) {
      value = 'NOT SET';
      valueColor = mutedWhite;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: mutedWhite),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: 120,
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.oxanium(
                color: mutedWhite,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.oxanium(
                color: valueColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBadge() {
    final color = statusColor(client.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: color.withOpacity(0.06),
      ),
      child: Text(
        client.status.toUpperCase(),
        style: GoogleFonts.oxanium(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Future<void> callClient() async {
    if (client.phone.trim().isEmpty) {
      showActionMessage('NO PHONE NUMBER AVAILABLE', dangerRed);
      return;
    }

    final uri = Uri(scheme: 'tel', path: client.phone.trim());

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        showActionMessage('COULD NOT OPEN PHONE DIALER', dangerRed);
      }
    } catch (_) {
      if (!mounted) return;

      showActionMessage('COULD NOT OPEN PHONE DIALER', dangerRed);
    }
  }

  Future<void> smsClient() async {
    if (client.phone.trim().isEmpty) {
      showActionMessage('NO PHONE NUMBER AVAILABLE', dangerRed);
      return;
    }

    final uri = Uri(scheme: 'sms', path: client.phone.trim());

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        showActionMessage('COULD NOT OPEN MESSAGING APP', dangerRed);
      }
    } catch (_) {
      if (!mounted) return;

      showActionMessage('COULD NOT OPEN MESSAGING APP', dangerRed);
    }
  }

  Future<void> emailClient() async {
    if (client.email.trim().isEmpty) {
      showActionMessage('NO EMAIL ADDRESS AVAILABLE', dangerRed);
      return;
    }

    final uri = Uri(scheme: 'mailto', path: client.email.trim());

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        showActionMessage('COULD NOT OPEN EMAIL APP', dangerRed);
      }
    } catch (_) {
      if (!mounted) return;

      showActionMessage('COULD NOT OPEN EMAIL APP', dangerRed);
    }
  }

  void showActionMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          style: GoogleFonts.oxanium(
            color: color == dangerRed ? white : spaceBlack,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget quickContactButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.8)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.oxanium(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> editClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditClientScreen(client: client)),
    );

    if (result is Client) {
      if (!mounted) return;

      setState(() {
        client = result;
      });

      await loadContactHistory();
    }
  }

  Future<void> deleteClient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: panelLight,
          title: Text(
            'DELETE CLIENT?',
            style: GoogleFonts.oxanium(
              color: white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'This will permanently delete ${client.name} and their contact history.',
            style: GoogleFonts.oxanium(color: mutedWhite, fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'CANCEL',
                style: GoogleFonts.oxanium(color: mutedWhite),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'DELETE',
                style: GoogleFonts.oxanium(
                  color: dangerRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ClientService.deleteClient(client.id);

      if (!mounted) return;

      Navigator.pop(context, 'deleted');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dangerRed,
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.oxanium(color: white),
          ),
        ),
      );
    }
  }

  Future<void> addContactHistory() async {
    final methodController = ValueNotifier<String>('Call');
    final resultController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panelLight,
              title: Text(
                'RECORD CONTACT',
                style: GoogleFonts.oxanium(
                  color: white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: methodController,
                      builder: (context, method, child) {
                        return DropdownButtonFormField<String>(
                          value: method,
                          dropdownColor: panelLight,
                          style: GoogleFonts.oxanium(
                            color: white,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            labelText: 'CONTACT METHOD',
                            labelStyle: GoogleFonts.oxanium(
                              color: mutedWhite,
                              fontSize: 10,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: mutedWhite),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: electricBlue),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Call',
                              child: Text('CALL'),
                            ),
                            DropdownMenuItem(value: 'SMS', child: Text('SMS')),
                            DropdownMenuItem(
                              value: 'Messenger',
                              child: Text('MESSENGER'),
                            ),
                            DropdownMenuItem(
                              value: 'Email',
                              child: Text('EMAIL'),
                            ),
                            DropdownMenuItem(
                              value: 'Visit',
                              child: Text('VISIT'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('OTHER'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              methodController.value = value;

                              setDialogState(() {});
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: resultController,
                      style: GoogleFonts.oxanium(color: white, fontSize: 12),
                      decoration: InputDecoration(
                        labelText: 'CONTACT RESULT',
                        labelStyle: GoogleFonts.oxanium(
                          color: mutedWhite,
                          fontSize: 10,
                        ),
                        hintText: 'Interested, no answer, etc.',
                        hintStyle: GoogleFonts.oxanium(
                          color: mutedWhite,
                          fontSize: 10,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: mutedWhite),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: electricBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 4,
                      style: GoogleFonts.oxanium(color: white, fontSize: 12),
                      decoration: InputDecoration(
                        labelText: 'CONTACT NOTES',
                        labelStyle: GoogleFonts.oxanium(
                          color: mutedWhite,
                          fontSize: 10,
                        ),
                        hintText: 'What happened during the contact?',
                        hintStyle: GoogleFonts.oxanium(
                          color: mutedWhite,
                          fontSize: 10,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: mutedWhite),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: electricBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'CANCEL',
                    style: GoogleFonts.oxanium(color: mutedWhite),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'SAVE',
                    style: GoogleFonts.oxanium(
                      color: electricBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      methodController.dispose();
      resultController.dispose();
      notesController.dispose();
      return;
    }

    setState(() {
      isSavingContact = true;
    });

    try {
      final updated = await ClientService.addContactHistory(
        clientId: client.id,
        contactMethod: methodController.value,
        result: resultController.text.trim(),
        notes: notesController.text.trim(),
      );

      if (!mounted) return;

      if (updated != null) {
        client = updated;
      }

      await loadContactHistory();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: successGreen,
          content: Text(
            'CONTACT HISTORY SAVED',
            style: GoogleFonts.oxanium(
              color: spaceBlack,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dangerRed,
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.oxanium(color: white),
          ),
        ),
      );
    } finally {
      methodController.dispose();
      resultController.dispose();
      notesController.dispose();

      if (mounted) {
        setState(() {
          isSavingContact = false;
        });
      }
    }
  }

  Widget contactHistoryCard(Map<String, dynamic> history) {
    final method = history['contactMethod']?.toString() ?? 'Call';

    final result = history['result']?.toString() ?? '';

    final notes = history['notes']?.toString() ?? '';

    final date = history['contactDate'];

    Color methodColor;

    switch (method.toLowerCase()) {
      case 'call':
        methodColor = electricBlue;
        break;

      case 'sms':
        methodColor = successGreen;
        break;

      case 'messenger':
        methodColor = const Color(0xFF8B7CFF);
        break;

      case 'email':
        methodColor = warningAmber;
        break;

      case 'visit':
        methodColor = const Color(0xFFFF7A45);
        break;

      default:
        methodColor = mutedWhite;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panelBlack,
        border: Border(
          left: BorderSide(color: methodColor, width: 3),
          top: BorderSide(color: white.withOpacity(0.5)),
          right: BorderSide(color: white.withOpacity(0.5)),
          bottom: BorderSide(color: white.withOpacity(0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: methodColor),
                ),
                child: Text(
                  method.toUpperCase(),
                  style: GoogleFonts.oxanium(
                    color: methodColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                formatDateTime(date),
                style: GoogleFonts.oxanium(color: mutedWhite, fontSize: 9),
              ),
            ],
          ),
          if (result.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'RESULT',
              style: GoogleFonts.oxanium(
                color: mutedWhite,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              result,
              style: GoogleFonts.oxanium(
                color: white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              'NOTES',
              style: GoogleFonts.oxanium(
                color: mutedWhite,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              notes,
              style: GoogleFonts.oxanium(
                color: mutedWhite,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(client.status);

    return Scaffold(
      backgroundColor: spaceBlack,
      appBar: AppBar(
        backgroundColor: spaceBlack,
        elevation: 0,
        titleSpacing: 10,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'CLIENT',
              style: GoogleFonts.oxanium(
                color: white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            Text(
              '//DETAILS',
              style: GoogleFonts.oxanium(
                color: electricBlue,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: editClient,
            icon: const Icon(Icons.edit, color: electricBlue),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: deleteClient,
            icon: const Icon(Icons.delete_outline, color: dangerRed),
            tooltip: 'Delete',
          ),
          const SizedBox(width: 5),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: white.withOpacity(0.7)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: electricBlue,
        foregroundColor: spaceBlack,
        elevation: 0,
        onPressed: isSavingContact ? null : addContactHistory,
        icon: const Icon(Icons.add_call),
        label: Text(
          'RECORD CONTACT',
          style: GoogleFonts.oxanium(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hudPanel(
              borderColor: color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: panelLight,
                          border: Border.all(color: color, width: 1.5),
                        ),
                        child: Text(
                          client.name.isNotEmpty
                              ? client.name[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.oxanium(
                            color: color,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: GoogleFonts.oxanium(
                                color: white,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              client.company.isNotEmpty
                                  ? client.company
                                  : 'NO COMPANY',
                              style: GoogleFonts.oxanium(
                                color: mutedWhite,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 9),
                            statusBadge(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            sectionLabel(
              'CONTACT INFORMATION',
              color: white,
              icon: Icons.contact_page,
            ),

            const SizedBox(height: 12),

            hudPanel(
              child: Column(
                children: [
                  infoRow('Phone', client.phone, icon: Icons.phone),
                  infoRow('Email', client.email, icon: Icons.email),
                  infoRow('Company', client.company, icon: Icons.business),
                  infoRow('Address', client.address, icon: Icons.location_on),
                  infoRow('Lead Source', client.leadSource, icon: Icons.source),
                ],
              ),
            ),

            const SizedBox(height: 16),

            hudPanel(
              borderColor: electricBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUICK CONTACT',
                    style: GoogleFonts.oxanium(
                      color: electricBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: quickContactButton(
                          label: 'CALL',
                          icon: Icons.phone,
                          color: electricBlue,
                          onPressed: callClient,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: quickContactButton(
                          label: 'SMS',
                          icon: Icons.sms,
                          color: successGreen,
                          onPressed: smsClient,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: quickContactButton(
                          label: 'EMAIL',
                          icon: Icons.email,
                          color: warningAmber,
                          onPressed: emailClient,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            sectionLabel(
              'SALES INFORMATION',
              color: electricBlue,
              icon: Icons.sell_outlined,
            ),

            const SizedBox(height: 12),

            hudPanel(
              borderColor: electricBlue,
              child: Column(
                children: [
                  infoRow(
                    'Interest',
                    client.productInterest,
                    icon: Icons.interests,
                  ),
                  infoRow(
                    'Product',
                    client.productModel,
                    icon: Icons.inventory_2,
                  ),
                  infoRow('Budget', client.budget, icon: Icons.payments),
                  infoRow(
                    'Payment',
                    client.paymentType,
                    icon: Icons.account_balance,
                  ),
                  infoRow(
                    'Deal Value',
                    client.estimatedDealValue,
                    icon: Icons.monetization_on,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            sectionLabel(
              'FOLLOW-UP',
              color: warningAmber,
              icon: Icons.calendar_month,
            ),

            const SizedBox(height: 12),

            hudPanel(
              borderColor: warningAmber,
              child: Column(
                children: [
                  infoRow(
                    'Date',
                    formatDate(client.followUpDate),
                    valueColor: client.followUpDate.isNotEmpty
                        ? warningAmber
                        : mutedWhite,
                    icon: Icons.calendar_today,
                  ),
                  infoRow('Time', client.followUpTime, icon: Icons.access_time),
                  infoRow('Reason', client.followUpReason, icon: Icons.flag),
                ],
              ),
            ),

            const SizedBox(height: 24),

            sectionLabel('NOTES', color: white, icon: Icons.notes),

            const SizedBox(height: 12),

            hudPanel(
              child: Text(
                client.notes.isNotEmpty ? client.notes : 'NO NOTES AVAILABLE',
                style: GoogleFonts.oxanium(
                  color: client.notes.isNotEmpty ? white : mutedWhite,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 28),

            sectionLabel(
              'CONTACT HISTORY',
              color: electricBlue,
              icon: Icons.history,
            ),

            const SizedBox(height: 12),

            if (isLoadingHistory)
              hudPanel(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: electricBlue,
                    ),
                  ),
                ),
              )
            else if (contactHistory.isEmpty)
              hudPanel(
                borderColor: mutedWhite,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.history, color: mutedWhite, size: 30),
                        const SizedBox(height: 10),
                        Text(
                          'NO CONTACT HISTORY',
                          style: GoogleFonts.oxanium(
                            color: mutedWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Record a call, message, visit, or other contact.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.oxanium(
                            color: mutedWhite,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...contactHistory.map(contactHistoryCard),
          ],
        ),
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  final Color color;
  final bool top;
  final bool left;

  CornerPainter({required this.color, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.top != top ||
        oldDelegate.left != left;
  }
}
