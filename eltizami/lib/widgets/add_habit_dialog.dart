import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

/// Dialog for adding/editing a habit
class AddHabitDialog extends StatefulWidget {
  final Habit? habitToEdit;

  const AddHabitDialog({
    super.key,
    this.habitToEdit,
  });

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Color _selectedColor;
  late IconData _selectedIcon;
  late HabitFrequency _frequency;
  List<int> _selectedWeekDays = [];
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  final List<IconData> _icons = [
    Icons.fitness_center,
    Icons.menu_book,
    Icons.water_drop,
    Icons.bedtime,
    Icons.self_improvement,
    Icons.directions_run,
    Icons.restaurant,
    Icons.code,
    Icons.brush,
    Icons.music_note,
    Icons.language,
    Icons.savings,
    Icons.smoke_free,
    Icons.phone_disabled,
    Icons.favorite,
    Icons.wb_sunny,
  ];

  @override
  void initState() {
    super.initState();
    final habit = widget.habitToEdit;
    _nameController = TextEditingController(text: habit?.name ?? '');
    _descriptionController =
        TextEditingController(text: habit?.description ?? '');
    _selectedColor = habit?.color ?? AppTheme.habitColors[0];
    _selectedIcon = habit?.icon ?? Icons.check_circle_outline;
    _frequency = habit?.frequency ?? HabitFrequency.daily;
    _selectedWeekDays = habit?.weekDays ?? [];
    _reminderEnabled = habit?.reminderEnabled ?? false;
    _reminderTime = TimeOfDay(
      hour: habit?.reminderHour ?? 9,
      minute: habit?.reminderMinute ?? 0,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitToEdit != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'تعديل العادة' : 'إضافة عادة جديدة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  _buildLabel('اسم العادة'),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'مثال: قراءة كتاب',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildLabel('الوصف (اختياري)'),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'أضف وصفاً للعادة...',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Icon Selection
                  _buildLabel('الأيقونة'),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _icons.map((icon) {
                      final isSelected = icon == _selectedIcon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: _selectedColor, width: 2)
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Color Selection
                  _buildLabel('اللون'),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: AppTheme.habitColors.map((color) {
                      final isSelected = color == _selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Frequency
                  _buildLabel('التكرار'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildFrequencyOption(
                          'يومياً',
                          'كل يوم',
                          HabitFrequency.daily,
                        ),
                        const Divider(height: 1),
                        _buildFrequencyOption(
                          'أسبوعياً',
                          'أيام محددة من الأسبوع',
                          HabitFrequency.weekly,
                        ),
                      ],
                    ),
                  ),

                  // Week Days (if weekly)
                  if (_frequency == HabitFrequency.weekly) ...[
                    const SizedBox(height: 16),
                    _buildWeekDaySelector(),
                  ],
                  const SizedBox(height: 24),

                  // Reminder
                  _buildLabel('التذكير'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.notifications_active,
                                    color: Colors.orange),
                                SizedBox(width: 12),
                                Text(
                                  'تفعيل التذكير',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _reminderEnabled,
                              onChanged: (value) {
                                setState(() => _reminderEnabled = value);
                              },
                              activeColor: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                        if (_reminderEnabled) ...[
                          const Divider(),
                          GestureDetector(
                            onTap: _selectReminderTime,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('وقت التذكير'),
                                  Text(
                                    _reminderTime.format(context),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'حفظ التغييرات' : 'إضافة العادة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.mediumGray,
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(
      String title, String subtitle, HabitFrequency freq) {
    final isSelected = _frequency == freq;
    return GestureDetector(
      onTap: () => setState(() => _frequency = freq),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _selectedColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _selectedColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? _selectedColor : null,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    final days = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = _selectedWeekDays.contains(dayNum);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedWeekDays.remove(dayNum);
              } else {
                _selectedWeekDays.add(dayNum);
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? _selectedColor : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  void _saveHabit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم العادة')),
      );
      return;
    }

    final provider = context.read<HabitProvider>();

    if (widget.habitToEdit != null) {
      // Update existing habit
      final updated = widget.habitToEdit!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        frequency: _frequency,
        weekDays: _frequency == HabitFrequency.weekly ? _selectedWeekDays : null,
        reminderEnabled: _reminderEnabled,
        reminderHour: _reminderTime.hour,
        reminderMinute: _reminderTime.minute,
      );
      provider.updateHabit(updated);
    } else {
      // Add new habit
      provider.addHabit(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        icon: _selectedIcon,
        color: _selectedColor,
        frequency: _frequency,
        weekDays: _frequency == HabitFrequency.weekly ? _selectedWeekDays : null,
        reminderEnabled: _reminderEnabled,
        reminderHour: _reminderTime.hour,
        reminderMinute: _reminderTime.minute,
      );
    }

    Navigator.pop(context);
  }
}
