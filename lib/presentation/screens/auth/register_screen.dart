import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // KulaHub brand palette (matches login screen)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kPrimaryDark = Color(0xFFC73F22);
  static const Color kFieldFill = Color(0xFFFCEFE8);
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);

  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email address is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final passwordValue = _formKey.currentState?.fields['password']?.value;
    if (value != passwordValue) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _register() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please agree to the User Agreement and Privacy Policy',
                style: GoogleFonts.afacad(color: Colors.white))),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
  }

  void _registerWith(String provider) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
  }

  void _goToLogin() {
    AppRouter.pushReplacementNamed(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: [
          Expanded(flex: 32, child: _buildTopPanel()),
          Expanded(flex: 68, child: _buildFormSheet()),
        ],
      ),
    );
  }

  Widget _buildTopPanel() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, kPrimaryDark],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -70,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle),
                        child: const Icon(CupertinoIcons.back,
                            color: Colors.white, size: 19),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/LOGO/logo.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSheet() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36), topRight: Radius.circular(36)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account',
                  style: GoogleFonts.afacad(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary)),
              const SizedBox(height: 6),
              Text('Sign up to get started',
                  style: GoogleFonts.afacad(
                      fontSize: 13.5, color: kTextSecondary)),
              const SizedBox(height: 24),
              _buildFieldLabel('Email Address'),
              _buildTextField(
                name: 'email',
                hint: 'Enter your email address',
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(CupertinoIcons.mail_solid,
                    size: 19, color: kTextSecondary),
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Password'),
              _buildTextField(
                name: 'password',
                hint: 'Enter your password',
                validator: _passwordValidator,
                obscure: _obscurePassword,
                prefixIcon: Icon(CupertinoIcons.lock_fill,
                    size: 19, color: kTextSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePassword
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye,
                      size: 19,
                      color: kTextSecondary),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Confirm Password'),
              _buildTextField(
                name: 'confirmPassword',
                hint: 'Re-enter your password',
                validator: _confirmPasswordValidator,
                obscure: _obscureConfirmPassword,
                prefixIcon: Icon(CupertinoIcons.lock_fill,
                    size: 19, color: kTextSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureConfirmPassword
                          ? CupertinoIcons.eye_slash
                          : CupertinoIcons.eye,
                      size: 19,
                      color: kTextSecondary),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 18),
              _buildTermsCheckbox(),
              const SizedBox(height: 22),
              _buildSubmitButton('Sign Up', _register),
              const SizedBox(height: 22),
              _buildSocialSection('Other ways to sign up'),
              const SizedBox(height: 24),
              _buildSwitchRow(
                  'Already have an account? ', 'Sign In', _goToLogin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextSecondary)),
    );
  }

  Widget _buildTextField({
    required String name,
    required String hint,
    required String? Function(String?) validator,
    bool obscure = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return FormBuilderTextField(
      name: name,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.afacad(
          fontSize: 14.5, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.afacad(
            fontSize: 14, color: kTextSecondary.withValues(alpha: 0.7)),
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 4), child: prefixIcon),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: kFieldFill,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) =>
                setState(() => _agreedToTerms = value ?? false),
            activeColor: kPrimaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: "I've read and agreed to ",
                      style: GoogleFonts.afacad(
                          fontSize: 12.5, color: kTextSecondary)),
                  TextSpan(
                      text: 'User Agreement',
                      style: GoogleFonts.afacad(
                          fontSize: 12.5,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: ' and ',
                      style: GoogleFonts.afacad(
                          fontSize: 12.5, color: kTextSecondary)),
                  TextSpan(
                      text: 'Privacy Policy',
                      style: GoogleFonts.afacad(
                          fontSize: 12.5,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Text(label,
                    style: GoogleFonts.afacad(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection(String label) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.afacad(fontSize: 13, color: kTextSecondary)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              onTap: () => _registerWith('google'),
              child: Image.asset(
                'assets/icons/google.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) => Text('G',
                    style: GoogleFonts.afacad(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kPrimaryColor)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(
      {required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFF0E4D8), width: 1.2),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildSwitchRow(String prefix, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prefix,
            style: GoogleFonts.afacad(color: kTextSecondary, fontSize: 13.5)),
        GestureDetector(
          onTap: onTap,
          child: Text(action,
              style: GoogleFonts.afacad(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5)),
        ),
      ],
    );
  }
}
