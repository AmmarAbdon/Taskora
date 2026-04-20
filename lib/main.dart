import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/service_locator.dart' as di;
import 'features/todo/presentation/bloc/todo_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/todo/presentation/bloc/calendar_bloc/calendar_bloc.dart';
import 'features/todo/presentation/bloc/navigation_bloc/navigation_bloc.dart';
import 'features/todo/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'features/todo/presentation/bloc/focus_bloc/focus_event.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';

late ValueNotifier<ThemeMode> themeNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  final prefs = di.sl<SharedPreferences>();
  final isDark = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier = ValueNotifier(isDark ? ThemeMode.dark : ThemeMode.light);

  themeNotifier.addListener(() {
    prefs.setBool('is_dark_mode', themeNotifier.value == ThemeMode.dark);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<TodoBloc>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()..add(LoadProfileEvent())),
        BlocProvider(create: (_) => di.sl<CalendarBloc>()),
        BlocProvider(create: (_) => di.sl<NavigationBloc>()),
        BlocProvider(create: (_) => di.sl<FocusBloc>()..add(LoadFocusSessionsEvent())),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            title: 'Taskora',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1), // Modern Indigo
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.outfitTextTheme(),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(
                0xFF09090B,
              ), // OLED-friendly deep zinc
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF818CF8), // Bright glowing indigo
                brightness: Brightness.dark,
                surface: const Color(
                  0xFF18181B,
                ), // Elevated dark component background
                primary: const Color(0xFF818CF8),
                onPrimary: Colors.white,
                primaryContainer: const Color(
                  0xFF3730A3,
                ), // Rich accent background
                onPrimaryContainer: const Color(0xFFE0E7FF),
                surfaceContainerHighest: const Color(
                  0xFF27272A,
                ), // Subtle outlines/cards
              ),
              textTheme: GoogleFonts.outfitTextTheme(
                ThemeData.dark().textTheme,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            ),
            themeMode: currentMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
