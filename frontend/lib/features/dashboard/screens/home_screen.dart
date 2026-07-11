import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/safety_score_dial.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Pick an image and route to OCR Editor
  Future<void> _pickImageAndScan(BuildContext context, String scanType) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && context.mounted) {
        context.push('/ocr-editor', extra: {
          'imagePath': image.path,
          'scanType': scanType,
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error accessing gallery permissions.')),
        );
      }
    }
  }

  // Show URL checker dialog input
  void _showUrlInputDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardBorderRadius),
        title: Text(
          'Check Website URL',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a suspicious URL to check risk score:',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'https://secure-login-bank.net',
                prefixIcon: const Icon(Icons.link, color: AppTheme.secondaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(context);
                context.push('/ai-loading', extra: {
                  'input': url,
                  'scanType': 'URL',
                });
              }
            },
            child: const Text('Check'),
          ),
        ],
      ),
    );
  }

  // Show dialog for community alerts details
  void _showAlertDetails(BuildContext context, String title, String details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardBorderRadius),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.dangerColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
        content: Text(
          details,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondaryColor, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understand'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // User Avatar Row
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl)
                      : const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                Text(
                  'SafeNet AI',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            
            // Score Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded, size: 14, color: AppTheme.secondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${stats.safetyScore}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            Text(
              'Good Morning, ${user?.displayName ?? 'User'} 👋',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDarkColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "You're protected today.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Safety Score Radial Meter
            SafetyScoreDial(score: stats.safetyScore),
            const SizedBox(height: 32),

            // Quick Action Grid Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Protection',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDarkColor,
                  ),
                ),
                Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Grid: 3 rows, 2 columns
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.25,
              children: [
                _buildActionCard(
                  context,
                  title: 'Scan Screenshot',
                  icon: Icons.screenshot_rounded,
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  iconColor: AppTheme.primaryColor,
                  onTap: () => _pickImageAndScan(context, 'Screenshot'),
                ),
                _buildActionCard(
                  context,
                  title: 'Analyze Message',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  onTap: () => context.go('/scan'),
                ),
                _buildActionCard(
                  context,
                  title: 'Verify Email',
                  icon: Icons.mail_outline_rounded,
                  color: AppTheme.successColor.withOpacity(0.1),
                  iconColor: AppTheme.successColor,
                  onTap: () => _pickImageAndScan(context, 'Email Screenshot'),
                ),
                _buildActionCard(
                  context,
                  title: 'Check Website',
                  icon: Icons.language_rounded,
                  color: const Color(0xFFEEF2F6),
                  iconColor: AppTheme.primaryColor,
                  onTap: () => _showUrlInputDialog(context),
                ),
                _buildActionCard(
                  context,
                  title: 'Scan QR Code',
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF7E22CE),
                  onTap: () => context.push('/qr-scanner'),
                ),
                _buildActionCard(
                  context,
                  title: 'Verify Job Offer',
                  icon: Icons.work_outline_rounded,
                  color: AppTheme.secondaryColor.withOpacity(0.08),
                  iconColor: AppTheme.secondaryColor,
                  onTap: () => context.go('/scan'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Community Alerts
            Text(
              'Community Alerts',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDarkColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildAlertCard(
              context,
              title: 'Fake UPI Scam',
              details: 'Scammers are sending fake electricity bill notices with a dynamic UPI barcode link claiming immediate account cut-off. Do not scan any external QR codes sent via SMS!',
              subtitle: 'Active in your area • 12m ago',
              icon: Icons.report_problem_rounded,
              color: AppTheme.dangerColor,
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              context,
              title: 'Fake Delivery Scam',
              details: 'SMS phishing messages pretending to be FedEx/Post Office requesting address updates or dynamic unpaid customs fees. Check official package tracking before inputting details.',
              subtitle: 'SMS Phishing • 1h ago',
              icon: Icons.local_shipping_rounded,
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              context,
              title: 'Fake Internship Offer',
              details: 'Social media advertisements promising 5000 INR/day for liking YouTube videos. Requesting upfront deposits or Telegram subscription fees is a task scam scam dna.',
              subtitle: 'Social Media • 3h ago',
              icon: Icons.school_rounded,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      
      // Floating AI Robot Scan Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open AI Chat direct or Quick text scan
          context.push('/ai-chat');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.android, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
          boxShadow: AppTheme.softShadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String title,
    required String details,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showAlertDetails(context, title, details),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          boxShadow: AppTheme.softShadows,
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
        ),
        child: Row(
          children: [
            // Left Alert accent colored border bar (Image 3)
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textLightColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textLightColor),
          ],
        ),
      ),
    );
  }
}
