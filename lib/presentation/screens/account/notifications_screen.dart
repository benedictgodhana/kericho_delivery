import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';

class NotificationItem {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;

  const NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<NotificationItem> _items = [
    NotificationItem(
      icon: Icons.delivery_dining,
      title: 'Order on the way',
      body: 'Your rider has picked up your order from The Grill House.',
      time: '2 min ago',
      unread: true,
    ),
    NotificationItem(
      icon: Icons.local_offer,
      title: '20% off your next order',
      body: 'Use code KULA20 at checkout. Valid until the weekend.',
      time: '1 hr ago',
      unread: true,
    ),
    NotificationItem(
      icon: Icons.star_rate,
      title: 'Rate your last order',
      body: 'How was your experience with Green Gardens Restaurant?',
      time: 'Yesterday',
    ),
    NotificationItem(
      icon: Icons.storefront,
      title: 'New vendor near you',
      body: 'MediCare Pharmacy just joined KulaHub Marketplace.',
      time: '2 days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: item.unread ? AppTheme.primaryColor.withOpacity(0.06) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: GoogleFonts.afacad(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(item.body, style: GoogleFonts.afacad(fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      Text(item.time, style: GoogleFonts.afacad(fontSize: 11, color: AppTheme.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
