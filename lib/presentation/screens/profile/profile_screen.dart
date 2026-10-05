import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kericho_delivery/data/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // KulaHub brand palette (matches home/menu/cart/rewards screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kSecondaryColor = Color(0xFFFFB020);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kSuccessColor = Color(0xFF2EAD6C);
  static const Color kErrorColor = Color(0xFFE5484D);

  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingAvatar = false;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.user;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBody: true,
      body: user == null
          ? SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildLoginPrompt()),
                ],
              ),
            )
          : _buildProfileContent(user, appProvider),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kCardColor,
                shape: BoxShape.circle,
                border: Border.all(color: kBorderColor, width: 1.2),
              ),
              child: const Icon(CupertinoIcons.back,
                  color: kTextPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Profile',
            style: GoogleFonts.afacad(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => AppRouter.pushNamed(AppRouter.settingsRoute),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kCardColor,
                shape: BoxShape.circle,
                border: Border.all(color: kBorderColor, width: 1.2),
              ),
              child: const Icon(CupertinoIcons.settings,
                  color: kTextPrimary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
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
                border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
              ),
              child: Icon(CupertinoIcons.person, size: 48, color: kPrimaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Please sign in to view profile',
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
              'Access your orders, saved addresses, and more',
              style: GoogleFonts.afacad(fontSize: 14, color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => AppRouter.pushNamed(AppRouter.login),
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
                        const Icon(CupertinoIcons.person_crop_circle_fill,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Sign In',
                          style: GoogleFonts.afacad(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    UserModel user,
    AppProvider appProvider,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildIdentityHeader(user),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 66, 20, 32),
            decoration: const BoxDecoration(color: kCardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    user.fullName,
                    style: GoogleFonts.afacad(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _getUserTypeText(user.userType),
                    style:
                        GoogleFonts.afacad(fontSize: 14, color: kTextSecondary),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailsCard(user),
                const SizedBox(height: 28),
                _buildSectionTitle('Account'),
                const SizedBox(height: 14),
                _buildAccountSection(appProvider),
                const SizedBox(height: 28),
                _buildAppInfo(),
                const SizedBox(height: 110),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Flat colored block + avatar overlapping the seam with the white content below.
  Widget _buildIdentityHeader(UserModel user) {
    const headerHeight = 190.0;
    const avatarSize = 100.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: headerHeight,
          width: double.infinity,
          color: kPrimaryColor,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle),
                      child: const Icon(CupertinoIcons.back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Details',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.afacad(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => AppRouter.pushNamed(AppRouter.settingsRoute),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle),
                      child: const Icon(CupertinoIcons.settings,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: headerHeight - avatarSize / 2,
          left: 0,
          right: 0,
          child: Center(child: _buildAvatar(user, avatarSize)),
        ),
      ],
    );
  }

  Widget _buildAvatar(UserModel user, double size) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: kBackgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: user.profileImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(size / 2),
                  child: user.profileImage!.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: user.profileImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                  color: kPrimaryColor)),
                          errorWidget: (context, url, error) => Icon(
                              CupertinoIcons.person_fill,
                              size: size * 0.48,
                              color: kTextSecondary),
                        )
                      : Image.file(
                          File(user.profileImage!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              CupertinoIcons.person_fill,
                              size: size * 0.48,
                              color: kTextSecondary),
                        ),
                )
              : Icon(CupertinoIcons.person_fill,
                  size: size * 0.48, color: kTextSecondary),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap:
                _isUploadingAvatar ? null : () => _showAvatarPickerSheet(user),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kSecondaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: _isUploadingAvatar
                  ? const Padding(
                      padding: EdgeInsets.all(7),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(CupertinoIcons.camera_fill,
                      size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(UserModel user) {
    return Column(
      children: [
        _buildDetailRow(
          icon: CupertinoIcons.mail_solid,
          label: 'Email',
          value: (user.email != null && user.email!.isNotEmpty)
              ? user.email!
              : 'Not set',
        ),
        Divider(height: 28, color: kBorderColor),
        _buildDetailRow(
          icon: CupertinoIcons.phone_fill,
          label: 'Mobile Number',
          value: '+254 ${user.phone}',
        ),
        Divider(height: 28, color: kBorderColor),
        _buildDetailRow(
          icon: _getUserTypeIcon(user.userType),
          label: 'Account Type',
          value: _getUserTypeText(user.userType),
        ),
        Divider(height: 28, color: kBorderColor),
        _buildDetailRow(
          icon: CupertinoIcons.calendar,
          label: 'Member Since',
          value: _formatMemberSince(user.createdAt),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: kPrimaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.afacad(
                      fontSize: 12.5, color: kTextSecondary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.afacad(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const List<String> _monthAbbreviations = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatMemberSince(DateTime date) {
    return '${_monthAbbreviations[date.month - 1]} ${date.year}';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.afacad(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: kTextPrimary,
          letterSpacing: -0.2),
    );
  }

  Widget _buildAccountSection(AppProvider appProvider) {
    final options = [
      (CupertinoIcons.pencil, 'Edit Profile', _editProfile, kTextPrimary),
      (
        CupertinoIcons.lock_shield_fill,
        'Privacy & Security',
        _showPrivacySettings,
        kTextPrimary
      ),
      (CupertinoIcons.globe, 'Language', _changeLanguage, kTextPrimary),
      (CupertinoIcons.moon_fill, 'Dark Mode', _toggleTheme, kTextPrimary),
      (CupertinoIcons.square_arrow_right, 'Sign Out', _signOut, kErrorColor),
    ];

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++)
            _buildAccountOption(
              options[i].$1,
              options[i].$2,
              options[i].$3,
              color: options[i].$4,
              showDivider: i < options.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildAccountOption(
    IconData icon,
    String label,
    VoidCallback onTap, {
    required Color color,
    required bool showDivider,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.afacad(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
                Icon(CupertinoIcons.chevron_forward,
                    size: 16, color: kTextSecondary.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 16, endIndent: 16, color: kBorderColor),
      ],
    );
  }

  Widget _buildAppInfo() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/LOGO/logo.png', height: 48, fit: BoxFit.contain),
          const SizedBox(height: 12),
          Text('KulaHub v1.0.0',
              style: GoogleFonts.afacad(fontSize: 13, color: kTextSecondary)),
          const SizedBox(height: 4),
          Text(
            '© ${DateTime.now().year} KulaHub. All rights reserved.',
            style: GoogleFonts.afacad(fontSize: 11.5, color: kTextSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return CupertinoIcons.person_fill;
      case UserType.rider:
        return CupertinoIcons.car_detailed;
      case UserType.merchant:
        return CupertinoIcons.bag_fill;
      case UserType.admin:
        return CupertinoIcons.shield_fill;
    }
  }

  String _getUserTypeText(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return 'Customer';
      case UserType.rider:
        return 'Delivery Rider';
      case UserType.merchant:
        return 'Merchant';
      case UserType.admin:
        return 'Admin';
    }
  }

  // Action Methods
  void _editProfile() {
    AppRouter.pushNamed(
      '/editProfile',
      arguments: {
        'user': Provider.of<AppProvider>(context, listen: false).user
      },
    );
  }

  void _showAvatarPickerSheet(UserModel user) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: const BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: kBorderColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 18),
              Text(
                'Update Profile Photo',
                style: GoogleFonts.afacad(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary),
              ),
              const SizedBox(height: 18),
              _buildAvatarPickerOption(
                icon: CupertinoIcons.camera_fill,
                label: 'Take Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatarImage(user, ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _buildAvatarPickerOption(
                icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickAvatarImage(user, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarPickerOption(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: kPrimaryColor),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.afacad(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatarImage(UserModel user, ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
        source: source, maxWidth: 800, imageQuality: 85);
    if (pickedFile == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider
          .updateUserProfile(user.copyWith(profileImage: pickedFile.path));
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _showPrivacySettings() {
    AppRouter.pushNamed('/privacy');
  }

  void _changeLanguage() {
    _showLanguageDialog();
  }

  void _toggleTheme() {
    Provider.of<AppProvider>(context, listen: false).toggleTheme();
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kCardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Sign Out',
              style: GoogleFonts.afacad(
                  fontWeight: FontWeight.w800, color: kTextPrimary)),
          content: Text('Are you sure you want to sign out?',
              style: GoogleFonts.afacad(color: kTextSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.afacad(
                      fontWeight: FontWeight.w700, color: kTextSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AppProvider>(context, listen: false).logout();
                AppRouter.pushNamedAndRemoveUntil(AppRouter.login);
              },
              child: Text('Sign Out',
                  style: GoogleFonts.afacad(
                      fontWeight: FontWeight.w700, color: kErrorColor)),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kCardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text('Select Language',
              style: GoogleFonts.afacad(
                  fontWeight: FontWeight.w800, color: kTextPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(CupertinoIcons.globe, color: kPrimaryColor),
                title: Text('English',
                    style: GoogleFonts.afacad(color: kTextPrimary)),
                trailing: appProvider.locale.languageCode == 'en'
                    ? Icon(CupertinoIcons.checkmark_alt, color: kSuccessColor)
                    : null,
                onTap: () {
                  appProvider.setLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(CupertinoIcons.globe, color: kPrimaryColor),
                title: Text('Kiswahili',
                    style: GoogleFonts.afacad(color: kTextPrimary)),
                trailing: appProvider.locale.languageCode == 'sw'
                    ? Icon(CupertinoIcons.checkmark_alt, color: kSuccessColor)
                    : null,
                onTap: () {
                  appProvider.setLocale(const Locale('sw', 'KE'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== BOTTOM NAV BAR ====================
  Widget _buildBottomNavBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: kTextPrimary,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
                color: kPrimaryColor.withValues(alpha: 0.25), width: 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 26,
                  offset: const Offset(0, 12)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.house_fill, 'Home', false,
                  () => AppRouter.pushNamedAndRemoveUntil(AppRouter.home)),
              _buildNavItem(CupertinoIcons.square_grid_2x2, 'Menu', false,
                  () => AppRouter.pushNamed(AppRouter.menu)),
              _buildCartNavItem(),
              _buildNavItem(CupertinoIcons.gift, 'Rewards', false,
                  () => AppRouter.pushNamed(AppRouter.promotions)),
              _buildNavItem(CupertinoIcons.person_fill, 'Profile', true, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool selected, VoidCallback onTap) {
    final color = selected ? kPrimaryColor : Colors.white.withValues(alpha: 0.55);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.afacad(
                color: color,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.3,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 14 : 0,
              height: 2,
              color: kPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartNavItem() {
    final appProvider = context.watch<AppProvider>();
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        AppRouter.pushNamed(AppRouter.cart);
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(CupertinoIcons.cart_fill,
                  color: Colors.white, size: 22),
            ),
            if (appProvider.cartItemCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: kErrorColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: kTextPrimary, width: 2)),
                  constraints:
                      const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Center(
                    child: Text(
                      appProvider.cartItemCount > 9
                          ? '9+'
                          : '${appProvider.cartItemCount}',
                      style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800),
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
