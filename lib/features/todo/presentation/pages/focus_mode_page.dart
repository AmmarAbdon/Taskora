import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/focus_bloc/focus_bloc.dart';
import '../bloc/focus_bloc/focus_event.dart';
import '../bloc/focus_bloc/focus_state.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../../../../core/theme/responsive.dart';

class FocusModePage extends StatelessWidget {
  const FocusModePage({super.key});

  String _formatTime(int remainingTime) {
    int minutes = remainingTime ~/ 60;
    int seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSettings(BuildContext context, FocusState state) {
    final workController = TextEditingController(text: (state.workDuration ~/ 60).toString());
    final breakController = TextEditingController(text: (state.breakDuration ~/ 60).toString());
    final targetController = TextEditingController(text: state.sessionsTarget.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Timer Settings",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   Expanded(
                    child: TextField(
                      controller: workController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Work (mins)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: breakController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Break (mins)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Daily Sessions Target",
                  prefixIcon: const Icon(Icons.flag_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: () {
                    final work = int.tryParse(workController.text) ?? 25;
                    final breakTime = int.tryParse(breakController.text) ?? 5;
                    final target = int.tryParse(targetController.text) ?? 8;
                    context.read<FocusBloc>().add(ChangeDurationEvent(
                      workDuration: work * 60,
                      breakDuration: breakTime * 60,
                      sessionsTarget: target,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<FocusBloc, FocusState>(
      listenWhen: (previous, current) => previous.remainingTime > 0 && current.remainingTime == 0,
      listener: (context, state) {
        context.read<TodoBloc>().add(LoadTodosEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.isWorking ? "Break session finished!" : "Work session finished!"),
            backgroundColor: state.isWorking ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: BlocBuilder<FocusBloc, FocusState>(
        builder: (context, state) {
          final totalDuration = state.isWorking ? state.workDuration : state.breakDuration;
          final progress = totalDuration == 0 ? 0.0 : state.remainingTime / totalDuration;

          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final isSmall = height < 600;
                
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: isSmall ? 8.h : 16.h),
                      
                      // --- Mode Switcher ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 40.w), 
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(value: true, icon: Icon(Icons.work_rounded, size: 16.sp), label: Text("Work", style: TextStyle(fontSize: 11.sp))),
                              ButtonSegment(value: false, icon: Icon(Icons.coffee_rounded, size: 16.sp), label: Text("Break", style: TextStyle(fontSize: 11.sp))),
                            ],
                            selected: {state.isWorking},
                            onSelectionChanged: (Set<bool> newSelection) {
                              if (state.isWorking != newSelection.first) {
                                context.read<FocusBloc>().add(ToggleModeEvent());
                              }
                            },
                          ),
                          IconButton(
                            onPressed: () => _showSettings(context, state),
                            icon: Icon(Icons.settings_suggest_rounded, size: 18.sp),
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ).animate().fadeIn().slideY(begin: -0.1),
                      
                      SizedBox(height: isSmall ? 8.h : 16.h),
                      
                      // --- Label ---
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: (state.isWorking ? const Color(0xFFEF4444) : const Color(0xFF10B981)).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          state.isWorking ? "FOCUS SESSION" : "RELAX TIME",
                          style: TextStyle(
                            color: state.isWorking ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            fontWeight: FontWeight.w900,
                            fontSize: 10.sp,
                            letterSpacing: 1,
                          ),
                        ),
                      ).animate().fadeIn().scale(),
                      
                      const Spacer(flex: 1), 
                      
                      // --- Main Timer Circle ---
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: (height * 0.35).clamp(160.0, 240.0),
                            height: (height * 0.35).clamp(160.0, 240.0),
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: (height * 0.012).clamp(8.0, 12.0),
                              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                state.isWorking ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                           .shimmer(duration: 3.seconds, color: Colors.white.withValues(alpha: 0.1)),
                          Text(
                            _formatTime(state.remainingTime),
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 54.sp,
                              letterSpacing: -1,
                            ),
                          ).animate().fadeIn().scale(delay: 200.ms),
                        ],
                      ),
                      
                      const Spacer(flex: 1),
                      
                      // --- Controls ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => context.read<FocusBloc>().add(ResetTimerEvent()),
                            padding: EdgeInsets.all(isSmall ? 10.w : 14.w),
                            icon: Icon(Icons.replay_rounded, size: 22.sp),
                          ),
                          SizedBox(width: 24.w),
                          IconButton.filled(
                            onPressed: () {
                              if (state.isRunning) {
                                context.read<FocusBloc>().add(StopTimerEvent());
                              } else {
                                context.read<FocusBloc>().add(StartTimerEvent());
                              }
                            },
                            padding: EdgeInsets.all(isSmall ? 14.w : 20.w),
                            icon: Icon(state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 32.sp),
                          ),
                        ],
                      ).animate().fadeIn().slideY(begin: 0.1),
                      
                      const Spacer(flex: 1),
                      
                      // --- Progress Card ---
                      _SessionsInfoCard(
                        count: state.sessionsToday, 
                        target: state.sessionsTarget,
                        isSmall: isSmall,
                      ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1),
                          
                      SizedBox(height: 110.h), // Bottom bar safe space
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SessionsInfoCard extends StatelessWidget {
  final int count;
  final int target;
  final bool isSmall;
  const _SessionsInfoCard({required this.count, required this.target, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isSmall ? 16.w : 20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28.w),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, color: theme.colorScheme.primary, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Progress",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
                    ),
                    Text("Daily focus productivity", style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 10.h : 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: "Sessions", value: "$count", color: theme.colorScheme.primary, isSmall: isSmall),
              _StatItem(label: "Target", value: "$target", color: Colors.grey, isSmall: isSmall),
              _StatItem(label: "Streak", value: "3 Days", color: const Color(0xFFF59E0B), isSmall: isSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isSmall;

  const _StatItem({required this.label, required this.value, required this.color, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: isSmall ? 16.sp : 20.sp, fontWeight: FontWeight.w900, color: color),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
        ),
      ],
    );
  }
}
