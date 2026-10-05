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

  // KulaHub brand palette (matches the redesigned home screen)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);

  // Refined accents (shared with home, menu, cart + merchant screens)
  static const Color kInk = kTextPrimary;
  static const Color kGold = kPrimaryColor;
  static const Color kHairline = kBorderColor;

  static const List<_RewardTier> _tiers = [
    _RewardTier('Bronze', 0),
    _RewardTier('Silver', 500),
    _RewardTier('Gold', 1500),
  ];

  static const List<Map<String, dynamic>> _redeemables = [
    {
      'icon': CupertinoIcons.car_detailed,
      'title': 'Free Delivery',
      'points': 150
    },
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
    final spent =
        orderProvider.orders.fold(0.0, (sum, o) => sum + o.totalAmount);
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

  void _showSnack(BuildContext context, String message,
      {bool success = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success
                  ? CupertinoIcons.checkmark_alt_circle_fill
                  : CupertinoIcons.sparkles,
              color: kGold,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.afacad(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: kInk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }

  void _redeem(BuildContext context, String title, int cost, int points) {
    HapticFeedback.mediumImpact();
    final canRedeem = points >= cost;
    _showSnack(
      context,
      canRedeem
          ? '$title redeemed!'
          : 'Need ${cost - points} more points for $title',
      success: canRedeem,
    );
  }

  void _copyCode(BuildContext context, String code) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    _showSnack(context, 'Copied $code to clipboard', success: true);
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
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildPointsCard(points, tier, nextTier),
            const SizedBox(height: 20),
            _buildHowItWorks(),
            const SizedBox(height: 36),
            _buildSectionTitle('Redeem Rewards'),
            const SizedBox(height: 20),
            _buildRedeemablesGrid(context, points),
            const SizedBox(height: 36),
            _buildSectionTitle('Promo Codes'),
            const SizedBox(height: 20),
            for (final promo in _promos)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPromoCard(context, promo),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // ───────────────────────── HEADER ─────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kCardColor,
              shape: BoxShape.circle,
              border: Border.all(color: kHairline, width: 1),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(CupertinoIcons.back, color: kInk, size: 19),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rewards',
                style: GoogleFonts.afacad(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'EARN, REDEEM, ENJOY',
                style: GoogleFonts.afacad(
                  fontSize: 11,
                  color: kGold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.afacad(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: kInk,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(width: 36, height: 2, color: kGold),
      ],
    );
  }

  // ───────────────────────── POINTS CARD ─────────────────────────

  Widget _buildPointsCard(int points, _RewardTier tier, _RewardTier? nextTier) {
    final progress = nextTier == null
        ? 1.0
        : (points - tier.threshold) / (nextTier.threshold - tier.threshold);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B2623), kInk],
          ),
        ),
        child: Stack(
          children: [
            // Warm glow accents (same language as the home hero)
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimaryColor.withValues(alpha: 0.28),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -60,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGold.withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'YOUR POINTS',
                        style: GoogleFonts.afacad(
                          color: kGold,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.rosette,
                                color: kGold, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '${tier.name} Tier',
                              style: GoogleFonts.afacad(
                                color: kInk,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$points',
                        style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'pts',
                        style: GoogleFonts.afacad(
                          color: kGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation(kGold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nextTier == null
                        ? "You've reached the highest tier!"
                        : '${nextTier.threshold - points} pts to ${nextTier.name} Tier',
                    style: GoogleFonts.afacad(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      for (var i = 0; i < _tiers.length; i++) ...[
                        _tierChip(_tiers[i], points >= _tiers[i].threshold),
                        if (i < _tiers.length - 1) const SizedBox(width: 8),
                      ],
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

  Widget _tierChip(_RewardTier tier, bool reached) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: reached ? kGold.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: reached
              ? kGold.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reached
                ? CupertinoIcons.checkmark_alt_circle_fill
                : CupertinoIcons.lock_fill,
            size: 12,
            color: reached ? kGold : Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 5),
          Text(
            tier.name,
            style: GoogleFonts.afacad(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: reached ? Colors.white : Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── HOW IT WORKS ─────────────────────────

  Widget _buildHowItWorks() {
    final items = [
      (CupertinoIcons.bag_fill, 'Earn', '1 pt per\nKSh 10 spent'),
      (CupertinoIcons.arrow_2_circlepath, 'Redeem', 'Points for\nperks'),
      (CupertinoIcons.rosette, 'Unlock', 'Tiers for bigger\nrewards'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kGold.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: kGold.withValues(alpha: 0.35)),
                      ),
                      child: Icon(items[i].$1, color: kGold, size: 19),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      items[i].$2,
                      style: GoogleFonts.afacad(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].$3,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.afacad(
                        fontSize: 12.5,
                        color: kTextSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1) Container(width: 1, color: kHairline),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────────────────── REDEEMABLES ─────────────────────────

  Widget _buildRedeemablesGrid(BuildContext context, int points) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _redeemables.length,
      itemBuilder: (context, index) {
        final reward = _redeemables[index];
        final cost = reward['points'] as int;
        final canRedeem = points >= cost;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kGold.withValues(alpha: canRedeem ? 0.16 : 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: kGold.withValues(alpha: canRedeem ? 0.4 : 0.2)),
                    ),
                    child: Icon(
                      reward['icon'] as IconData,
                      color: canRedeem ? kGold : kGold.withValues(alpha: 0.6),
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  if (!canRedeem)
                    const Icon(CupertinoIcons.lock_fill,
                        size: 14, color: kTextSecondary),
                ],
              ),
              const Spacer(),
              Text(
                reward['title'] as String,
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                canRedeem ? '$cost pts' : '${cost - points} pts to go',
                style: GoogleFonts.afacad(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: canRedeem ? kGold : kTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _redeem(
                    context, reward['title'] as String, cost, points),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: canRedeem ? kInk : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: canRedeem
                        ? null
                        : Border.all(color: kHairline, width: 1.2),
                    boxShadow: canRedeem
                        ? [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 5)),
                          ]
                        : null,
                  ),
                  child: Text(
                    'Redeem',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.afacad(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: canRedeem ? Colors.white : kTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── PROMO TICKETS ─────────────────────────

  Widget _buildPromoCard(BuildContext context, Map<String, String> promo) {
    const stubWidth = 88.0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: kCardColor,
                      padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(
                              color: kGold.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: kGold.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.ticket_fill,
                                    size: 13, color: kGold),
                                const SizedBox(width: 6),
                                Text(
                                  promo['code']!,
                                  style: GoogleFonts.afacad(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.3,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            promo['title']!,
                            style: GoogleFonts.afacad(
                              color: kInk,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            promo['desc']!,
                            style: GoogleFonts.afacad(
                              color: kTextSecondary,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.clock,
                                  size: 13, color: kInk),
                              const SizedBox(width: 6),
                              Text(
                                promo['expiry']!,
                                style: GoogleFonts.afacad(
                                  color: kInk,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _copyCode(context, promo['code']!),
                    child: Container(
                      width: stubWidth,
                      color: kInk,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: kGold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.doc_on_clipboard,
                                color: kInk, size: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'COPY',
                            style: GoogleFonts.afacad(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Perforation: dashed line + notches where the stub meets the ticket
            Positioned(
              right: stubWidth,
              top: 14,
              bottom: 14,
              width: 1,
              child: const CustomPaint(painter: _DashedLinePainter(kHairline)),
            ),
            Positioned(
              right: stubWidth - 10,
              top: -10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    color: kBackgroundColor, shape: BoxShape.circle),
              ),
            ),
            Positioned(
              right: stubWidth - 10,
              bottom: -10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    color: kBackgroundColor, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── BOTTOM NAV BAR ─────────────────────────

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: kInk,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: kGold.withValues(alpha: 0.25), width: 1),
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
                  () => AppRouter.pushNamed(AppRouter.home)),
              _buildNavItem(CupertinoIcons.square_grid_2x2, 'Menu', false,
                  () => AppRouter.pushNamed(AppRouter.menu)),
              _buildCartNavItem(context),
              _buildNavItem(CupertinoIcons.gift_fill, 'Rewards', true, () {}),
              _buildNavItem(CupertinoIcons.person_fill, 'Profile', false,
                  () => AppRouter.pushNamed(AppRouter.profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool selected, VoidCallback onTap) {
    final color = selected ? kGold : Colors.white.withValues(alpha: 0.55);
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
              color: kGold,
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
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: kGold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: kGold.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(CupertinoIcons.cart_fill, color: kInk, size: 22),
            ),
            if (appProvider.cartItemCount > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: kInk, width: 2),
                  ),
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

class _RewardTier {
  final String name;
  final int threshold;
  const _RewardTier(this.name, this.threshold);
}

/// Vertical dashed line used as the ticket perforation on promo cards.
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const dash = 5.0;
    const gap = 5.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0.5, y), Offset(0.5, (y + dash).clamp(0, size.height)), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}