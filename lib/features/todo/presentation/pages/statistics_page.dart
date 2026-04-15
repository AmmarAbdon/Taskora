import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/profile_service.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = sl<ProfileService>().getProfile();

    return Scaffold(
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoaded) {
            final total = state.todos.length;
            final completed = state.todos.where((t) => t.isCompleted).length;
            final pending = total - completed;
            final productivity = total == 0 ? 0.0 : (completed / total) * 100;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50), // Minimized space before image
                  
                  // --- Profile Header (Premium Row) ---
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55, // Further increased size
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          backgroundImage: profile?.imagePath != null
                              ? FileImage(File(profile!.imagePath!))
                              : null,
                          child: profile?.imagePath == null
                              ? Icon(
                                  Icons.person_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 40,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Welcome back,",
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            profile?.name ?? 'User',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 32), // Increased yellow space
                  
                  // --- Productivity Score (Compact) ---
                  Container(
                    height: 110, // More compact height
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10,
                          top: -10,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "PRODUCTIVITY SCORE",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "${productivity.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                  
                  const SizedBox(height: 32), // Increased yellow space
                  
                  // --- Mini Stats ---
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: "Completed",
                          value: completed.toString(),
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: "Pending",
                          value: pending.toString(),
                          icon: Icons.pending_rounded,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn(),
                  
                  const SizedBox(height: 32), // Increased yellow space
                  
                  // --- Overview ---
                  Row(
                    children: [
                      Text(
                        "Overview",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.insights_rounded, color: Colors.grey, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (total > 0)
                    Container(
                      height: 170, // Reduced height for single-screen fit
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 6,
                              centerSpaceRadius: 50,
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFF10B981),
                                  value: completed.toDouble(),
                                  title: "",
                                  radius: 15,
                                  badgeWidget: _ChartBadge(completed.toString(), const Color(0xFF10B981)),
                                  badgePositionPercentageOffset: 1.1,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFF59E0B),
                                  value: pending.toDouble(),
                                  title: "",
                                  radius: 15,
                                  badgeWidget: _ChartBadge(pending.toString(), const Color(0xFFF59E0B)),
                                  badgePositionPercentageOffset: 1.1,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "TOTAL",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$total",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).fadeIn()
                  else
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          style: BorderStyle.none,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 60,
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No tasks available yet.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Icon(Icons.arrow_right_alt_rounded, color: color.withValues(alpha: 0.3), size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBadge extends StatelessWidget {
  final String value;
  final Color color;

  const _ChartBadge(this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
