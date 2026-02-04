import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kericho_delivery/data/models/order_model.dart';
import 'package:kericho_delivery/data/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/order_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Enhanced color palette matching HomeScreen
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
  static const Color kOverlayWhite = Color(0x1AFFFFFF);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = appProvider.user;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: user == null
          ? _buildLoginPrompt()
          : Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 320), // Increased to match header height
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Statistics Cards
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: kCardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: kBorderColor.withOpacity(0.5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildStatCard(
                                          icon: CupertinoIcons.bag_fill,
                                          value: orderProvider.totalOrders
                                              .toString(),
                                          label: 'Orders',
                                          color: kPrimaryColor,
                                        ),
                                        _buildStatCard(
                                          icon: CupertinoIcons
                                              .money_dollar_circle_fill,
                                          value:
                                              'KSh ${orderProvider.totalSpent.toStringAsFixed(0)}',
                                          label: 'Spent',
                                          color: kWarningColor,
                                        ),
                                        _buildStatCard(
                                          icon: CupertinoIcons.star_fill,
                                          value:
                                              user.rating?.toStringAsFixed(1) ??
                                                  'N/A',
                                          label: 'Rating',
                                          color: Colors.amber,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Quick Actions Grid
                                  Text(
                                    'Quick Actions',
                                    style: GoogleFonts.afacad(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: kTextPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GridView.count(
                                    crossAxisCount: 3,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    childAspectRatio: 1.1,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    children: [
                                      _buildActionButton(
                                        icon: CupertinoIcons.bag_fill,
                                        label: 'Orders',
                                        onTap: () => AppRouter.pushNamed(
                                            AppRouter.orderHistory!),
                                        color: kPrimaryColor,
                                      ),
                                      _buildActionButton(
                                        icon: CupertinoIcons.location_fill,
                                        label: 'Addresses',
                                        onTap: _manageAddresses,
                                        color: kInfoColor,
                                      ),
                                      _buildActionButton(
                                        icon: CupertinoIcons.heart_fill,
                                        label: 'Favorites',
                                        onTap: _viewFavorites,
                                        color: kErrorColor,
                                      ),
                                      _buildActionButton(
                                        icon: CupertinoIcons.creditcard_fill,
                                        label: 'Payments',
                                        onTap: _managePayments,
                                        color: kSuccessColor,
                                      ),
                                      _buildActionButton(
                                        icon: CupertinoIcons.bell_fill,
                                        label: 'Notifications',
                                        onTap: _manageNotifications,
                                        color: kWarningColor,
                                      ),
                                      _buildActionButton(
                                        icon:
                                            CupertinoIcons.question_circle_fill,
                                        label: 'Help',
                                        onTap: _showHelp,
                                        color: kTextSecondary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Recent Orders Section
                                  if (orderProvider.orders.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Recent Orders',
                                              style: GoogleFonts.afacad(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                color: kTextPrimary,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                AppRouter.pushNamed(
                                                    AppRouter.orderHistory!);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: kPrimaryColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'View All',
                                                      style: GoogleFonts.afacad(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: kPrimaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      CupertinoIcons
                                                          .chevron_right,
                                                      color: kPrimaryColor,
                                                      size: 14,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ...orderProvider
                                            .getRecentOrders(limit: 3)
                                            .map((order) =>
                                                _buildRecentOrderCard(order))
                                            .toList(),
                                      ],
                                    ),
                                  const SizedBox(height: 24),
                                  // Account Settings
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Account Settings',
                                        style: GoogleFonts.afacad(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: kTextPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: kCardColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: kBorderColor
                                                  .withOpacity(0.5)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            _buildSettingOption(
                                              icon: CupertinoIcons.person_fill,
                                              label: 'Edit Profile',
                                              onTap: _editProfile,
                                            ),
                                            _buildSettingOption(
                                              icon: CupertinoIcons.lock_fill,
                                              label: 'Privacy & Security',
                                              onTap: _showPrivacySettings,
                                            ),
                                            _buildSettingOption(
                                              icon: CupertinoIcons.globe,
                                              label: 'Language',
                                              onTap: _changeLanguage,
                                            ),
                                            _buildSettingOption(
                                              icon: CupertinoIcons.moon_fill,
                                              label: 'Dark Mode',
                                              onTap: _toggleTheme,
                                              trailing: Switch(
                                                value: appProvider.themeMode ==
                                                    ThemeMode.dark,
                                                onChanged: (value) =>
                                                    _toggleTheme(),
                                                activeColor: kPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Support Section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Support',
                                        style: GoogleFonts.afacad(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: kTextPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: kCardColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: kBorderColor
                                                  .withOpacity(0.5)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            _buildSettingOption(
                                              icon: CupertinoIcons
                                                  .question_circle_fill,
                                              label: 'Help Center',
                                              onTap: _showHelp,
                                            ),
                                            _buildSettingOption(
                                              icon: CupertinoIcons
                                                  .exclamationmark_circle_fill,
                                              label: 'Report an Issue',
                                              onTap: () => AppRouter.pushNamed(
                                                  '/report'),
                                            ),
                                            _buildSettingOption(
                                              icon: CupertinoIcons.star_fill,
                                              label: 'Rate Us',
                                              onTap: () =>
                                                  AppRouter.pushNamed('/rate'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Sign Out Button
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: kErrorColor.withOpacity(0.3)),
                                      color: kErrorColor.withOpacity(0.05),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        CupertinoIcons.arrow_right_square_fill,
                                        color: kErrorColor,
                                      ),
                                      title: Text(
                                        'Sign Out',
                                        style: GoogleFonts.afacad(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: kErrorColor,
                                        ),
                                      ),
                                      trailing: Icon(
                                        CupertinoIcons.chevron_right,
                                        color: kErrorColor.withOpacity(0.7),
                                      ),
                                      onTap: _signOut,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // App Version
                                  Center(
                                    child: Text(
                                      'Kericho Delivery v1.0.0',
                                      style: GoogleFonts.afacad(
                                        fontSize: 14,
                                        color: kTextSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Text(
                                      '© ${DateTime.now().year} Kericho Delivery. All rights reserved.',
                                      style: GoogleFonts.afacad(
                                        fontSize: 12,
                                        color: kTextSecondary,
                                      ),
                                    ),
                                  ),
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
                _buildCurvedHeader(user),
              ],
            ),
    );
  }

  Widget _buildCurvedHeader(UserModel user) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipPath(
        clipper: ProfileHeaderCurveClipper(),
        child: Container(
          height: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryDark, const Color(0xFF1E293B)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    // Settings Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            AppRouter.pushNamed('/settings');
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kOverlayWhite,
                            ),
                            child: Icon(
                              CupertinoIcons.gear,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Profile Picture with gradient border
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [kPrimaryColor, kSuccessColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: user.profileImage != null
                            ? CachedNetworkImage(
                                imageUrl: user.profileImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.white,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildDefaultProfile(),
                              )
                            : _buildDefaultProfile(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User Name
                    Text(
                      user.fullName,
                      style: GoogleFonts.afacad(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // User Phone
                    Text(
                      user.phone,
                      style: GoogleFonts.afacad(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (user.email != null && user.email!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          user.email!,
                          style: GoogleFonts.afacad(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 16),
                    // User Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getUserTypeColor(user.userType),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getUserTypeColor(user.userType)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getUserTypeIcon(user.userType),
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getUserTypeText(user.userType),
                            style: GoogleFonts.afacad(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Verification Badge
                    if (user.isVerified)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kSuccessColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: kSuccessColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                size: 16,
                                color: kSuccessColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Verified Account',
                                style: GoogleFonts.afacad(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: kSuccessColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultProfile() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Icon(
          CupertinoIcons.person_fill,
          size: 50,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      color: kBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kSuccessColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.person_fill,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Sign in to your account',
            style: GoogleFonts.afacad(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Access your orders, saved addresses,\nand more features',
            style: GoogleFonts.afacad(
              fontSize: 16,
              color: kTextSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    AppRouter.pushNamed(AppRouter.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: kPrimaryColor.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.arrow_right_to_line, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Sign In',
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    AppRouter.pushNamed(AppRouter.register);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: BorderSide(color: kPrimaryColor, width: 2),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.person_add, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Create Account',
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.afacad(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 13,
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderColor.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.afacad(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              _getStatusIcon(order.status),
              color: _getStatusColor(order.status),
              size: 24,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Order #${order.orderNumber}',
                style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(order.status),
                style: GoogleFonts.afacad(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _getStatusColor(order.status),
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDate(order.createdAt),
              style: GoogleFonts.afacad(
                fontSize: 13,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'KSh ${order.totalAmount.toStringAsFixed(2)}',
              style: GoogleFonts.afacad(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kPrimaryColor,
              ),
            ),
          ],
        ),
        trailing: Icon(
          CupertinoIcons.chevron_right,
          color: kTextSecondary,
        ),
        onTap: () {
          AppRouter.pushNamed(
            AppRouter.orderTracking,
            arguments: {'orderId': order.id},
          );
        },
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: kPrimaryColor,
            size: 20,
          ),
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.afacad(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: kTextPrimary,
        ),
      ),
      trailing: trailing ??
          Icon(
            CupertinoIcons.chevron_right,
            color: kTextSecondary,
            size: 18,
          ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Helper Methods
  Color _getUserTypeColor(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return kPrimaryColor;
      case UserType.rider:
        return kInfoColor;
      case UserType.merchant:
        return kSuccessColor;
      case UserType.admin:
        return Colors.purple;
    }
  }

  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return CupertinoIcons.person_fill;
      case UserType.rider:
        return Icons.directions_bike;
      case UserType.merchant:
        return CupertinoIcons.bag_fill;
      case UserType.admin:
        return CupertinoIcons.gear_solid;
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

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.pickedUp:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return kWarningColor;
      case OrderStatus.accepted:
        return kInfoColor;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.pickedUp:
        return kPrimaryColor;
      case OrderStatus.delivered:
        return kSuccessColor;
      case OrderStatus.cancelled:
        return kErrorColor;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return CupertinoIcons.clock_fill;
      case OrderStatus.accepted:
        return CupertinoIcons.checkmark_circle_fill;
      case OrderStatus.preparing:
        return CupertinoIcons.time_solid;
      case OrderStatus.ready:
        return CupertinoIcons.bag_fill;
      case OrderStatus.pickedUp:
        return Icons.directions_bike;
      case OrderStatus.delivered:
        return CupertinoIcons.checkmark_seal_fill;
      case OrderStatus.cancelled:
        return CupertinoIcons.xmark_circle_fill;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
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

  void _manageAddresses() {
    AppRouter.pushNamed('/addresses');
  }

  void _viewFavorites() {
    AppRouter.pushNamed('/favorites');
  }

  void _managePayments() {
    AppRouter.pushNamed('/paymentMethods');
  }

  void _manageNotifications() {
    AppRouter.pushNamed('/notifications');
  }

  void _showHelp() {
    AppRouter.pushNamed('/help');
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
          title: Text(
            'Sign Out',
            style: GoogleFonts.afacad(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: GoogleFonts.afacad(
              fontSize: 15,
              color: kTextSecondary,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AppProvider>(context, listen: false).logout();
                AppRouter.pushNamedAndRemoveUntil(AppRouter.login);
              },
              child: Text(
                'Sign Out',
                style: GoogleFonts.afacad(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kErrorColor,
                ),
              ),
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
          title: Text(
            'Select Language',
            style: GoogleFonts.afacad(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.globe,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                  ),
                ),
                title: Text(
                  'English',
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: appProvider.locale.languageCode == 'en'
                    ? Icon(
                        CupertinoIcons.checkmark_alt_circle_fill,
                        color: kSuccessColor,
                      )
                    : null,
                onTap: () {
                  appProvider.setLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.globe,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                  ),
                ),
                title: Text(
                  'Kiswahili',
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: appProvider.locale.languageCode == 'sw'
                    ? Icon(
                        CupertinoIcons.checkmark_alt_circle_fill,
                        color: kSuccessColor,
                      )
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
}

class ProfileHeaderCurveClipper extends CustomClipper<Path> {
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
