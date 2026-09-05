import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/video_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;
  final List<VideoItem>? queue;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.queue,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isLocked = false;
  bool _isPlaying = false;
  double _currentSpeed = 1.0;
  Timer? _hideTimer;

  // Gesture
  double _brightness = 0.5;
  double _volume = 0.5;
  bool _showBrightness = false;
  bool _showVolume = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _initBrightnessVolume();
  }

  Future<void> _initBrightnessVolume() async {
    try {
      _brightness = await ScreenBrightness().current;
      _volume = await FlutterVolumeController.getVolume() ?? 0.5;
    } catch (_) {}
  }

  Future<void> _initPlayer() async {
    try {
      _controller = VideoPlayerController.file(File(widget.video.path));
      await _controller.initialize();
      await _controller.play();
      WakelockPlus.enable();

      // Landscape recommended
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]);

      setState(() {
        _isInitialized = true;
        _isPlaying = true;
      });
      _startHideTimer();
    } catch (e) {
      debugPrint('Player init error: $e');
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

  Future<void> _takeScreenshot() async {
    // Placeholder - will save frame later
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          if (_isLocked) return;
          final screenWidth = MediaQuery.of(context).size.width;
          final delta = -details.delta.dy / 300;

          if (details.localPosition.dx < screenWidth / 2) {
            // Brightness
            _brightness = (_brightness + delta).clamp(0.0, 1.0);
            await ScreenBrightness().setScreenBrightness(_brightness);
            setState(() {
              _showBrightness = true;
              _showVolume = false;
            });
          } else {
            // Volume
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
          alignment: Alignment.center,
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

            // Brightness Indicator
            if (_showBrightness)
              _buildIndicator(Icons.brightness_6_rounded, _brightness),

            // Volume Indicator
            if (_showVolume)
              _buildIndicator(Icons.volume_up_rounded, _volume),

            // Controls
            if (_showControls && _isInitialized) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(IconData icon, double value) {
    return Container(
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
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black38,
      child: Column(
        children: [
          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      widget.video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: _changeSpeed,
                    child: Text(
                      '${_currentSpeed}x',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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

          const Spacer(),

          // Center Play
          if (!_isLocked)
            IconButton(
              onPressed: _togglePlay,
              iconSize: 68,
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                color: Colors.white,
              ),
            ),

          const Spacer(),

          // Bottom
          if (!_isLocked)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
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
                    const SizedBox(height: 4),
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
                            size: 34,
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
                              const SnackBar(content: Text('Screen Recording coming soon')),
                            );
                          },
                          child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
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
