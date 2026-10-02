import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/order_provider.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  // KulaHub brand palette (matches home/menu/cart screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kPrimaryDark = Color(0xFFC73F22);
  static const Color kSecondaryColor = Color(0xFFFFB020);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);
  static const Color kSuccessColor = Color(0xFF2EAD6C);
  static const Color kErrorColor = Color(0xFFE5484D);

  static const List<_RewardTier> _tiers = [
    _RewardTier('Bronze', 0),
    _RewardTier('Silver', 500),
    _RewardTier('Gold', 1500),
  ];

  static const List<Map<String, dynamic>> _redeemables = [
    {'icon': CupertinoIcons.car_detailed, 'title': 'Free Delivery', 'points': 150},
    {'icon': CupertinoIcons.tag_fill, 'title': 'KSh 100 Off', 'points': 300},
    {'icon': CupertinoIcons.gift_fill, 'title': 'Free Dessert', 'points': 220},
    {'icon': CupertinoIcons.percent, 'title': '20% Off Order', 'points': 500},
  ];

  static const List<Map<String, String>> _promos = [
    {
      'code': 'KULA20',
      'title': '20% off your next order',
      'desc': 'Valid on orders above KSh 500. Applies to all vendors.',
      'expiry': 'Expires in 3 days',
    },
    {
      'code': 'FREESHIP',
      'title': 'Free delivery',
      'desc': 'Zero delivery fee on your first order from a new vendor.',
      'expiry': 'Expires in 7 days',
    },
    {
      'code': 'WEEKEND10',
      'title': '10% off weekend deals',
      'desc': 'Stackable with vendor-specific weekend promotions.',
      'expiry': 'Weekends only',
    },
  ];

  // 1 point per KSh 10 spent across past orders.
  int _calculatePoints(OrderProvider orderProvider) {
    final spent = orderProvider.orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    return (spent / 10).round();
  }

  _RewardTier _currentTier(int points) {
    var tier = _tiers.first;
    for (final t in _tiers) {
      if (points >= t.threshold) tier = t;
    }
    return tier;
  }

  _RewardTier? _nextTier(int points) {
    for (final t in _tiers) {
      if (points < t.threshold) return t;
    }
    return null;
  }

  void _redeem(BuildContext context, String title, int cost, int points) {
    HapticFeedback.mediumImpact();
    final canRedeem = points >= cost;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          canRedeem ? '$title redeemed!' : 'Need ${cost - points} more points for $title',
          style: GoogleFonts.afacad(color: Colors.white),
        ),
        backgroundColor: canRedeem ? kSuccessColor : kTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _copyCode(BuildContext context, String code) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $code to clipboard', style: GoogleFonts.afacad(color: Colors.white)),
        backgroundColor: kTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final points = _calculatePoints(orderProvider);
    final tier = _currentTier(points);
    final nextTier = _nextTier(points);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBody: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 18),
            _buildPointsCard(points, tier, nextTier),
            const SizedBox(height: 24),
            _buildHowItWorks(),
            const SizedBox(height: 28),
            _buildSectionTitle('Redeem Rewards'),
            const SizedBox(height: 14),
            _buildRedeemablesGrid(context, points),
            const SizedBox(height: 28),
            _buildSectionTitle('Promo Codes'),
            const SizedBox(height: 14),
            for (final promo in _promos)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPromoCard(context, promo),
              ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
            child: const Icon(CupertinoIcons.back, color: kTextPrimary, size: 20),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'Rewards',
          style: GoogleFonts.afacad(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(int points, _RewardTier tier, _RewardTier? nextTier) {
    final progress = nextTier == null
        ? 1.0
        : (points - tier.threshold) / (nextTier.threshold - tier.threshold);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, kPrimaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.gift_fill, color: Colors.white.withValues(alpha: 0.9), size: 20),
              const SizedBox(width: 8),
              Text(
                'Your Points',
                style: GoogleFonts.afacad(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${tier.name} Tier',
                  style: GoogleFonts.afacad(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$points pts',
            style: GoogleFonts.afacad(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(kSecondaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nextTier == null
                ? 'You\'ve reached the highest tier!'
                : '${nextTier.threshold - points} pts to ${nextTier.name} Tier',
            style: GoogleFonts.afacad(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    final items = [
      (CupertinoIcons.bag_fill, 'Earn 1 pt per\nKSh 10 spent'),
      (CupertinoIcons.arrow_2_circlepath, 'Redeem points\nfor perks'),
      (CupertinoIcons.rosette, 'Unlock tiers for\nbigger rewards'),
    ];
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: item == items.last ? 0 : 10),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor, width: 1),
              ),
              child: Column(
                children: [
                  Icon(item.$1, color: kPrimaryColor, size: 22),
                  const SizedBox(height: 8),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.afacad(fontSize: 11.5, fontWeight: FontWeight.w600, color: kTextSecondary, height: 1.25),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.afacad(fontSize: 19, fontWeight: FontWeight.w800, color: kTextPrimary, letterSpacing: -0.2),
    );
  }

  Widget _buildRedeemablesGrid(BuildContext context, int points) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: _redeemables.length,
      itemBuilder: (context, index) {
        final reward = _redeemables[index];
        final cost = reward['points'] as int;
        final canRedeem = points >= cost;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kSecondaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(reward['icon'] as IconData, color: kSecondaryColor, size: 18),
              ),
              const Spacer(),
              Text(
                reward['title'] as String,
                style: GoogleFonts.afacad(fontSize: 13.5, fontWeight: FontWeight.w700, color: kTextPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '$cost pts',
                    style: GoogleFonts.afacad(fontSize: 12, fontWeight: FontWeight.w700, color: kTextSecondary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _redeem(context, reward['title'] as String, cost, points),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: canRedeem ? kPrimaryColor : kBorderColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Redeem',
                        style: GoogleFonts.afacad(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: canRedeem ? Colors.white : kTextSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromoCard(BuildContext context, Map<String, String> promo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, kSecondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  promo['code']!,
                  style: GoogleFonts.afacad(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 13),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyCode(context, promo['code']!),
                child: const Icon(CupertinoIcons.doc_on_clipboard, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            promo['title']!,
            style: GoogleFonts.afacad(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            promo['desc']!,
            style: GoogleFonts.afacad(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            promo['expiry']!,
            style: GoogleFonts.afacad(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAV BAR ====================
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.house_fill, 'Home', false, () => AppRouter.pushNamed(AppRouter.home)),
              _buildNavItem(CupertinoIcons.square_grid_2x2, 'Menu', false, () => AppRouter.pushNamed(AppRouter.menu)),
              _buildCartNavItem(context),
              _buildNavItem(CupertinoIcons.gift_fill, 'Rewards', true, () {}),
              _buildNavItem(CupertinoIcons.person_fill, 'Profile', false, () => AppRouter.pushNamed(AppRouter.profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? kPrimaryColor : kTextSecondary, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.afacad(
                color: selected ? kPrimaryColor : kTextSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartNavItem(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        AppRouter.pushNamed(AppRouter.cart);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: kPrimaryColor.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(CupertinoIcons.cart_fill, color: Colors.white, size: 22),
            ),
            if (appProvider.cartItemCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: kErrorColor, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      appProvider.cartItemCount > 9 ? '9+' : '${appProvider.cartItemCount}',
                      style: GoogleFonts.afacad(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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

class _RewardTier {
  final String name;
  final int threshold;
  const _RewardTier(this.name, this.threshold);
}
