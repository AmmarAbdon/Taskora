import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../main.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';
import '../bloc/navigation_bloc/navigation_bloc.dart';
import '../bloc/navigation_bloc/navigation_event.dart';
import '../bloc/navigation_bloc/navigation_state.dart';
import 'add_edit_todo_page.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'focus_mode_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titles = ["My Tasks", "New Task", "Dashboard", "Focus Mode"];

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        final selectedIndex = navState.selectedIndex;

        Widget page;
        switch (selectedIndex) {
          case 0: page = const HomePage(); break;
          case 1: page = const AddEditTodoPage(isIntegrated: true); break;
          case 2: page = const StatisticsPage(); break;
          case 3: page = const FocusModePage(); break;
          default: page = const SizedBox.shrink();
        }

        return BlocListener<TodoBloc, TodoState>(
          listener: (context, state) {
            if (state is TodoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            } else if (state is TodoActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titles[selectedIndex],
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedIndex == 0)
                            ValueListenableBuilder<ThemeMode>(
                              valueListenable: themeNotifier,
                              builder: (context, currentMode, child) {
                                final isDark = currentMode == ThemeMode.dark;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: AnimatedSwitcher(duration: const Duration(milliseconds: 400), child: page),
            ),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 75,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(context, 0, Icons.home_rounded, "Home", selectedIndex),
                        _buildNavItem(context, 1, Icons.add_circle_rounded, "Add", selectedIndex, isPrimary: true),
                        _buildNavItem(context, 2, Icons.bar_chart_rounded, "Dashboard", selectedIndex),
                        _buildNavItem(context, 3, Icons.timer_rounded, "Focus", selectedIndex),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, int selectedIndex, {bool isPrimary = false}) {
    final theme = Theme.of(context);
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => context.read<NavigationBloc>().add(ChangeTabEvent(index)),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isPrimary ? 20 : 16, vertical: isPrimary ? 12 : 8),
        decoration: BoxDecoration(
          color: isPrimary
              ? theme.colorScheme.primary
              : isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isPrimary
                    ? Colors.white
                    : isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                size: isPrimary ? 28 : 24,
              ),
            ),
            if (!isPrimary && isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
