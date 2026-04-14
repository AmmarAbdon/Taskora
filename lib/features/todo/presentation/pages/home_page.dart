import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/todo_item.dart';
import '../widgets/filter_bar.dart';
import '../widgets/empty_view.dart';
import 'add_edit_todo_page.dart';
import '../../domain/entities/todo_entity.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/profile_service.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(LoadTodosEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final profile = sl<ProfileService>().getProfile();
    final name = profile?.name.split(' ').first ?? 'there';
    
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning, $name";
    if (hour < 17) return "Good Afternoon, $name";
    return "Good Evening, $name";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Greeting (Fixed) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Stay productive today!",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // --- Search Field (Fixed) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => context.read<TodoBloc>().add(SearchTodosEvent(v)),
                decoration: InputDecoration(
                  hintText: "Find your task...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- Filter Bar (Fixed) ---
            BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoLoaded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: FilterBar(
                      activeFilter: state.filter,
                      onFilterChanged: (filter) {
                        context.read<TodoBloc>().add(FilterTodosEvent(filter));
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // --- List of Items (Scrollable) ---
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  BlocBuilder<TodoBloc, TodoState>(
                    builder: (context, state) {
                      if (state is TodoLoading) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is TodoLoaded) {
                        if (state.todos.isEmpty) {
                          return const SliverFillRemaining(
                            child: EmptyView(),
                          );
                        }
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final todo = state.todos[index];
                                return TodoItem(
                                  todo: todo,
                                  index: index,
                                  onTap: () async {
                                    final updated = await Navigator.push<TodoEntity>(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddEditTodoPage(todo: todo)),
                                    );
                                    if (updated != null && context.mounted) {
                                      context.read<TodoBloc>().add(UpdateTodoEvent(updated));
                                    }
                                  },
                                  onToggle: () {
                                    context.read<TodoBloc>().add(ToggleTodoStatusEvent(todo));
                                  },
                                  onDelete: () {
                                    // Simplified delete for cleaner UI
                                    context.read<TodoBloc>().add(DeleteTodoEvent(todo.id!, todo.notificationId));
                                  },
                                );
                              },
                              childCount: state.todos.length,
                            ),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.large(
          onPressed: () async {
            final todo = await Navigator.push<TodoEntity>(
              context,
              MaterialPageRoute(builder: (_) => const AddEditTodoPage()),
            );
            if (todo != null && context.mounted) {
              context.read<TodoBloc>().add(AddTodoEvent(todo));
            }
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }
}
