import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardBorderRadius),
        title: Text('Select Language', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English (US)'),
              trailing: const Icon(Icons.check, color: AppTheme.secondaryColor),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Hindi (हिन्दी)'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish (Español)'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardBorderRadius),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(text, style: GoogleFonts.inter(height: 1.45, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Appearance
          _buildSectionHeader('Appearance'),
          _buildSettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined, color: AppTheme.primaryColor),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language_rounded, color: AppTheme.primaryColor),
                title: const Text('Language'),
                subtitle: const Text('English'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showLanguageDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section: Safety Updates
          _buildSectionHeader('Notifications'),
          _buildSettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryColor),
                title: const Text('Scam Threat Alerts'),
                subtitle: const Text('Notify when local scams are reported'),
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section: Data & Backup
          _buildSectionHeader('Storage & Data'),
          _buildSettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined, color: AppTheme.dangerColor),
                title: const Text('Delete Scan History'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Scan History?'),
                      content: const Text('This will delete all analyzed scan history and cached logs permanently.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
                          onPressed: () {
                            ref.read(historyProvider.notifier).clearAll();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Scan history purged.')),
                            );
                          },
                          child: const Text('Purge'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section: Legal & Info
          _buildSectionHeader('Support & Legal'),
          _buildSettingsCard(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
                title: const Text('About SafeNet AI'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showInfoDialog(
                  context,
                  'About SafeNet AI',
                  'SafeNet AI is an advanced security guardian leveraging machine learning, OCR analysis, and threat reputation APIs to protect users from modern digital scams (vishing, phishing, card clones, job frauds, etc.). Built as a hackathon showcase MVP.',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.verified_user_outlined, color: AppTheme.primaryColor),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showInfoDialog(
                  context,
                  'Privacy Policy',
                  'Your scanning history, messages, and uploaded files are analyzed locally or encrypted and routed directly to secure threat checking nodes. We do not store or sell your sensitive private logs.',
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.feedback_outlined, color: AppTheme.primaryColor),
                title: const Text('Send Feedback'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for your feedback!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout Session'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppTheme.secondaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.cardBorderRadius,
        side: BorderSide(color: Colors.grey.shade200.withOpacity(0.5)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
