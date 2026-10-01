import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aaj_ka/models/models.dart';
import 'package:aaj_ka/services/storage_service.dart';
import 'package:aaj_ka/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AajKa 1% Core Engine Tests', () {
    test('XP and Level progression math', () {
      // Level 1 starts at 0
      expect(UserProfile.xpForLevel(1), 0);
      // Level 2 requires 100 XP
      expect(UserProfile.xpForLevel(2), 100);
      // Level 3 requires 250 XP
      expect(UserProfile.xpForLevel(3), 250);
      // Level 4 requires 450 XP
      expect(UserProfile.xpForLevel(4), 450);

      final profile = UserProfile(
        id: 'test_user',
        level: 1,
        xp: 50,
      );

      expect(profile.currentLevelXp, 50);
      expect(profile.neededForNextLevel, 100);
      expect(profile.levelProgress, 0.5);
    });

    test('TaskItem serialization', () {
      final task = TaskItem(
        id: 'task_123',
        title: 'Read 5 pages',
        category: TaskCategory.learning,
        difficulty: TaskDifficulty.medium,
        scheduledDate: '2026-09-15',
        recurring: RecurringSchedule.daily,
      );

      final map = task.toMap();
      final restored = TaskItem.fromMap(map);

      expect(restored.id, 'task_123');
      expect(restored.title, 'Read 5 pages');
      expect(restored.category, TaskCategory.learning);
      expect(restored.difficulty, TaskDifficulty.medium);
      expect(restored.xp, 25);
      expect(restored.recurring, RecurringSchedule.daily);
    });

    test('AppState daily challenge and user task completion awards XP and streak', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final appState = AppState(storage);

      expect(appState.profile.level, 1);
      expect(appState.profile.currentStreak, 0);

      // Complete suggested daily challenge
      expect(appState.todaySuggestedTask, isNotNull);
      final initialSuggestedXp = appState.todaySuggestedTask!.xp;

      appState.toggleSuggestedChallenge();

      expect(appState.dailyState?.isCompleted, true);
      expect(appState.todaySuggestedTask?.isCompleted, true);
      // initialSuggestedXp + 10 (suggested bonus) + 50 (achievement) + 50 (all goals done) = +110
      expect(appState.profile.xp, initialSuggestedXp + 110);
      expect(appState.profile.currentStreak, 1);
      expect(appState.profile.totalTasksCompleted, 1);

      // Add user task and complete it
      appState.addUserTask(
        title: 'Walk 15 minutes',
        category: TaskCategory.health,
        difficulty: TaskDifficulty.easy,
        recurring: RecurringSchedule.todayOnly,
      );

      expect(appState.todayUserTasks.length, 1);
      final userTask = appState.todayUserTasks.first;

      appState.toggleUserTask(userTask);

      expect(userTask.isCompleted, true);
      // +10 XP for easy task (all goals bonus was already claimed today)
      expect(appState.profile.xp, initialSuggestedXp + 110 + 10);
      expect(appState.isToday1PercentComplete, true);
    });

    test('Reroll daily challenge decreases remaining quota', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final appState = AppState(storage);

      expect(appState.rerollsRemaining, 2);

      final didReroll = appState.rerollDailyChallenge();
      expect(didReroll, true);
      expect(appState.rerollsRemaining, 1);

      final didReroll2 = appState.rerollDailyChallenge();
      expect(didReroll2, true);
      expect(appState.rerollsRemaining, 0);

      // 3rd attempt should fail as quota is exhausted
      final didReroll3 = appState.rerollDailyChallenge();
      expect(didReroll3, false);
    });

    test('Streak Shield protects missed day without resetting streak', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      // Setup user with 5-day streak, 1 shield, last active 2 days ago
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoStr = "${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2, '0')}-${twoDaysAgo.day.toString().padLeft(2, '0')}";

      final initialProfile = UserProfile(
        id: 'test_shield_user',
        currentStreak: 5,
        longestStreak: 5,
        streakShields: 1,
        lastActiveDate: twoDaysAgoStr,
      );
      await storage.saveUserProfile(initialProfile);

      // Loading app state checks streak integrity
      final appState = AppState(storage);

      expect(appState.profile.streakShields, 0); // Shield consumed
      expect(appState.profile.currentStreak, 5); // Streak preserved!
      expect(appState.pendingShieldUsed, isNotNull); // Event fired
      expect(appState.pendingShieldUsed!.currentStreak, 5);
    });

    test('Level Up event fires when XP crosses threshold', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final appState = AppState(storage);

      expect(appState.profile.level, 1);
      expect(appState.pendingLevelUp, isNull);

      // Add task with hard difficulty (50 XP) and complete
      appState.addUserTask(
        title: 'Hard Workout',
        category: TaskCategory.health,
        difficulty: TaskDifficulty.epic, // 100 XP
        recurring: RecurringSchedule.todayOnly,
      );

      final task = appState.todayUserTasks.first;
      appState.toggleUserTask(task);

      // User gets 50 XP (task) + 50 XP (achievement First Step) = 100 XP -> crosses Level 2 threshold (100 XP)
      expect(appState.profile.level >= 2, true);
      expect(appState.pendingLevelUp, isNotNull);
      expect(appState.pendingLevelUp!.newLevel >= 2, true);
    });

    test('Weekly review data calculations', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final appState = AppState(storage);

      final weekly = appState.getWeeklyReviewData();
      expect(weekly.containsKey('weekTasks'), true);
      expect(weekly.containsKey('weekXp'), true);
      expect(weekly.containsKey('activeDaysCount'), true);
      expect(weekly.containsKey('bestCategory'), true);
      expect(weekly.containsKey('percentage'), true);
    });
  });
}
