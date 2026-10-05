import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // KulaHub brand palette (matches profile/home/cart screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kSuccessColor = Color(0xFF2EAD6C);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _sectionTitle('Quick Links'),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildRow(
                        icon: CupertinoIcons.time,
                        title: 'Order History',
                        onTap: () => AppRouter.pushNamed(AppRouter.orderHistory),
                        showChevron: true,
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.heart_fill,
                        title: 'Favorites',
                        onTap: () => AppRouter.pushNamed('/favorites'),
                        showChevron: true,
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.bell_fill,
                        title: 'Notifications',
                        onTap: () => AppRouter.pushNamed('/notifications'),
                        showChevron: true,
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.tag_fill,
                        title: 'Promotions',
                        onTap: () => AppRouter.pushNamed(AppRouter.promotions),
                        showChevron: true,
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.question_circle_fill,
                        title: 'Help',
                        onTap: () => AppRouter.pushNamed('/help'),
                        showChevron: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle('Preferences'),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildSwitchRow(
                        icon: CupertinoIcons.moon_fill,
                        title: 'Dark Mode',
                        subtitle: 'Switch between light and dark appearance',
                        value: appProvider.themeMode == ThemeMode.dark,
                        onChanged: (_) => appProvider.toggleTheme(),
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.globe,
                        title: 'Language',
                        subtitle: appProvider.locale.languageCode == 'en' ? 'English' : appProvider.locale.languageCode,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('More languages coming soon', style: GoogleFonts.afacad(color: Colors.white)),
                              backgroundColor: kTextPrimary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                        showChevron: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle('Account & Security'),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildRow(
                        icon: CupertinoIcons.lock_shield_fill,
                        title: 'Privacy & Security',
                        onTap: () => AppRouter.pushNamed('/privacy'),
                        showChevron: true,
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.location_solid,
                        title: 'Saved Addresses',
                        onTap: () => AppRouter.pushNamed('/addresses'),
                        showChevron: true,
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.creditcard_fill,
                        title: 'Payment Methods',
                        onTap: () => AppRouter.pushNamed('/paymentMethods'),
                        showChevron: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle('About'),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildRow(
                        icon: CupertinoIcons.info_circle_fill,
                        title: 'About KulaHub',
                        subtitle: 'Version 1.0.0',
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.doc_text_fill,
                        title: 'Terms of Service',
                        onTap: () {},
                        showChevron: true,
                      ),
                      _divider(),
                      _buildRow(
                        icon: CupertinoIcons.shield_fill,
                        title: 'Privacy Policy',
                        onTap: () {},
                        showChevron: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
              child: const Icon(CupertinoIcons.back, color: kTextPrimary, size: 19),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Settings',
            style: GoogleFonts.afacad(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.afacad(fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 1, color: kTextSecondary),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 16, endIndent: 16, color: kBorderColor);

  Widget _buildRow({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 17, color: kPrimaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w600, color: kTextPrimary)),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle, style: GoogleFonts.afacad(fontSize: 12.5, color: kTextSecondary)),
                    ),
                ],
              ),
            ),
            if (showChevron) Icon(CupertinoIcons.chevron_forward, size: 16, color: kTextSecondary.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 17, color: kPrimaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w600, color: kTextPrimary)),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle, style: GoogleFonts.afacad(fontSize: 12.5, color: kTextSecondary)),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kSuccessColor,
          ),
        ],
      ),
    );
  }
}
