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

  String _getCategoryImage(String category) {
    return 'assets/categories/${category.toLowerCase()}.png';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work': return const Color(0xFF6366F1);
      case 'personal': return const Color(0xFFEC4899);
      case 'shopping': return const Color(0xFFF59E0B);
      case 'health': return const Color(0xFF10B981);
      case 'education': return const Color(0xFF8B5CF6);
      case 'finance': return const Color(0xFF059669);
      case 'social': return const Color(0xFF3B82F6);
      case 'sports': return const Color(0xFFF97316);
      default: return const Color(0xFF64748B);
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return const Color(0xFFEF4444);
      case TodoPriority.medium:
        return const Color(0xFFF59E0B);
      case TodoPriority.low:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = todo.isCompleted;
    final categoryColor = _getCategoryColor(todo.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // --- Pro Image Container ---
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        _getCategoryImage(todo.category),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          _getCategoryIcon(todo.category),
                          color: categoryColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ).animate().shimmer(duration: 2.seconds, color: Colors.white24).scale(
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(width: 16),

                  // --- Content Area ---
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                todo.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: -0.5,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isCompleted
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (todo.isPinned)
                              Icon(Icons.push_pin_rounded,
                                  size: 16, color: categoryColor),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildInfoChip(
                              context,
                              Icons.calendar_today_rounded,
                              DateFormat('MMM d').format(todo.dateTime),
                            ),
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              context,
                              Icons.access_time_rounded,
                              DateFormat('hh:mm a').format(todo.dateTime),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Priority Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(todo.priority)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(todo.priority),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getPriorityColor(todo.priority)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    todo.priority.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: _getPriorityColor(todo.priority),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Delete Button
                            IconButton(
                              onPressed: onDelete,
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: theme.colorScheme.error.withValues(alpha: 0.6),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 12),
                            // Status Toggle
                            GestureDetector(
                              onTap: onToggle,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? categoryColor
                                      : categoryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                                  size: 20,
                                  color: isCompleted ? Colors.white : categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.05, curve: Curves.easeOut);
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
