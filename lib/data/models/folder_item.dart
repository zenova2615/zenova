import 'package:equatable/equatable.dart';
import 'video_item.dart';

class FolderItem extends Equatable {
  final String name;
  final String path;
  final int videoCount;
  final List<VideoItem> videos;

  const FolderItem({
    required this.name,
    required this.path,
    required this.videoCount,
    this.videos = const [],
  });

  @override
  List<Object?> get props => [name, path, videoCount];
}
