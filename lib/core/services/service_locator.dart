import 'package:get_it/get_it.dart';
import '../../features/todo/data/datasources/todo_local_datasource.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/domain/usecases/add_todo.dart';
import '../../features/todo/domain/usecases/delete_todo.dart';
import '../../features/todo/domain/usecases/get_todos.dart';
import '../../features/todo/domain/usecases/update_todo.dart';
import '../../features/todo/presentation/bloc/todo_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'profile_service.dart';

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
      notificationService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodos(sl()));
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
  await notificationService.init();
  sl.registerLazySingleton(() => notificationService);

  sl.registerLazySingleton(() => ProfileService(sl()));
}
