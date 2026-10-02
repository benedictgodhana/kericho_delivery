import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/presentation/screens/auth/otp_verification_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // KulaHub brand palette (matches home/cart/profile/settings screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kPrimaryDark = Color(0xFFC73F22);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);

  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 9-digit number';
    }
    return null;
  }

  // Returns control to wherever auth was requested from, falling back to
  // Home only when there is nothing to return to (e.g. fresh onboarding).
  void _completeAuth() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
    }
  }

  void _continue() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final phone = _formKey.currentState!.value['phone'] as String;

    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => OtpVerificationScreen(phone: phone)),
    );

    if (verified == true && mounted) {
      _completeAuth();
    }
  }

  void _continueWithGoogle() async {
    setState(() => _isLoading = true);
    await context.read<AppProvider>().loginWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);
    _completeAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Column(
        children: [
          Expanded(flex: 38, child: _buildTopPanel()),
          Expanded(flex: 62, child: _buildFormSheet()),
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
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -70,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
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
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                        child: const Icon(CupertinoIcons.back, color: Colors.white, size: 19),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/KulaHub_logo-removebg-preview.png',
                        height: 46,
                        fit: BoxFit.contain,
                      ),
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back \u{1F44B}',
                style: GoogleFonts.afacad(fontSize: 24, fontWeight: FontWeight.w800, color: kTextPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your phone number to continue',
                style: GoogleFonts.afacad(fontSize: 14.5, color: kTextSecondary),
              ),
              const SizedBox(height: 26),
              _buildPhoneField(),
              const SizedBox(height: 22),
              _buildContinueButton(),
              const SizedBox(height: 22),
              _buildOrDivider(),
              const SizedBox(height: 18),
              _buildGoogleButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return FormBuilderTextField(
      name: 'phone',
      keyboardType: TextInputType.phone,
      validator: _phoneValidator,
      style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary),
        floatingLabelStyle: GoogleFonts.afacad(fontSize: 13, color: kPrimaryColor, fontWeight: FontWeight.w700),
        hintText: '7XX XXX XXX',
        hintStyle: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary.withValues(alpha: 0.7)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\u{1F1F0}\u{1F1EA}', style: GoogleFonts.afacad(fontSize: 18)),
                const SizedBox(width: 8),
                Text('+254', style: GoogleFonts.afacad(color: kTextPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(width: 10),
                Container(width: 1.2, height: 20, color: kBorderColor),
              ],
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: kBorderColor, width: 1.3)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: kBorderColor, width: 1.3)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: kPrimaryColor, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : _continue,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('Continue', style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: kBorderColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: GoogleFonts.afacad(color: kTextSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        Expanded(child: Divider(color: kBorderColor, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : _continueWithGoogle,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: kBorderColor, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/google.png',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) =>
                    Text('G', style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w800, color: kPrimaryColor)),
              ),
              const SizedBox(width: 12),
              Text('Continue with Google', style: GoogleFonts.afacad(fontSize: 15, fontWeight: FontWeight.w700, color: kTextPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
