import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../models/download_item.dart';
import '../services/download_service.dart';

class DownloaderScreen extends StatefulWidget {
  const DownloaderScreen({super.key});

  @override
  State<DownloaderScreen> createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  final _urlController = TextEditingController();
  final _downloadService = DownloadService();
  List<DownloadItem> _downloads = [];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyzeAndDownload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final item = await _downloadService.addToQueue(
      title: 'Video \( {DateTime.now().hour}: \){DateTime.now().minute}',
      url: url,
    );

    setState(() => _downloads = _downloadService.queue);

    _downloadService.startDownload(item.id, (updated) {
      setState(() => _downloads = _downloadService.queue);
    });

    _urlController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Downloader', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _urlController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Paste video URL...',
                      prefixIcon: const Icon(Icons.link_rounded, color: AppColors.textTertiary),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            _urlController.text = data!.text!;
                          }
                        },
                        icon: const Icon(Icons.paste_rounded, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _analyzeAndDownload,
                      child: const Text('Download'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _downloads.isEmpty
                  ? const Center(
                      child: Text(
                        'No downloads yet',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _downloads.length,
                      itemBuilder: (context, index) {
                        final item = _downloads[index];
                        return _DownloadTile(item: item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final DownloadItem item;
  const _DownloadTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: item.progress,
            backgroundColor: AppColors.surfaceVariant,
            color: AppColors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            '${(item.progress * 100).toStringAsFixed(0)}%  •  ${item.status.name}',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
