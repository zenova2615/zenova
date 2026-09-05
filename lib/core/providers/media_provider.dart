import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/media_service.dart';
import '../../data/models/video_item.dart';
import '../../data/models/folder_item.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService();
});

final videosProvider = FutureProvider<List<VideoItem>>((ref) async {
  final service = ref.read(mediaServiceProvider);
  return service.getAllVideos();
});

final foldersProvider = FutureProvider<List<FolderItem>>((ref) async {
  final service = ref.read(mediaServiceProvider);
  return service.getFolders();
});

final mediaPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(mediaServiceProvider);
  return service.requestPermission();
});
