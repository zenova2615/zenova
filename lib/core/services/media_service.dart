import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/video_item.dart';
import '../../data/models/folder_item.dart';

class MediaService {
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    final status = await Permission.videos.request();
    if (status.isGranted) return true;

    // Fallback for older Android
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  Future<List<VideoItem>> getAllVideos() async {
    if (kIsWeb) return [];

    final permitted = await requestPermission();
    if (!permitted) return [];

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      onlyAll: true,
    );

    if (albums.isEmpty) return [];

    final List<AssetEntity> assets = await albums.first.getAssetListRange(
      start: 0,
      end: 5000, // performance target
    );

    final List<VideoItem> videos = [];

    for (final asset in assets) {
      final file = await asset.file;
      if (file == null) continue;

      videos.add(VideoItem(
        id: asset.id,
        title: asset.title ?? 'Unknown',
        path: file.path,
        duration: asset.duration,
        size: await file.length(),
        dateAdded: asset.createDateTime,
        folderName: albums.first.name,
      ));
    }

    // Natural sort by title
    videos.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return videos;
  }

  Future<List<FolderItem>> getFolders() async {
    if (kIsWeb) return [];

    final permitted = await requestPermission();
    if (!permitted) return [];

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
    );

    final List<FolderItem> folders = [];

    for (final album in albums) {
      final count = await album.assetCountAsync;
      if (count == 0) continue;

      folders.add(FolderItem(
        name: album.name,
        path: album.id,
        videoCount: count,
      ));
    }

    return folders;
  }
}
