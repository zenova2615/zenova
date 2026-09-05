import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBarBackground,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.phone_android_rounded,
                  label: 'Clone',
                  isSelected: navigationShell.currentIndex == AppConstants.navAppClone,
                  onTap: () => _onTap(AppConstants.navAppClone),
                ),
                _NavItem(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Share',
                  isSelected: navigationShell.currentIndex == AppConstants.navShare,
                  onTap: () => _onTap(AppConstants.navShare),
                ),
                _NavItem(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'Player',
                  isSelected: navigationShell.currentIndex == AppConstants.navPlayer,
                  onTap: () => _onTap(AppConstants.navPlayer),
                  isPrimary: true,
                ),
                _NavItem(
                  icon: Icons.download_rounded,
                  label: 'Download',
                  isSelected: navigationShell.currentIndex == AppConstants.navDownloader,
                  onTap: () => _onTap(AppConstants.navDownloader),
                ),
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Tools',
                  isSelected: navigationShell.currentIndex == AppConstants.navOtherTools,
                  onTap: () => _onTap(AppConstants.navOtherTools),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isPrimary;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.navBarUnselected;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppConstants.animFast,
              padding: isPrimary ? const EdgeInsets.all(6) : EdgeInsets.zero,
              decoration: isPrimary && isSelected
                  ? BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                icon,
                size: isPrimary ? 28 : 24,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
