import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  static const Color spaceBlack = Color(0xFF000000);
  static const Color panelBlack = Color(0xFF050505);
  static const Color panelLight = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFF4F7FA);
  static const Color mutedWhite = Color(0xFF9BA7B5);
  static const Color electricBlue = Color(0xFF00A8FF);
  static const Color dangerRed = Color(0xFFFF304F);
  static const Color successGreen = Color(0xFF20E080);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'ENTER EMAIL AND PASSWORD';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await AuthService.login(email, password);

      if (!mounted) return;

      if (result['success'] == true || result['token'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() {
          errorMessage = result['message']?.toString() ?? 'LOGIN FAILED';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
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
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: dangerRed, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: dangerRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
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

                  // LOGIN PANEL
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
                              'AGENT LOGIN',
                              style: GoogleFonts.oxanium(
                                color: white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Text(
                          'AUTHORIZED PERSONNEL ONLY',
                          style: GoogleFonts.oxanium(
                            color: mutedWhite,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 25),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.oxanium(
                            color: white,
                            fontSize: 13,
                          ),
                          decoration: _inputDecoration(
                            label: 'EMAIL',
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          onSubmitted: (_) => _login(),
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
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    obscurePassword
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

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
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
                                    'ENTER SYSTEM',
                                    style: GoogleFonts.oxanium(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // DIVIDER
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Colors.white12),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'OR',
                                style: GoogleFonts.oxanium(
                                  color: Colors.white38,
                                  fontSize: 9,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: Colors.white12),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // CREATE ACCOUNT
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _openRegister,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: white,
                              side: BorderSide(color: Colors.white38, width: 1),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Text(
                              'CREATE ACCOUNT',
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
                        'SYSTEM READY',
                        style: GoogleFonts.oxanium(
                          color: mutedWhite,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'SALES//TOOL • SECURE ACCESS',
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
