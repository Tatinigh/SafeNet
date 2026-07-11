import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class SafetyScoreDial extends StatefulWidget {
  final int score;
  final double size;

  const SafetyScoreDial({
    super.key,
    required this.score,
    this.size = 200.0,
  });

  @override
  State<SafetyScoreDial> createState() => _SafetyScoreDialState();
}

class _SafetyScoreDialState extends State<SafetyScoreDial> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(SafetyScoreDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final currentScore = _animation.value.round();
          
          // Determine color based on safety score thresholds
          final scoreColor = currentScore >= 75
              ? AppTheme.primaryColor // Deep Blue (Safe / Active)
              : currentScore >= 40
                  ? AppTheme.warningColor
                  : AppTheme.dangerColor;

          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.04),
                  blurRadius: 24,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Paint the Ring
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ScoreDialPainter(
                    score: _animation.value,
                    maxScore: 100.0,
                    activeColor: scoreColor,
                    isDark: isDark,
                  ),
                ),
                
                // Score Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentScore',
                      style: GoogleFonts.outfit(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SAFETY SCORE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textLightColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScoreDialPainter extends CustomPainter {
  final double score;
  final double maxScore;
  final Color activeColor;
  final bool isDark;

  _ScoreDialPainter({
    required this.score,
    required this.maxScore,
    required this.activeColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    final strokeWidth = 12.0;

    // 1. Draw dashed background ring
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 2. Draw outer dashed decoration ring (similar to Stitch AI mockup)
    final decorationPaint = Paint()
      ..color = AppTheme.secondaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw circular dashed outer border manually using paths or arcs
    const double dashWidth = 3.0;
    const double dashSpace = 4.0;
    double startAngle = -pi / 2;
    final double totalLength = 2 * pi * (radius + 8);
    final int dashCount = (totalLength / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final double angle = startAngle + (i * (dashWidth + dashSpace) / (radius + 8));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + 8),
        angle,
        dashWidth / (radius + 8),
        false,
        decorationPaint,
      );
    }

    // 3. Draw active progress gradient arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Sweep calculation: start from top (-pi / 2) and go clockwise
    final sweepAngleActive = (score / maxScore) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngleActive,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreDialPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.activeColor != activeColor;
  }
}
