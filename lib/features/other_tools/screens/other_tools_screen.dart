import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../vault/screens/vault_screen.dart';

class OtherToolsScreen extends StatelessWidget {
  const OtherToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Other Tools',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text(
              'Additional media tools',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                _ToolItem(
                  icon: Icons.lock_rounded,
                  label: 'Private Vault',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VaultScreen()),
                    );
                  },
                ),
                const _ToolItem(icon: Icons.folder_outlined, label: 'File Manager'),
                const _ToolItem(icon: Icons.compress_rounded, label: 'Compressor'),
                const _ToolItem(icon: Icons.swap_horiz_rounded, label: 'Converter'),
                const _ToolItem(icon: Icons.content_cut_rounded, label: 'Trimmer'),
                const _ToolItem(icon: Icons.audiotrack_rounded, label: 'Audio Extract'),
                const _ToolItem(icon: Icons.subtitles_rounded, label: 'Subtitle'),
                const _ToolItem(icon: Icons.info_outline_rounded, label: 'Media Info'),
                const _ToolItem(icon: Icons.storage_rounded, label: 'Storage'),
                const _ToolItem(icon: Icons.videocam_outlined, label: 'Recorder'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ToolItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: InkWell(
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label - Coming soon')),
              );
            },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
