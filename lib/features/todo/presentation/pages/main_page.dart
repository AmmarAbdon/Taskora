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
import '../../../../core/theme/responsive.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive().init(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallHeight = size.height < 700;
    
    final titles = ["My Tasks", "New Task", "Dashboard", "Focus Mode"];

    final appBarHeight = isSmallHeight ? 65.h : 75.h;
    final topMargin = isSmallHeight ? 25.h : 35.h;

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
                  margin: EdgeInsets.fromLTRB(20, 0, 20, isSmallHeight ? 80 : 100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              );
            } else if (state is TodoActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.fromLTRB(20, 0, 20, isSmallHeight ? 80 : 100),
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
              preferredSize: Size.fromHeight(appBarHeight + topMargin),
              child: Container(
                margin: EdgeInsets.fromLTRB(16, topMargin, 16, 0),
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
                      height: appBarHeight,
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
                                    fontSize: isSmallHeight ? 18.sp : 22.sp,
                                  ),
                                ),
                                Container(
                                  width: isSmallHeight ? 20.w : 30.w,
                                  height: 4.h,
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
                                  padding: isSmallHeight ? const EdgeInsets.all(4) : null,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    constraints: isSmallHeight ? const BoxConstraints() : null,
                                    padding: isSmallHeight ? EdgeInsets.zero : const EdgeInsets.all(8.0),
                                    icon: Icon(
                                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                      color: theme.colorScheme.primary,
                                      size: isSmallHeight ? 20 : 24,
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
              margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, isSmallHeight ? 8.h : 16.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: isSmallHeight ? 60.h : 70.h,
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
        padding: EdgeInsets.symmetric(horizontal: isPrimary ? 18.w : 14.w, vertical: isPrimary ? 10.h : 6.h),
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
                    offset: Offset(0, 4.h),
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
                size: isPrimary ? 26.sp : 22.sp,
              ),
            ),
            if (!isPrimary && isSelected) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 9.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
