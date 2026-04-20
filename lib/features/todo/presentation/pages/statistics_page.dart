import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/profile_service.dart';
import '../../../onboarding/presentation/pages/profile_setup_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isShortScreen = size.height < 750;

    return Scaffold(
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, todoState) {
          if (todoState is TodoLoaded) {
            final total = todoState.todos.length;
            final completed =
                todoState.todos.where((t) => t.isCompleted).length;
            final productivity = total == 0 ? 0.0 : (completed / total) * 100;

            return BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                UserProfile? profile;
                if (profileState is ProfileLoaded) {
                  profile = profileState.profile;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // --- MASSIVE Profile Header with Edit Icon ---
                      _buildHeader(context, profile, theme, isShortScreen),

                      const SizedBox(height: 20),

                      // --- Analysis Section (Radial Activity Dial) ---
                      Expanded(
                        child: _buildRadialDial(
                                theme, productivity, completed, total)
                            .animate()
                            .scale(begin: const Offset(0.9, 0.9))
                            .fadeIn(),
                      ),

                      const SizedBox(height: 20),

                      // --- Stat Row ---
                      Row(
                        children: [
                          Expanded(
                              child: _StatTile(
                                  "DONE",
                                  "$completed",
                                  const Color(0xFF10B981),
                                  Icons.check_circle_rounded)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _StatTile(
                                  "LEFT",
                                  "${total - completed}",
                                  const Color(0xFFF59E0B),
                                  Icons.pending_actions_rounded)),
                        ],
                      ).animate(delay: 400.ms).fadeIn(),

                      const SizedBox(height: 110),
                    ],
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile? profile,
      ThemeData theme, bool isSmall) {
    final radius = isSmall ? 55.0 : 70.0;
    return Column(
      children: [
        GestureDetector(
          onTap: () => _openProfile(context),
          child: Stack(
            children: [
              Hero(
                tag: 'profile_avatar_stats',
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: theme.colorScheme.primary, width: 2)),
                  child: CircleAvatar(
                    radius: radius,
                    backgroundColor: theme.colorScheme.surface,
                    backgroundImage: profile?.imagePath != null
                        ? FileImage(File(profile!.imagePath!))
                        : null,
                    child: profile?.imagePath == null
                        ? Icon(Icons.person_rounded,
                            color: theme.colorScheme.primary, size: radius)
                        : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile?.name ?? 'User',
          style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900, letterSpacing: -1, fontSize: 30),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildRadialDial(ThemeData theme, double score, int done, int total) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 40,
              offset: const Offset(0, 20)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 24,
              color: theme.colorScheme.primary.withOpacity(0.05),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Progress Ring
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 24,
              color: theme.colorScheme.primary,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "SCORE",
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2),
              ),
              Text(
                "${score.toInt()}%",
                style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: -2),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$done / $total TASKS",
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const ProfileSetupPage(
                isEditing: true, heroTag: 'profile_avatar_stats')));
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatTile(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
        ],
      ),
    );
  }
}
