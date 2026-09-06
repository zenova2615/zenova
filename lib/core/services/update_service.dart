import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // এই লিংকটা পরে তোমার আসল version.json দিয়ে বদলাবে
  static const String versionUrl =
      'https://raw.githubusercontent.com/zenova2615/zenova/main/version.json';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(versionUrl)).timeout(
            const Duration(seconds: 8),
          );

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final latestVersion = data['version'] as String?;
      final downloadUrl = data['download_url'] as String?;
      final forceUpdate = data['force_update'] ?? false;
      final message = data['message'] ?? 'A new version is available.';

      if (latestVersion == null || downloadUrl == null) return;

      if (_isNewerVersion(latestVersion, currentVersion)) {
        if (!context.mounted) return;

        showDialog(
          context: context,
          barrierDismissible: !forceUpdate,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Update Available',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Version $latestVersion is available.\n\n$message',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                onPressed: () async {
                  final uri = Uri.parse(downloadUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }
}
