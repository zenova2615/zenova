import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/video_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isLocked = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _controller = VideoPlayerController.file(
      // ignore: unnecessary_cast
      await Future.value(null), // will handle properly below
    );

    try {
      _controller = VideoPlayerController.networkUrl(Uri.file(widget.video.path));
      // For local file:
      // _controller = VideoPlayerController.file(File(widget.video.path));

      await _controller.initialize();
      await _controller.play();
      WakelockPlus.enable();

      setState(() {
        _isInitialized = true;
      });

      _startHideTimer();
    } catch (e) {
      debugPrint('Player error: $e');
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller.value.isPlaying) {
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
      } else {
        _controller.play();
        _startHideTimer();
      }
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '\( {hours.toString().padLeft(2, '0')}: \){minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '\( {minutes.toString().padLeft(2, '0')}: \){seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
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
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),

            // Controls Overlay
            if (_showControls && _isInitialized)
              Container(
                color: Colors.black45,
                child: Column(
                  children: [
                    // Top Bar
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _isLocked = !_isLocked);
                              },
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

                    // Center Play Button
                    if (!_isLocked)
                      IconButton(
                        onPressed: _togglePlay,
                        iconSize: 64,
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                          color: Colors.white,
                        ),
                      ),

                    const Spacer(),

                    // Bottom Controls
                    if (!_isLocked)
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            children: [
                              // Progress
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: AppColors.primary,
                                  bufferedColor: Colors.white38,
                                  backgroundColor: Colors.white24,
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
                              const SizedBox(height: 8),
                              // Control Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final pos = _controller.value.position - const Duration(seconds: 10);
                                      _controller.seekTo(pos < Duration.zero ? Duration.zero : pos);
                                    },
                                    icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 28),
                                  ),
                                  IconButton(
                                    onPressed: _togglePlay,
                                    icon: Icon(
                                      _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      final pos = _controller.value.position + const Duration(seconds: 10);
                                      _controller.seekTo(pos);
                                    },
                                    icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 28),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // TODO: Screenshot (next)
                                    },
                                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
