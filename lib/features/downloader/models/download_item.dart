import 'package:equatable/equatable.dart';

enum DownloadStatus { queued, downloading, paused, completed, failed, canceled }

class DownloadItem extends Equatable {
  final String id;
  final String title;
  final String url;
  final String savePath;
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final int totalBytes;
  final int downloadedBytes;
  final String? error;
  final DateTime createdAt;

  const DownloadItem({
    required this.id,
    required this.title,
    required this.url,
    required this.savePath,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.error,
    required this.createdAt,
  });

  DownloadItem copyWith({
    DownloadStatus? status,
    double? progress,
    int? totalBytes,
    int? downloadedBytes,
    String? error,
  }) {
    return DownloadItem(
      id: id,
      title: title,
      url: url,
      savePath: savePath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      error: error ?? this.error,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, status, progress, downloadedBytes];
}
