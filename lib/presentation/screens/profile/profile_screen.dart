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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = appProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppRouter.pushNamed('/settings');
            },
          ),
        ],
      ),
      body: user == null
          ? _buildLoginPrompt()
          : _buildProfileContent(user, orderProvider, appProvider),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Please sign in to view profile',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Access your orders, saved addresses, and more',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              AppRouter.pushNamed(AppRouter.login);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Sign In'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              AppRouter.pushNamed(AppRouter.register);
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    UserModel user,
    OrderProvider orderProvider,
    AppProvider appProvider,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            color: AppTheme.primaryColor.withOpacity(0.05),
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 3,
                        ),
                      ),
                      child: user.profileImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: user.profileImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: _editProfile,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // User Info
                Text(
                  user.fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  user.phone,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (user.email != null && user.email!.isNotEmpty)
                  Text(
                    user.email!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                const SizedBox(height: 16),

                // User Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(user.userType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getUserTypeIcon(user.userType),
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getUserTypeText(user.userType),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Verification Badge
                if (user.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Statistics
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Orders',
                  orderProvider.totalOrders.toString(),
                  Icons.shopping_bag,
                ),
                _buildStatCard(
                  'Spent',
                  'KSh ${orderProvider.totalSpent.toStringAsFixed(0)}',
                  Icons.attach_money,
                ),
                _buildStatCard(
                  'Rating',
                  user.rating?.toStringAsFixed(1) ?? 'N/A',
                  Icons.star,
                  color: Colors.amber,
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.2,
                  children: [
                    _buildActionButton(
                      Icons.history,
                      'Orders',
                      () => AppRouter.pushNamed(AppRouter.orderHistory!),
                    ),
                    _buildActionButton(
                      Icons.location_on,
                      'Addresses',
                      _manageAddresses,
                    ),
                    _buildActionButton(
                      Icons.favorite,
                      'Favorites',
                      _viewFavorites,
                    ),
                    _buildActionButton(
                      Icons.payment,
                      'Payments',
                      _managePayments,
                    ),
                    _buildActionButton(
                      Icons.notifications,
                      'Notifications',
                      _manageNotifications,
                    ),
                    _buildActionButton(
                      Icons.help,
                      'Help',
                      _showHelp,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Recent Orders
          if (orderProvider.orders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Recent Orders',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          AppRouter.pushNamed(AppRouter.orderHistory!);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...orderProvider.getRecentOrders(limit: 3).map((order) {
                    return _buildRecentOrderCard(order);
                  }).toList(),
                ],
              ),
            ),

          // Account Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAccountOption(
                  Icons.edit,
                  'Edit Profile',
                  _editProfile,
                ),
                _buildAccountOption(
                  Icons.security,
                  'Privacy & Security',
                  _showPrivacySettings,
                ),
                _buildAccountOption(
                  Icons.language,
                  'Language',
                  _changeLanguage,
                ),
                _buildAccountOption(
                  Icons.dark_mode,
                  'Dark Mode',
                  _toggleTheme,
                ),
                _buildAccountOption(
                  Icons.logout,
                  'Sign Out',
                  _signOut,
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // App Info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                Text(
                  'Kericho Delivery v1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© ${DateTime.now().year} Kericho Delivery. All rights reserved.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon,
      {Color color = AppTheme.primaryColor}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
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
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () {
        AppRouter.pushNamed(
          AppRouter.orderTracking,
          arguments: {'orderId': order.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Order Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(order.status),
                color: _getStatusColor(order.status),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.orderNumber}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(order.status),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KSh ${order.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color color = AppTheme.textPrimary,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: GoogleFonts.poppins(color: color),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Helper Methods
  Color _getUserTypeColor(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return AppTheme.primaryColor;
      case UserType.rider:
        return Colors.blue;
      case UserType.merchant:
        return Colors.green;
      case UserType.admin:
        return Colors.purple;
    }
  }

  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.customer:
        return Icons.person;
      case UserType.rider:
        return Icons.delivery_dining;
      case UserType.merchant:
        return Icons.store;
      case UserType.admin:
        return Icons.admin_panel_settings;
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
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.pickedUp:
        return AppTheme.primaryColor;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.accepted:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.shopping_bag;
      case OrderStatus.pickedUp:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
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
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<AppProvider>(context, listen: false).logout();
                AppRouter.pushNamedAndRemoveUntil(AppRouter.login);
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
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
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                trailing: appProvider.locale.languageCode == 'en'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  appProvider.setLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Kiswahili'),
                trailing: appProvider.locale.languageCode == 'sw'
                    ? const Icon(Icons.check, color: Colors.green)
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
