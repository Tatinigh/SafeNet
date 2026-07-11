import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Safety School'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Callout Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.glowGradient,
                borderRadius: AppTheme.cardBorderRadius,
                boxShadow: AppTheme.glowingShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Your Scam IQ',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Take our interactive quiz to learn how to spot scam DNA patterns.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.push('/quiz'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Play Quiz'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.school, size: 64, color: Colors.white24),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Scam Threat Categories',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDarkColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid of categories
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLearnItem(
                  context,
                  title: 'UPI Fraud',
                  desc: 'Scammers send fake money request links or spoofed UPI payment alerts.',
                  tips: 'Never enter your UPI PIN to RECEIVE money. PIN is only for sending money.',
                  icon: Icons.currency_rupee_rounded,
                  color: AppTheme.dangerColor,
                ),
                _buildLearnItem(
                  context,
                  title: 'Phishing Attacks',
                  desc: 'Spoofed emails and texts claiming account block to steal passwords.',
                  tips: 'Always check the domain name suffix and SSL certificate origin.',
                  icon: Icons.filter_list_off_rounded,
                  color: AppTheme.primaryColor,
                ),
                _buildLearnItem(
                  context,
                  title: 'QR Code Traps',
                  desc: 'Stickers pasted over official vendor QR codes redirecting to fraudulent private accounts.',
                  tips: 'Double check the merchant name display on the scanner before completing payment.',
                  icon: Icons.qr_code_2_rounded,
                  color: Colors.purple,
                ),
                _buildLearnItem(
                  context,
                  title: 'Job Scams',
                  desc: 'Fake WhatsApp/Telegram work-from-home offers demanding upfront security fees.',
                  tips: 'Unverified companies asking you to pay for training or deposits are always scams.',
                  icon: Icons.work_outline_rounded,
                  color: AppTheme.secondaryColor,
                ),
                _buildLearnItem(
                  context,
                  title: 'Deepfake Scams',
                  desc: 'AI synthesized voices or video clones pretending to be distressed family members.',
                  tips: 'Establish a private passcode with family members or call them directly back on a trusted line.',
                  icon: Icons.face_retouching_natural_rounded,
                  color: Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnItem(
    BuildContext context, {
    required String title,
    required String desc,
    required String tips,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: AppTheme.softShadows,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textDarkColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security, size: 14, color: AppTheme.successColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Safety Tip: $tips',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
