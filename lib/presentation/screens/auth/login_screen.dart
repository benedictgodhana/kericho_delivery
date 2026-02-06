// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/core/constants/app_constants.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final GoogleSignIn _googleSignIn =
      GoogleSignIn.standard(scopes: ['email', 'profile']);

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _showLinkGoogle = false;

  String _phoneNumber = '';

  // 4-digit OTP
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  // Resend cooldown
  bool _canResend = true;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  // Colors
  static const Color kPrimaryColor = Color(0xFF0F766E);
  static const Color kPrimaryDark = Color(0xFF0F172A);
  static const Color kBackgroundColor = Color(0xFFF8FAFC);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF0F172A);
  static const Color kTextSecondary = Color(0xFF64748B);
  static const Color kBorderColor = Color(0xFFE2E8F0);
  static const Color kSuccessColor = Color(0xFF10B981);
  static const Color kErrorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    for (var controller in _otpControllers) {
      controller.addListener(() {
        if (!_isOtpSent) {
          for (var c in _otpControllers) c.clear();
        }
      });
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _otpControllers) controller.dispose();
    for (var focusNode in _otpFocusNodes) focusNode.dispose();
    super.dispose();
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[0-9]{9}$').hasMatch(value))
      return 'Enter a valid 9-digit number';
    return null;
  }

  Future<Map<String, dynamic>> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        throw Exception('Google sign-in failed: idToken is null or empty.');
      }

      return {
        'id_token': googleAuth.idToken,
        'access_token': googleAuth.accessToken,
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photo': googleUser.photoUrl,
      };
    } catch (e) {
      rethrow;
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _sendOtp() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      _phoneNumber = formData['phone'];

      setState(() => _isLoading = true);
      HapticFeedback.lightImpact();

      try {
        print('Sending OTP to: 254$_phoneNumber');
        await AppProvider.instance.sendOtp('254$_phoneNumber');

        setState(() {
          _isLoading = false;
          _isOtpSent = true;
          _showLinkGoogle = false;
        });

        _startResendTimer();
        _showSnackBar('OTP sent to +254 $_phoneNumber', isError: false);
        FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
      } catch (e) {
        setState(() => _isLoading = false);
        String msg = 'Failed to send OTP';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Network is unreachable')) {
          msg = 'Please check your internet connection';
        } else if (e.toString().contains('Timeout')) {
          msg = 'Request timeout. Please try again';
        } else {
          msg = e.toString();
        }
        _showSnackBar(msg, isError: true);
      }
    }
  }

  void _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 4) {
      _showSnackBar('Please enter the 4-digit OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final result =
          await AppProvider.instance.verifyOtp('254$_phoneNumber', otp);

      if (result is Map<String, dynamic> && result['success'] == true) {
        final hasGoogle = result['has_google'] == true;

        _showSnackBar('Phone verified successfully!', isError: false);

        if (hasGoogle) {
          await Future.delayed(const Duration(milliseconds: 500));
          AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
        } else {
          setState(() {
            _isLoading = false;
            _showLinkGoogle = true;
          });
        }
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('Invalid or expired OTP', isError: true);
        _clearOtpFields();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      String msg = 'OTP verification failed';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network is unreachable')) {
        msg = 'Please check your internet connection';
      } else if (e.toString().contains('Timeout')) {
        msg = 'Request timeout. Please try again';
      } else {
        msg = e.toString();
      }
      _showSnackBar(msg, isError: true);
      _clearOtpFields();
    }
  }

  void _linkGoogle() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final googleData = await _signInWithGoogle();
      await AppProvider.instance.linkGoogleAccount(googleData);

      _showSnackBar('Google account linked successfully!', isError: false);
      await Future.delayed(const Duration(milliseconds: 500));
      AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
    } catch (e) {
      setState(() => _isLoading = false);
      String msg = 'Failed to link Google account';
      if (e.toString().contains('cancelled')) {
        msg = 'Google sign in cancelled';
      } else {
        msg = e.toString();
      }
      _showSnackBar(msg, isError: true);
    }
  }

  void _signInWithGoogleOnly() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final googleData = await _signInWithGoogle();
      final result = await AppProvider.instance.loginWithGoogle(googleData, '');

      if (result is Map<String, dynamic> && result['success'] == true) {
        final hasPhone = result['has_phone'] == true;

        _showSnackBar('Welcome!', isError: false);

        if (hasPhone) {
          await Future.delayed(const Duration(milliseconds: 500));
          AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
        } else {
          // TODO: Navigate to AddPhoneScreen (implement separately)
          _showSnackBar('Please add your phone number to continue',
              isError: false);
          // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => AddPhoneScreen()));
        }
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      String msg = 'Google login failed';
      if (e.toString().contains('cancelled'))
        msg = 'Google sign in cancelled';
      else
        msg = e.toString();
      _showSnackBar(msg, isError: true);
    }
  }

  void _clearOtpFields() {
    for (var c in _otpControllers) c.clear();
    FocusScope.of(context).unfocus();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle,
                color: Colors.white),
            const SizedBox(width: 12),
            Flexible(
                child: Text(message,
                    style: GoogleFonts.afacad(color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? kErrorColor : kSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleOtpChange(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    } else if (value.isNotEmpty && index == 3) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Render the curved header first (background)
          _buildCurvedHeader(screenHeight, screenWidth),
          // Then render the main content (foreground)
          Column(
            children: [
              SizedBox(height: screenHeight * 0.4),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              _showLinkGoogle
                                  ? 'Link Google Account'
                                  : _isOtpSent
                                      ? 'Enter OTP'
                                      : 'Sign In',
                              style: GoogleFonts.afacad(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: kTextPrimary,
                                  letterSpacing: -1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _showLinkGoogle
                                  ? 'Link your Google account for a better experience'
                                  : _isOtpSent
                                      ? 'Enter the 4-digit code sent to +254 $_phoneNumber'
                                      : 'Use your phone number or Google to continue',
                              style: GoogleFonts.afacad(
                                  fontSize: 15,
                                  color: kTextSecondary,
                                  height: 1.4),
                            ),
                            const SizedBox(height: 32),

                            // ── Main content switches here ─────────────────────────────────────
                            if (_showLinkGoogle)
                              _buildLinkGoogleSection()
                            else if (_isOtpSent)
                              _buildOtpSection()
                            else
                              _buildInitialSection(),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurvedHeader(double screenHeight, double screenWidth) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: LoginHeaderCurveClipper(),
        child: Container(
          height: screenHeight * 0.4,
          decoration: BoxDecoration(
            color: kPrimaryDark,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              _buildFastFoodImage(),

              // Content
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 32,
                            color: kPrimaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        constraints:
                            BoxConstraints(maxWidth: screenWidth * 0.8),
                        child: Text(
                          'Kericho Delivery',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.afacad(
                            fontSize:
                                screenWidth * 0.09, // Responsive font size
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order from your favorite stores',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Initial screen: Phone + Google options
  Widget _buildInitialSection() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          // Phone input with Kenyan flag
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(20), // More rounded
                    border: Border.all(color: kBorderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Kenyan Flag + Country Code
                      Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20), // More rounded
                            bottomLeft: Radius.circular(20), // More rounded
                          ),
                          border: Border(
                            right: BorderSide(color: kBorderColor, width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Kenyan Flag
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  '🇰🇪',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Country Code
                            Text(
                              '+254',
                              style: GoogleFonts.afacad(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: kTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Phone Number Input
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'phone',
                          decoration: InputDecoration(
                            hintText: '7XX XXX XXX',
                            hintStyle: GoogleFonts.afacad(
                              color: kTextSecondary,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            errorStyle: TextStyle(height: 0),
                          ),
                          style: GoogleFonts.afacad(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kTextPrimary,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: _phoneValidator,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Send OTP button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)), // More rounded
                elevation: 0,
                shadowColor: kPrimaryColor.withOpacity(0.3),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/send.png',
                          width: 22,
                          height: 22,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Send OTP',
                          style: GoogleFonts.afacad(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 32),

          // Divider + Google option
          Row(
            children: [
              Expanded(child: Divider(color: kBorderColor, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: GoogleFonts.afacad(
                    color: kTextSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: kBorderColor, thickness: 1)),
            ],
          ),

          const SizedBox(height: 24),

          // Google button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogleOnly,
              icon: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/google.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (_, __, ___) => Text(
                      'G',
                      style: GoogleFonts.afacad(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFDB4437),
                      ),
                    ),
                  ),
                ),
              ),
              label: Text(
                'Continue with Google',
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kBorderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)), // More rounded
                backgroundColor: Colors.white,
                foregroundColor: kTextPrimary,
              ),
            ),
          ),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy',
              textAlign: TextAlign.center,
              style: GoogleFonts.afacad(
                fontSize: 12,
                color: kTextSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // OTP input section (4 digits)
  Widget _buildOtpSection() {
    return Column(
      children: [
        // OTP fields
        Container(
          margin: const EdgeInsets.only(bottom: 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final fieldSize = (width - 48) / 4; // spacing for 4 fields

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Container(
                    width: fieldSize.clamp(60, 80),
                    height: fieldSize.clamp(60, 80),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(20), // More rounded
                      border: Border.all(
                        color: _otpControllers[index].text.isNotEmpty
                            ? kPrimaryColor
                            : kBorderColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: GoogleFonts.afacad(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary,
                        ),
                        onChanged: (v) => _handleOtpChange(index, v),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),

        // Verify button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)), // More rounded
              elevation: 0,
              shadowColor: kPrimaryColor.withOpacity(0.3),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/verify.png',
                        width: 22,
                        height: 22,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Verify OTP',
                        style: GoogleFonts.afacad(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive code? ",
              style: GoogleFonts.afacad(
                color: kTextSecondary,
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: _canResend ? _sendOtp : null,
              child: Text(
                _canResend ? 'Resend' : 'Resend ($_resendCountdown s)',
                style: GoogleFonts.afacad(
                  color: _canResend ? kPrimaryColor : kTextSecondary,
                  fontWeight: _canResend ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Link Google section (after successful OTP)
  Widget _buildLinkGoogleSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(24), // More rounded
            border: Border.all(color: kBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.person_add_rounded,
                    size: 40,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Link Google Account',
                style: GoogleFonts.afacad(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Link your Google account for easier sign-ins and profile setup',
                textAlign: TextAlign.center,
                style: GoogleFonts.afacad(
                  fontSize: 15,
                  color: kTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _linkGoogle,
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/google.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) => Text(
                          'G',
                          style: GoogleFonts.afacad(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFDB4437),
                          ),
                        ),
                      ),
                    ),
                  ),
                  label: Text(
                    'Link with Google',
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB4437),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20)), // More rounded
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => AppRouter.pushNamedAndRemoveUntil(AppRouter.home),
          child: Text(
            'Skip for now',
            style: GoogleFonts.afacad(
              color: kTextSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFastFoodImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/fast_food.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryColor, const Color(0xFF0D9488)],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LoginHeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    final secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
