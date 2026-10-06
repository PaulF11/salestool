import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  String? errorMessage;

  static const Color spaceBlack = Color(0xFF000000);
  static const Color panelBlack = Color(0xFF050505);
  static const Color panelLight = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFF4F7FA);
  static const Color mutedWhite = Color(0xFF9BA7B5);
  static const Color electricBlue = Color(0xFF00A8FF);
  static const Color dangerRed = Color(0xFFFF304F);
  static const Color successGreen = Color(0xFF20E080);

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() {
      errorMessage = null;
    });

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        errorMessage = 'ALL FIELDS ARE REQUIRED';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'PASSWORDS DO NOT MATCH';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        errorMessage = 'PASSWORD MUST BE AT LEAST 6 CHARACTERS';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.register(name, email, password);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: panelBlack,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          content: Text(
            'ACCOUNT CREATED SUCCESSFULLY',
            style: GoogleFonts.oxanium(
              color: successGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.oxanium(
        color: mutedWhite,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: electricBlue, size: 19),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
    );
  }

  void _backToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: spaceBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO
                  Column(
                    children: [
                      Text(
                        'SALES',
                        style: GoogleFonts.oxanium(
                          color: white,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 5,
                        ),
                      ),
                      Text(
                        '//TOOL',
                        style: GoogleFonts.oxanium(
                          color: electricBlue,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  // REGISTER PANEL
                  Container(
                    decoration: BoxDecoration(
                      color: panelBlack,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 25,
                              color: electricBlue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'CREATE ACCOUNT',
                              style: GoogleFonts.oxanium(
                                color: white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Text(
                          'REGISTER NEW SALES PERSONNEL',
                          style: GoogleFonts.oxanium(
                            color: mutedWhite,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 25),

                        TextField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.oxanium(
                            color: white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            label: 'FULL NAME',
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.oxanium(
                            color: white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            label: 'EMAIL',
                            icon: Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordController,
                          obscureText: hidePassword,
                          style: GoogleFonts.oxanium(
                            color: white,
                            fontSize: 13,
                          ),
                          decoration:
                              _inputDecoration(
                                label: 'PASSWORD',
                                icon: Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  icon: Icon(
                                    hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: mutedWhite,
                                    size: 19,
                                  ),
                                ),
                              ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: confirmPasswordController,
                          obscureText: hideConfirmPassword,
                          onSubmitted: (_) => _register(),
                          style: GoogleFonts.oxanium(
                            color: white,
                            fontSize: 13,
                          ),
                          decoration:
                              _inputDecoration(
                                label: 'CONFIRM PASSWORD',
                                icon: Icons.lock_reset_outlined,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hideConfirmPassword =
                                          !hideConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    hideConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: mutedWhite,
                                    size: 19,
                                  ),
                                ),
                              ),
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: dangerRed.withValues(alpha: 0.08),
                              border: Border.all(
                                color: dangerRed.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: dangerRed,
                                  size: 18,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: GoogleFonts.oxanium(
                                      color: dangerRed,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // CREATE ACCOUNT BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: electricBlue,
                              disabledBackgroundColor: electricBlue.withValues(
                                alpha: 0.35,
                              ),
                              foregroundColor: Colors.black,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 21,
                                    height: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    'CREATE ACCOUNT',
                                    style: GoogleFonts.oxanium(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // BACK TO LOGIN
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _backToLogin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: white,
                              side: const BorderSide(
                                color: Colors.white38,
                                width: 1,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Text(
                              'BACK TO LOGIN',
                              style: GoogleFonts.oxanium(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // SYSTEM STATUS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'REGISTRATION SYSTEM READY',
                        style: GoogleFonts.oxanium(
                          color: mutedWhite,
                          fontSize: 9,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'SALES//TOOL • SECURE REGISTRATION',
                    style: GoogleFonts.oxanium(
                      color: Colors.white24,
                      fontSize: 8,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
