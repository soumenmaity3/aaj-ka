import '../models/models.dart';

class QuestDatabase {
  static List<QuestJourney> initialJourneys() {
    return [
      _create30DayAtomicJourney(),
      _create21DayDigitalDetoxJourney(),
      _create14DayMorningMomentumJourney(),
    ];
  }

  static QuestJourney _create30DayAtomicJourney() {
    return QuestJourney(
      id: 'journey_30_atomic',
      title: '30-Day Atomic 1% Quest',
      tagline: 'Transform your daily habits by 1% each day through 30 progressive missions.',
      badgeEmoji: '🌱',
      totalDays: 30,
      currentDay: 1,
      isEnrolled: true, // Enrolled by default for instant delight
      missions: [
        QuestMission(
          dayNumber: 1,
          title: 'Drink 500ml water right upon waking',
          description: 'Kickstart your metabolism and flush out overnight toxins before touching any screens.',
          category: TaskCategory.health,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 3,
        ),
        QuestMission(
          dayNumber: 2,
          title: 'Write down 3 things you love about yourself',
          description: 'Counter self-criticism. Write down 3 qualities or accomplishments you appreciate.',
          category: TaskCategory.growth,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 3,
          title: 'Do 15 bodyweight squats or 10 pushups',
          description: 'Get your blood pumping and oxygen flowing right now wherever you are.',
          category: TaskCategory.health,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 4,
          title: 'Read 5 pages of a book uninterrupted',
          description: 'Put your phone in another room and focus completely on 5 pages.',
          category: TaskCategory.learning,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 10,
        ),
        QuestMission(
          dayNumber: 5,
          title: 'Declutter your workspace in 5 minutes',
          description: 'A clean desk creates clarity. Wipe down the surface and organize notes.',
          category: TaskCategory.productivity,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 6,
          title: 'Send a genuine message of appreciation to a friend',
          description: 'Strengthen a bond. Tell someone why you appreciate having them in your life.',
          category: TaskCategory.relationships,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 3,
        ),
        QuestMission(
          dayNumber: 7,
          title: '🏆 Milestone 1: 15-Minute Nature Walk & Reflection',
          description: 'Week 1 completed! Walk outside without headphones or phone and reflect on your week.',
          category: TaskCategory.mindfulness,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 15,
        ),
        QuestMission(
          dayNumber: 8,
          title: 'Track every rupee or dollar spent today',
          description: 'Financial consciousness begins with tracking every single daily expense.',
          category: TaskCategory.money,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 9,
          title: 'Eat one meal today with zero screens',
          description: 'Put your phone away. Savor the flavors, textures, and nourishment of your food.',
          category: TaskCategory.digitalWellbeing,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 15,
        ),
        QuestMission(
          dayNumber: 10,
          title: 'Execute a 25-minute Pomodoro focus block',
          description: 'Pick your most avoided task. Single-task with 100% focus until the timer ends.',
          category: TaskCategory.productivity,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 25,
        ),
        QuestMission(
          dayNumber: 11,
          title: 'Practice 4-7-8 deep breathing for 5 minutes',
          description: 'Inhale for 4 seconds, hold for 7 seconds, exhale slowly for 8 seconds. Reset your nervous system.',
          category: TaskCategory.mindfulness,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 12,
          title: 'Learn one new concept or mental model',
          description: 'Look up First Principles thinking, Pareto Principle, or Inversion and write 1 sentence.',
          category: TaskCategory.learning,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 15,
        ),
        QuestMission(
          dayNumber: 13,
          title: 'Stretch your full body for 10 minutes',
          description: 'Hamstrings, shoulders, spine, and hip flexors. Release physical tension.',
          category: TaskCategory.health,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 10,
        ),
        QuestMission(
          dayNumber: 14,
          title: '🏆 Milestone 2: 2-Hour Digital Sunset tonight',
          description: 'Week 2 done! Turn off all social media and bright screens 2 hours before bed.',
          category: TaskCategory.digitalWellbeing,
          difficulty: TaskDifficulty.hard,
          durationMinutes: 30,
        ),
        QuestMission(
          dayNumber: 15,
          title: 'Save or invest ₹100 / \$5 today',
          description: 'Transfer a small sum to your savings account or mutual fund.',
          category: TaskCategory.money,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 16,
          title: 'Help someone at home or work without being asked',
          description: 'Anticipate a need and solve it with zero expectation of reward.',
          category: TaskCategory.kindness,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 10,
        ),
        QuestMission(
          dayNumber: 17,
          title: 'Plan tomorrow’s 3 critical victories tonight',
          description: 'Write down the top 3 high-leverage outcomes before going to sleep.',
          category: TaskCategory.productivity,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 18,
          title: 'Engage in 20 minutes of intense physical training',
          description: 'Brisk run, HIIT workout, or calisthenics. Push your cardiovascular limits.',
          category: TaskCategory.health,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 20,
        ),
        QuestMission(
          dayNumber: 19,
          title: 'Clean out 10 unused apps or subscriptions',
          description: 'Free digital space and mental bandwidth by removing unused distractions.',
          category: TaskCategory.digitalWellbeing,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 10,
        ),
        QuestMission(
          dayNumber: 20,
          title: 'Read 15 pages of non-fiction',
          description: 'Accelerate your knowledge compounding. Take 1 actionable note.',
          category: TaskCategory.learning,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 25,
        ),
        QuestMission(
          dayNumber: 21,
          title: '🏆 Milestone 3: 3-Week Habit Lock & Gratitude',
          description: '21 Days completed! Habit neuroscience says your neural pathways are locking in.',
          category: TaskCategory.growth,
          difficulty: TaskDifficulty.hard,
          durationMinutes: 20,
        ),
        QuestMission(
          dayNumber: 22,
          title: 'Say NO to one unnecessary commitment',
          description: 'Protect your energy. Politely decline a distraction that doesn’t serve your goals.',
          category: TaskCategory.productivity,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 23,
          title: 'Prepare healthy meals/snacks for tomorrow',
          description: 'Prevent impulsive eating by having fruits, nuts, or healthy food ready.',
          category: TaskCategory.health,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 15,
        ),
        QuestMission(
          dayNumber: 24,
          title: 'Practice active listening in a conversation',
          description: 'Listen without planning your reply. Hear the emotions behind the words.',
          category: TaskCategory.relationships,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 15,
        ),
        QuestMission(
          dayNumber: 25,
          title: 'Spend 15 minutes organizing your finances/budget',
          description: 'Review bank balances, categorize recent expenditures, and adjust monthly budget.',
          category: TaskCategory.money,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 15,
        ),
        QuestMission(
          dayNumber: 26,
          title: 'Complete a 45-minute deep focus project sprint',
          description: 'Zero tabs, phone off. Advance your most meaningful personal or career project.',
          category: TaskCategory.career,
          difficulty: TaskDifficulty.hard,
          durationMinutes: 45,
        ),
        QuestMission(
          dayNumber: 27,
          title: 'Replace one complaining thought with a creative solution',
          description: 'Whenever frustration strikes today, immediately ask: "How can I solve this?"',
          category: TaskCategory.mindfulness,
          difficulty: TaskDifficulty.easy,
          durationMinutes: 5,
        ),
        QuestMission(
          dayNumber: 28,
          title: 'Write a heartfelt letter or message of gratitude',
          description: 'Send sincere thanks to a parent, mentor, or friend who shaped who you are.',
          category: TaskCategory.kindness,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 15,
        ),
        QuestMission(
          dayNumber: 29,
          title: 'Nightly self-reflection: What did 1% improvement feel like?',
          description: 'Review how far you have come from Day 1 to Day 29.',
          category: TaskCategory.growth,
          difficulty: TaskDifficulty.medium,
          durationMinutes: 15,
        ),
        QuestMission(
          dayNumber: 30,
          title: '👑 Grand Finale: The 30-Day Atomic 1% Transformation!',
          description: 'You did it! 30 consecutive days of showing up. You are 135% better than Day 1!',
          category: TaskCategory.growth,
          difficulty: TaskDifficulty.epic,
          durationMinutes: 30,
        ),
      ],
    );
  }

  static QuestJourney _create21DayDigitalDetoxJourney() {
    return QuestJourney(
      id: 'journey_21_detox',
      title: '21-Day Digital Detox & Focus Forge',
      tagline: 'Reclaim your attention span, dopamine baseline, and peace of mind.',
      badgeEmoji: '📱',
      totalDays: 21,
      currentDay: 1,
      isEnrolled: false,
      missions: List.generate(21, (i) {
        final day = i + 1;
        return QuestMission(
          dayNumber: day,
          title: 'Detox Mission $day: Screen-free focus for ${15 + (day * 2)}m',
          description: 'Silence notifications and spend time reading, walking, or writing offline.',
          category: TaskCategory.digitalWellbeing,
          difficulty: day % 7 == 0 ? TaskDifficulty.hard : TaskDifficulty.medium,
          durationMinutes: 15 + (day * 2),
        );
      }),
    );
  }

  static QuestJourney _create14DayMorningMomentumJourney() {
    return QuestJourney(
      id: 'journey_14_morning',
      title: '14-Day Morning Momentum',
      tagline: 'Win the morning, win the day with energizing physical and mental habits.',
      badgeEmoji: '⚡',
      totalDays: 14,
      currentDay: 1,
      isEnrolled: false,
      missions: List.generate(14, (i) {
        final day = i + 1;
        return QuestMission(
          dayNumber: day,
          title: 'Morning Spark $day: Hydrate + ${5 + day}m workout + sunlight',
          description: 'Get natural sunlight in your eyes and complete morning movement before breakfast.',
          category: TaskCategory.health,
          difficulty: day % 7 == 0 ? TaskDifficulty.hard : TaskDifficulty.medium,
          durationMinutes: 10 + day,
        );
      }),
    );
  }
}
