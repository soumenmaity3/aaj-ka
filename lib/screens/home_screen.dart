import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/celebration_dialogs.dart';
import 'create_task_bottom_sheet.dart';
import '../widgets/home_mission_control_widget.dart';

class HomeScreen extends StatelessWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _checkAndTriggerEvents(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.pendingLevelUp != null) {
        final ev = appState.pendingLevelUp!;
        appState.clearLevelUpEvent();
        CelebrationHelper.showLevelUpDialog(context, ev.newLevel, ev.totalXp);
      } else if (appState.pendingAchievement != null) {
        final ev = appState.pendingAchievement!;
        appState.clearAchievementEvent();
        CelebrationHelper.showAchievementDialog(context, ev.achievement);
      } else if (appState.pendingShieldUsed != null) {
        final ev = appState.pendingShieldUsed!;
        appState.clearShieldUsedEvent();
        CelebrationHelper.showStreakShieldUsedDialog(context, ev.currentStreak);
      } else if (appState.showDailyAllCompletedCelebration) {
        appState.markAllCompletedBonusCelebrated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Row(
              children: const [
                Text('🎉', style: TextStyle(fontSize: 22)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Aaj ka 1% complete! +50 Daily Bonus XP earned 🌱',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _checkAndTriggerEvents(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = appState.profile;
    final suggested = appState.todaySuggestedTask;
    final userTasks = appState.todayUserTasks;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Re-render check
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Greeting & Quick Profile info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, ${profile.username} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ready for today\'s 1%?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSubDark
                                : AppColors.textSubLight,
                          ),
                        ),
                      ],
                    ),
                    // Quick Streak Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.streakFireLight.withValues(
                          alpha: 0.35,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.streakFire.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 5),
                          Text(
                            '${profile.currentStreak}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.streakFireDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Level & 1% Daily Score Bar
                _buildProgressCard(context, profile, isDark),
                const SizedBox(height: 22),

                // Section Title: AajKa Challenge
                Row(
                  children: [
                    const Text(
                      '✨ AajKa Challenge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    // Surprise Me Button
                    InkWell(
                      onTap: () {
                        final surprise = appState.generateSurpriseChallenge();
                        CelebrationHelper.showSurpriseMeDialog(
                          context: context,
                          surpriseTask: surprise,
                          onAcceptAsToday: () {
                            appState.setSurpriseChallengeAsToday(surprise);
                          },
                          onRerollAnother: () {
                            final another = appState
                                .generateSurpriseChallenge();
                            CelebrationHelper.showSurpriseMeDialog(
                              context: context,
                              surpriseTask: another,
                              onAcceptAsToday: () {
                                appState.setSurpriseChallengeAsToday(another);
                              },
                              onRerollAnother: () {},
                            );
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.streakFireLight.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Text('🎲', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              'Surprise Me',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.streakFireDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Suggested Challenge / Mission Control Widget
                if (suggested != null)
                  HomeMissionControlWidget(appState: appState),
                const SizedBox(height: 28),

                // Section Title: My Tasks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '👤 My Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          CreateTaskBottomSheet.show(context, appState),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Create My Task',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // User Tasks List or Empty State
                if (userTasks.isEmpty)
                  _buildEmptyUserTasksState(context, isDark)
                else
                  ...userTasks.map(
                    (t) => _buildUserTaskItem(context, t, isDark),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    UserProfile profile,
    bool isDark,
  ) {
    final todayCount = appState.todayCompletedCount;
    final totalCount = appState.todayTotalTasksCount;
    final scoreEarned = appState.todayEarnedScorePoints;
    final scoreTotal = appState.todayTotalScorePoints;
    final isDone = appState.isToday1PercentComplete;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Level progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Level ${profile.level}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${profile.currentLevelXp} / ${profile.neededForNextLevel} XP',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                    ),
                  ),
                ],
              ),
              Text(
                '${(profile.levelProgress * 100).toInt()}% to Lvl ${profile.level + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textSubDark
                      : AppColors.textSubLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: profile.levelProgress,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Daily 1% completion indicator & Encouragement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isDone ? '🎉 Aaj ka 1% complete!' : 'Today\'s 1% Goal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDone ? AppColors.primaryDark : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDone
                        ? '“Aaj tumne khud ko 1% better banaya.”'
                        : 'Bas ek chhota step to keep going.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSubDark
                          : AppColors.textSubLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgDark : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$todayCount / $totalCount done',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Score: $scoreEarned/$scoreTotal',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserTaskItem(BuildContext context, TaskItem task, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.primary.withValues(alpha: 0.5)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          InkWell(
            onTap: () => appState.toggleUserTask(task),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  width: 1.8,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Title & metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted
                        ? (isDark
                              ? AppColors.textSubDark
                              : AppColors.textSubLight)
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${task.category.emoji} ${task.category.label}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? AppColors.textSubDark
                            : AppColors.textSubLight,
                      ),
                    ),
                    if (task.recurring != RecurringSchedule.todayOnly) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• ${task.recurring.label}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.streakFireDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // XP Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDark : AppColors.bgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${task.xp} XP',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.streakFireDark,
              ),
            ),
          ),

          // Delete icon
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: Colors.grey,
            visualDensity: VisualDensity.compact,
            onPressed: () => appState.deleteTask(task.id),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUserTasksState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          const Text(
            'Nothing here yet.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Start with one tiny step. Add your own task or accept today\'s challenge.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => CreateTaskBottomSheet.show(context, appState),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('+ Create My Task'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
