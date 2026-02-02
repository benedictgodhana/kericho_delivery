import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/user_model.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserType _selectedUserType = UserType.customer;

  // Custom validators
  String? _requiredValidator(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  String? _nameValidator(String? value) {
    final requiredError = _requiredValidator(value, fieldName: 'Full name');
    if (requiredError != null) return requiredError;
    
    if (value!.length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final requiredError = _requiredValidator(value, fieldName: 'Phone number');
    if (requiredError != null) return requiredError;
    
    final phoneRegex = RegExp(r'^[0-9]{9}$');
    if (!phoneRegex.hasMatch(value!)) {
      return 'Enter a valid 9-digit number';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Enter a valid email';
      }
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final requiredError = _requiredValidator(value, fieldName: 'Password');
    if (requiredError != null) return requiredError;
    
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final requiredError = _requiredValidator(value, fieldName: 'Confirm password');
    if (requiredError != null) return requiredError;
    
    final passwordValue = _formKey.currentState?.fields['password']?.value;
    if (value != passwordValue) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _termsValidator(bool? value) {
    if (value == null || value == false) {
      return 'You must accept the terms';
    }
    return null;
  }

  void _register() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      // For now, navigate to home
      AppRouter.pushNamedAndRemoveUntil(AppRouter.home);
    }
  }

  void _goToLogin() {
    AppRouter.pushReplacementNamed(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                onPressed: () => AppRouter.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              
              Text(
                'Sign up to get started',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Registration Form
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    // Full Name
                    FormBuilderTextField(
                      name: 'fullName',
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => _nameValidator(value),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Phone Number
                    FormBuilderTextField(
                      name: 'phone',
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixText: '+254 ',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) => _phoneValidator(value),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email (Optional)
                    FormBuilderTextField(
                      name: 'email',
                      decoration: InputDecoration(
                        labelText: 'Email (Optional)',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => _emailValidator(value),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // User Type Selection
                    FormBuilderDropdown<UserType>(
                      name: 'userType',
                      initialValue: _selectedUserType,
                      decoration: InputDecoration(
                        labelText: 'I am a',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: UserType.customer,
                          child: Row(
                            children: [
                              const Icon(Icons.shopping_cart, size: 20),
                              const SizedBox(width: 10),
                              Text('Customer', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: UserType.rider,
                          child: Row(
                            children: [
                              const Icon(Icons.delivery_dining, size: 20),
                              const SizedBox(width: 10),
                              Text('Delivery Rider', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: UserType.merchant,
                          child: Row(
                            children: [
                              const Icon(Icons.store, size: 20),
                              const SizedBox(width: 10),
                              Text('Merchant', style: GoogleFonts.poppins()),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedUserType = value);
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password
                    FormBuilderTextField(
                      name: 'password',
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) => _passwordValidator(value),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Confirm Password
                    FormBuilderTextField(
                      name: 'confirmPassword',
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) => _confirmPasswordValidator(value),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Terms Agreement
                    FormBuilderCheckbox(
                      name: 'acceptTerms',
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'I agree to the ',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: GoogleFonts.poppins(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.poppins(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      validator: (value) => _termsValidator(value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Login Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: _goToLogin,
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Additional Info based on user type
              if (_selectedUserType == UserType.rider)
                _buildRiderInfo(),
              if (_selectedUserType == UserType.merchant)
                _buildMerchantInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.teaGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining, color: AppTheme.kerichoGreen),
              const SizedBox(width: 8),
              Text(
                'Become a Rider',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.kerichoGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Earn money by delivering orders\n'
            '• Flexible working hours\n'
            '• Weekly payments via M-Pesa\n'
            '• Required: Valid ID, Motorcycle/Bicycle',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.kerichoGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.teaGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: AppTheme.kerichoGreen),
              const SizedBox(width: 8),
              Text(
                'List Your Business',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.kerichoGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Reach more customers in Kericho\n'
            '• Manage orders through our app\n'
            '• Secure payments via M-Pesa\n'
            '• Required: Business license, KRA PIN',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.kerichoGreen,
            ),
          ),
        ],
      ),
    );
  }
}