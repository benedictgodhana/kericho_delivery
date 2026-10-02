import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/screens/auth/complete_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // KulaHub brand palette (matches login screen)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kErrorColor = Color(0xFFE5484D);

  static const int _codeLength = 6;
  static const int _resendSeconds = 30;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_codeLength, (_) => FocusNode());

  bool _isVerifying = false;
  String? _errorText;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsLeft = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    setState(() => _errorText = null);
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_code.length == _codeLength) {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _verify() async {
    if (_code.length != _codeLength) {
      setState(() => _errorText = 'Enter the 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });
    HapticFeedback.mediumImpact();

    // Simulated backend verification.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final appProvider = context.read<AppProvider>();
    if (appProvider.isExistingPhone(widget.phone)) {
      await appProvider.loginWithPhone(widget.phone);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      final created = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => CompleteProfileScreen(phone: widget.phone)),
      );
      if (!mounted) return;
      setState(() => _isVerifying = false);
      if (created == true) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    setState(() => _isVerifying = false);
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    HapticFeedback.lightImpact();
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code resent', style: GoogleFonts.afacad(color: Colors.white)),
        backgroundColor: kTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String get _maskedPhone {
    final digits = widget.phone;
    if (digits.length < 9) return '+254 $digits';
    return '+254 ${digits.substring(0, 3)} XXX ${digits.substring(6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                'Verify your number',
                style: GoogleFonts.afacad(fontSize: 24, fontWeight: FontWeight.w800, color: kTextPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit verification code to $_maskedPhone',
                style: GoogleFonts.afacad(fontSize: 14.5, color: kTextSecondary, height: 1.4),
              ),
              const SizedBox(height: 32),
              _buildOtpBoxes(),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Text(_errorText!, style: GoogleFonts.afacad(fontSize: 12.5, color: kErrorColor, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 28),
              _buildVerifyButton(),
              const SizedBox(height: 22),
              Center(child: _buildResendRow()),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Text(
                    'Change phone number',
                    style: GoogleFonts.afacad(fontSize: 14, fontWeight: FontWeight.w700, color: kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_codeLength, (index) {
        return SizedBox(
          width: 50,
          height: 64,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.afacad(fontSize: 26, fontWeight: FontWeight.w800, color: kTextPrimary),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFFFF8F1),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: _errorText != null ? kErrorColor : kBorderColor, width: 1.3),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: _errorText != null ? kErrorColor : kBorderColor, width: 1.3),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: const BorderSide(color: kPrimaryColor, width: 1.8),
              ),
            ),
            onChanged: (value) => _onDigitChanged(index, value),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isVerifying ? null : _verify,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(28)),
          child: Center(
            child: _isVerifying
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text('Verify', style: GoogleFonts.afacad(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildResendRow() {
    if (_secondsLeft > 0) {
      return Text(
        'Resend code in 0:${_secondsLeft.toString().padLeft(2, '0')}',
        style: GoogleFonts.afacad(fontSize: 13.5, color: kTextSecondary, fontWeight: FontWeight.w600),
      );
    }
    return GestureDetector(
      onTap: _resend,
      child: Text(
        'Resend code',
        style: GoogleFonts.afacad(fontSize: 13.5, color: kPrimaryColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}
