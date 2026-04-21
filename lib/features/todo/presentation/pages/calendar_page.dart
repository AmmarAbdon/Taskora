import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_state.dart';
import '../bloc/todo_event.dart';
import '../bloc/calendar_bloc/calendar_bloc.dart';
import '../bloc/calendar_bloc/calendar_event.dart';
import '../bloc/calendar_bloc/calendar_state.dart';
import '../../domain/entities/todo_entity.dart';
import '../widgets/todo_item.dart';
import '../../../../core/theme/responsive.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calendar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, calState) {
          return Column(
            children: [
              BlocBuilder<TodoBloc, TodoState>(
                builder: (context, todoState) {
                  List<TodoEntity> todos = [];
                  if (todoState is TodoLoaded) {
                    todos = todoState.todos;
                  }

                  return Container(
                    margin: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10.w,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: TableCalendar<TodoEntity>(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: calState.focusedDay,
                      selectedDayPredicate: (day) => isSameDay(calState.selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        context.read<CalendarBloc>().add(SelectDayEvent(selectedDay, focusedDay));
                      },
                      eventLoader: (day) {
                        return todos
                            .where((t) => isSameDay(t.dateTime, day))
                            .toList();
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: BlocBuilder<TodoBloc, TodoState>(
                  builder: (context, todoState) {
                    if (todoState is TodoLoaded) {
                      final dayTodos = todoState.todos
                          .where(
                            (t) => isSameDay(t.dateTime, calState.selectedDay),
                          )
                          .toList();

                      if (dayTodos.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48.sp,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "No tasks for this day",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 14.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 80.h),
                        itemCount: dayTodos.length,
                        itemBuilder: (context, index) {
                          final todo = dayTodos[index];
                          return TodoItem(
                            todo: todo,
                            onTap: () {},
                            onToggle: () {
                              context.read<TodoBloc>().add(ToggleTodoStatusEvent(todo));
                            },
                            onDelete: () {
                              context.read<TodoBloc>().add(DeleteTodoEvent(todo.id!, todo.notificationId));
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
