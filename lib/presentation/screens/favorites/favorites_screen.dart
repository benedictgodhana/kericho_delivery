import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/data/models/merchant_model.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Color palette matching HomeScreen
  static const Color kPrimaryColor = Color(0xFF0F766E);
  static const Color kPrimaryDark = Color(0xFF0D9488);
  static const Color kBackgroundColor = Color(0xFFF8FAFC);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF0F172A);
  static const Color kTextSecondary = Color(0xFF64748B);
  static const Color kBorderColor = Color(0xFFE2E8F0);
  static const Color kSuccessColor = Color(0xFF10B981);
  static const Color kWarningColor = Color(0xFFF59E0B);
  static const Color kErrorColor = Color(0xFFEF4444);
  static const Color kInfoColor = Color(0xFF3B82F6);
  static const Color kGradientStart = Color(0xFF0F766E);
  static const Color kGradientEnd = Color(0xFF115E59);
  static const Color kSurfaceLight = Color(0xFFF1F5F9);

  final List<String> _sortOptions = [
    'Recently Added',
    'A to Z',
    'Rating: High to Low',
    'Delivery Time',
  ];
  String _selectedSortOption = 'Recently Added';
  bool _isGridView = false;

  void _toggleView() {
    HapticFeedback.lightImpact();
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _navigateToMerchant(String merchantId, String merchantName) {
    HapticFeedback.mediumImpact();
    AppRouter.pushNamed(
      AppRouter.merchant,
      arguments: {'merchantId': merchantId, 'merchantName': merchantName},
    );
  }

  void _removeFromFavorites(String merchantId) {
    HapticFeedback.lightImpact();
    final appProvider = context.read<AppProvider>();
    appProvider.toggleFavorite(merchantId as MerchantModel);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(CupertinoIcons.heart_slash, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Removed from favorites',
              style: GoogleFonts.afacad(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: kErrorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 6,
      ),
    );
  }

  void _clearAllFavorites() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kCardColor,
        title: Row(
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle, color: kWarningColor),
            const SizedBox(width: 12),
            Text(
              'Clear All Favorites?',
              style: GoogleFonts.afacad(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove all items from your favorites? This action cannot be undone.',
          style: GoogleFonts.afacad(
            fontSize: 15,
            color: kTextSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: kBorderColor, width: 1.5),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.afacad(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final appProvider = context.read<AppProvider>();
              appProvider.clearAllFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(CupertinoIcons.checkmark_circle_fill,
                          color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        'All favorites cleared',
                        style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: kSuccessColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                  elevation: 6,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kErrorColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: kErrorColor.withOpacity(0.3),
            ),
            child: Text(
              'Clear All',
              style: GoogleFonts.afacad(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MerchantModel> _getFavoriteMerchants(
      AppProvider appProvider, MerchantProvider merchantProvider) {
    final favoriteIds = appProvider.favorites;
    return merchantProvider.merchants
        .where((merchant) => favoriteIds.contains(merchant.id))
        .toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kSurfaceLight, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Icon(
                CupertinoIcons.heart,
                size: 64,
                color: kTextSecondary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No favorites yet',
              style: GoogleFonts.afacad(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Save your favorite restaurants and stores for quick access. Tap the heart icon on any merchant to add it here.',
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: kTextSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Navigate to home to browse
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: kPrimaryColor.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.compass, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Explore Stores',
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
    );
  }

  Widget _buildMerchantCard(MerchantModel merchant, bool isGridView) {
    if (isGridView) {
      return _buildGridViewCard(merchant);
    } else {
      return _buildListViewCard(merchant);
    }
  }

  Widget _buildListViewCard(MerchantModel merchant) {
    return GestureDetector(
      onTap: () => _navigateToMerchant(merchant.id, merchant.name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorderColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            _buildMerchantImage(merchant, height: 120, width: 120),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            merchant.name,
                            style: GoogleFonts.afacad(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeFromFavorites(merchant.id),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kErrorColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.heart_fill,
                              size: 18,
                              color: kErrorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      merchant.description,
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: kTextSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kSurfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.star_fill,
                                size: 13,
                                color: kWarningColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                merchant.rating.toStringAsFixed(1),
                                style: GoogleFonts.afacad(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kWarningColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kSurfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kBorderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.clock,
                                size: 13,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${merchant.deliveryTime} min',
                                style: GoogleFonts.afacad(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: merchant.deliveryFee == 0
                                ? kSuccessColor.withOpacity(0.1)
                                : kSurfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: merchant.deliveryFee == 0
                                  ? kSuccessColor.withOpacity(0.3)
                                  : kBorderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                merchant.deliveryFee == 0
                                    ? CupertinoIcons.checkmark_seal_fill
                                    : CupertinoIcons.car_detailed,
                                size: 13,
                                color: merchant.deliveryFee == 0
                                    ? kSuccessColor
                                    : kPrimaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                merchant.deliveryFee == 0
                                    ? 'Free'
                                    : 'KSh ${merchant.deliveryFee.toInt()}',
                                style: GoogleFonts.afacad(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: merchant.deliveryFee == 0
                                      ? kSuccessColor
                                      : kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridViewCard(MerchantModel merchant) {
    return GestureDetector(
      onTap: () => _navigateToMerchant(merchant.id, merchant.name),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorderColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildMerchantImage(merchant, height: 140, width: double.infinity),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _removeFromFavorites(merchant.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.heart_fill,
                        size: 18,
                        color: kErrorColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant.name,
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSurfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.star_fill,
                              size: 12,
                              color: kWarningColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              merchant.rating.toStringAsFixed(1),
                              style: GoogleFonts.afacad(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kWarningColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSurfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              size: 12,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${merchant.deliveryTime} min',
                              style: GoogleFonts.afacad(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: merchant.deliveryFee == 0
                          ? kSuccessColor.withOpacity(0.1)
                          : kSurfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: merchant.deliveryFee == 0
                            ? kSuccessColor.withOpacity(0.3)
                            : kBorderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          merchant.deliveryFee == 0
                              ? CupertinoIcons.checkmark_seal_fill
                              : CupertinoIcons.car_detailed,
                          size: 14,
                          color: merchant.deliveryFee == 0
                              ? kSuccessColor
                              : kPrimaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          merchant.deliveryFee == 0
                              ? 'Free Delivery'
                              : 'KSh ${merchant.deliveryFee.toInt()}',
                          style: GoogleFonts.afacad(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: merchant.deliveryFee == 0
                                ? kSuccessColor
                                : kPrimaryColor,
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
      ),
    );
  }

  Widget _buildMerchantImage(
    MerchantModel merchant, {
    double height = 160,
    double width = double.infinity,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        height: height,
        width: width,
        color: kSurfaceLight,
        child: merchant.imageUrl != null
            ? (merchant.imageUrl!.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: merchant.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) =>
                        _buildImagePlaceholder(),
                  )
                : Image.asset(
                    merchant.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(),
                  ))
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: kSurfaceLight,
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Icon(
            CupertinoIcons.building_2_fill,
            size: 28,
            color: kTextSecondary.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  void _showSortOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort By',
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kSurfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: 20,
                        color: kTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ..._sortOptions.map((option) {
              final isSelected = option == _selectedSortOption;
              return ListTile(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedSortOption = option);
                  Navigator.pop(context);
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? kPrimaryColor.withOpacity(0.1)
                        : kSurfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSortIcon(option),
                    color: isSelected ? kPrimaryColor : kTextSecondary,
                    size: 20,
                  ),
                ),
                title: Text(
                  option,
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? kPrimaryColor : kTextPrimary,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: kPrimaryColor,
                        size: 22,
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(String option) {
    switch (option) {
      case 'Recently Added':
        return CupertinoIcons.clock;
      case 'A to Z':
        return CupertinoIcons.textformat_abc;
      case 'Rating: High to Low':
        return CupertinoIcons.star;
      case 'Delivery Time':
        return CupertinoIcons.time;
      default:
        return CupertinoIcons.sort_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, MerchantProvider>(
      builder: (context, appProvider, merchantProvider, child) {
        final favoriteMerchants = _getFavoriteMerchants(appProvider, merchantProvider);
        
        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: Text(
              'Favorites',
              style: GoogleFonts.afacad(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              if (favoriteMerchants.isNotEmpty)
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showSortOptions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: kSurfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getSortIcon(_selectedSortOption),
                              size: 16,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedSortOption,
                              style: GoogleFonts.afacad(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleView,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kSurfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBorderColor, width: 1.5),
                        ),
                        child: Icon(
                          _isGridView
                              ? CupertinoIcons.list_bullet
                              : CupertinoIcons.square_grid_2x2,
                          size: 18,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
            ],
          ),
          body: favoriteMerchants.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${favoriteMerchants.length} ${favoriteMerchants.length == 1 ? 'favorite' : 'favorites'}',
                            style: GoogleFonts.afacad(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kTextSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearAllFavorites,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: kErrorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: kErrorColor.withOpacity(0.3),
                                    width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.trash,
                                    size: 14,
                                    color: kErrorColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Clear All',
                                    style: GoogleFonts.afacad(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: kErrorColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isGridView
                          ? GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              itemCount: favoriteMerchants.length,
                              itemBuilder: (context, index) {
                                return _buildMerchantCard(
                                    favoriteMerchants[index], true);
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: favoriteMerchants.length,
                              itemBuilder: (context, index) {
                                return _buildMerchantCard(
                                    favoriteMerchants[index], false);
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}