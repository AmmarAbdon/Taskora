import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_event.dart';
import 'package:taskora/features/profile/presentation/bloc/profile_state.dart';
import 'profile_setup_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Organize Your Life",
      description: "Keep track of all your tasks and goals in one place. Simple, clean and effective.",
      icon: Icons.auto_awesome_mosaic_rounded,
    ),
    OnboardingData(
      title: "Never Miss a Deadline",
      description: "Set smart reminders and get notified exactly when you need to take action.",
      icon: Icons.notifications_active_rounded,
    ),
    OnboardingData(
      title: "Analyze Your Progress",
      description: "Visualize your productivity with beautiful charts and stay motivated every day.",
      icon: Icons.insights_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is OnboardingCompleteSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (v) => _currentPageNotifier.value = v,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final data = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          data.icon,
                          size: 100,
                          color: theme.colorScheme.primary,
                        ),
                      )
                          .animate(key: ValueKey('icon_$index'))
                          .scale(begin: const Offset(0.6, 0.6), duration: 500.ms, curve: Curves.elasticOut)
                          .fadeIn(duration: 300.ms),
                      const SizedBox(height: 60),
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      )
                          .animate(key: ValueKey('title_$index'))
                          .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 150.ms, curve: Curves.easeOut)
                          .fadeIn(duration: 400.ms, delay: 150.ms),
                      const SizedBox(height: 20),
                      Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      )
                          .animate(key: ValueKey('desc_$index'))
                          .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 280.ms, curve: Curves.easeOut)
                          .fadeIn(duration: 400.ms, delay: 280.ms),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              bottom: 60,
              left: 40,
              right: 40,
              child: ValueListenableBuilder<int>(
                valueListenable: _currentPageNotifier,
                builder: (context, currentPage, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton.extended(
                        onPressed: () {
                          if (currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            context.read<ProfileBloc>().add(CompleteOnboardingEvent());
                          }
                        },
                        label: Text(currentPage == _pages.length - 1 ? "Get Started" : "Next"),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
