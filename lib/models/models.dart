/// Categories for daily challenges and tasks
enum TaskCategory {
  learning('Learning', '📚', 0xFF3B82F6),
  health('Health', '💪', 0xFF10B981),
  mindfulness('Mindfulness', '🧘', 0xFF8B5CF6),
  relationships('Relationships', '❤️', 0xFFEC4899),
  money('Money', '💰', 0xFFF59E0B),
  productivity('Productivity', '⚡', 0xFF06B6D4),
  career('Career', '💼', 0xFF6366F1),
  digitalWellbeing('Digital Wellbeing', '📱', 0xFF14B8A6),
  creativity('Creativity', '🎨', 0xFFF97316),
  personalLife('Personal Life', '🧹', 0xFF84CC16),
  growth('Personal Growth', '🌱', 0xFF10B981),
  kindness('Kindness', '🤝', 0xFFE11D48);

  final String label;
  final String emoji;
  final int colorValue;

  const TaskCategory(this.label, this.emoji, this.colorValue);

  static TaskCategory fromString(String name) {
    return TaskCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase() || e.label.toLowerCase() == name.toLowerCase(),
      orElse: () => TaskCategory.growth,
    );
  }
}

/// Difficulty levels and their corresponding XP and 1% points
enum TaskDifficulty {
  easy('Easy', 10, 1, 0xFF10B981),
  medium('Medium', 25, 2, 0xFF3B82F6),
  hard('Hard', 50, 3, 0xFFF59E0B),
  epic('Epic', 100, 5, 0xFF8B5CF6);

  final String label;
  final int xp;
  final int points;
  final int colorValue;

  const TaskDifficulty(this.label, this.xp, this.points, this.colorValue);

  static TaskDifficulty fromString(String name) {
    return TaskDifficulty.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase() || e.label.toLowerCase() == name.toLowerCase(),
      orElse: () => TaskDifficulty.medium,
    );
  }
}

/// Source of the task
enum TaskSource {
  suggested,
  user,
}

/// Recurring frequency for custom tasks
enum RecurringSchedule {
  todayOnly('Today only'),
  daily('Daily'),
  weekly('Weekly');

  final String label;
  const RecurringSchedule(this.label);

  static RecurringSchedule fromString(String name) {
    return RecurringSchedule.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase(),
      orElse: () => RecurringSchedule.todayOnly,
    );
  }
}

/// A task item (either daily suggested or user created)
class TaskItem {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskDifficulty difficulty;
  final int xp;
  final int durationMinutes;
  final TaskSource source;
  final RecurringSchedule recurring;
  final DateTime createdAt;
  final String scheduledDate; // YYYY-MM-DD
  bool isCompleted;
  DateTime? completedAt;

  TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.difficulty,
    int? xp,
    this.durationMinutes = 10,
    this.source = TaskSource.user,
    this.recurring = RecurringSchedule.todayOnly,
    DateTime? createdAt,
    required this.scheduledDate,
    this.isCompleted = false,
    this.completedAt,
  })  : xp = xp ?? difficulty.xp,
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'difficulty': difficulty.name,
      'xp': xp,
      'durationMinutes': durationMinutes,
      'source': source.name,
      'recurring': recurring.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDate': scheduledDate,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    final diff = TaskDifficulty.fromString(map['difficulty'] ?? 'medium');
    return TaskItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: TaskCategory.fromString(map['category'] ?? 'growth'),
      difficulty: diff,
      xp: map['xp'] is int ? map['xp'] : diff.xp,
      durationMinutes: map['durationMinutes'] is int ? map['durationMinutes'] : 10,
      source: (map['source'] == 'suggested') ? TaskSource.suggested : TaskSource.user,
      recurring: RecurringSchedule.fromString(map['recurring'] ?? 'todayOnly'),
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      scheduledDate: map['scheduledDate'] ?? '',
      isCompleted: map['isCompleted'] == true,
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt']) : null,
    );
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskDifficulty? difficulty,
    int? xp,
    int? durationMinutes,
    TaskSource? source,
    RecurringSchedule? recurring,
    DateTime? createdAt,
    String? scheduledDate,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      xp: xp ?? this.xp,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      source: source ?? this.source,
      recurring: recurring ?? this.recurring,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Daily challenge recommendation state
class DailyChallengeState {
  final String date; // YYYY-MM-DD
  final String taskId;
  int rerollsUsed;
  bool isCompleted;
  bool bonusXpClaimed;

  DailyChallengeState({
    required this.date,
    required this.taskId,
    this.rerollsUsed = 0,
    this.isCompleted = false,
    this.bonusXpClaimed = false,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'taskId': taskId,
        'rerollsUsed': rerollsUsed,
        'isCompleted': isCompleted,
        'bonusXpClaimed': bonusXpClaimed,
      };

  factory DailyChallengeState.fromMap(Map<String, dynamic> map) => DailyChallengeState(
        date: map['date'] ?? '',
        taskId: map['taskId'] ?? '',
        rerollsUsed: map['rerollsUsed'] ?? 0,
        isCompleted: map['isCompleted'] == true,
        bonusXpClaimed: map['bonusXpClaimed'] == true,
      );
}

/// User profile and gamification progression
class UserProfile {
  String id;
  String username;
  String avatar;
  int level;
  int xp;
  int currentStreak;
  int longestStreak;
  int streakShields;
  int totalTasksCompleted;
  List<String> preferredCategories;
  int dailyMinutesBudget;
  String lastActiveDate; // YYYY-MM-DD of last completion
  List<String> activeDates; // List of YYYY-MM-DD for streak visualization
  DateTime createdAt;

  UserProfile({
    required this.id,
    this.username = 'Friend',
    this.avatar = '🌱',
    this.level = 1,
    this.xp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.streakShields = 1,
    this.totalTasksCompleted = 0,
    List<String>? preferredCategories,
    this.dailyMinutesBudget = 15,
    this.lastActiveDate = '',
    List<String>? activeDates,
    DateTime? createdAt,
  })  : preferredCategories = preferredCategories ?? ['health', 'growth', 'learning'],
        activeDates = activeDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'avatar': avatar,
        'level': level,
        'xp': xp,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'streakShields': streakShields,
        'totalTasksCompleted': totalTasksCompleted,
        'preferredCategories': preferredCategories,
        'dailyMinutesBudget': dailyMinutesBudget,
        'lastActiveDate': lastActiveDate,
        'activeDates': activeDates,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] ?? 'guest',
        username: map['username'] ?? 'Friend',
        avatar: map['avatar'] ?? '🌱',
        level: map['level'] ?? 1,
        xp: map['xp'] ?? 0,
        currentStreak: map['currentStreak'] ?? 0,
        longestStreak: map['longestStreak'] ?? 0,
        streakShields: map['streakShields'] ?? 1,
        totalTasksCompleted: map['totalTasksCompleted'] ?? 0,
        preferredCategories: (map['preferredCategories'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ['health', 'growth', 'learning'],
        dailyMinutesBudget: map['dailyMinutesBudget'] ?? 15,
        lastActiveDate: map['lastActiveDate'] ?? '',
        activeDates: (map['activeDates'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      );

  /// XP requirements calculation:
  /// Level 1: 0 - 100
  /// Level 2: 100 - 250 (+150)
  /// Level 3: 250 - 450 (+200)
  /// Level 4: 450 - 700 (+250)
  /// Level 5: 700 - 1000 (+300)
  /// Level N threshold = LevelBaseXp(N)
  static int xpForLevel(int targetLevel) {
    if (targetLevel <= 1) return 0;
    int total = 0;
    for (int lvl = 1; lvl < targetLevel; lvl++) {
      total += 50 + (lvl * 50);
    }
    return total;
  }

  /// Calculates XP required to reach the next level from current level
  int get xpForNextLevel => xpForLevel(level + 1);

  /// Calculates base XP required for current level
  int get xpForCurrentLevel => xpForLevel(level);

  /// Progress inside current level from 0.0 to 1.0
  double get levelProgress {
    final currentBase = xpForCurrentLevel;
    final nextBase = xpForNextLevel;
    final needed = nextBase - currentBase;
    if (needed <= 0) return 1.0;
    final progress = (xp - currentBase) / needed;
    return progress.clamp(0.0, 1.0);
  }

  int get currentLevelXp => (xp - xpForCurrentLevel).clamp(0, xpForNextLevel - xpForCurrentLevel);
  int get neededForNextLevel => xpForNextLevel - xpForCurrentLevel;
}

/// Achievement structure
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String requirementType; // 'first_task', 'streak', 'tasks_count', 'level', 'xp'
  final int requirementValue;
  final int bonusXp;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requirementType,
    required this.requirementValue,
    this.bonusXp = 50,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'requirementType': requirementType,
        'requirementValue': requirementValue,
        'bonusXp': bonusXp,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromMap(Map<String, dynamic> map) => Achievement(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        icon: map['icon'] ?? '🏆',
        requirementType: map['requirementType'] ?? '',
        requirementValue: map['requirementValue'] ?? 0,
        bonusXp: map['bonusXp'] ?? 50,
        isUnlocked: map['isUnlocked'] == true,
        unlockedAt: map['unlockedAt'] != null ? DateTime.tryParse(map['unlockedAt']) : null,
      );
}

/// A specific day mission in a multi-day quest campaign
class QuestMission {
  final int dayNumber;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskDifficulty difficulty;
  final int durationMinutes;
  final int xp;
  bool isCompleted;
  DateTime? completedAt;

  QuestMission({
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    this.durationMinutes = 15,
    int? xp,
    this.isCompleted = false,
    this.completedAt,
  }) : xp = xp ?? difficulty.xp;

  Map<String, dynamic> toMap() => {
        'dayNumber': dayNumber,
        'title': title,
        'description': description,
        'category': category.name,
        'difficulty': difficulty.name,
        'durationMinutes': durationMinutes,
        'xp': xp,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory QuestMission.fromMap(Map<String, dynamic> map) => QuestMission(
        dayNumber: map['dayNumber'] ?? 1,
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        category: TaskCategory.fromString(map['category'] ?? 'growth'),
        difficulty: TaskDifficulty.fromString(map['difficulty'] ?? 'medium'),
        durationMinutes: map['durationMinutes'] ?? 15,
        xp: map['xp'] ?? 25,
        isCompleted: map['isCompleted'] == true,
        completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt']) : null,
      );

  TaskItem toTaskItem(String dateStr) {
    return TaskItem(
      id: 'quest_day_$dayNumber',
      title: 'Day $dayNumber: $title',
      description: description,
      category: category,
      difficulty: difficulty,
      xp: xp,
      durationMinutes: durationMinutes,
      source: TaskSource.suggested,
      recurring: RecurringSchedule.todayOnly,
      scheduledDate: dateStr,
      isCompleted: isCompleted,
    );
  }
}

/// Multi-day Journey Campaign (e.g. 30-Day Atomic 1% Transformation)
class QuestJourney {
  final String id;
  final String title;
  final String tagline;
  final String badgeEmoji;
  final int totalDays;
  int currentDay;
  bool isEnrolled;
  bool isCompleted;
  List<QuestMission> missions;

  QuestJourney({
    required this.id,
    required this.title,
    required this.tagline,
    required this.badgeEmoji,
    required this.totalDays,
    this.currentDay = 1,
    this.isEnrolled = false,
    this.isCompleted = false,
    required this.missions,
  });

  QuestMission? get currentMission {
    if (currentDay > totalDays) return null;
    return missions.firstWhere(
      (m) => m.dayNumber == currentDay,
      orElse: () => missions.first,
    );
  }

  int get completedDaysCount => missions.where((m) => m.isCompleted).length;
  double get progressFraction => totalDays > 0 ? (completedDaysCount / totalDays).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'tagline': tagline,
        'badgeEmoji': badgeEmoji,
        'totalDays': totalDays,
        'currentDay': currentDay,
        'isEnrolled': isEnrolled,
        'isCompleted': isCompleted,
        'missions': missions.map((m) => m.toMap()).toList(),
      };

  factory QuestJourney.fromMap(Map<String, dynamic> map) => QuestJourney(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        tagline: map['tagline'] ?? '',
        badgeEmoji: map['badgeEmoji'] ?? '🌱',
        totalDays: map['totalDays'] ?? 30,
        currentDay: map['currentDay'] ?? 1,
        isEnrolled: map['isEnrolled'] == true,
        isCompleted: map['isCompleted'] == true,
        missions: (map['missions'] as List<dynamic>?)
                ?.map((m) => QuestMission.fromMap(m as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

