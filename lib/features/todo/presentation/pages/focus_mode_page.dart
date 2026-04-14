import 'package:flutter/material.dart';
import 'dart:async';

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  static const int _workDuration = 25 * 60;
  static const int _breakDuration = 5 * 60;

  int _remainingTime = _workDuration;
  bool _isWorking = true;
  bool _isRunning = false;
  Timer? _timer;

  void _startPauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTime > 0) {
          setState(() => _remainingTime--);
        } else {
          _timer?.cancel();
          setState(() {
            _isRunning = false;
            _isWorking = !_isWorking;
            _remainingTime = _isWorking ? _workDuration : _breakDuration;
          });
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingTime = _isWorking ? _workDuration : _breakDuration;
    });
  }

  void _toggleMode() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorking = !_isWorking;
      _remainingTime = _isWorking ? _workDuration : _breakDuration;
    });
  }

  String get _formattedTime {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalDuration = _isWorking ? _workDuration : _breakDuration;
    final progress = _remainingTime / totalDuration;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Mode Toggle ---
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, icon: Icon(Icons.work), label: Text("Work")),
                ButtonSegment(value: false, icon: Icon(Icons.coffee), label: Text("Break")),
              ],
              selected: {_isWorking},
              onSelectionChanged: (Set<bool> newSelection) {
                if (_isWorking != newSelection.first) {
                  _toggleMode();
                }
              },
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: _isWorking ? const Color(0xFFEF4444).withValues(alpha: 0.1) : const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _isWorking ? "Focus Session" : "Break Time",
                style: TextStyle(
                  color: _isWorking ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 64),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isWorking ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  _formattedTime,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    elevation: 2,
                  ),
                  child: const Icon(Icons.refresh, size: 32),
                ),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: _startPauseTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(28),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 4,
                  ),
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
