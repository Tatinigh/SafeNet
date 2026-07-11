import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/analysis_provider.dart';
import '../../../core/theme/app_theme.dart';

class AiLoadingScreen extends ConsumerStatefulWidget {
  final String input;
  final String scanType;

  const AiLoadingScreen({
    super.key,
    required this.input,
    required this.scanType,
  });

  @override
  ConsumerState<AiLoadingScreen> createState() => _AiLoadingScreenState();
}

class _AiLoadingScreenState extends ConsumerState<AiLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  int _stepIndex = 0;
  Timer? _stepTimer;
  bool _aborted = false;

  final List<String> _loadingSteps = [
    'Reading content...',
    'Extracting text details...',
    'Scanning redirect links...',
    'Detecting phishing vectors...',
    'Comparing with scam blacklists...',
    'Generating explanation...',
    'Calculating risk score...',
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _startStepAnimations();
    _executeAnalysis();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  void _startStepAnimations() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_stepIndex < _loadingSteps.length - 1) {
        setState(() {
          _stepIndex++;
        });
        ref.read(analysisProvider.notifier).updateLoadingStep(_loadingSteps[_stepIndex]);
      } else {
        timer.cancel();
      }
    });
  }

  void _executeAnalysis() async {
    // Call repository scan
    final reportId = await ref.read(analysisProvider.notifier).startAnalysis(
      widget.input,
      widget.scanType,
    );

    if (_aborted) return;

    if (reportId != null && mounted) {
      context.pushReplacement('/ai-result', extra: {'reportId': reportId});
    } else if (mounted) {
      final error = ref.read(analysisProvider).errorMessage;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Analysis Failed'),
          content: Text(error ?? 'Something went wrong during verification.'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(); // close dialog
                context.pop(); // return back to options
              },
              child: const Text('Back'),
            ),
          ],
        ),
      );
    }
  }

  void _abortAnalysis() {
    setState(() {
      _aborted = true;
    });
    _stepTimer?.cancel();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Extract hostname simulation if URL is checked
    String originText = 'unidentified-payload';
    String linksDetectedText = '0 detected';
    if (widget.scanType == 'URL') {
      try {
        final uri = Uri.parse(widget.input);
        originText = uri.host.isNotEmpty ? uri.host : widget.input;
        linksDetectedText = '1 detected';
      } catch (_) {
        originText = widget.input;
      }
    } else if (widget.input.toLowerCase().contains('http')) {
      originText = 'external-redirect.net';
      linksDetectedText = '1 detected';
    }

    final double progressPercent = (_stepIndex + 1) / _loadingSteps.length;
    final double threatProgressVal = 0.042 * (_stepIndex + 1) * 2; // simulated minor growth

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFEFF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Header (Image 1)
                Text(
                  'SafeNet AI',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Glowing Active Surveillance badge (Image 1)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF0D9488)),
                        const SizedBox(width: 6),
                        Text(
                          'ACTIVE SURVEILLANCE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D9488),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // Rotating Scanning Dial logo (Image 1)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glowing circular pulse
                      Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondaryColor.withOpacity(0.04),
                        ),
                      ),
                      // Rotating dotted canvas scanner ring
                      RotationTransition(
                        turns: _rotationController,
                        child: CustomPaint(
                          size: const Size(160, 160),
                          painter: _RadarDottedPainter(),
                        ),
                      ),
                      // Glowing Center shield
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: AppTheme.softShadows,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppTheme.primaryColor,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Step progress Card (Image 1)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: AppTheme.cardBorderRadius,
                    boxShadow: AppTheme.softShadows,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _loadingSteps[_stepIndex],
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info Matrix Grid (Image 1)
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoGridCard(
                        context,
                        title: 'ORIGIN',
                        value: originText,
                        icon: Icons.dns_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoGridCard(
                        context,
                        title: 'LINKS',
                        value: linksDetectedText,
                        icon: Icons.link,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Full Width Threat Probability Card (Image 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: AppTheme.cardBorderRadius,
                    boxShadow: AppTheme.softShadows,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'THREAT PROBABILITY',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textLightColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${threatProgressVal.toStringAsFixed(3)}%',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progressPercent * 0.25,
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Abort button (Image 1)
                OutlinedButton(
                  onPressed: _abortAnalysis,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    'ABORT ANALYSIS',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textDarkColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGridCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: AppTheme.softShadows,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textLightColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.textDarkColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _RadarDottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw thin circular track
    paint.color = AppTheme.secondaryColor.withOpacity(0.2);
    canvas.drawCircle(center, radius, paint);

    // Draw active scanning arc sector
    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppTheme.secondaryColor,
          AppTheme.secondaryColor.withOpacity(0.0),
        ],
        stops: const [0.15, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      1.5,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
