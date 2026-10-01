import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;
  final StorageService storage;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const ProfileScreen({
    super.key,
    required this.appState,
    required this.storage,
    required this.onThemeModeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _avatarChoices = ['🌱', '🚀', '⚡', '🦁', '🦉', '🌸', '🧘', '🔥'];

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: widget.appState.profile.username);
    String selectedAvatar = widget.appState.profile.avatar;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose Avatar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _avatarChoices.map((av) {
                    final isSel = selectedAvatar == av;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedAvatar = av),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryLight : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: AppColors.primary, width: 2) : null,
                        ),
                        child: Text(av, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.appState.updateProfile(
                    username: nameController.text.trim().isEmpty
                        ? 'Friend'
                        : nameController.text.trim(),
                    avatar: selectedAvatar,
                  );
                  Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will clear all tasks, streak, XP and achievements on this device. Start fresh?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.appState.resetAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = widget.appState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Profile & Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(profile.avatar, style: const TextStyle(fontSize: 34)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Level ${profile.level} • ${profile.xp} XP',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: _showEditProfileDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Overview Stats Grid
              Row(
                children: [
                  _buildStatTile('Tasks Completed', '${profile.totalTasksCompleted}', '✅', isDark),
                  const SizedBox(width: 10),
                  _buildStatTile('Current Streak', '${profile.currentStreak} d', '🔥', isDark),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatTile('Longest Streak', '${profile.longestStreak} d', '⚡', isDark),
                  const SizedBox(width: 10),
                  _buildStatTile('Streak Shields', '${profile.streakShields}', '🛡️', isDark),
                ],
              ),
              const SizedBox(height: 24),

              // Guest Mode Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primaryDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Guest Mode Active',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your daily 1% progress is safely stored locally on this device.',
                            style: TextStyle(fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings Section
              const Text(
                '⚙️ Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              // Reminder Toggles
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Morning Prompt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                      subtitle: const Text('“🌱 Your 1% is waiting. What will you improve today?”', style: TextStyle(fontSize: 12)),
                      value: widget.storage.getMorningReminder(),
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => widget.storage.setMorningReminder(val));
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Evening Streak Warning', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                      subtitle: const Text('“⏰ You haven’t completed today’s 1%. Just one small step.”', style: TextStyle(fontSize: 12)),
                      value: widget.storage.getEveningReminder(),
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => widget.storage.setEveningReminder(val));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Theme Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    DropdownButton<String>(
                      value: widget.storage.getThemeMode(),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'system', child: Text('System')),
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'dark', child: Text('Dark')),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          widget.storage.setThemeMode(mode);
                          if (mode == 'light') {
                            widget.onThemeModeChanged(ThemeMode.light);
                          } else if (mode == 'dark') {
                            widget.onThemeModeChanged(ThemeMode.dark);
                          } else {
                            widget.onThemeModeChanged(ThemeMode.system);
                          }
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Reset Data
              Center(
                child: TextButton.icon(
                  onPressed: _confirmReset,
                  icon: const Icon(Icons.delete_forever_outlined, color: AppColors.error, size: 20),
                  label: const Text(
                    'Reset All Data & Start Fresh',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, String icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSubDark : AppColors.textSubLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
