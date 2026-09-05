import 'package:equatable/equatable.dart';

class VideoItem extends Equatable {
  final String id;
  final String title;
  final String path;
  final String? thumbnailPath;
  final int duration; // in seconds
  final int size; // in bytes
  final DateTime dateAdded;
  final String? folderName;

  const VideoItem({
    required this.id,
    required this.title,
    required this.path,
    this.thumbnailPath,
    required this.duration,
    required this.size,
    required this.dateAdded,
    this.folderName,
  });

  String get durationText {
    final hours = duration \~/ 3600;
    final minutes = (duration % 3600) \~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '\( {hours.toString().padLeft(2, '0')}: \){minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '\( {minutes.toString().padLeft(2, '0')}: \){seconds.toString().padLeft(2, '0')}';
  }

  String get sizeText {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  List<Object?> get props => [id, title, path, duration, size, dateAdded];
}
