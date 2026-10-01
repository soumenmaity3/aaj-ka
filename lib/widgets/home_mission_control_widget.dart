import 'package:flutter/material.dart';
import 'dart:math';
import '../services/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class HomeMissionControlWidget extends StatelessWidget {
  final AppState appState;

  const HomeMissionControlWidget({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final suggested = appState.todaySuggestedTask;
    if (suggested == null) return const SizedBox();

    final isCompleted = suggested.isCompleted;
    final active = appState.activeJourney;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isCompleted ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: Quest Badge & Intensity Dial
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (active.isEnrolled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(active.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'Day ${min(active.currentDay, active.totalDays)} of ${active.totalDays} • ${active.title}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text(
                  'Daily Challenge',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

              // Intensity Dial
              PopupMenuButton<ChallengeIntensity>(
                initialValue: appState.intensity,
                onSelected: (val) => appState.setIntensity(val),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgDark : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appState.intensity.label.split(' ')[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 14),
                    ],
                  ),
                ),
                itemBuilder: (context) =>
                    ChallengeIntensity.values.map((intensity) {
                      return PopupMenuItem(
                        value: intensity,
                        child: Text(intensity.label),
                      );
                    }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Core Challenge Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(
                    suggested.category.colorValue,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      suggested.category.emoji,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      suggested.category.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(suggested.category.colorValue),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // XP Badge with Bonus
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.streakFireLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.streakFireDark,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+${suggested.xp + 10 + (appState.intensity.bonusMultiplierXp - 25 > 0 ? appState.intensity.bonusMultiplierXp - 25 : 0)} XP',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.streakFireDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            suggested.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.primary,
            ),
          ),
          if (suggested.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              suggested.description,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                height: 1.35,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Focus Timer Area
          if (!isCompleted)
            _buildTimerSection(context, isDark)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mission Accomplished! 🔥',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (active.isEnrolled) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            _buildRoadmap(context, active, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerSection(BuildContext context, bool isDark) {
    String formatTime(int seconds) {
      int m = seconds ~/ 60;
      int s = seconds % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    final rerolls = appState.rerollsRemaining;

    return Column(
      children: [
        if (appState.isTimerActive)
          Row(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: appState.timerProgressFraction,
                      strokeWidth: 6,
                      backgroundColor: isDark
                          ? AppColors.bgDark
                          : AppColors.bgLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        formatTime(appState.timerRemainingSeconds),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.isTimerPaused ? 'Paused' : 'Focus Mode Active',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            appState.isTimerPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryLight.withValues(
                              alpha: 0.3,
                            ),
                            foregroundColor: AppColors.primaryDark,
                          ),
                          onPressed: () {
                            if (appState.isTimerPaused) {
                              appState.resumeTimer();
                            } else {
                              appState.pauseTimer();
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.stop_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            foregroundColor: Colors.red,
                          ),
                          onPressed: () => appState.resetTimer(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => appState.startTimer(),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text(
                    'Start Timer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Complete manually button
              OutlinedButton(
                onPressed: () => appState.toggleSuggestedChallenge(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              if (!appState.activeJourney.isEnrolled) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: rerolls > 0
                      ? () => appState.rerollDailyChallenge()
                      : null,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text('$rerolls'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildRoadmap(BuildContext context, QuestJourney active, bool isDark) {
    // Show current day and next 4 days
    final startDay = max(
      1,
      active.currentDay - 1,
    ); // 1 before current if possible
    final daysToShow = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Roadmap',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(daysToShow, (index) {
            final day = startDay + index;
            if (day > active.totalDays) return const SizedBox();

            final isPast = day < active.currentDay;
            final isCurrent = day == active.currentDay;

            return Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPast
                        ? AppColors.primary
                        : (isCurrent
                              ? AppColors.primaryLight
                              : (isDark
                                    ? AppColors.bgDark
                                    : AppColors.bgLight)),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isPast
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? AppColors.primaryDark
                                  : (isDark ? Colors.white54 : Colors.black54),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                // Milestone indicator
                if (day % 7 == 0)
                  const Text('🎁', style: TextStyle(fontSize: 10))
                else
                  const SizedBox(height: 12), // Placeholder to keep alignment
              ],
            );
          }),
        ),
      ],
    );
  }
}
