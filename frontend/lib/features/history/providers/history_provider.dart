import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/providers.dart';
import '../../analysis/models/analysis_report.dart';

/// Filter selection state.
enum HistoryFilter { all, safe, suspicious, dangerous }

class HistoryState {
  final List<AnalysisReport> reports;
  final HistoryFilter filter;
  final String searchQuery;

  HistoryState({
    required this.reports,
    this.filter = HistoryFilter.all,
    this.searchQuery = '',
  });

  HistoryState copyWith({
    List<AnalysisReport>? reports,
    HistoryFilter? filter,
    String? searchQuery,
  }) {
    return HistoryState(
      reports: reports ?? this.reports,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier handling search filters and history deletions.
class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(HistoryState(reports: [])) {
    loadReports();
  }

  void loadReports() {
    final hiveService = _ref.read(hiveServiceProvider);
    state = state.copyWith(reports: hiveService.getAllReports());
  }

  void setFilter(HistoryFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> toggleFavorite(String id) async {
    final hiveService = _ref.read(hiveServiceProvider);
    await hiveService.toggleFavoriteReport(id);
    loadReports();
  }

  Future<void> deleteReport(String id) async {
    final hiveService = _ref.read(hiveServiceProvider);
    await hiveService.deleteReport(id);
    loadReports();
  }

  Future<void> clearAll() async {
    final hiveService = _ref.read(hiveServiceProvider);
    await hiveService.clearAllReports();
    loadReports();
  }
}

/// Provider to manage scan history.
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});

/// Computes a filtered list of history items according to state filters.
final filteredHistoryProvider = Provider<List<AnalysisReport>>((ref) {
  final state = ref.watch(historyProvider);
  
  return state.reports.where((report) {
    // 1. Search Query filter
    final matchesQuery = report.content.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
        report.summary.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
        report.scanType.toLowerCase().contains(state.searchQuery.toLowerCase());

    if (!matchesQuery) return false;

    // 2. Risk Level filter
    switch (state.filter) {
      case HistoryFilter.safe:
        return report.riskScore < 40;
      case HistoryFilter.suspicious:
        return report.riskScore >= 40 && report.riskScore < 75;
      case HistoryFilter.dangerous:
        return report.riskScore >= 75;
      case HistoryFilter.all:
      default:
        return true;
    }
  }).toList();
});
