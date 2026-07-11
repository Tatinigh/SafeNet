import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/scan')) return 1;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/learn')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/scan');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/learn');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getCurrentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Screen contents
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 78), // Spacing for bottom navbar
              child: child,
            ),
          ),
          
          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 78,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(context, 0, Icons.home_rounded, 'Home', selectedIndex),
                  const SizedBox(width: 8),
                  _buildScanItem(context, selectedIndex),
                  const SizedBox(width: 8),
                  _buildNavItem(context, 2, Icons.history_rounded, 'History', selectedIndex),
                  _buildNavItem(context, 3, Icons.school_rounded, 'Learn', selectedIndex),
                  _buildNavItem(context, 4, Icons.person_rounded, 'Profile', selectedIndex),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, int selectedIndex) {
    final isSelected = index == selectedIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final activeBgColor = isDark 
        ? AppTheme.secondaryColor.withOpacity(0.15)
        : AppTheme.secondaryColor.withOpacity(0.12);
    final activeTextColor = AppTheme.primaryColor;
    final inactiveTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabSelected(context, index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? activeBgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? AppTheme.secondaryColor 
                    : inactiveTextColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected 
                    ? (isDark ? Colors.white : activeTextColor)
                    : inactiveTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanItem(BuildContext context, int selectedIndex) {
    final isSelected = selectedIndex == 1;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(context, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -12),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.secondaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withOpacity(isSelected ? 0.45 : 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -6),
              child: Text(
                'Scan',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected 
                      ? AppTheme.secondaryColor 
                      : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
