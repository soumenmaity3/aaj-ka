import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../data/challenge_database.dart';
import '../data/quest_database.dart';
import 'storage_service.dart';

enum ChallengeIntensity {
  casual('🌱 Casual', 10, '5m micro-habit'),
  standard('⚡ Standard', 25, '15m focused habit'),
  beast('🔥 Beast Mode', 50, '30m high-impact sprint');

  final String label;
  final int bonusMultiplierXp;
  final String description;
  const ChallengeIntensity(this.label, this.bonusMultiplierXp, this.description);
}

class LevelUpEvent {
  final int newLevel;
  final int totalXp;
  LevelUpEvent(this.newLevel, this.totalXp);
}

class AchievementUnlockedEvent {
  final Achievement achievement;
  AchievementUnlockedEvent(this.achievement);
}

class StreakShieldUsedEvent {
  final int currentStreak;
  StreakShieldUsedEvent(this.currentStreak);
}

class AppState extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  late UserProfile _profile;
  List<TaskItem> _tasks = [];
  List<Achievement> _achievements = [];
  List<QuestJourney> _journeys = [];
  DailyChallengeState? _dailyState;
  TaskItem? _todaySuggestedTask;

  // Challenge Intensity
  ChallengeIntensity _intensity = ChallengeIntensity.standard;

  // Interactive Live Focus Timer
  Timer? _countdownTimer;
  int _timerTotalSeconds = 0;
  int _timerRemainingSeconds = 0;
  bool _isTimerActive = false;
  bool _isTimerPaused = false;

  // Notification / Modal events
  LevelUpEvent? pendingLevelUp;
  AchievementUnlockedEvent? pendingAchievement;
  StreakShieldUsedEvent? pendingShieldUsed;
  bool showDailyAllCompletedCelebration = false;

  AppState(this._storage) {
    _loadState();
  }

  // Getters
  UserProfile get profile => _profile;
  List<TaskItem> get tasks => _tasks;
  List<Achievement> get achievements => _achievements;
  List<QuestJourney> get journeys => _journeys;
  DailyChallengeState? get dailyState => _dailyState;
  TaskItem? get todaySuggestedTask => _todaySuggestedTask;
  ChallengeIntensity get intensity => _intensity;

  // Timer Getters
  int get timerTotalSeconds => _timerTotalSeconds;
  int get timerRemainingSeconds => _timerRemainingSeconds;
  bool get isTimerActive => _isTimerActive;
  bool get isTimerPaused => _isTimerPaused;
  double get timerProgressFraction => _timerTotalSeconds > 0
      ? (_timerRemainingSeconds / _timerTotalSeconds).clamp(0.0, 1.0)
      : 0.0;

  QuestJourney get activeJourney {
    return _journeys.firstWhere(
      (j) => j.isEnrolled,
      orElse: () => _journeys.isNotEmpty ? _journeys.first : QuestDatabase.initialJourneys().first,
    );
  }

  String get todayDateStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  int get maxRerollsPerDay {
    if (_profile.level >= 10) return 4;
    if (_profile.level >= 5) return 3;
    return 2;
  }

  int get rerollsRemaining {
    if (_dailyState == null) return maxRerollsPerDay;
    return (maxRerollsPerDay - _dailyState!.rerollsUsed).clamp(0, maxRerollsPerDay);
  }

  /// Today's user tasks
  List<TaskItem> get todayUserTasks {
    final today = todayDateStr;
    return _tasks.where((t) {
      if (t.source == TaskSource.suggested) return false;
      if (t.recurring == RecurringSchedule.daily) return true;
      if (t.recurring == RecurringSchedule.weekly) {
        // Active on the same weekday
        final todayWeekday = DateTime.now().weekday;
        return t.createdAt.weekday == todayWeekday;
      }
      return t.scheduledDate == today;
    }).toList();
  }

  /// All active tasks for today including suggested challenge
  List<TaskItem> get allTodayTasks {
    final list = <TaskItem>[];
    if (_todaySuggestedTask != null) {
      list.add(_todaySuggestedTask!);
    }
    list.addAll(todayUserTasks);
    return list;
  }

  /// Today's completion count
  int get todayCompletedCount {
    int count = 0;
    if (_dailyState?.isCompleted == true) count++;
    count += todayUserTasks.where((t) => t.isCompleted).length;
    return count;
  }

  int get todayTotalTasksCount {
    int total = _todaySuggestedTask != null ? 1 : 0;
    total += todayUserTasks.length;
    return total;
  }

  /// Daily 1% Score
  int get todayEarnedScorePoints {
    int points = 0;
    if (_dailyState?.isCompleted == true && _todaySuggestedTask != null) {
      points += _todaySuggestedTask!.difficulty.points;
    }
    for (var t in todayUserTasks) {
      if (t.isCompleted) {
        points += t.difficulty.points;
      }
    }
    return points;
  }

  int get todayTotalScorePoints {
    int points = 0;
    if (_todaySuggestedTask != null) {
      points += _todaySuggestedTask!.difficulty.points;
    }
    for (var t in todayUserTasks) {
      points += t.difficulty.points;
    }
    return points == 0 ? 5 : points;
  }

  bool get isToday1PercentComplete {
    return todayCompletedCount > 0;
  }

  bool get areAllTodayGoalsDone {
    if (todayTotalTasksCount == 0) return false;
    return todayCompletedCount == todayTotalTasksCount;
  }

  // Initialization
  void _loadState() {
    _profile = _storage.getUserProfile();
    _tasks = _storage.getTasks();
    _achievements = _storage.getAchievements();
    _journeys = _storage.getJourneys();
    if (_journeys.isEmpty) {
      _journeys = QuestDatabase.initialJourneys();
      _storage.saveJourneys(_journeys);
    }

    _checkStreakIntegrity();
    _initDailyChallenge();
  }

  // Streak Verification
  void _checkStreakIntegrity() {
    final today = todayDateStr;
    final lastActive = _profile.lastActiveDate;

    if (lastActive.isEmpty) {
      return;
    }

    if (lastActive == today) {
      // Already active today, streak is safe
      return;
    }

    final now = DateTime.now();
    final todayDt = DateTime(now.year, now.month, now.day);
    final lastParts = lastActive.split('-').map(int.parse).toList();
    final lastDt = DateTime(lastParts[0], lastParts[1], lastParts[2]);

    final differenceInDays = todayDt.difference(lastDt).inDays;

    if (differenceInDays == 1) {
      // Last active was yesterday, streak holds until end of today
      return;
    } else if (differenceInDays > 1) {
      // Missed at least one day!
      if (_profile.streakShields > 0 && _profile.currentStreak > 0) {
        // Shield saves the streak!
        _profile.streakShields -= 1;
        pendingShieldUsed = StreakShieldUsedEvent(_profile.currentStreak);
        // Set last active to yesterday so streak can continue today
        final yesterday = todayDt.subtract(const Duration(days: 1));
        _profile.lastActiveDate = DateFormat('yyyy-MM-dd').format(yesterday);
        _storage.saveUserProfile(_profile);
      } else {
        // Streak resets gracefully
        _profile.currentStreak = 0;
        _storage.saveUserProfile(_profile);
      }
    }
  }

  // Daily Challenge Generation
  void _initDailyChallenge() {
    final today = todayDateStr;
    _dailyState = _storage.getDailyChallengeState(today);

    if (_dailyState == null) {
      // Recommend task for today: check active journey first
      TaskItem chosen;
      final active = activeJourney;
      final mission = active.currentMission;
      if (active.isEnrolled && mission != null && !mission.isCompleted) {
        chosen = mission.toTaskItem(today);
      } else {
        chosen = _recommendDailyChallenge();
      }

      _dailyState = DailyChallengeState(
        date: today,
        taskId: chosen.id,
        rerollsUsed: 0,
        isCompleted: false,
      );
      _storage.saveDailyChallengeState(_dailyState!);
      _todaySuggestedTask = chosen.copyWith(
        scheduledDate: today,
        source: TaskSource.suggested,
        isCompleted: false,
      );
    } else {
      // Load chosen task
      TaskItem found;
      final active = activeJourney;
      final mission = active.missions.cast<QuestMission?>().firstWhere(
            (m) => m?.toTaskItem(today).id == _dailyState!.taskId || 'quest_day_${m?.dayNumber}' == _dailyState!.taskId,
            orElse: () => null,
          );

      if (mission != null) {
        found = mission.toTaskItem(today);
      } else {
        found = ChallengeDatabase.allChallenges.firstWhere(
          (c) => c.id == _dailyState!.taskId,
          orElse: () => ChallengeDatabase.allChallenges.first,
        );
      }

      _todaySuggestedTask = found.copyWith(
        scheduledDate: today,
        source: TaskSource.suggested,
        isCompleted: _dailyState!.isCompleted,
      );
    }
    notifyListeners();
  }

  TaskItem _recommendDailyChallenge({String? excludeId}) {
    final all = ChallengeDatabase.allChallenges;
    final prefs = _profile.preferredCategories;

    // Filter by preferences first if available
    var candidates = all.where((c) {
      if (excludeId != null && c.id == excludeId) return false;
      return prefs.contains(c.category.name);
    }).toList();

    if (candidates.isEmpty) {
      candidates = all.where((c) => excludeId == null || c.id != excludeId).toList();
    }

    // Filter by user level
    // Levels 1-3: prefer Easy/Medium
    // Levels 4-7: Medium/Hard
    // Level 8+: Any including Epic
    if (_profile.level <= 3) {
      final easyMed = candidates.where((c) => c.difficulty == TaskDifficulty.easy || c.difficulty == TaskDifficulty.medium).toList();
      if (easyMed.isNotEmpty) candidates = easyMed;
    }

    final rand = Random();
    return candidates[rand.nextInt(candidates.length)];
  }

  // Reroll Daily Challenge
  bool rerollDailyChallenge() {
    if (rerollsRemaining <= 0 || _dailyState == null || _dailyState!.isCompleted) {
      return false;
    }

    _dailyState!.rerollsUsed += 1;
    final nextTask = _recommendDailyChallenge(excludeId: _dailyState!.taskId);
    _dailyState = DailyChallengeState(
      date: _dailyState!.date,
      taskId: nextTask.id,
      rerollsUsed: _dailyState!.rerollsUsed,
      isCompleted: false,
    );
    _todaySuggestedTask = nextTask.copyWith(
      scheduledDate: todayDateStr,
      source: TaskSource.suggested,
      isCompleted: false,
    );

    _storage.saveDailyChallengeState(_dailyState!);
    notifyListeners();
    return true;
  }

  // Surprise Me 🎲
  TaskItem generateSurpriseChallenge() {
    final all = ChallengeDatabase.allChallenges;
    final rand = Random();
    return all[rand.nextInt(all.length)];
  }

  void setSurpriseChallengeAsToday(TaskItem surprise) {
    if (_dailyState != null && _dailyState!.isCompleted) return;

    _dailyState = DailyChallengeState(
      date: todayDateStr,
      taskId: surprise.id,
      rerollsUsed: _dailyState?.rerollsUsed ?? 0,
      isCompleted: false,
    );
    _todaySuggestedTask = surprise.copyWith(
      scheduledDate: todayDateStr,
      source: TaskSource.suggested,
      isCompleted: false,
    );
    _storage.saveDailyChallengeState(_dailyState!);
    notifyListeners();
  }

  // Task Completion Handler
  void toggleSuggestedChallenge() {
    if (_dailyState == null || _todaySuggestedTask == null) return;
    if (_dailyState!.isCompleted) return; // Anti-abuse: once completed, stay completed

    _dailyState!.isCompleted = true;
    _todaySuggestedTask!.isCompleted = true;
    _todaySuggestedTask!.completedAt = DateTime.now();

    // Advance active Quest Journey if applicable
    final active = activeJourney;
    if (active.isEnrolled && active.currentMission != null) {
      final mission = active.currentMission!;
      mission.isCompleted = true;
      mission.completedAt = DateTime.now();
      if (active.currentDay < active.totalDays) {
        active.currentDay += 1;
      } else {
        active.isCompleted = true;
      }
      _storage.saveJourneys(_journeys);
    }

    // Stop timer if it was running
    resetTimer();

    // Bonus XP for suggested daily challenge (+10 bonus on top of task XP + intensity bonus)
    final intensityBonus = _intensity.bonusMultiplierXp - 25;
    final bonusXp = 10 + (intensityBonus > 0 ? intensityBonus : 0);
    final earnedXp = _todaySuggestedTask!.xp + bonusXp;

    _storage.saveDailyChallengeState(_dailyState!);
    _onTaskCompleted(earnedXp);
  }

  void toggleUserTask(TaskItem task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx == -1) return;

    final current = _tasks[idx];
    if (current.isCompleted) {
      // Toggle off (does not deduct lifetime XP to prevent negative exploits)
      current.isCompleted = false;
      current.completedAt = null;
      _storage.saveTasks(_tasks);
      notifyListeners();
      return;
    }

    current.isCompleted = true;
    current.completedAt = DateTime.now();
    _storage.saveTasks(_tasks);

    _onTaskCompleted(current.xp);
  }

  void _onTaskCompleted(int earnedXp) {
    final today = todayDateStr;

    // 1. Update Streak
    if (_profile.lastActiveDate != today) {
      _profile.currentStreak += 1;
      if (_profile.currentStreak > _profile.longestStreak) {
        _profile.longestStreak = _profile.currentStreak;
      }
      _profile.lastActiveDate = today;
      if (!_profile.activeDates.contains(today)) {
        _profile.activeDates.add(today);
      }

      // 7-Day streak reward: +1 Streak Shield & +100 bonus XP!
      if (_profile.currentStreak % 7 == 0) {
        _profile.streakShields += 1;
        earnedXp += 100;
      }
    }

    // 2. Increment Counters
    _profile.totalTasksCompleted += 1;

    // 3. Daily All Goals Complete Bonus (+50 XP)
    if (areAllTodayGoalsDone && !_dailyStateBonusClaimedToday()) {
      earnedXp += 50;
      if (_dailyState != null) {
        _dailyState!.bonusXpClaimed = true;
        _storage.saveDailyChallengeState(_dailyState!);
      }
      showDailyAllCompletedCelebration = true;
    }

    // 4. Add XP and check Level Up
    _addXp(earnedXp);

    // 5. Check Achievements
    _checkAchievements();

    _storage.saveUserProfile(_profile);
    notifyListeners();
  }

  bool _dailyStateBonusClaimedToday() {
    return _dailyState?.bonusXpClaimed == true;
  }

  void markAllCompletedBonusCelebrated() {
    showDailyAllCompletedCelebration = false;
    if (_dailyState != null) {
      _dailyState!.bonusXpClaimed = true;
      _storage.saveDailyChallengeState(_dailyState!);
    }
    notifyListeners();
  }

  void _addXp(int amount) {
    _profile.xp += amount;
    // Check level progression
    int currentLevel = _profile.level;
    while (_profile.xp >= UserProfile.xpForLevel(currentLevel + 1)) {
      currentLevel++;
    }

    if (currentLevel > _profile.level) {
      _profile.level = currentLevel;
      pendingLevelUp = LevelUpEvent(_profile.level, _profile.xp);
    }
  }

  void clearLevelUpEvent() {
    pendingLevelUp = null;
    notifyListeners();
  }

  void clearShieldUsedEvent() {
    pendingShieldUsed = null;
    notifyListeners();
  }

  void clearAchievementEvent() {
    pendingAchievement = null;
    notifyListeners();
  }

  // Achievement Check Engine
  void _checkAchievements() {
    for (var ach in _achievements) {
      if (ach.isUnlocked) continue;

      bool shouldUnlock = false;
      switch (ach.requirementType) {
        case 'tasks_count':
          if (_profile.totalTasksCompleted >= ach.requirementValue) {
            shouldUnlock = true;
          }
          break;
        case 'streak':
          if (_profile.currentStreak >= ach.requirementValue) {
            shouldUnlock = true;
          }
          break;
        case 'level':
          if (_profile.level >= ach.requirementValue) {
            shouldUnlock = true;
          }
          break;
        case 'xp':
          if (_profile.xp >= ach.requirementValue) {
            shouldUnlock = true;
          }
          break;
      }

      if (shouldUnlock) {
        ach.isUnlocked = true;
        ach.unlockedAt = DateTime.now();
        _addXp(ach.bonusXp);
        pendingAchievement = AchievementUnlockedEvent(ach);
      }
    }
    _storage.saveAchievements(_achievements);
  }

  // User Task Operations
  void addUserTask({
    required String title,
    String description = '',
    required TaskCategory category,
    required TaskDifficulty difficulty,
    required RecurringSchedule recurring,
    int durationMinutes = 15,
  }) {
    final newTask = TaskItem(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      difficulty: difficulty,
      xp: difficulty.xp,
      durationMinutes: durationMinutes,
      source: TaskSource.user,
      recurring: recurring,
      scheduledDate: todayDateStr,
      isCompleted: false,
    );

    _tasks.insert(0, newTask);
    _storage.saveTasks(_tasks);
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    _storage.saveTasks(_tasks);
    notifyListeners();
  }

  // Add explored challenge to user's daily tasks
  void addChallengeToToday(TaskItem challenge) {
    final newTask = TaskItem(
      id: _uuid.v4(),
      title: challenge.title,
      description: challenge.description,
      category: challenge.category,
      difficulty: challenge.difficulty,
      xp: challenge.xp,
      durationMinutes: challenge.durationMinutes,
      source: TaskSource.user,
      recurring: RecurringSchedule.todayOnly,
      scheduledDate: todayDateStr,
      isCompleted: false,
    );

    _tasks.insert(0, newTask);
    _storage.saveTasks(_tasks);
    notifyListeners();
  }

  // Profile Updates
  void updateProfile({
    String? username,
    String? avatar,
    List<String>? preferredCategories,
    int? dailyMinutesBudget,
  }) {
    if (username != null) _profile.username = username.trim();
    if (avatar != null) _profile.avatar = avatar;
    if (preferredCategories != null) _profile.preferredCategories = preferredCategories;
    if (dailyMinutesBudget != null) _profile.dailyMinutesBudget = dailyMinutesBudget;

    _storage.saveUserProfile(_profile);
    notifyListeners();
  }

  // Weekly review calculations
  Map<String, dynamic> getWeeklyReviewData() {
    final now = DateTime.now();
    int weekTasks = 0;
    int weekXp = 0;
    final categoryCounts = <String, int>{};
    final activeDaysThisWeek = <int>{};

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dayStr = DateFormat('yyyy-MM-dd').format(day);
      if (_profile.activeDates.contains(dayStr)) {
        activeDaysThisWeek.add(day.weekday);
      }
    }

    for (var t in _tasks) {
      if (t.isCompleted && t.completedAt != null) {
        if (now.difference(t.completedAt!).inDays <= 7) {
          weekTasks++;
          weekXp += t.xp;
          categoryCounts[t.category.label] = (categoryCounts[t.category.label] ?? 0) + 1;
        }
      }
    }

    if (_dailyState?.isCompleted == true && _todaySuggestedTask != null) {
      weekTasks++;
      weekXp += _todaySuggestedTask!.xp + 10;
      categoryCounts[_todaySuggestedTask!.category.label] =
          (categoryCounts[_todaySuggestedTask!.category.label] ?? 0) + 1;
    }

    String bestCategory = 'Mindfulness';
    int maxCount = 0;
    categoryCounts.forEach((cat, count) {
      if (count > maxCount) {
        maxCount = count;
        bestCategory = cat;
      }
    });

    return {
      'weekTasks': weekTasks,
      'weekXp': weekXp,
      'activeDaysCount': activeDaysThisWeek.length,
      'bestCategory': bestCategory,
      'percentage': ((activeDaysThisWeek.length / 7) * 100).round(),
    };
  }

  // Challenge Intensity Switcher
  void setIntensity(ChallengeIntensity level) {
    _intensity = level;
    notifyListeners();
  }

  // Quest Journey Enrollment
  void enrollInJourney(String journeyId) {
    for (var j in _journeys) {
      j.isEnrolled = (j.id == journeyId);
    }
    _storage.saveJourneys(_journeys);

    // If today's challenge hasn't been completed yet, update it to the newly enrolled quest mission
    if (_dailyState != null && !_dailyState!.isCompleted) {
      final active = activeJourney;
      final mission = active.currentMission;
      if (mission != null && !mission.isCompleted) {
        final task = mission.toTaskItem(todayDateStr);
        _dailyState = DailyChallengeState(
          date: todayDateStr,
          taskId: task.id,
          rerollsUsed: _dailyState!.rerollsUsed,
          isCompleted: false,
        );
        _todaySuggestedTask = task;
        _storage.saveDailyChallengeState(_dailyState!);
      }
    }
    notifyListeners();
  }

  // Interactive Live Focus Timer
  void startTimer({int? minutes}) {
    final mins = minutes ?? _todaySuggestedTask?.durationMinutes ?? 10;
    _countdownTimer?.cancel();
    _timerTotalSeconds = (mins * 60).clamp(60, 7200);
    _timerRemainingSeconds = _timerTotalSeconds;
    _isTimerActive = true;
    _isTimerPaused = false;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerPaused && _timerRemainingSeconds > 0) {
        _timerRemainingSeconds--;
        notifyListeners();
        if (_timerRemainingSeconds == 0) {
          timer.cancel();
          _isTimerActive = false;
          // Auto complete the challenge when timer hits 0!
          toggleSuggestedChallenge();
        }
      }
    });
  }

  void pauseTimer() {
    _isTimerPaused = true;
    notifyListeners();
  }

  void resumeTimer() {
    _isTimerPaused = false;
    notifyListeners();
  }

  void resetTimer() {
    _countdownTimer?.cancel();
    _isTimerActive = false;
    _isTimerPaused = false;
    _timerRemainingSeconds = 0;
    _timerTotalSeconds = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // Reset/Guest Mode
  Future<void> resetAllData() async {
    resetTimer();
    await _storage.clearAll();
    _loadState();
  }
}
