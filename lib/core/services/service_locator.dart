import 'package:get_it/get_it.dart';
import '../../features/todo/data/datasources/todo_local_datasource.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/domain/usecases/add_todo.dart';
import '../../features/todo/domain/usecases/delete_todo.dart';
import '../../features/todo/domain/usecases/get_focus_sessions_count.dart';
import '../../features/todo/domain/usecases/get_todos.dart';
import '../../features/todo/domain/usecases/update_todo.dart';
import '../../features/todo/presentation/bloc/todo_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'profile_service.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/todo/presentation/bloc/calendar_bloc/calendar_bloc.dart';
import '../../features/todo/presentation/bloc/todo_form_bloc/todo_form_bloc.dart';
import '../../features/todo/presentation/bloc/navigation_bloc/navigation_bloc.dart';
import '../../features/todo/presentation/bloc/focus_bloc/focus_bloc.dart';
import '../../features/profile/presentation/bloc/profile_form_bloc/profile_form_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // BLoC
  sl.registerFactory(
    () => TodoBloc(
      getTodos: sl(),
      addTodo: sl(),
      updateTodo: sl(),
      deleteTodo: sl(),
      getFocusSessionsCount: sl(),
      notificationService: sl(),
    ),
  );
  sl.registerFactory(() => ProfileBloc(sl()));
  sl.registerFactory(() => CalendarBloc());
  sl.registerFactory(() => TodoFormBloc());
  sl.registerFactory(() => NavigationBloc());
  sl.registerFactory(() => FocusBloc(repository: sl()));
  sl.registerFactory(() => ProfileFormBloc());

  // Use cases
  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => GetFocusSessionsCount(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => UpdateTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));

  // Repository
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(),
  );

  // Core Services
  final notificationService = NotificationService();
  // Initialize in background to speed up app startup
  notificationService.init(); 
  sl.registerLazySingleton(() => notificationService);

  sl.registerLazySingleton(() => ProfileService(sl()));
}
