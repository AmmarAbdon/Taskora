import 'package:equatable/equatable.dart';

class FocusState extends Equatable {
  final bool isRunning;
  final bool isWorking;
  final int remainingTime;
  final int workDuration; // in seconds
  final int breakDuration; // in seconds
  final int sessionsToday;
  final int sessionsTarget;

  const FocusState({
    required this.isRunning,
    required this.isWorking,
    required this.remainingTime,
    required this.workDuration,
    required this.breakDuration,
    this.sessionsToday = 0,
    this.sessionsTarget = 8,
  });

  factory FocusState.initial() => const FocusState(
        isRunning: false,
        isWorking: true,
        remainingTime: 1500, // 25 mins
        workDuration: 1500,
        breakDuration: 300,
        sessionsToday: 0,
        sessionsTarget: 8,
      );

  FocusState copyWith({
    bool? isRunning,
    bool? isWorking,
    int? remainingTime,
    int? workDuration,
    int? breakDuration,
    int? sessionsToday,
    int? sessionsTarget,
  }) {
    return FocusState(
      isRunning: isRunning ?? this.isRunning,
      isWorking: isWorking ?? this.isWorking,
      remainingTime: remainingTime ?? this.remainingTime,
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      sessionsToday: sessionsToday ?? this.sessionsToday,
      sessionsTarget: sessionsTarget ?? this.sessionsTarget,
    );
  }

  @override
  List<Object?> get props => [isRunning, isWorking, remainingTime, workDuration, breakDuration, sessionsToday, sessionsTarget];
}
