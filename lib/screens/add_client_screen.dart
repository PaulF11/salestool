import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/client_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final addressController = TextEditingController();
  final productInterestController = TextEditingController();
  final productModelController = TextEditingController();
  final budgetController = TextEditingController();
  final followUpReasonController = TextEditingController();
  final estimatedDealValueController = TextEditingController();
  final lastContactResultController = TextEditingController();
  final notesController = TextEditingController();

  String paymentType = 'Cash';
  String status = 'New';
  String leadSource = 'Facebook';

  DateTime? followUpDate;
  TimeOfDay? followUpTime;
  DateTime? lastContactDate;

  bool isSaving = false;

  static const Color spaceBlack = Color(0xFF000000);
  static const Color panelBlack = Color(0xFF050505);
  static const Color panelLight = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFF4F7FA);
  static const Color mutedWhite = Color(0xFF9BA7B5);
  static const Color electricBlue = Color(0xFF00A8FF);
  static const Color dangerRed = Color(0xFFFF304F);
  static const Color warningAmber = Color(0xFFFFB020);
  static const Color successGreen = Color(0xFF20E080);

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
    lastContactResultController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'SELECT DATE';

    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'SELECT TIME';

    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  Future<void> _selectFollowUpDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: followUpDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: electricBlue,
              surface: panelBlack,
              onSurface: white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: panelBlack),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        followUpDate = selected;
      });
    }
  }

  Future<void> _selectFollowUpTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: followUpTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: electricBlue,
              surface: panelBlack,
              onSurface: white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: panelBlack),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        followUpTime = selected;
      });
    }
  }

  Future<void> _selectLastContactDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: lastContactDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: electricBlue,
              surface: panelBlack,
              onSurface: white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: panelBlack),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        lastContactDate = selected;
      });
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ClientService.addClient(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        company: companyController.text.trim(),
        address: addressController.text.trim(),
        productInterest: productInterestController.text.trim(),
        productModel: productModelController.text.trim(),
        budget: budgetController.text.trim(),
        paymentType: paymentType,
        status: status,
        leadSource: leadSource,
        followUpDate: followUpDate != null ? _formatDate(followUpDate) : '',
        followUpTime: followUpTime != null ? _formatTime(followUpTime) : '',
        followUpReason: followUpReasonController.text.trim(),
        estimatedDealValue: estimatedDealValueController.text.trim(),
        lastContactDate: lastContactDate != null
            ? _formatDate(lastContactDate)
            : '',
        lastContactResult: lastContactResultController.text.trim(),
        notes: notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: successGreen,
          content: Text(
            'CLIENT RECORD CREATED',
            style: GoogleFonts.oxanium(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dangerRed,
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.oxanium(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.oxanium(
        color: mutedWhite,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
      hintStyle: GoogleFonts.oxanium(color: Colors.white24, fontSize: 10),
      prefixIcon: icon != null
          ? Icon(icon, color: electricBlue, size: 18)
          : null,
      filled: true,
      fillColor: panelLight,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.white24, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: electricBlue, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: dangerRed, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: dangerRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 16),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool requiredField = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.oxanium(color: white, fontSize: 12),
      cursorColor: electricBlue,
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label REQUIRED';
              }
              return null;
            }
          : null,
      decoration: _inputDecoration(label: label, icon: icon, hint: hint),
    );
  }

  Widget _sectionHeader({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: electricBlue, width: 1),
            ),
            child: Text(
              number,
              style: GoogleFonts.oxanium(
                color: electricBlue,
                fontSize: 11,
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
                  title,
                  style: GoogleFonts.oxanium(
                    color: white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.oxanium(
                    color: mutedWhite,
                    fontSize: 8,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: panelLight,
      style: GoogleFonts.oxanium(color: white, fontSize: 11),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: electricBlue),
      decoration: _inputDecoration(label: label, icon: icon),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.oxanium(color: white, fontSize: 11),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateButton({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
    Color accent = electricBlue,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: panelLight,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.oxanium(
                      color: mutedWhite,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.oxanium(
                      color: value == 'SELECT DATE' || value == 'SELECT TIME'
                          ? Colors.white38
                          : white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
              size: 18,
            ),
          ],
        ),
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
        centerTitle: false,
        iconTheme: const IconThemeData(color: white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALES//TOOL',
              style: GoogleFonts.oxanium(
                color: white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'NEW CLIENT RECORD',
              style: GoogleFonts.oxanium(
                color: electricBlue,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP STATUS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: panelBlack,
                    border: Border.all(
                      color: electricBlue.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: electricBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'CREATE NEW CLIENT PROFILE',
                          style: GoogleFonts.oxanium(
                            color: white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: successGreen),
                        ),
                        child: Text(
                          'READY',
                          style: GoogleFonts.oxanium(
                            color: successGreen,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CLIENT INFORMATION
                _sectionHeader(
                  number: '01',
                  title: 'CLIENT INFORMATION',
                  subtitle: 'PRIMARY CUSTOMER IDENTIFICATION',
                ),

                _textField(
                  controller: nameController,
                  label: 'CLIENT NAME',
                  icon: Icons.person_outline,
                  requiredField: true,
                ),

                const SizedBox(height: 12),

                _textField(
                  controller: phoneController,
                  label: 'PHONE NUMBER',
                  icon: Icons.phone_outlined,
                  requiredField: true,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 12),

                _textField(
                  controller: companyController,
                  label: 'COMPANY',
                  icon: Icons.business_outlined,
                ),

                const SizedBox(height: 12),

                _textField(
                  controller: addressController,
                  label: 'ADDRESS',
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 22),

                // CONTACT INFORMATION
                _sectionHeader(
                  number: '02',
                  title: 'CONTACT INFORMATION',
                  subtitle: 'OPTIONAL COMMUNICATION DETAILS',
                ),

                _textField(
                  controller: emailController,
                  label: 'EMAIL ADDRESS',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 22),

                // SALES INFORMATION
                _sectionHeader(
                  number: '03',
                  title: 'SALES INFORMATION',
                  subtitle: 'LEAD AND PRODUCT DETAILS',
                ),

                _textField(
                  controller: productInterestController,
                  label: 'PRODUCT INTEREST',
                  icon: Icons.category_outlined,
                ),

                const SizedBox(height: 12),

                _textField(
                  controller: productModelController,
                  label: 'PRODUCT / MODEL',
                  icon: Icons.inventory_2_outlined,
                ),

                const SizedBox(height: 12),

                _textField(
                  controller: budgetController,
                  label: 'BUDGET',
                  icon: Icons.account_balance_wallet_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 520) {
                      return Column(
                        children: [
                          _dropdown(
                            label: 'PAYMENT TYPE',
                            value: paymentType,
                            items: const ['Cash', 'Bank Financing'],
                            icon: Icons.payments_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  paymentType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          _dropdown(
                            label: 'LEAD SOURCE',
                            value: leadSource,
                            items: const [
                              'Facebook',
                              'Walk-in',
                              'Referral',
                              'Website',
                              'Phone',
                              'Other',
                            ],
                            icon: Icons.source_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  leadSource = value;
                                });
                              }
                            },
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _dropdown(
                            label: 'PAYMENT TYPE',
                            value: paymentType,
                            items: const ['Cash', 'Bank Financing'],
                            icon: Icons.payments_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  paymentType = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dropdown(
                            label: 'LEAD SOURCE',
                            value: leadSource,
                            items: const [
                              'Facebook',
                              'Walk-in',
                              'Referral',
                              'Website',
                              'Phone',
                              'Other',
                            ],
                            icon: Icons.source_outlined,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  leadSource = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                _dropdown(
                  label: 'CLIENT STATUS',
                  value: status,
                  items: const [
                    'New',
                    'Contacted',
                    'Interested',
                    'Negotiating',
                    'Won',
                    'Lost',
                  ],
                  icon: Icons.flag_outlined,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        status = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 12),

                _textField(
                  controller: estimatedDealValueController,
                  label: 'ESTIMATED DEAL VALUE',
                  icon: Icons.trending_up_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 22),

                // FOLLOW-UP
                _sectionHeader(
                  number: '04',
                  title: 'FOLLOW-UP',
                  subtitle: 'SCHEDULE THE NEXT CUSTOMER ACTION',
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 500) {
                      return Column(
                        children: [
                          _dateButton(
                            label: 'FOLLOW-UP DATE',
                            value: _formatDate(followUpDate),
                            icon: Icons.calendar_today_outlined,
                            onTap: _selectFollowUpDate,
                          ),
                          const SizedBox(height: 12),
                          _dateButton(
                            label: 'FOLLOW-UP TIME',
                            value: _formatTime(followUpTime),
                            icon: Icons.access_time_outlined,
                            onTap: _selectFollowUpTime,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _dateButton(
                            label: 'FOLLOW-UP DATE',
                            value: _formatDate(followUpDate),
                            icon: Icons.calendar_today_outlined,
                            onTap: _selectFollowUpDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateButton(
                            label: 'FOLLOW-UP TIME',
                            value: _formatTime(followUpTime),
                            icon: Icons.access_time_outlined,
                            onTap: _selectFollowUpTime,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                _textField(
                  controller: followUpReasonController,
                  label: 'FOLLOW-UP REASON',
                  icon: Icons.flag_outlined,
                  hint: 'Example: Send quotation',
                ),

                const SizedBox(height: 22),

                // CONTACT STATUS
                _sectionHeader(
                  number: '05',
                  title: 'CONTACT STATUS',
                  subtitle: 'MOST RECENT CUSTOMER INTERACTION',
                ),

                _dateButton(
                  label: 'LAST CONTACT DATE',
                  value: _formatDate(lastContactDate),
                  icon: Icons.history_outlined,
                  accent: warningAmber,
                  onTap: _selectLastContactDate,
                ),

                const SizedBox(height: 12),

                _textField(
                  controller: lastContactResultController,
                  label: 'LAST CONTACT RESULT',
                  icon: Icons.forum_outlined,
                  hint: 'Example: Customer requested quotation',
                  maxLines: 2,
                ),

                const SizedBox(height: 22),

                // NOTES
                _sectionHeader(
                  number: '06',
                  title: 'NOTES',
                  subtitle: 'ADDITIONAL CLIENT INFORMATION',
                ),

                _textField(
                  controller: notesController,
                  label: 'CLIENT NOTES',
                  icon: Icons.notes_outlined,
                  maxLines: 5,
                  hint: 'Add important details about this client...',
                ),

                const SizedBox(height: 28),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveClient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: electricBlue,
                      disabledBackgroundColor: electricBlue.withValues(
                        alpha: 0.35,
                      ),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_outlined, size: 19),
                              const SizedBox(width: 9),
                              Text(
                                'SAVE CLIENT RECORD',
                                style: GoogleFonts.oxanium(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'SALES//TOOL • CLIENT DATABASE',
                    style: GoogleFonts.oxanium(
                      color: Colors.white24,
                      fontSize: 8,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
