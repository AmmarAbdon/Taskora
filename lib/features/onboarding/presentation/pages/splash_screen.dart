import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/profile_service.dart';
import '../../../todo/presentation/bloc/todo_bloc.dart';
import '../../../todo/presentation/bloc/todo_event.dart';
import 'onboarding_page.dart';
import 'profile_setup_page.dart';
import '../../../todo/presentation/pages/main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Start loading data immediately so it's ready when the splash ends
    if (mounted) {
      context.read<TodoBloc>().add(LoadTodosEvent());
    }

    // Reduced delay from 3000ms to 1200ms for a snappier start
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final profileService = sl<ProfileService>();
    final onboardingComplete = profileService.isOnboardingComplete();
    final profileComplete = profileService.isProfileComplete();

    if (!onboardingComplete) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const OnboardingPage(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else if (!profileComplete) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const ProfileSetupPage(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const MainPage(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1), // Always use brand indigo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon using the generated logo
            ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/app_icon.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.task_alt_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            const Text(
                  'Taskora',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                )
                .animate()
                .slideY(
                  begin: 0.3,
                  duration: 500.ms,
                  delay: 300.ms,
                  curve: Curves.easeOut,
                )
                .fadeIn(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: 8),

            const Text(
              'Master Your Productivity',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

            const SizedBox(height: 80),

            // Animated loading dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) =>
                    Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .scaleXY(
                          begin: 1.0,
                          end: 1.5,
                          duration: 600.ms,
                          delay: Duration(milliseconds: i * 200),
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scaleXY(begin: 1.5, end: 1.0, duration: 600.ms),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
