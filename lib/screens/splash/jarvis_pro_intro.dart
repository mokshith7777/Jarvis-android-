import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays the v3.3 cinematic splash once at cold launch, then fades into the app.
class JarvisProIntro extends StatefulWidget {
  const JarvisProIntro({super.key, required this.child});
  final Widget child;

  @override
  State<JarvisProIntro> createState() => _JarvisProIntroState();
}

class _JarvisProIntroState extends State<JarvisProIntro> {
  VideoPlayerController? _video;
  Timer? _fallbackTimer;
  bool _finished = false;
  bool _fallback = false;

  @override
  void initState() {
    super.initState();
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _finished = true;
      return;
    }
    _startVideo();
  }

  Future<void> _startVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/branding/JARVIS_PRO_Cinematic_Enhanced_Final.mp4',
    );
    _video = controller;
    try {
      await controller.initialize();
      if (!mounted || _finished) return;
      await controller.setLooping(false);
      controller.addListener(_onVideoUpdate);
      await controller.play();
      setState(() {});
    } catch (_) {
      if (!mounted || _finished) return;
      _fallback = true;
      _fallbackTimer = Timer(const Duration(seconds: 3), _finish);
      setState(() {});
    }
  }

  void _onVideoUpdate() {
    final controller = _video;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    if (duration > Duration.zero &&
        controller.value.position >= duration &&
        !controller.value.isPlaying) {
      _finish();
    }
  }

  void _finish() {
    if (!mounted || _finished) return;
    _fallbackTimer?.cancel();
    _video?.pause();
    setState(() => _finished = true);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _video?.removeListener(_onVideoUpdate);
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _finished
          ? KeyedSubtree(key: const ValueKey('app'), child: widget.child)
          : _fallback
              ? _FallbackSplash(key: const ValueKey('fallback'), onSkip: _finish)
              : _video?.value.isInitialized == true
                  ? _VideoSplash(
                      key: const ValueKey('video'),
                      controller: _video!,
                      onSkip: _finish,
                    )
                  : const _LoadingSplash(key: ValueKey('loading')),
    );
  }
}

class _VideoSplash extends StatelessWidget {
  const _VideoSplash({
    super.key,
    required this.controller,
    required this.onSkip,
  });
  final VideoPlayerController controller;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSkip,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              right: 16,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black54,
                ),
                child: const Text('SKIP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSplash extends StatelessWidget {
  const _LoadingSplash({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFF050505),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      );
}

class _FallbackSplash extends StatelessWidget {
  const _FallbackSplash({super.key, required this.onSkip});
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bolt, color: Color(0xFF00E5FF), size: 64),
              SizedBox(height: 16),
              Text(
                'JARVIS PRO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'PERSONAL AI COMMAND CENTER',
                style: TextStyle(color: Colors.white70, letterSpacing: 2),
              ),
            ],
          ),
        ),
      );
}
