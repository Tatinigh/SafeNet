import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import Screens (we'll implement them next)
import '../../features/authentication/screens/login_screen.dart';
import '../../features/dashboard/screens/home_screen.dart';
import '../../features/scan/screens/scan_options_screen.dart';
import '../../features/scan/screens/qr_scanner_screen.dart';
import '../../features/scan/screens/ocr_editor_screen.dart';
import '../../features/analysis/screens/ai_loading_screen.dart';
import '../../features/analysis/screens/ai_result_screen.dart';
import '../../features/chat/screens/ai_chat_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/learn/screens/learn_screen.dart';
import '../../features/learn/screens/quiz_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/dashboard/screens/main_shell.dart';

// Provider for GoRouter to enable dependency injection and dynamic routing redirects
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // ShellRoute for persistent bottom navigation bar
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/scan',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScanOptionsScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/learn',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LearnScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      // Full screen routes
      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/ocr-editor',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final imagePath = extra?['imagePath'] as String? ?? '';
          final scanType = extra?['scanType'] as String? ?? 'Screenshot';
          return OcrEditorScreen(imagePath: imagePath, scanType: scanType);
        },
      ),
      GoRoute(
        path: '/ai-loading',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final input = extra?['input'] as String? ?? '';
          final scanType = extra?['scanType'] as String? ?? 'Text';
          return AiLoadingScreen(input: input, scanType: scanType);
        },
      ),
      GoRoute(
        path: '/ai-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final reportId = extra?['reportId'] as String? ?? '';
          return AiResultScreen(reportId: reportId);
        },
      ),
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
