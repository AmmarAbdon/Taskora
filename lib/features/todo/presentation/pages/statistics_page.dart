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
import '../../../../core/theme/responsive.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, todoState) {
          if (todoState is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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

                return LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          // --- Profile Header ---
                          _buildHeader(
                              context, profile, theme, constraints.maxHeight),

                          const SizedBox(height: 16),

                          // --- Analysis Section (Radial Activity Dial) ---
                          _buildRadialDial(theme, productivity, completed,
                                  total, constraints.maxHeight)
                              .animate()
                              .scale(begin: const Offset(0.9, 0.9))
                              .fadeIn(),

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

                          const SizedBox(height: 120), // Space for bottom bar
                        ],
                      ),
                    ),
                  );
                });
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile? profile,
      ThemeData theme, double maxHeight) {
    final radius = 60.w.clamp(40.0, 70.0);
    return Column(
      children: [
        GestureDetector(
          onTap: () => _openProfile(context),
          child: Stack(
            children: [
              Hero(
                tag: 'profile_avatar_stats',
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: theme.colorScheme.primary, width: 2.w)),
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
                bottom: 5.h,
                right: 5.w,
                child: Container(
                  padding: EdgeInsets.all(radius * 0.12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4.h)),
                    ],
                  ),
                  child: Icon(Icons.edit_rounded,
                      color: Colors.white,
                      size: (radius * 0.3).clamp(12.0, 18.0)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          profile?.name ?? 'User',
          style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              fontSize: 26.sp.clamp(20.0, 30.0)),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildRadialDial(
      ThemeData theme, double score, int done, int total, double maxHeight) {
    final dialSize = 220.w.clamp(160.0, 250.0);
    final strokeWidth = (dialSize * 0.08).clamp(14.0, 20.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: Offset(0, 10.h)),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Ring
            SizedBox(
              width: dialSize,
              height: dialSize,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: strokeWidth,
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                strokeCap: StrokeCap.round,
              ),
            ),
            // Progress Ring
            SizedBox(
              width: dialSize,
              height: dialSize,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: strokeWidth,
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
                      fontSize: 11.sp,
                      letterSpacing: 2),
                ),
                Text(
                  "${score.toInt()}%",
                  style: TextStyle(
                      fontSize: 54.sp,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: -2),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$done / $total TASKS",
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 9.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
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
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 10.h),
          Text(value,
              style: TextStyle(
                  fontSize: 24.sp, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
        ],
      ),
    );
  }
}
