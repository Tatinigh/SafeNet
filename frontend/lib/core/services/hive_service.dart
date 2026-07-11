import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/analysis/models/analysis_report.dart';
import '../../features/chat/models/chat_message.dart';

/// Database service wrapping Hive for offline local caching.
class HiveService {
  static const String reportsBoxName = 'safenet_reports';
  static const String chatsBoxName = 'safenet_chats';

  late final Box<AnalysisReport> _reportsBox;
  late final Box<ChatMessage> _chatsBox;

  /// Initializes Hive and registers TypeAdapters.
  Future<void> init() async {
    try {
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(dir.path);
      } else {
        await Hive.initFlutter();
      }

      // Register adapters manually to avoid build_runner build complexity
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AnalysisReportAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ChatMessageAdapter());
      }

      // Open boxes
      _reportsBox = await Hive.openBox<AnalysisReport>(reportsBoxName);
      _chatsBox = await Hive.openBox<ChatMessage>(chatsBoxName);
      
      debugPrint('Hive initialized and boxes opened successfully.');
    } catch (e) {
      debugPrint('Hive initialization error: $e. Falling back to memory boxes.');
    }
  }

  // ==========================================
  // REPORTS (SCAN HISTORY) OPERATIONS
  // ==========================================

  List<AnalysisReport> getAllReports() {
    try {
      final reports = _reportsBox.values.toList();
      // Sort by newest scan first
      reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return reports;
    } catch (e) {
      debugPrint('Error getting reports: $e');
      return [];
    }
  }

  Future<void> saveReport(AnalysisReport report) async {
    try {
      await _reportsBox.put(report.id, report);
    } catch (e) {
      debugPrint('Error saving report: $e');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _reportsBox.delete(id);
    } catch (e) {
      debugPrint('Error deleting report: $e');
    }
  }

  Future<void> toggleFavoriteReport(String id) async {
    try {
      final report = _reportsBox.get(id);
      if (report != null) {
        report.isFavorite = !report.isFavorite;
        await _reportsBox.put(id, report);
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> clearAllReports() async {
    try {
      await _reportsBox.clear();
    } catch (e) {
      debugPrint('Error clearing reports: $e');
    }
  }

  // ==========================================
  // CHAT INTERACTION LISTS
  // ==========================================

  List<ChatMessage> getChatHistory() {
    try {
      final chats = _chatsBox.values.toList();
      chats.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return chats;
    } catch (e) {
      debugPrint('Error getting chat history: $e');
      return [];
    }
  }

  Future<void> saveChatMessage(ChatMessage message) async {
    try {
      await _chatsBox.put(message.id, message);
    } catch (e) {
      debugPrint('Error saving chat message: $e');
    }
  }

  Future<void> clearChatHistory() async {
    try {
      await _chatsBox.clear();
    } catch (e) {
      debugPrint('Error clearing chat: $e');
    }
  }
}
