// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
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
  bool _obscurePassword = true;

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

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _login() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final phone = formData['phone'];
      final password = formData['password'];

      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
  }

  void _goToRegister() {
    AppRouter.pushNamed(AppRouter.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with curved image
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 320,
            floating: false,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Curved background image
                  ClipPath(
                    clipper: _CurvedBottomClipper(),
                    child: Container(
                      height: 350,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/portrait-young-african-guy-accepts-order-by-phone-motorbike-holding-boxes-with-pizza-sit-his-bike-urban-place.jpg',
                          ),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.4),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Back button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () => AppRouter.pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                  
                  // Logo and title overlay
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'WELCOME BACK',
                          style: GoogleFonts.lexend(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to continue your journey',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Login form
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'LOG IN TO YOUR ACCOUNT',
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Text(
                    'Enter your credentials to access your account',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                      letterSpacing: 0.3,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login Form
                  FormBuilder(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Phone Number Field
                        FormBuilderTextField(
                          name: 'phone',
                          decoration: InputDecoration(
                            labelText: 'PHONE NUMBER',
                            labelStyle: GoogleFonts.lexend(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 13,
                              letterSpacing: 1.0,
                            ),
                            hintText: '7XX XXX XXX',
                            hintStyle: GoogleFonts.lexend(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '+254',
                                    style: GoogleFonts.lexend(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 1.5,
                                    height: 22,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          ),
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey[900],
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => _phoneValidator(value),
                        ),
                        
                        const SizedBox(height: 22),
                        
                        // Password Field
                        FormBuilderTextField(
                          name: 'password',
                          decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            labelStyle: GoogleFonts.lexend(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 13,
                              letterSpacing: 1.0,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey[600],
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          ),
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey[900],
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) => _passwordValidator(value),
                        ),
                        
                        const SizedBox(height: 18),
                        
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: Text(
                              'FORGOT PASSWORD?',
                              style: GoogleFonts.lexend(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'SIGN IN',
                                        style: GoogleFonts.lexend(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Divider with "or"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: GoogleFonts.lexend(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Google Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _loginWithGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              shadowColor: Colors.grey[100],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/google.png',
                                  height: 26,
                                  width: 26,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        Icons.g_mobiledata,
                                        size: 20,
                                        color: Colors.grey[700],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'CONTINUE WITH GOOGLE',
                                  style: GoogleFonts.lexend(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey[800],
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 34),
                        
                        // Register Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.lexend(
                                color: Colors.grey[700],
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                            GestureDetector(
                              onTap: _goToRegister,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppTheme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'SIGN UP NOW',
                                  style: GoogleFonts.lexend(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Terms and Privacy
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'By continuing, you agree to our Terms of Service and Privacy Policy',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                              letterSpacing: 0.2,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for curved bottom edge
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 50);
    
    // Create a curved bottom
    path.quadraticBezierTo(
      size.width / 4, 
      size.height,
      size.width / 2, 
      size.height - 30,
    );
    
    path.quadraticBezierTo(
      3 * size.width / 4, 
      size.height - 60,
      size.width, 
      size.height - 50,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}