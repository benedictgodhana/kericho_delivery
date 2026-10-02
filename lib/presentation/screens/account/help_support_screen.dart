import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // KulaHub brand palette (matches settings/profile screens)
  static const Color kPrimaryColor = Color(0xFFFF5A36);
  static const Color kBackgroundColor = Color(0xFFFFF8F1);
  static const Color kCardColor = Colors.white;
  static const Color kTextPrimary = Color(0xFF16181D);
  static const Color kTextSecondary = Color(0xFF6C757D);
  static const Color kBorderColor = Color(0xFFF0E4D8);

  int? _expandedIndex;

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How do I track my order?',
      'a': 'Open Orders from your profile and tap any active order to see live status and rider details.',
    },
    {
      'q': 'Can I order from multiple restaurants at once?',
      'a': 'Each order currently comes from a single restaurant so your food arrives together and fresh. Place a separate order for a different vendor.',
    },
    {
      'q': 'What payment methods are supported?',
      'a': 'M-PESA, card, KulaHub Wallet, and cash on delivery where the vendor supports it.',
    },
    {
      'q': 'How do refunds work?',
      'a': 'If an order is cancelled before the vendor accepts it, any payment is refunded automatically within 24 hours.',
    },
  ];

  void _showComingSoon() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Live chat support is launching soon', style: GoogleFonts.afacad(color: Colors.white)),
        backgroundColor: kTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactTile(
                          icon: CupertinoIcons.chat_bubble_2_fill,
                          label: 'Live Chat',
                          onTap: _showComingSoon,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildContactTile(
                          icon: CupertinoIcons.phone_fill,
                          label: 'Call Us',
                          onTap: () => launchUrl(Uri.parse('tel:+254700000000')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildContactTile(
                          icon: CupertinoIcons.mail_solid,
                          label: 'Email',
                          onTap: () => launchUrl(Uri.parse('mailto:support@kulahub.app')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle('Frequently Asked Questions'),
                  const SizedBox(height: 12),
                  _buildFaqCard(),
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
            'Help & Support',
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

  Widget _buildContactTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: kCardColor,
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimaryColor, size: 22),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.afacad(fontSize: 12.5, fontWeight: FontWeight.w700, color: kTextPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard() {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < _faqs.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: kBorderColor),
            _buildFaqRow(index: i, question: _faqs[i]['q']!, answer: _faqs[i]['a']!),
          ],
        ],
      ),
    );
  }

  Widget _buildFaqRow({required int index, required String question, required String answer}) {
    final isExpanded = _expandedIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _expandedIndex = isExpanded ? null : index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: GoogleFonts.afacad(fontSize: 14.5, fontWeight: FontWeight.w700, color: kTextPrimary),
                  ),
                ),
                Icon(
                  isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                  size: 16,
                  color: kTextSecondary.withValues(alpha: 0.6),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              Text(
                answer,
                style: GoogleFonts.afacad(fontSize: 13, color: kTextSecondary, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
