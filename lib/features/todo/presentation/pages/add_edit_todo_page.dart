import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_form_bloc/todo_form_bloc.dart';
import '../bloc/todo_form_bloc/todo_form_event.dart';
import '../bloc/todo_form_bloc/todo_form_state.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../domain/entities/todo_entity.dart';
import '../../../../core/services/service_locator.dart';

class AddEditTodoPage extends StatefulWidget {
  final TodoEntity? todo;
  final bool isIntegrated;

  const AddEditTodoPage({super.key, this.todo, this.isIntegrated = false});

  @override
  State<AddEditTodoPage> createState() => _AddEditTodoPageState();
}

class _AddEditTodoPageState extends State<AddEditTodoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TodoFormBloc _formBloc;

  final List<String> _categories = [
    'Personal', 'Work', 'Shopping', 'Health', 'Education', 'Finance', 'Social', 'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _formBloc = sl<TodoFormBloc>();
    _formBloc.add(InitializeFormEvent(widget.todo));
    
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');

    _titleController.addListener(() {
      _formBloc.add(TitleChangedEvent(_titleController.text));
    });
    _descriptionController.addListener(() {
      _formBloc.add(DescriptionChangedEvent(_descriptionController.text));
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save(TodoFormState state) {
    if (_formKey.currentState!.validate()) {
      final combinedDateTime = DateTime(
        state.selectedDate.year,
        state.selectedDate.month,
        state.selectedDate.day,
        state.selectedTime.hour,
        state.selectedTime.minute,
      );

      final todo = TodoEntity(
        id: widget.todo?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dateTime: combinedDateTime,
        isCompleted: widget.todo?.isCompleted ?? false,
        notificationId: widget.todo?.notificationId ?? Random().nextInt(1000000),
        priority: state.selectedPriority,
        category: state.selectedCategory,
        isPinned: state.isPinned,
        enableReminder: state.enableReminder,
      );

      if (widget.isIntegrated) {
        context.read<TodoBloc>().add(AddTodoEvent(todo));
      } else {
        Navigator.pop(context, todo);
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work': return Icons.business_center_rounded;
      case 'personal': return Icons.person_outline_rounded;
      case 'shopping': return Icons.shopping_bag_outlined;
      case 'health': return Icons.favorite_border_rounded;
      case 'education': return Icons.menu_book_rounded;
      case 'finance': return Icons.account_balance_wallet_rounded;
      case 'social': return Icons.people_outline_rounded;
      case 'sports': return Icons.directions_run_rounded;
      default: return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _formBloc,
      child: BlocBuilder<TodoFormBloc, TodoFormState>(
        builder: (context, state) {
          final List<Widget> items = [
            const SizedBox(height: 60),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "What needs to be done?",
                border: InputBorder.none,
                hintStyle: TextStyle(color: theme.colorScheme.outlineVariant),
              ),
              validator: (v) => v == null || v.isEmpty ? "Title is required" : null,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Add description...",
                prefixIcon: const Icon(Icons.notes, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    label: "Date",
                    value: DateFormat('MMM d, yyyy').format(state.selectedDate),
                    icon: Icons.calendar_today_rounded,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: state.selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) _formBloc.add(DateChangedEvent(date));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PickerTile(
                    label: "Time",
                    value: state.selectedTime.format(context),
                    icon: Icons.access_time_rounded,
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: state.selectedTime);
                      if (time != null) _formBloc.add(TimeChangedEvent(time));
                    },
                  ),
                ),
              ],
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 32),
            Text("Category", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                .animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 8),
            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = state.selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => _formBloc.add(CategoryChangedEvent(cat)),
                    avatar: Icon(
                      _getCategoryIcon(cat),
                      size: 16,
                      color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  );
                },
              ),
            ).animate(delay: 350.ms).fadeIn().slideX(begin: 0.1),
            const SizedBox(height: 24),
            Text("Priority", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
                .animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 12),
            Row(
              children: TodoPriority.values.map((p) {
                final isSelected = state.selectedPriority == p;
                Color pColor;
                switch (p) {
                  case TodoPriority.high: pColor = Colors.red; break;
                  case TodoPriority.medium: pColor = Colors.orange; break;
                  case TodoPriority.low: pColor = Colors.green; break;
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () => _formBloc.add(PriorityChangedEvent(p)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? pColor : pColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: pColor, width: isSelected ? 2 : 1),
                        ),
                        child: Center(
                          child: Text(
                            p.name.toUpperCase(),
                            style: TextStyle(color: isSelected ? Colors.white : pColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 24),
            _ToggleTile(
              label: "Pin to top",
              hint: "Pin this task to the top of the list",
              value: state.isPinned,
              onChanged: (v) => _formBloc.add(PinnedChangedEvent(v)),
              icon: Icons.push_pin_outlined,
            ).animate(delay: 500.ms).fadeIn(),
            const SizedBox(height: 12),
            _ToggleTile(
              label: "Enable Reminder",
              hint: "Sends a notification at the selected time",
              value: state.enableReminder,
              onChanged: (v) => _formBloc.add(ReminderChangedEvent(v)),
              icon: Icons.notifications_active_outlined,
            ).animate(delay: 550.ms).fadeIn(),
            const SizedBox(height: 32),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _save(state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  widget.todo == null ? "CREATE TASK" : "UPDATE TASK",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.2),
          ];

          final content = Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 100.0),
              children: items,
            ),
          );

          if (widget.isIntegrated) return content;

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.todo == null ? "Create New Task" : "Edit Task", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            body: content,
          );
        },
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _ToggleTile({required this.label, required this.hint, required this.value, required this.onChanged, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(hint, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
