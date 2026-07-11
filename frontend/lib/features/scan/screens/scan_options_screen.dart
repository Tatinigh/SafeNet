import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';

class ScanOptionsScreen extends StatelessWidget {
  const ScanOptionsScreen({super.key});

  Future<void> _handleImageSelection(BuildContext context, ImageSource source, String scanType) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
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
          const SnackBar(content: Text('Error accessing camera/gallery permissions.')),
        );
      }
    }
  }

  Future<void> _handlePdfSelection(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null && context.mounted) {
        // Navigate to loading directly using PDF title as text simulation
        context.push('/ai-loading', extra: {
          'input': 'File: ${result.files.single.name}\nSize: ${result.files.single.size} bytes',
          'scanType': 'PDF Document',
        });
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
  }

  void _showPasteTextDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardBorderRadius),
        title: Text('Paste Spam Message', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Dear customer, you have won cash prize...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                context.push('/ai-loading', extra: {
                  'input': text,
                  'scanType': 'Message Text',
                });
              }
            },
            child: const Text('Analyze'),
          ),
        ],
      ),
    );
  }

  void _showPasteUrlDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardBorderRadius),
        title: Text('Paste Website URL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://security-verify-login.xyz',
            prefixIcon: const Icon(Icons.link),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
            child: const Text('Analyze URL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Digital Scan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Verification Source',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDarkColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload screenshots, URLs, or documents to scan for threat indicators.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Grid of Scan Options
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.15,
              children: [
                _buildScanOption(
                  context,
                  title: 'Upload Screenshot',
                  icon: Icons.add_photo_alternate_rounded,
                  color: AppTheme.primaryColor,
                  onTap: () => _handleImageSelection(context, ImageSource.gallery, 'Screenshot'),
                ),
                _buildScanOption(
                  context,
                  title: 'Take Photo',
                  icon: Icons.camera_alt_rounded,
                  color: AppTheme.secondaryColor,
                  onTap: () => _handleImageSelection(context, ImageSource.camera, 'Photo Scan'),
                ),
                _buildScanOption(
                  context,
                  title: 'Paste Text',
                  icon: Icons.assignment_rounded,
                  color: AppTheme.successColor,
                  onTap: () => _showPasteTextDialog(context),
                ),
                _buildScanOption(
                  context,
                  title: 'Paste URL',
                  icon: Icons.link_rounded,
                  color: AppTheme.warningColor,
                  onTap: () => _showPasteUrlDialog(context),
                ),
                _buildScanOption(
                  context,
                  title: 'Upload PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  color: AppTheme.dangerColor,
                  onTap: () => _handlePdfSelection(context),
                ),
                _buildScanOption(
                  context,
                  title: 'Scan QR Code',
                  icon: Icons.qr_code_scanner_rounded,
                  color: Colors.purple,
                  onTap: () => context.push('/qr-scanner'),
                ),
                _buildScanOption(
                  context,
                  title: 'Email Screenshot',
                  icon: Icons.mail_rounded,
                  color: Colors.teal,
                  onTap: () => _handleImageSelection(context, ImageSource.gallery, 'Email Screenshot'),
                ),
                _buildScanOption(
                  context,
                  title: 'Job Advertisement',
                  icon: Icons.work_rounded,
                  color: Colors.indigo,
                  onTap: () => _handleImageSelection(context, ImageSource.gallery, 'Job Advertisement'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Coming soon panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
                borderRadius: AppTheme.cardBorderRadius,
                border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.mic_none_rounded, color: AppTheme.textLightColor, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voice Scam Scan (Coming Soon)',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textDarkColor,
                          ),
                        ),
                        Text(
                          'Scan phone conversation recordings for real-time AI deepfake detection.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
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

  Widget _buildScanOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.cardBorderRadius,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
