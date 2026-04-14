import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/todo_entity.dart';

class TodoItem extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final int index; // For staggered animation

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    this.index = 0,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work': return Icons.work_outline_rounded;
      case 'personal': return Icons.person_outline_rounded;
      case 'shopping': return Icons.shopping_bag_outlined;
      case 'health': return Icons.favorite_border_rounded;
      case 'education': return Icons.menu_book_rounded;
      default: return Icons.category_outlined;
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high: return const Color(0xFFEF4444);
      case TodoPriority.medium: return const Color(0xFFF59E0B);
      case TodoPriority.low: return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = todo.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // --- Status Button ---
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // --- Content ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                todo.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  color: isCompleted ? theme.colorScheme.onSurfaceVariant : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (todo.isPinned) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.push_pin, size: 14, color: theme.colorScheme.primary),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(todo.category),
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              todo.category,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, hh:mm a').format(todo.dateTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- Priority Indicator & Actions ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(todo.priority).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          todo.priority.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(todo.priority),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    // Staggered slide-in + fade animation on first build
    .animate()
    .slideX(
      begin: 0.1,
      end: 0,
      duration: 400.ms,
      delay: Duration(milliseconds: (index * 80).clamp(0, 600)),
      curve: Curves.easeOut,
    )
    .fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: (index * 80).clamp(0, 600)),
    );
  }
}
