import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/providers.dart';
import '../models/analysis_report.dart';

/// State representation for AI Analysis processes.
class AnalysisState {
  final bool isLoading;
  final String currentStep;
  final AnalysisReport? report;
  final String? errorMessage;

  AnalysisState({
    this.isLoading = false,
    this.currentStep = '',
    this.report,
    this.errorMessage,
  });

  AnalysisState copyWith({
    bool? isLoading,
    String? currentStep,
    AnalysisReport? report,
    String? errorMessage,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
      report: report ?? this.report,
      errorMessage: errorMessage,
    );
  }
}

/// StateNotifier handling the API calls and Hive caching.
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final Ref _ref;

  AnalysisNotifier(this._ref) : super(AnalysisState());

  /// Triggers a scam threat analysis scan.
  /// Steps through animated text and writes the result to local history cache.
  Future<String?> startAnalysis(String input, String scanType) async {
    state = AnalysisState(isLoading: true, currentStep: 'Reading content...');
    
    try {
      final apiClient = _ref.read(apiClientProvider);
      final hiveService = _ref.read(hiveServiceProvider);

      // Perform scan call depending on input type
      late AnalysisReport result;
      
      if (scanType == 'URL') {
        result = await apiClient.analyzeUrl(input);
      } else if (scanType == 'QR Code') {
        result = await apiClient.analyzeQr(input);
      } else {
        result = await apiClient.analyzeText(input, scanType);
      }

      // Save report in Hive local cache
      await hiveService.saveReport(result);

      state = AnalysisState(
        isLoading: false,
        currentStep: 'Done',
        report: result,
      );
      
      return result.id;
    } catch (e) {
      state = AnalysisState(
        isLoading: false,
        errorMessage: 'Connection timed out. Please check your network and retry.',
      );
      return null;
    }
  }

  /// Sets the currently displaying status step text.
  void updateLoadingStep(String step) {
    state = state.copyWith(currentStep: step);
  }
}

/// Provider to access the scan analysis logic.
final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier(ref);
});

/// Provider to fetch a specific report by ID from local cache (useful on the Result view).
final reportByIdProvider = Provider.family<AnalysisReport?, String>((ref, id) {
  final hiveService = ref.watch(hiveServiceProvider);
  final reports = hiveService.getAllReports();
  try {
    return reports.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
});
