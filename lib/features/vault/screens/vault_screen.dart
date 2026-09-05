import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _isUnlocked = false;
  final _pinController = TextEditingController();

  void _checkPin() {
    // Simple demo PIN: 1234
    if (_pinController.text == '1234') {
      setState(() => _isUnlocked = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong PIN'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Private Vault', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: _isUnlocked ? _buildUnlocked() : _buildLockScreen(),
    );
  }

  Widget _buildLockScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Private Vault',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter PIN to unlock',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 12,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '••••',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkPin,
                child: const Text('Unlock'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Default PIN: 1234 (change later)',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlocked() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: const Column(
            children: [
              Icon(Icons.folder_special_rounded, size: 48, color: AppColors.textTertiary),
              SizedBox(height: 16),
              Text(
                'Vault is empty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Move private videos here for protection',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
