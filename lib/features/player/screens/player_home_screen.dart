import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class PlayerHomeScreen extends StatelessWidget {
  const PlayerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Video Player',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Player Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text(
              'Your Media, Your Way',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Continue Watching',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _EmptyCard(
              icon: Icons.history_rounded,
              message: 'No videos in progress',
            ),
            const SizedBox(height: 28),
            const Text(
              'Recent Videos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _EmptyCard(
              icon: Icons.video_library_outlined,
              message: 'No recent videos',
            ),
            const SizedBox(height: 28),
            const Text(
              'Folders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _EmptyCard(
              icon: Icons.folder_outlined,
              message: 'Media folders will appear here',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
