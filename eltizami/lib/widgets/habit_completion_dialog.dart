import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

/// Dialog for completing a habit with optional notes
class HabitCompletionDialog extends StatefulWidget {
  final Habit habit;

  const HabitCompletionDialog({
    super.key,
    required this.habit,
  });

  @override
  State<HabitCompletionDialog> createState() => _HabitCompletionDialogState();
}

class _HabitCompletionDialogState extends State<HabitCompletionDialog> {
  late TextEditingController _notesController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<HabitProvider>();
    _isCompleted = provider.isHabitCompleted(widget.habit.id);
    _notesController = TextEditingController(
      text: provider.getCompletionNotes(widget.habit.id) ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.habit.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.habit.icon,
                      color: widget.habit.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (widget.habit.description != null)
                          Text(
                            widget.habit.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Completion Toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isCompleted = !_isCompleted;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCompleted
                        ? widget.habit.color.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isCompleted
                          ? widget.habit.color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _isCompleted
                              ? widget.habit.color
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isCompleted
                                ? widget.habit.color
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: _isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isCompleted ? 'تم الإنجاز!' : 'اضغط للتحديد كمنجز',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isCompleted
                              ? widget.habit.color
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notes Section (Optional)
              Text(
                'ملاحظات (اختياري)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'أضف ملاحظاتك هنا...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.habit.color,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.note_alt_outlined,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveCompletion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.habit.color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'حفظ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCompletion() {
    final provider = context.read<HabitProvider>();
    final notes = _notesController.text.trim();

    if (_isCompleted) {
      provider.completeHabitWithNotes(
        widget.habit.id,
        notes: notes.isNotEmpty ? notes : null,
      );
    } else {
      // If unchecking, just toggle off
      if (provider.isHabitCompleted(widget.habit.id)) {
        provider.toggleHabitCompletion(widget.habit.id);
      }
    }

    Navigator.pop(context);
  }
}
