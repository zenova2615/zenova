import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AppCloneScreen extends StatelessWidget {
  const AppCloneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Clone', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text(
            'Create independent app clones',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Warning Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'App Clone works only on supported apps and requires device compatibility. Original apps remain safe.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'My Clones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: const Column(
              children: [
                Icon(Icons.phone_android_rounded, size: 42, color: AppColors.textTertiary),
                SizedBox(height: 12),
                Text('No clones created yet', style: TextStyle(color: AppColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Supported Apps',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _CloneAppTile(name: 'WhatsApp', icon: Icons.chat_rounded),
          _CloneAppTile(name: 'Facebook', icon: Icons.facebook_rounded),
          _CloneAppTile(name: 'Instagram', icon: Icons.camera_alt_rounded),
          _CloneAppTile(name: 'Telegram', icon: Icons.send_rounded),
        ],
      ),
    );
  }
}

class _CloneAppTile extends StatelessWidget {
  final String name;
  final IconData icon;

  const _CloneAppTile({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        subtitle: const Text('Supported', style: TextStyle(fontSize: 12, color: AppColors.success)),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$name Clone - Coming in next update')),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Clone'),
        ),
      ),
    );
  }
}
