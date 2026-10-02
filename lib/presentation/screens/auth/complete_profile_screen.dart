import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Minimal signup shown once an OTP verifies a phone number that has no
/// existing account. Collects only what's required to place an order.
class CompleteProfileScreen extends StatefulWidget {
  final String phone;

  const CompleteProfileScreen({super.key, required this.phone});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  // KulaHub brand palette (matches login/OTP screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kSuccessColor = Color(0xFF2EAD6C);

  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSaving = false;

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> _continue() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    final values = _formKey.currentState!.value;

    setState(() => _isSaving = true);
    await context.read<AppProvider>().registerCustomer(
          fullName: values['fullName'] as String,
          phone: widget.phone,
          email: (values['email'] as String?)?.isNotEmpty == true ? values['email'] as String : null,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBorderColor, width: 1.2),
                    ),
                    child: const Icon(CupertinoIcons.back, color: kTextPrimary, size: 20),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "You're almost there",
                  style: GoogleFonts.afacad(fontSize: 24, fontWeight: FontWeight.w800, color: kTextPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us a bit about you to finish creating your account',
                  style: GoogleFonts.afacad(fontSize: 14.5, color: kTextSecondary, height: 1.4),
                ),
                const SizedBox(height: 28),
                _buildField(
                  name: 'fullName',
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  validator: _nameValidator,
                  prefixIcon: Icon(CupertinoIcons.person_fill, size: 19, color: kTextSecondary),
                ),
                const SizedBox(height: 16),
                _buildReadOnlyPhoneField(),
                const SizedBox(height: 16),
                _buildField(
                  name: 'email',
                  label: 'Email Address (optional)',
                  hint: 'Enter your email address',
                  validator: _emailValidator,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(CupertinoIcons.mail_solid, size: 19, color: kTextSecondary),
                ),
                const SizedBox(height: 28),
                _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String name,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    Widget? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return FormBuilderTextField(
      name: name,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: _fieldDecoration(label: label, hint: hint, prefixIcon: prefixIcon),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary),
      floatingLabelStyle: GoogleFonts.afacad(fontSize: 13, color: kPrimaryColor, fontWeight: FontWeight.w700),
      hintText: hint,
      hintStyle: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary.withValues(alpha: 0.7)),
      prefixIcon: prefixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Center(widthFactor: 1, heightFactor: 1, child: prefixIcon),
            ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(widthFactor: 1, heightFactor: 1, child: suffixIcon),
            ),
      suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: kBorderColor, width: 1.3)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: kBorderColor, width: 1.3)),
      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: kBorderColor, width: 1.3)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: kPrimaryColor, width: 1.6)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: Colors.red)),
    );
  }

  Widget _buildReadOnlyPhoneField() {
    return TextFormField(
      enabled: false,
      initialValue: '+254 ${widget.phone}',
      style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: _fieldDecoration(
        label: 'Phone Number',
        hint: '',
        prefixIcon: Icon(CupertinoIcons.phone_fill, size: 19, color: kTextSecondary),
        suffixIcon: Icon(CupertinoIcons.checkmark_seal_fill, size: 18, color: kSuccessColor),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isSaving ? null : _continue,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(28)),
          child: Center(
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('Continue', style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
