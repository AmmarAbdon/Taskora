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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60, // Increased size
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        backgroundImage: profile?.imagePath != null 
                            ? FileImage(File(profile!.imagePath!)) 
                            : null,
                        child: profile?.imagePath == null 
                            ? Icon(Icons.person, color: theme.colorScheme.primary, size: 60)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Here's your progress,",
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
                      ),
                      Text(
                        profile?.name.split(' ').first ?? 'User',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), // Made name slightly larger too
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Productivity Score",
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${productivity.toStringAsFixed(1)}%",
                          style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 100.ms, curve: Curves.easeOut),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: "Completed",
                          value: completed.toString(),
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: "Pending",
                          value: pending.toString(),
                          icon: Icons.pending_actions,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 250.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 250.ms, curve: Curves.easeOut),
                  const SizedBox(height: 48),
                  Text(
                    "Overview",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  if (total > 0)
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections: [
                            PieChartSectionData(
                              color: const Color(0xFF10B981),
                              value: completed.toDouble(),
                              title: '$completed',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: const Color(0xFFF59E0B),
                              value: pending.toDouble(),
                              title: '$pending',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Center(child: Text("No tasks available to show statistics.")),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
