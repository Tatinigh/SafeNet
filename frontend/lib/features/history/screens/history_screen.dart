import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/history_provider.dart';
import '../../analysis/models/analysis_report.dart';
import '../../../core/theme/app_theme.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final filteredReports = ref.watch(filteredHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (historyState.reports.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Scans?'),
                    content: const Text('This action will delete all scan history from this device permanently.'),
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
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              onChanged: (val) => ref.read(historyProvider.notifier).setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search scans or categories...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
              ),
            ),
          ),

          // 2. Filter Pills row
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFilterPill(ref, 'All', HistoryFilter.all, historyState.filter),
                _buildFilterPill(ref, 'Safe', HistoryFilter.safe, historyState.filter),
                _buildFilterPill(ref, 'Suspicious', HistoryFilter.suspicious, historyState.filter),
                _buildFilterPill(ref, 'Dangerous', HistoryFilter.dangerous, historyState.filter),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. History List
          Expanded(
            child: filteredReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 64,
                          color: AppTheme.textLightColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No history reports found.',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildHistoryListItem(context, ref, report, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(WidgetRef ref, String label, HistoryFilter filterValue, HistoryFilter activeFilter) {
    final isSelected = filterValue == activeFilter;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) {
            ref.read(historyProvider.notifier).setFilter(filterValue);
          }
        },
        selectedColor: AppTheme.primaryColor,
        backgroundColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.25),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryListItem(BuildContext context, WidgetRef ref, AnalysisReport report, bool isDark) {
    final Color riskColor = report.riskScore >= 75
        ? AppTheme.dangerColor
        : report.riskScore >= 40
            ? AppTheme.warningColor
            : AppTheme.successColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: AppTheme.softShadows,
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onTap: () {
          context.push('/ai-result', extra: {'reportId': report.id});
        },
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: riskColor.withOpacity(0.1),
          ),
          child: Text(
            '${report.riskScore}%',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: riskColor,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              report.scanType,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.secondaryColor,
              ),
            ),
            const Spacer(),
            Text(
              '${report.timestamp.month}/${report.timestamp.day}',
              style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLightColor),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textDarkColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              report.summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                report.isFavorite ? Icons.star : Icons.star_border,
                color: report.isFavorite ? AppTheme.warningColor : AppTheme.textLightColor,
              ),
              onPressed: () => ref.read(historyProvider.notifier).toggleFavorite(report.id),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerColor),
              onPressed: () => ref.read(historyProvider.notifier).deleteReport(report.id),
            ),
          ],
        ),
      ),
    );
  }
}
