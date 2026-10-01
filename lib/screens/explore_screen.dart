import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/challenge_database.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  final AppState appState;

  const ExploreScreen({super.key, required this.appState});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  TaskCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Explore Challenges'),
        actions: [
          if (_selectedCategory != null)
            TextButton(
              onPressed: () => setState(() => _selectedCategory = null),
              child: const Text('Show All'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category horizontal filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TaskCategory.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final cat = TaskCategory.values[i];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text('${cat.emoji} ${cat.label}'),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryDark
                            : (isDark ? Colors.white70 : AppColors.textMainLight),
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedCategory = val ? cat : null;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Challenges List
            Expanded(
              child: _buildChallengesList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesList(bool isDark) {
    var list = ChallengeDatabase.allChallenges;
    if (_selectedCategory != null) {
      list = list.where((c) => c.category == _selectedCategory).toList();
    }

    final userLevel = widget.appState.profile.level;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final challenge = list[i];
        // Check level unlock requirement
        int requiredLevel = 1;
        if (challenge.difficulty == TaskDifficulty.hard) requiredLevel = 4;
        if (challenge.difficulty == TaskDifficulty.epic) requiredLevel = 8;

        final isLocked = userLevel < requiredLevel;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(challenge.category.colorValue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(challenge.category.emoji, style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          challenge.category.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(challenge.category.colorValue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(challenge.difficulty.colorValue).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      challenge.difficulty.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(challenge.difficulty.colorValue),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // XP & Duration
                  Text(
                    '${challenge.durationMinutes}m • +${challenge.xp} XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                challenge.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              if (challenge.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (isLocked)
                Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Unlocks at Level $requiredLevel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add to Today'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        widget.appState.addChallengeToToday(challenge);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added "${challenge.title}" to My Tasks! 🌱'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
