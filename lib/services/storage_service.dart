import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/challenge_database.dart';

class StorageService {
  static const String _keyProfile = 'aajka_profile';
  static const String _keyTasks = 'aajka_tasks';
  static const String _keyDailyChallenge = 'aajka_daily_challenge';
  static const String _keyAchievements = 'aajka_achievements';
  static const String _keyOnboardingDone = 'aajka_onboarding_done';
  static const String _keyThemeMode = 'aajka_theme_mode';
  static const String _keyMorningReminder = 'aajka_morning_reminder';
  static const String _keyEveningReminder = 'aajka_evening_reminder';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Onboarding
  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(_keyOnboardingDone, value);
  }

  // User Profile
  UserProfile getUserProfile() {
    final str = _prefs.getString(_keyProfile);
    if (str != null && str.isNotEmpty) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        return UserProfile.fromMap(map);
      } catch (_) {}
    }
    return UserProfile(id: 'guest_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final str = jsonEncode(profile.toMap());
    await _prefs.setString(_keyProfile, str);
  }

  // Tasks
  List<TaskItem> getTasks() {
    final str = _prefs.getString(_keyTasks);
    if (str != null && str.isNotEmpty) {
      try {
        final list = jsonDecode(str) as List<dynamic>;
        return list.map((item) => TaskItem.fromMap(item as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final list = tasks.map((t) => t.toMap()).toList();
    await _prefs.setString(_keyTasks, jsonEncode(list));
  }

  // Daily Challenge State
  DailyChallengeState? getDailyChallengeState(String todayStr) {
    final str = _prefs.getString(_keyDailyChallenge);
    if (str != null && str.isNotEmpty) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        final state = DailyChallengeState.fromMap(map);
        if (state.date == todayStr) {
          return state;
        }
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveDailyChallengeState(DailyChallengeState state) async {
    await _prefs.setString(_keyDailyChallenge, jsonEncode(state.toMap()));
  }

  // Achievements
  List<Achievement> getAchievements() {
    final str = _prefs.getString(_keyAchievements);
    if (str != null && str.isNotEmpty) {
      try {
        final list = jsonDecode(str) as List<dynamic>;
        final loaded = list.map((a) => Achievement.fromMap(a as Map<String, dynamic>)).toList();
        // Merge with initial if any new ones added
        final map = {for (var a in loaded) a.id: a};
        return ChallengeDatabase.initialAchievements.map((init) {
          return map[init.id] ?? init;
        }).toList();
      } catch (_) {}
    }
    return List.from(ChallengeDatabase.initialAchievements);
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    final list = achievements.map((a) => a.toMap()).toList();
    await _prefs.setString(_keyAchievements, jsonEncode(list));
  }

  // Quest Journeys
  static const String _keyJourneys = 'aajka_quest_journeys';

  List<QuestJourney> getJourneys() {
    final str = _prefs.getString(_keyJourneys);
    if (str != null && str.isNotEmpty) {
      try {
        final list = jsonDecode(str) as List<dynamic>;
        return list.map((item) => QuestJourney.fromMap(item as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveJourneys(List<QuestJourney> journeys) async {
    final list = journeys.map((j) => j.toMap()).toList();
    await _prefs.setString(_keyJourneys, jsonEncode(list));
  }

  // Theme Mode
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  // Reminders
  bool getMorningReminder() => _prefs.getBool(_keyMorningReminder) ?? true;
  Future<void> setMorningReminder(bool val) => _prefs.setBool(_keyMorningReminder, val);

  bool getEveningReminder() => _prefs.getBool(_keyEveningReminder) ?? true;
  Future<void> setEveningReminder(bool val) => _prefs.setBool(_keyEveningReminder, val);

  // Clear data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
