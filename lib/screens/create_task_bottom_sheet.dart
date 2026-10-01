import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class CreateTaskBottomSheet extends StatefulWidget {
  final AppState appState;

  const CreateTaskBottomSheet({super.key, required this.appState});

  static void show(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateTaskBottomSheet(appState: appState),
    );
  }

  @override
  State<CreateTaskBottomSheet> createState() => _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends State<CreateTaskBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TaskCategory _category = TaskCategory.learning;
  TaskDifficulty _difficulty = TaskDifficulty.medium;
  RecurringSchedule _recurring = RecurringSchedule.todayOnly;

  @override
  void initState() {
    super.initState();
    // Auto focus on open for lightning-fast input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.appState.addUserTask(
      title: title,
      category: _category,
      difficulty: _difficulty,
      recurring: _recurring,
      durationMinutes: _difficulty == TaskDifficulty.easy
          ? 5
          : (_difficulty == TaskDifficulty.medium ? 15 : 30),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Personal Task',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Task Input
          TextField(
            controller: _titleController,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'e.g., Study Flutter for 30 minutes',
              hintStyle: TextStyle(
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
              ),
              prefixIcon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
              filled: true,
              fillColor: isDark ? AppColors.bgDark : AppColors.bgLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Difficulty & XP chips
          Row(
            children: [
              const Text(
                'Difficulty:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              ...TaskDifficulty.values.take(3).map((diff) {
                final isSelected = _difficulty == diff;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${diff.label} (+${diff.xp} XP)'),
                    selected: isSelected,
                    selectedColor: Color(diff.colorValue).withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Color(diff.colorValue)
                          : (isDark ? Colors.white70 : AppColors.textSubLight),
                    ),
                    side: BorderSide(
                      color: isSelected ? Color(diff.colorValue) : Colors.transparent,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _difficulty = diff);
                    },
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),

          // Category Selector (horizontal)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: TaskCategory.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (ctx, i) {
                final cat = TaskCategory.values[i];
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text('${cat.emoji} ${cat.label}'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryLight,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryDark
                        : (isDark ? Colors.white70 : AppColors.textSubLight),
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _category = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Frequency / Schedule options
          Row(
            children: RecurringSchedule.values.map((sched) {
              final isSelected = _recurring == sched;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(sched.label),
                  selected: isSelected,
                  selectedColor: AppColors.streakFireLight,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.streakFireDark
                        : (isDark ? Colors.white70 : AppColors.textSubLight),
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.streakFire : Colors.transparent,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _recurring = sched);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Add Task CTA button
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 20),
                SizedBox(width: 8),
                Text('Add Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
