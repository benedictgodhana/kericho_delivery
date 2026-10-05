import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';

// Shown when a guest hits an action that requires an account (e.g. checkout).
class AuthPromptScreen extends StatelessWidget {
  const AuthPromptScreen({super.key});

  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);

  Future<void> _signIn(BuildContext context) async {
    final authenticated = await AppRouter.pushNamed(AppRouter.login);
    if (authenticated == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kCardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: kBorderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(CupertinoIcons.back,
                          color: kTextPrimary, size: 19),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: kPrimaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Icon(CupertinoIcons.person_crop_circle,
                            size: 48, color: kPrimaryColor),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sign in to continue',
                        style: GoogleFonts.afacad(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                            letterSpacing: -0.3),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(width: 36, height: 2, color: kPrimaryColor),
                      const SizedBox(height: 14),
                      Text(
                        'Sign in or create an account to place your order and track delivery',
                        style: GoogleFonts.afacad(
                            fontSize: 14, color: kTextSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () => _signIn(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                      CupertinoIcons.person_crop_circle_fill,
                                      color: Colors.white,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text('Sign In',
                                      style: GoogleFonts.afacad(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
