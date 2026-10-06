import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/client.dart';
import '../services/client_service.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  static const Color spaceBlack = Color(0xFF000000);
  static const Color panelBlack = Color(0xFF050505);
  static const Color panelLight = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFF4F7FA);
  static const Color mutedWhite = Color(0xFF9BA7B5);
  static const Color electricBlue = Color(0xFF00A8FF);
  static const Color dangerRed = Color(0xFFFF304F);
  static const Color warningAmber = Color(0xFFFFB020);
  static const Color successGreen = Color(0xFF20E080);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController companyController;
  late final TextEditingController addressController;
  late final TextEditingController productInterestController;
  late final TextEditingController productModelController;
  late final TextEditingController budgetController;
  late final TextEditingController followUpReasonController;
  late final TextEditingController estimatedDealValueController;
  late final TextEditingController notesController;

  String selectedPaymentType = 'Cash';
  String selectedLeadSource = 'Facebook';
  String selectedStatus = 'New';

  DateTime? followUpDate;
  TimeOfDay? followUpTime;

  bool isSaving = false;

  final List<String> paymentTypes = ['Cash', 'Bank Financing'];

  final List<String> leadSources = [
    'Facebook',
    'Walk-in',
    'Referral',
    'Website',
    'Phone',
    'Other',
  ];

  final List<String> statuses = [
    'New',
    'Contacted',
    'Interested',
    'Negotiating',
    'Won',
    'Lost',
    'Follow-up',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();

    final client = widget.client;

    nameController = TextEditingController(text: client.name);

    phoneController = TextEditingController(text: client.phone);

    emailController = TextEditingController(text: client.email);

    companyController = TextEditingController(text: client.company);

    addressController = TextEditingController(text: client.address);

    productInterestController = TextEditingController(
      text: client.productInterest,
    );

    productModelController = TextEditingController(text: client.productModel);

    budgetController = TextEditingController(text: client.budget);

    followUpReasonController = TextEditingController(
      text: client.followUpReason,
    );

    estimatedDealValueController = TextEditingController(
      text: client.estimatedDealValue,
    );

    notesController = TextEditingController(text: client.notes);

    selectedPaymentType = _getValidValue(
      client.paymentType,
      paymentTypes,
      'Cash',
    );

    selectedLeadSource = _getValidValue(
      client.leadSource,
      leadSources,
      'Facebook',
    );

    selectedStatus = _getValidStatus(client.status);

    followUpDate = _parseDate(client.followUpDate);
    followUpTime = _parseTime(client.followUpTime);
  }

  String _getValidValue(String value, List<String> options, String fallback) {
    if (value.isNotEmpty && options.contains(value)) {
      return value;
    }

    return fallback;
  }

  String _getValidStatus(String value) {
    if (value.isEmpty) {
      return 'New';
    }

    if (statuses.contains(value)) {
      return value;
    }

    return 'New';
  }

  DateTime? _parseDate(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  TimeOfDay? _parseTime(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    final raw = value.trim().toUpperCase();

    // Handles 24-hour format: 13:30
    final twentyFourHourMatch = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);

    if (twentyFourHourMatch != null) {
      final hour = int.tryParse(twentyFourHourMatch.group(1)!);
      final minute = int.tryParse(twentyFourHourMatch.group(2)!);

      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    // Handles 12-hour format: 1:30 PM
    final twelveHourMatch = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    ).firstMatch(raw);

    if (twelveHourMatch != null) {
      int? hour = int.tryParse(twelveHourMatch.group(1)!);

      final minute = int.tryParse(twelveHourMatch.group(2)!);

      final period = twelveHourMatch.group(3);

      if (hour != null &&
          minute != null &&
          period != null &&
          hour >= 1 &&
          hour <= 12 &&
          minute >= 0 &&
          minute <= 59) {
        if (period == 'AM') {
          if (hour == 12) {
            hour = 0;
          }
        } else {
          if (hour != 12) {
            hour += 12;
          }
        }

        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    companyController.dispose();
    addressController.dispose();
    productInterestController.dispose();
    productModelController.dispose();
    budgetController.dispose();
    followUpReasonController.dispose();
    estimatedDealValueController.dispose();
    notesController.dispose();

    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
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
    EdgeInsets padding = const EdgeInsets.all(15),
    Color borderColor = white,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: panelBlack,
            border: Border.all(color: borderColor.withValues(alpha: 0.7)),
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
        Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.4)),
        ),
      ],
    );
  }

  Widget inputField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool requiredField = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.oxanium(color: white, fontSize: 12),
        cursorColor: electricBlue,
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }

                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: GoogleFonts.oxanium(
            color: mutedWhite,
            fontSize: 10,
            letterSpacing: 0.7,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: mutedWhite, size: 18)
              : null,
          filled: true,
          fillColor: panelLight,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF555555)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: electricBlue),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: dangerRed),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: dangerRed),
          ),
          errorStyle: GoogleFonts.oxanium(color: dangerRed, fontSize: 9),
        ),
      ),
    );
  }

  Widget dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    Color accentColor = electricBlue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: panelLight,
        style: GoogleFonts.oxanium(color: white, fontSize: 12),
        decoration: InputDecoration(
          labelText: label.toUpperCase(),
          labelStyle: GoogleFonts.oxanium(
            color: mutedWhite,
            fontSize: 10,
            letterSpacing: 0.7,
          ),
          prefixIcon: Icon(icon, color: mutedWhite, size: 18),
          filled: true,
          fillColor: panelLight,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF555555)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accentColor),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item.toUpperCase(),
              style: GoogleFonts.oxanium(color: white, fontSize: 11),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> selectFollowUpDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: followUpDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: spaceBlack,
            dialogTheme: const DialogThemeData(backgroundColor: panelLight),
            colorScheme: const ColorScheme.dark(
              primary: electricBlue,
              surface: panelLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        followUpDate = selected;
      });
    }
  }

  Future<void> selectFollowUpTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: followUpTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: panelLight,
              dialHandColor: electricBlue,
              hourMinuteColor: panelBlack,
            ),
            colorScheme: const ColorScheme.dark(
              primary: electricBlue,
              surface: panelLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        followUpTime = selected;
      });
    }
  }

  Widget dateSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panelLight,
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: warningAmber, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: selectFollowUpDate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FOLLOW-UP DATE',
                    style: GoogleFonts.oxanium(
                      color: mutedWhite,
                      fontSize: 9,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    followUpDate == null
                        ? 'NOT SET'
                        : formatDate(followUpDate!),
                    style: GoogleFonts.oxanium(
                      color: followUpDate == null ? mutedWhite : white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (followUpDate != null)
            IconButton(
              onPressed: () {
                setState(() {
                  followUpDate = null;
                });
              },
              icon: const Icon(Icons.close, color: dangerRed, size: 18),
              tooltip: 'Clear date',
            ),
          IconButton(
            onPressed: selectFollowUpDate,
            icon: const Icon(
              Icons.edit_calendar,
              color: warningAmber,
              size: 18,
            ),
            tooltip: 'Select date',
          ),
        ],
      ),
    );
  }

  Widget timeSelector() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panelLight,
        border: Border.all(color: const Color(0xFF555555)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: warningAmber, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: selectFollowUpTime,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FOLLOW-UP TIME',
                    style: GoogleFonts.oxanium(
                      color: mutedWhite,
                      fontSize: 9,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    followUpTime == null
                        ? 'NOT SET'
                        : formatTime(followUpTime!),
                    style: GoogleFonts.oxanium(
                      color: followUpTime == null ? mutedWhite : white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (followUpTime != null)
            IconButton(
              onPressed: () {
                setState(() {
                  followUpTime = null;
                });
              },
              icon: const Icon(Icons.close, color: dangerRed, size: 18),
              tooltip: 'Clear time',
            ),
          IconButton(
            onPressed: selectFollowUpTime,
            icon: const Icon(Icons.schedule, color: warningAmber, size: 18),
            tooltip: 'Select time',
          ),
        ],
      ),
    );
  }

  Future<void> saveClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updated = await ClientService.updateClient(
        clientId: widget.client.id,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        company: companyController.text.trim(),
        address: addressController.text.trim(),
        productInterest: productInterestController.text.trim(),
        productModel: productModelController.text.trim(),
        budget: budgetController.text.trim(),
        paymentType: selectedPaymentType,
        status: selectedStatus,
        leadSource: selectedLeadSource,
        followUpDate: followUpDate == null
            ? ''
            : followUpDate!.toIso8601String(),
        followUpTime: followUpTime == null ? '' : formatTime(followUpTime!),
        followUpReason: followUpReasonController.text.trim(),
        estimatedDealValue: estimatedDealValueController.text.trim(),
        notes: notesController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, updated);
    } catch (error) {
      if (!mounted) {
        return;
      }

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
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'won':
      case 'closed':
        return successGreen;

      case 'lost':
        return dangerRed;

      case 'follow-up':
      case 'negotiating':
        return warningAmber;

      case 'interested':
      case 'contacted':
        return electricBlue;

      default:
        return mutedWhite;
    }
  }

  Widget statusPreview() {
    final color = statusColor(selectedStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 9, color: color),
          const SizedBox(width: 9),
          Text(
            'CURRENT STATUS',
            style: GoogleFonts.oxanium(
              color: mutedWhite,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Text(
            selectedStatus.toUpperCase(),
            style: GoogleFonts.oxanium(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: spaceBlack,
      appBar: AppBar(
        backgroundColor: spaceBlack,
        elevation: 0,
        titleSpacing: 10,
        leading: IconButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: white),
        ),
        title: Row(
          children: [
            Text(
              'EDIT',
              style: GoogleFonts.oxanium(
                color: white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            Text(
              '//CLIENT',
              style: GoogleFonts.oxanium(
                color: electricBlue,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: white.withValues(alpha: 0.7)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
          children: [
            hudPanel(
              borderColor: electricBlue,
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: electricBlue, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'UPDATE CLIENT RECORD',
                      style: GoogleFonts.oxanium(
                        color: white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
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
                  inputField(
                    label: 'Name',
                    controller: nameController,
                    icon: Icons.person,
                    requiredField: true,
                  ),
                  inputField(
                    label: 'Phone',
                    controller: phoneController,
                    icon: Icons.phone,
                    requiredField: true,
                  ),
                  inputField(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email,
                  ),
                  inputField(
                    label: 'Company',
                    controller: companyController,
                    icon: Icons.business,
                  ),
                  inputField(
                    label: 'Address',
                    controller: addressController,
                    icon: Icons.location_on,
                  ),
                  dropdownField(
                    label: 'Lead Source',
                    value: selectedLeadSource,
                    items: leadSources,
                    icon: Icons.source,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedLeadSource = value;
                      });
                    },
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
                  inputField(
                    label: 'Product Interest',
                    controller: productInterestController,
                    icon: Icons.interests,
                  ),
                  inputField(
                    label: 'Product Model',
                    controller: productModelController,
                    icon: Icons.inventory_2,
                  ),
                  inputField(
                    label: 'Budget',
                    controller: budgetController,
                    icon: Icons.payments,
                  ),
                  dropdownField(
                    label: 'Payment Type',
                    value: selectedPaymentType,
                    items: paymentTypes,
                    icon: Icons.account_balance,
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedPaymentType = value;
                      });
                    },
                  ),
                  inputField(
                    label: 'Estimated Deal Value',
                    controller: estimatedDealValueController,
                    icon: Icons.monetization_on,
                  ),
                  statusPreview(),
                  dropdownField(
                    label: 'Status',
                    value: selectedStatus,
                    items: statuses,
                    icon: Icons.flag_outlined,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedStatus = value;
                      });
                    },
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
                  dateSelector(),

                  const SizedBox(height: 10),

                  timeSelector(),

                  const SizedBox(height: 12),

                  inputField(
                    label: 'Follow-up Reason',
                    controller: followUpReasonController,
                    icon: Icons.flag,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            sectionLabel('NOTES', color: white, icon: Icons.notes),

            const SizedBox(height: 12),

            hudPanel(
              child: inputField(
                label: 'Notes',
                controller: notesController,
                icon: Icons.notes,
                maxLines: 5,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: electricBlue,
                  foregroundColor: spaceBlack,
                  disabledBackgroundColor: mutedWhite,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: spaceBlack,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isSaving ? 'SAVING...' : 'SAVE CHANGES',
                  style: GoogleFonts.oxanium(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
