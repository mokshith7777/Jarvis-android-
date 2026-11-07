import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Five-second portrait-first brand reveal shown once at cold app launch.
class JarvisProIntro extends StatefulWidget {
  const JarvisProIntro({super.key, required this.child});
  final Widget child;

  @override
  State<JarvisProIntro> createState() => _JarvisProIntroState();
}

class _JarvisProIntroState extends State<JarvisProIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..forward();
    _timer = Timer(const Duration(milliseconds: 5000), () {
      if (mounted) setState(() => _finished = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
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
          : _IntroCanvas(key: const ValueKey('intro'), controller: _controller),
    );
  }
}

class _IntroCanvas extends StatelessWidget {
  const _IntroCanvas({super.key, required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020612),
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = controller.value;
            final reveal = Curves.easeOutCubic.transform((t * 1.45).clamp(0.0, 1.0));
            final titleIn = Curves.easeOutBack.transform(((t - .42) / .32).clamp(0.0, 1.0));
            final pulse = .72 + .28 * math.sin(t * math.pi * 10).abs();
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -.05),
                        radius: 1.0,
                        colors: [
                          const Color(0xFF082B68).withValues(alpha: .42 * reveal),
                          const Color(0xFF020612),
                          const Color(0xFF01030A),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ReactorPainter(
                      progress: t,
                      reveal: reveal,
                      pulse: pulse,
                    ),
                  ),
                ),
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: MediaQuery.of(context).size.height * .245,
                  child: Opacity(
                    opacity: titleIn.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 24 * (1 - titleIn)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(colors: [
                                  Color(0xFF9EDBFF),
                                  Color(0xFF1E6BFF),
                                  Color(0xFFFF4E00),
                                  Color(0xFFFFAE00),
                                ]).createShader(bounds),
                            child: const Text(
                              'JARVIS PRO',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 31,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4.2,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'PERSONAL AI • SYSTEMS ONLINE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF8CCBFF).withValues(alpha: .82),
                              fontSize: 9,
                              letterSpacing: 2.4,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 42,
                  child: Opacity(
                    opacity: (t * 2.8).clamp(0.0, 1.0) * (1 - (t * .35)),
                    child: const Text(
                      'INITIALIZING CORE SYSTEMS',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 8,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReactorPainter extends CustomPainter {
  _ReactorPainter({
    required this.progress,
    required this.reveal,
    required this.pulse,
  });
  final double progress;
  final double reveal;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .405);
    final radius = math.min(size.width * .405, size.height * .265) * reveal;
    if (radius <= 0) return;
    final blue = const Color(0xFF168BFF);
    final cyan = const Color(0xFF64DFFF);
    final red = const Color(0xFFFF174F);
    final gold = const Color(0xFFFFA52B);

    final glow = Paint()
      ..color = blue.withValues(alpha: .28 * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * .22);
    canvas.drawCircle(center, radius * .72, glow);

    void ring(double r, Color color, double width, double rotation,
        {bool dashed = false}) {
      final paint = Paint()
        ..color = color.withValues(alpha: .82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * .75);
      if (!dashed) {
        canvas.drawCircle(center, r, paint);
      } else {
        final path = Path();
        for (var i = 0; i < 48; i++) {
          final a = i * math.pi * 2 / 48 + rotation;
          final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
          if (i % 2 == 0) {
            path.moveTo(p.dx, p.dy);
            path.lineTo(
              center.dx + math.cos(a + .055) * r,
              center.dy + math.sin(a + .055) * r,
            );
          }
        }
        canvas.drawPath(path, paint);
      }
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);
    ring(radius, red, 5, 0);
    ring(radius * .91, gold, 2.5, 0, dashed: true);
    ring(radius * .79, const Color(0xFF294D7D), 7, 0);
    ring(radius * .72, cyan, 2.2, 0, dashed: true);
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-progress * math.pi * 3.2);
    canvas.translate(-center.dx, -center.dy);
    ring(radius * .59, blue, 4, 0);
    ring(radius * .49, cyan, 2, 0, dashed: true);
    canvas.restore();

    final core = Paint()
      ..shader = RadialGradient(colors: [
        const Color(0xFFE9FFFF),
        cyan,
        blue.withValues(alpha: .88),
        const Color(0xFF05245B),
      ]).createShader(Rect.fromCircle(center: center, radius: radius * .34));
    canvas.drawCircle(center, radius * .34, core);
    final coreGlow = Paint()
      ..color = cyan.withValues(alpha: .48 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius * .29, coreGlow);

    final nodes = Paint()..color = gold.withValues(alpha: .95);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + progress * math.pi * 2;
      final p = center + Offset(math.cos(a) * radius * .84,
          math.sin(a) * radius * .84);
      canvas.drawCircle(p, radius * .018, nodes);
    }
  }

  @override
  bool shouldRepaint(covariant _ReactorPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.reveal != reveal ||
      oldDelegate.pulse != pulse;
}
