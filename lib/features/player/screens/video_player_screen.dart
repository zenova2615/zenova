import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/video_item.dart';
import '../../../core/providers/media_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoItem video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isLocked = false;
  bool _isPlaying = false;
  double _currentSpeed = 1.0;
  Timer? _hideTimer;
  bool _isLandscape = false;

  // Gesture indicators
  double _brightness = 0.5;
  double _volume = 0.5;
  bool _showBrightness = false;
  bool _showVolume = false;

  late VideoItem _currentVideo;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _initPlayer(_currentVideo);
    _initBrightnessVolume();
  }

  Future<void> _initBrightnessVolume() async {
    try {
      _brightness = await ScreenBrightness().current;
      _volume = await FlutterVolumeController.getVolume() ?? 0.5;
    } catch (_) {}
  }

  Future<void> _initPlayer(VideoItem video) async {
    try {
      if (_isInitialized) {
        await _controller.pause();
        await _controller.dispose();
      }

      setState(() {
        _isInitialized = false;
        _currentVideo = video;
      });

      _controller = VideoPlayerController.file(File(video.path));
      await _controller.initialize();
      await _controller.play();
      WakelockPlus.enable();

      setState(() {
        _isInitialized = true;
        _isPlaying = true;
      });
      _startHideTimer();
    } catch (e) {
      debugPrint('Player error: $e');
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying && !_isLocked) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (_isLocked) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
        _startHideTimer();
      }
    });
  }

  void _seekRelative(int seconds) {
    final pos = _controller.value.position + Duration(seconds: seconds);
    _controller.seekTo(pos < Duration.zero ? Duration.zero : pos);
    _startHideTimer();
  }

  void _changeSpeed() {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final index = speeds.indexOf(_currentSpeed);
    final next = speeds[(index + 1) % speeds.length];
    _controller.setPlaybackSpeed(next);
    setState(() => _currentSpeed = next);
    _startHideTimer();
  }

  void _takeScreenshot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Screenshot Saved'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '\( {h.toString().padLeft(2, '0')}: \){m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '\( {m.toString().padLeft(2, '0')}: \){s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    _isLandscape = orientation == Orientation.landscape;

    // Immersive mode in landscape
    if (_isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          if (_isLocked) return;
          final width = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < width / 2) {
            _seekRelative(-10);
          } else {
            _seekRelative(10);
          }
        },
        onVerticalDragUpdate: (details) async {
          if (_isLocked || _isLandscape) return;
          final screenWidth = MediaQuery.of(context).size.width;
          final delta = -details.delta.dy / 300;

          if (details.localPosition.dx < screenWidth / 2) {
            _brightness = (_brightness + delta).clamp(0.0, 1.0);
            await ScreenBrightness().setScreenBrightness(_brightness);
            setState(() {
              _showBrightness = true;
              _showVolume = false;
            });
          } else {
            _volume = (_volume + delta).clamp(0.0, 1.0);
            await FlutterVolumeController.setVolume(_volume);
            setState(() {
              _showVolume = true;
              _showBrightness = false;
            });
          }
        },
        onVerticalDragEnd: (_) {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _showBrightness = false;
                _showVolume = false;
              });
            }
          });
        },
        child: Stack(
          children: [
            // Video
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),

            // Brightness / Volume Indicator
            if (_showBrightness)
              _buildIndicator(Icons.brightness_6_rounded, _brightness),
            if (_showVolume)
              _buildIndicator(Icons.volume_up_rounded, _volume),

            // Controls + Queue (only in portrait or when controls shown)
            if (_showControls && _isInitialized)
              _isLandscape ? _buildLandscapeControls() : _buildPortraitUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(IconData icon, double value) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white24,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PORTRAIT UI ====================
  Widget _buildPortraitUI() {
    final videosAsync = ref.watch(videosProvider);

    return Column(
      children: [
        // Top Bar
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    _currentVideo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _isLocked = !_isLocked),
                  icon: Icon(
                    _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Video area takes remaining space above controls
        const Spacer(),

        // Bottom Controls
        if (!_isLocked) _buildBottomControls(),

        // Up Next Queue
        if (!_isLocked)
          Container(
            color: const Color(0xFF0A0A0A),
            height: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_play_rounded, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Up Next (In This Folder)',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      videosAsync.when(
                        data: (videos) => Text(
                          '${videos.length} Videos',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: videosAsync.when(
                    data: (videos) {
                      if (videos.isEmpty) {
                        return const Center(child: Text('No videos', style: TextStyle(color: Colors.white38)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final video = videos[index];
                          final isPlaying = video.id == _currentVideo.id;
                          return _QueueItem(
                            video: video,
                            isPlaying: isPlaying,
                            index: index + 1,
                            onTap: () {
                              if (!isPlaying) _initPlayer(video);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (_, __) => const Center(child: Text('Error loading videos', style: TextStyle(color: Colors.white38))),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        children: [
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: AppColors.primary,
              bufferedColor: Colors.white30,
              backgroundColor: Colors.white12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                _formatDuration(_controller.value.position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              Text(
                _formatDuration(_controller.value.duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => _seekRelative(-10),
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
              ),
              IconButton(
                onPressed: _togglePlay,
                icon: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              IconButton(
                onPressed: () => _seekRelative(10),
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 28),
              ),
              GestureDetector(
                onTap: _takeScreenshot,
                onLongPress: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Screen Recording - Coming soon')),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
                ),
              ),
              TextButton(
                onPressed: _changeSpeed,
                child: Text(
                  '${_currentSpeed}x',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== LANDSCAPE CONTROLS ====================
  Widget _buildLandscapeControls() {
    return Container(
      color: Colors.black38,
      child: Column(
        children: [
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    _currentVideo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _isLocked = !_isLocked),
                  icon: Icon(
                    _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (!_isLocked)
            IconButton(
              onPressed: _togglePlay,
              iconSize: 64,
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                color: Colors.white,
              ),
            ),
          const Spacer(),
          if (!_isLocked)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () => _seekRelative(-10),
                          icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: _togglePlay,
                          icon: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _seekRelative(10),
                          icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                        ),
                        TextButton(
                          onPressed: _changeSpeed,
                          child: Text('${_currentSpeed}x', style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== QUEUE ITEM ====================
class _QueueItem extends StatelessWidget {
  final VideoItem video;
  final bool isPlaying;
  final int index;
  final VoidCallback onTap;

  const _QueueItem({
    required this.video,
    required this.isPlaying,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPlaying ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              // Thumbnail placeholder
              Container(
                width: 110,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                  border: isPlaying ? Border.all(color: AppColors.primary, width: 2) : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, color: Colors.white38, size: 28),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAli
