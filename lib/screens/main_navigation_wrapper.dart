import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'create_task_bottom_sheet.dart';

class MainNavigationWrapper extends StatefulWidget {
  final AppState appState;
  final StorageService storage;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  const MainNavigationWrapper({
    super.key,
    required this.appState,
    required this.storage,
    this.onThemeModeChanged,
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      HomeScreen(appState: widget.appState),
      ProgressScreen(appState: widget.appState),
      const SizedBox(), // Placeholder for + Add button
      ExploreScreen(appState: widget.appState),
      ProfileScreen(
        appState: widget.appState,
        storage: widget.storage,
        onThemeModeChanged: widget.onThemeModeChanged ?? (_) {},
      ),
    ];

    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Home', isDark),
                    _buildNavItem(1, Icons.bar_chart_rounded, 'Progress', isDark),
                    _buildAddActionButton(context),
                    _buildNavItem(3, Icons.explore_rounded, 'Explore', isDark),
                    _buildNavItem(4, Icons.person_rounded, 'Profile', isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.textSubDark : AppColors.textSubLight);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddActionButton(BuildContext context) {
    return InkWell(
      onTap: () => CreateTaskBottomSheet.show(context, widget.appState),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
