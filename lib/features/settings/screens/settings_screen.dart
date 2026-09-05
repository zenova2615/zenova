import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionTitle(title: 'General'),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Appearance',
            subtitle: 'AMOLED Black',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),

          _SectionTitle(title: 'Player'),
          _SettingsTile(
            icon: Icons.play_circle_rounded,
            title: 'Player Settings',
            subtitle: 'Orientation, controls, gestures',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.speed_rounded,
            title: 'Default Speed',
            subtitle: '1.0x',
            onTap: () {},
          ),

          _SectionTitle(title: 'Storage'),
          _SettingsTile(
            icon: Icons.folder_rounded,
            title: 'Download Location',
            subtitle: 'ZENOVA/Downloads',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.cleaning_services_rounded,
            title: 'Clear Cache',
            subtitle: 'Free up space',
            onTap: () {},
          ),

          _SectionTitle(title: 'Privacy'),
          _SettingsTile(
            icon: Icons.lock_rounded,
            title: 'Private Vault',
            subtitle: 'Protected media',
            onTap: () {},
          ),

          _SectionTitle(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About ZENOVA',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
    );
  }
}
