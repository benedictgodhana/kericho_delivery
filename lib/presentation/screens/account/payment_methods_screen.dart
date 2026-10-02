import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/data/models/order_model.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // KulaHub brand palette (matches settings/profile/home screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);

  PaymentMethod _defaultMethod = PaymentMethod.mpesa;

  void _addCard() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Adding new cards requires a connected payment provider',
          style: GoogleFonts.afacad(color: Colors.white),
        ),
        backgroundColor: kTextPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _sectionTitle('Default Payment Method'),
                  const SizedBox(height: 12),
                  _buildMethodTile(
                    method: PaymentMethod.mpesa,
                    icon: CupertinoIcons.phone_fill,
                    title: 'M-PESA',
                    subtitle: 'Pay instantly via STK push',
                  ),
                  const SizedBox(height: 10),
                  _buildMethodTile(
                    method: PaymentMethod.card,
                    icon: CupertinoIcons.creditcard_fill,
                    title: 'Card',
                    subtitle: 'Visa, Mastercard',
                  ),
                  const SizedBox(height: 10),
                  _buildMethodTile(
                    method: PaymentMethod.wallet,
                    icon: CupertinoIcons.money_dollar_circle_fill,
                    title: 'KulaHub Wallet',
                    subtitle: 'KSh 0.00 balance',
                  ),
                  const SizedBox(height: 10),
                  _buildMethodTile(
                    method: PaymentMethod.cash,
                    icon: CupertinoIcons.money_dollar,
                    title: 'Cash on Delivery',
                    subtitle: 'Pay the rider when your order arrives',
                  ),
                  const SizedBox(height: 28),
                  _buildAddCardButton(),
                ],
              ),
            ),
          ],
        ),
      ),
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
              child: const Icon(CupertinoIcons.back, color: kTextPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Payment Methods',
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

  Widget _buildMethodTile({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _defaultMethod == method;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _defaultMethod = method);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCardColor,
          border: Border.all(color: selected ? kPrimaryColor : kBorderColor, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: kPrimaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w700, color: kTextPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.afacad(fontSize: 12.5, color: kTextSecondary)),
                ],
              ),
            ),
            Icon(
              selected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
              size: 22,
              color: selected ? kPrimaryColor : kBorderColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCardButton() {
    return GestureDetector(
      onTap: _addCard,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kCardColor,
          border: Border.all(color: kPrimaryColor, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.add, size: 18, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text(
              'Add New Card',
              style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w700, color: kPrimaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
