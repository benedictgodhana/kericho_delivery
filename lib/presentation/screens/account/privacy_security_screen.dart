import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, Icons.fingerprint, 'Biometric login', 'Use fingerprint or face unlock', true),
          _tile(context, Icons.shield_outlined, 'Two-factor authentication', 'Add an extra layer of security', false),
          _tile(context, Icons.visibility_off_outlined, 'Hide order history from vendors', 'Vendors only see what\'s needed to fulfil your order', true),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete account', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Permanently remove your KulaHub account and data'),
            onTap: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, bool initial) {
    return StatefulBuilder(
      builder: (context, setState) {
        var value = initial;
        return SwitchListTile(
          secondary: Icon(icon, color: AppTheme.primaryColor),
          title: Text(title, style: GoogleFonts.afacad(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: GoogleFonts.afacad(fontSize: 12)),
          value: value,
          activeColor: AppTheme.primaryColor,
          onChanged: (v) => setState(() => value = v),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('This action is permanent and cannot be undone. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
