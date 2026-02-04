// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isNewUser = false;
  String _phoneNumber = '';
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  
  // Color palette matching home screen
  static const Color kPrimaryColor = Color(0xFF0F766E);
  static const Color kPrimaryDark = Color(0xFF0F172A);
  static const Color kBackgroundColor = Color(0xFFF8FAFC);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF0F172A);
  static const Color kTextSecondary = Color(0xFF64748B);
  static const Color kBorderColor = Color(0xFFE2E8F0);
  static const Color kSuccessColor = Color(0xFF10B981);
  static const Color kWarningColor = Color(0xFFF59E0B);
  static const Color kErrorColor = Color(0xFFEF4444);
  static const Color kInfoColor = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    // Clear OTP when user navigates back to phone input
    for (var controller in _otpControllers) {
      controller.addListener(() {
        if (!_isOtpSent) {
          for (var c in _otpControllers) {
            c.clear();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Custom validators
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

  // Simulate checking if user exists
  Future<bool> _checkIfUserExists(String phone) async {
    // This would be your API call
    await Future.delayed(const Duration(seconds: 1));
    
    // For demo: Assume 0712345678 is an existing user
    return phone != "712345678";
  }

  void _sendOtp() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      _phoneNumber = formData['phone'];
      
      setState(() => _isLoading = true);
      HapticFeedback.lightImpact();
      
      try {
        // Send OTP to phone number
        await Future.delayed(const Duration(seconds: 1));
        
        // Check if user exists
        final userExists = await _checkIfUserExists(_phoneNumber);
        
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
          _isNewUser = !userExists;
        });
        
        _showSnackBar(
          userExists ? 'OTP sent to +254 $_phoneNumber' : 'New user detected',
          isError: false,
        );
        
        if (_isOtpSent) {
          FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showSnackBar('Failed to send OTP', isError: true);
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
      // Verify OTP with your API
      await Future.delayed(const Duration(seconds: 1));
      
      if (otp == "1234") { // Demo OTP
        if (!_isNewUser) {
          // Existing user - login successful
          _showSnackBar('Welcome back!', isError: false);
          await Future.delayed(const Duration(milliseconds: 500));
          AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
        } else {
          // New user - show Google auth
          setState(() => _isLoading = false);
        }
      } else {
        _showSnackBar('Invalid OTP. Try again', isError: true);
        _clearOtpFields();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Verification failed', isError: true);
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    
    try {
      // Simulate Google auth
      await Future.delayed(const Duration(seconds: 2));
      
      // Get user data from Google (simulated)
      final googleUser = {
        'name': 'John Doe',
        'email': 'john.doe@gmail.com',
        'phone': _phoneNumber,
      };
      
      _showSnackBar('Account linked successfully!', isError: false);
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to home
      AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Google login failed', isError: true);
    }
  }

  void _goBackToPhone() {
    HapticFeedback.lightImpact();
    setState(() {
      _isOtpSent = false;
      _isNewUser = false;
      _phoneNumber = '';
      _clearOtpFields();
    });
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    FocusScope.of(context).unfocus();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.grey.shade100,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.afacad(color: Colors.white),
            ),
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
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      } else {
        _verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Curved Header with Fast Food Image
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Curved background container
                Container(
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    child: _buildFastFoodImage(),
                  ),
                ),
                
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 16,
                  child: _isOtpSent 
                      ? GestureDetector(
                          onTap: _goBackToPhone,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
                
                // App logo and title
                Positioned(
                  bottom: 40,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        'Kericho Delivery',
                        style: GoogleFonts.afacad(
                          fontSize: 28,
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
                      const SizedBox(height: 8),
                      Text(
                        'Order from your favorite stores',
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Login Form
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step indicator
                  if (_isOtpSent) _buildStepIndicator(),
                  
                  const SizedBox(height: 20),
                  
                  // Title based on state
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _isNewUser && _isOtpSent 
                          ? 'Link Your Account'
                          : _isOtpSent 
                              ? 'Enter OTP'
                              : 'Sign In',
                      style: GoogleFonts.afacad(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  
                  // Subtitle based on state
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      _isNewUser && _isOtpSent
                          ? 'Link your Google account to continue'
                          : _isOtpSent
                              ? 'Enter the 4-digit code sent to +254 $_phoneNumber'
                              : 'Enter your phone number to continue',
                      style: GoogleFonts.afacad(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: kTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  // Main content based on state
                  if (!_isOtpSent)
                    _buildPhoneForm()
                  else if (_isOtpSent && !_isNewUser)
                    _buildOtpForm()
                  else
                    _buildGoogleAuthForm(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Step 1: Phone verified',
              style: GoogleFonts.afacad(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kPrimaryColor,
              ),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _isNewUser ? kPrimaryColor : kBorderColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '2',
                style: GoogleFonts.afacad(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          // Phone Number Field
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FormBuilderTextField(
              name: 'phone',
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: GoogleFonts.afacad(
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                  fontSize: 14,
                ),
                hintText: '7XX XXX XXX',
                hintStyle: GoogleFonts.afacad(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+254',
                          style: GoogleFonts.afacad(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1.5,
                        height: 24,
                        color: kBorderColor,
                      ),
                    ],
                  ),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
              style: GoogleFonts.afacad(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: kTextPrimary,
                letterSpacing: 1,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => _phoneValidator(value),
            ),
          ),
          
          // Send OTP Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shadowColor: kPrimaryColor.withOpacity(0.4),
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
                        Icon(Icons.send_rounded, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          'Send OTP',
                          style: GoogleFonts.afacad(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: kBorderColor,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: GoogleFonts.afacad(
                    color: kTextSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: kBorderColor,
                  thickness: 1,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Google Login for existing users
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                setState(() => _isLoading = true);
                await Future.delayed(const Duration(seconds: 2));
                setState(() => _isLoading = false);
                AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: kCardColor,
                foregroundColor: kTextPrimary,
                side: BorderSide(color: kBorderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/google.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDB4437),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Terms and Privacy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: kTextSecondary,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                  TextSpan(
                    text: ' and ',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: kTextSecondary,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        // OTP Input Fields
        Container(
          margin: const EdgeInsets.only(bottom: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _otpControllers[index].text.isEmpty 
                        ? kBorderColor 
                        : kPrimaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.afacad(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                      letterSpacing: 2,
                    ),
                    maxLength: 1,
                    onChanged: (value) => _handleOtpChange(index, value),
                    onTap: () => _otpControllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _otpControllers[index].text.length,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        
        // Verify OTP Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: kSuccessColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                      Icon(Icons.verified_rounded, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Verify & Continue',
                        style: GoogleFonts.afacad(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Resend OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: GoogleFonts.afacad(
                color: kTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _sendOtp();
              },
              child: Text(
                'Resend OTP',
                style: GoogleFonts.afacad(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleAuthForm() {
    return Column(
      children: [
        // Google Account Info
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Info icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_rounded,
                  size: 32,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'New Account Detected',
                style: GoogleFonts.afacad(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Link your Google account to create your profile automatically',
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  color: kTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Divider(color: kBorderColor),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: kSuccessColor),
                  const SizedBox(width: 8),
                  Text(
                    'Name from Google',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: kSuccessColor),
                  const SizedBox(width: 8),
                  Text(
                    'Email from Google',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: kSuccessColor),
                  const SizedBox(width: 8),
                  Text(
                    'Phone: +254 $_phoneNumber',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Link Google Account Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _loginWithGoogle,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB4437),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                        'assets/icons/google.png',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.g_mobiledata_rounded, size: 24);
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Link Google Account',
                        style: GoogleFonts.afacad(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Alternative: Manual signup
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            AppRouter.pushNamed(AppRouter.register);
          },
          child: Text(
            'Or create account manually',
            style: GoogleFonts.afacad(
              color: kPrimaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
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
        // Fast food image
        Image.asset(
          'assets/images/fast_food.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback gradient with food icons
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kPrimaryColor,
                    const Color(0xFF0D9488),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    right: 40,
                    child: Icon(Icons.fastfood_rounded, size: 60, color: Colors.white.withOpacity(0.3)),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 30,
                    child: Icon(Icons.local_pizza_rounded, size: 50, color: Colors.white.withOpacity(0.3)),
                  ),
                  Positioned(
                    top: 100,
                    left: 20,
                    child: Icon(Icons.coffee_rounded, size: 40, color: Colors.white.withOpacity(0.3)),
                  ),
                ],
              ),
            );
          },
        ),
        // Gradient overlay
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