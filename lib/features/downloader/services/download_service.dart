import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/download_item.dart';

class DownloadService {
  final List<DownloadItem> _queue = [];

  List<DownloadItem> get queue => List.unmodifiable(_queue);

  Future<String> getDownloadDirectory() async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final downloadDir = Directory(p.join(dir.path, 'ZENOVA', 'Downloads'));
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  Future<DownloadItem> addToQueue({
    required String title,
    required String url,
  }) async {
    final dir = await getDownloadDirectory();
    final fileName = '\( {DateTime.now().millisecondsSinceEpoch}_ \){title.replaceAll(RegExp(r'[^\w\s-]'), '')}';
    final savePath = p.join(dir, '$fileName.mp4');

    final item = DownloadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      url: url,
      savePath: savePath,
      createdAt: DateTime.now(),
    );

    _queue.insert(0, item);
    return item;
  }

  // Basic simulation for now (real download will be improved later)
  Future<void> startDownload(String id, Function(DownloadItem) onUpdate) async {
    final index = _queue.indexWhere((e) => e.id == id);
    if (index == -1) return;

    var item = _queue[index].copyWith(status: DownloadStatus.downloading);
    _queue[index] = item;
    onUpdate(item);

    // Simulated progress (replace with real http download later)
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      item = item.copyWith(
        progress: i / 10,
        downloadedBytes: i * 1024 * 1024,
        totalBytes: 10 * 1024 * 1024,
      );
      _queue[index] = item;
      onUpdate(item);
    }

    item = item.copyWith(status: DownloadStatus.completed, progress: 1.0);
    _queue[index] = item;
    onUpdate(item);
  }

  void pause(String id) {
    final index = _queue.indexWhere((e) => e.id == id);
    if (index != -1) {
      _queue[index] = _queue[index].copyWith(status: DownloadStatus.paused);
    }
  }

  void cancel(String id) {
    _queue.removeWhere((e) => e.id == id);
  }
}
