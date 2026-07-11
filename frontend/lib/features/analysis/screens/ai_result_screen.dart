import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/analysis_provider.dart';
import '../models/analysis_report.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../core/theme/app_theme.dart';

class AiResultScreen extends ConsumerWidget {
  final String reportId;

  const AiResultScreen({super.key, required this.reportId});

  // Handle PDF report export
  void _exportPdf(BuildContext context, AnalysisReport report) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final file = await PdfGenerator.generateReport(report);
      if (context.mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report PDF generated successfully: ${file.path.split('/').last}'),
            backgroundColor: AppTheme.successColor,
            action: SnackBarAction(
              label: 'SHARE',
              textColor: Colors.white,
              onPressed: () {
                Share.shareXFiles([XFile(file.path)], text: 'SafeNet AI Threat Analysis Report');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate PDF report.'), backgroundColor: AppTheme.dangerColor),
        );
      }
    }
  }

  void _shareReportText(AnalysisReport report) {
    final text = 'SafeNet AI Scam Analysis Alert!\n'
        'Scan Type: ${report.scanType}\n'
        'Risk Score: ${report.riskScore}%\n'
        'Status: ${report.status}\n'
        'Summary: ${report.summary}\n'
        'Recommendations: ${report.recommendations.join(', ')}\n'
        'Stay safe with SafeNet AI!';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(reportByIdProvider(reportId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.dangerColor),
              const SizedBox(height: 16),
              Text(
                'Report details not found locally.',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final bool isHighRisk = report.riskScore >= 50;
    final Color riskColor = isHighRisk ? AppTheme.dangerColor : AppTheme.successColor;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'SafeNet AI',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            // Safety Score Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🛡 92',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Large Threat Analysis Score Card (Image 4 red layout)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isHighRisk 
                      ? [AppTheme.dangerColor, const Color(0xFF991B1B)]
                      : [AppTheme.successColor, const Color(0xFF166534)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppTheme.cardBorderRadius,
                boxShadow: isHighRisk ? AppTheme.dangerGlowingShadow : AppTheme.softShadows,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THREAT ANALYSIS LEVEL',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${report.riskScore}%',
                            style: GoogleFonts.outfit(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isHighRisk ? Icons.report_problem : Icons.verified_user,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.warning, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        isHighRisk ? 'HIGH RISK DETECTED' : 'SAFE CONTENT DETECTED',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report.summary,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Horizontal Recommended Actions Cards (Image 4)
            SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: _buildRecommendationQuickCards(report.recommendations),
              ),
            ),
            const SizedBox(height: 28),

            // 3. Analysis Insights expandable lists (Image 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analysis Insights',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDarkColor,
                  ),
                ),
                Text(
                  'View Details',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.reasons.length,
              itemBuilder: (context, index) {
                return _buildInsightTile(context, report.reasons[index]);
              },
            ),
            const SizedBox(height: 28),

            // 4. Scam DNA Profile Animated Progress bars (Image 4)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: AppTheme.cardBorderRadius,
                boxShadow: AppTheme.softShadows,
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fingerprint, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Scam DNA Profile',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textDarkColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDnaProgressBar('Urgency', report.scamDna.urgency),
                  const SizedBox(height: 14),
                  _buildDnaProgressBar('Money Request', report.scamDna.money),
                  const SizedBox(height: 14),
                  _buildDnaProgressBar('Fear Tactic', report.scamDna.fear),
                  const SizedBox(height: 14),
                  _buildDnaProgressBar('Identity Theft', report.scamDna.identity),
                  const SizedBox(height: 14),
                  _buildDnaProgressBar('Fake Branding', report.scamDna.branding),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 5. PDF Save and Share Actions Bottom Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportPdf(context, report),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('Save Report'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareReportText(report),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      
      // Robot launcher FAB -> launches AI Chat
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai-chat'),
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
      ),
    );
  }

  // Recommendations Quick Action Cards Layout
  List<Widget> _buildRecommendationQuickCards(List<String> recommendations) {
    return recommendations.map((rec) {
      Color cardBorderColor = const Color(0xFFCBD5E1);
      Color cardBgColor = const Color(0xFFF8FAFC);
      Color textColor = AppTheme.primaryColor;
      IconData icon = Icons.info_outline;

      if (rec.contains('Click')) {
        cardBorderColor = const Color(0xFFFECDD3); // soft red
        cardBgColor = const Color(0xFFFFF1F2);
        textColor = const Color(0xFFE11D48);
        icon = Icons.do_not_disturb_on_total_silence_rounded;
      } else if (rec.contains('Pay')) {
        cardBorderColor = const Color(0xFFFED7AA); // soft orange
        cardBgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFEA580C);
        icon = Icons.money_off_rounded;
      } else if (rec.contains('Block') || rec.contains('Report')) {
        cardBorderColor = const Color(0xFFBAE6FD); // soft blue
        cardBgColor = const Color(0xFFF0F9FF);
        textColor = const Color(0xFF0284C7);
        icon = Icons.block_flipped;
      } else if (rec.contains('Verify')) {
        cardBorderColor = const Color(0xFFBBF7D0); // soft green
        cardBgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF16A34A);
        icon = Icons.verified_user_rounded;
      }

      return Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              rec,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // Expandable Insight Tile (Image 4)
  Widget _buildInsightTile(BuildContext context, AnalysisReason reason) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose icon depending on reason keywords
    IconData icon = Icons.info_outline;
    if (reason.title.contains('Urgency')) icon = Icons.timer_outlined;
    else if (reason.title.contains('payment') || reason.title.contains('Pay')) icon = Icons.monetization_on_outlined;
    else if (reason.title.contains('website') || reason.title.contains('Domain')) icon = Icons.link_off_rounded;
    else if (reason.title.contains('sender') || reason.title.contains('KYC')) icon = Icons.person_search_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadows,
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          reason.title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.textDarkColor,
          ),
        ),
        subtitle: Text(
          'Severity: ${reason.severity}',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: reason.severity == 'Critical' || reason.severity == 'High' 
                ? AppTheme.dangerColor 
                : AppTheme.textLightColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Text(
              reason.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
                height: 1.4,
              ),
            ),
          )
        ],
      ),
    );
  }

  // DNA Progress Bar (Image 4 animated slider styling)
  Widget _buildDnaProgressBar(String label, int val) {
    Color barColor = AppTheme.primaryColor;
    if (val >= 80) {
      barColor = AppTheme.dangerColor;
    } else if (val >= 50) {
      barColor = AppTheme.warningColor;
    } else {
      barColor = AppTheme.secondaryColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            Text(
              '$val%',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: val / 100),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade100,
                color: barColor,
                minHeight: 8,
              ),
            );
          },
        ),
      ],
    );
  }
}
