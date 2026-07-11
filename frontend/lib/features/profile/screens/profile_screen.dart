import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final stats = ref.watch(dashboardProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cyber Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Meta Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: AppTheme.cardBorderRadius,
                boxShadow: AppTheme.softShadows,
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl)
                        : const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'John Doe',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textDarkColor,
                          ),
                        ),
                        Text(
                          user?.email ?? 'user@safenetai.org',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ACTIVE SYSTEM SHIELD',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Grid (Safety score, Total scans, Safe decisions, Scams prevented)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Safety Score',
                    value: '${stats.safetyScore}%',
                    icon: Icons.security_rounded,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Total Scans',
                    value: '${stats.totalScans}',
                    icon: Icons.explore_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Safe Decisions',
                    value: '${stats.safeDecisions}',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Scams Prevented',
                    value: '${stats.scamsPrevented}',
                    icon: Icons.shield_rounded,
                    color: AppTheme.dangerColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Achievements section
            Text(
              'Unlocked Safety Badges',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textDarkColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildBadgeListItem(
              context,
              title: 'First Responder',
              desc: 'Completed your first digital threat assessment scan.',
              icon: Icons.stars_rounded,
              unlocked: true,
            ),
            const SizedBox(height: 12),
            _buildBadgeListItem(
              context,
              title: 'Scam Buster',
              desc: 'Answered all scenarios correctly in the Scam IQ quiz.',
              icon: Icons.verified_user_rounded,
              unlocked: stats.scamsPrevented >= 1, // Unlock if they have done a scan
            ),
            const SizedBox(height: 12),
            _buildBadgeListItem(
              context,
              title: 'Phishing Guardian',
              desc: 'Flagged 5 suspicious link redirections successfully.',
              icon: Icons.gpp_good_rounded,
              unlocked: false, // Locked until criteria met
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: AppTheme.softShadows,
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeListItem(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required bool unlocked,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = unlocked ? AppTheme.warningColor : AppTheme.textLightColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: badgeColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: unlocked 
                        ? (isDark ? Colors.white : AppTheme.textDarkColor) 
                        : AppTheme.textLightColor,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (!unlocked)
            const Icon(Icons.lock_outline_rounded, color: AppTheme.textLightColor, size: 18),
        ],
      ),
    );
  }
}
