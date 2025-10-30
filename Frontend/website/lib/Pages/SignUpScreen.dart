// lib/screens/signup_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:website/Providers/AuthProviders/registerProviders.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignUpScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  double _passwordStrength = 0.0; // 0.0 - 1.0

  // Animation for card entrance
  late final AnimationController _animController;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardOffset;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_updatePasswordStrength);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardOpacity = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _cardOffset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final pw = _passwordCtrl.text;
    setState(() {
      _passwordStrength = _estimatePasswordStrength(pw);
    });
  }

  double _estimatePasswordStrength(String pw) {
    if (pw.isEmpty) return 0.0;
    double score = 0;
    if (pw.length >= 8) score += 0.35;
    if (RegExp(r'[A-Z]').hasMatch(pw)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(pw)) score += 0.2;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) score += 0.25;
    if (score > 1) score = 1;
    return score;
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your name';
    if (v.trim().length < 2) return 'Name is too short';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final email = v.trim();
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v))
      return 'Use at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Use at least one number';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Color _strengthColor(double val) {
    if (val < 0.3) return Colors.redAccent;
    if (val < 0.6) return Colors.amber;
    return Colors.green;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final notifier = ref.read(authProvider.notifier);

    final response = await notifier.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    final success = response["success"] == true;
    final message = response["message"] ?? "Something went wrong";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? '✅ $message' : '❌ $message')),
    );

    if (success) context.go('/Login');

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [
        Color(0xFF0F172A), // slate-900
        Color(0xFF0EA5A4), // teal-400
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            child: SlideTransition(
              position: _cardOffset,
              child: FadeTransition(
                opacity: _cardOpacity,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      // subtle glass effect
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF06B6D4),
                                    Color(0xFF7C3AED),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shield,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Create account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Protect your browsing — sign up to start detecting phishing sites.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Name
                              _buildTextField(
                                controller: _nameCtrl,
                                hint: 'Full name',
                                label: 'Name',
                                validator: _validateName,
                                prefixIcon: Icons.person,
                                textInputType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                              ),
                              const SizedBox(height: 12),

                              // Email
                              _buildTextField(
                                controller: _emailCtrl,
                                hint: 'you@example.com',
                                label: 'Email',
                                validator: _validateEmail,
                                prefixIcon: Icons.email,
                                textInputType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),

                              // Password
                              _buildTextField(
                                controller: _passwordCtrl,
                                hint: 'Create a strong password',
                                label: 'Password',
                                validator: _validatePassword,
                                prefixIcon: Icons.lock,
                                obscureText: _obscurePassword,
                                suffix: IconButton(
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  color: Colors.white70,
                                ),
                              ),

                              // Strength bar
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength,
                                      minHeight: 6,
                                      backgroundColor: Colors.white24,
                                      valueColor: AlwaysStoppedAnimation(
                                        _strengthColor(_passwordStrength),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _passwordStrength <= 0
                                          ? 'Empty'
                                          : _passwordStrength < 0.3
                                          ? 'Weak'
                                          : _passwordStrength < 0.6
                                          ? 'Okay'
                                          : 'Strong',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Confirm password
                              _buildTextField(
                                controller: _confirmCtrl,
                                hint: 'Re-enter password',
                                label: 'Confirm Password',
                                validator: _validateConfirm,
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscureConfirm,
                                suffix: IconButton(
                                  onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  color: Colors.white70,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                    backgroundColor: const Color(
                                      0xFF06B6D4,
                                    ), // teal
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign up',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Footer
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.go('/Login');
                                    },
                                    child: const Text(
                                      'Log in',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.go('/Home');
                                    },
                                    child: const Text(
                                      'Log in',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    Widget? suffix,
    bool obscureText = false,
    TextInputType textInputType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.white70)
            : null,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.18)),
          borderRadius: BorderRadius.circular(12),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
