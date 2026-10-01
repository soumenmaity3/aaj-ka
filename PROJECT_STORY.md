# 📖 The Story of Building "AajKa 1%"

> **“Don’t become perfect. Become 1% better.”**  
> *One small action today. No overwhelming to-do lists. Bas ek chhota step.*

---

## 🌟 1. Executive Summary & Vision

**AajKa 1%** is a mobile-first self-improvement and daily habit app inspired by atomic habits and modern gamification apps like *Duolingo* and *Finch*. Rather than overwhelming users with corporate productivity dashboards, multi-step subtasks, and complex Gantt charts, **AajKa 1%** boils personal development down to a single question every day:

> **“Aaj mujhe kya karna hai?”**

The application is built in **Flutter** with a full offline-first architecture, beautiful micro-animations, confetti celebrations, level-up systems, streak shields, and a warm, supportive friend tone blending English with natural Hinglish encouragement.

---

## 🧭 2. The Core Daily Loop

The entire product architecture is structured around this seamless habit loop:

```
┌──────────────────────────────────────────────────────────────┐
│                      THE DAILY 1% LOOP                       │
│                                                              │
│   1. Open App                                                │
│      └─► Warm greeting: "Good morning/evening, Rahul 👋"      │
│                                                              │
│   2. Today's Question Answered                               │
│      └─► "Ready for today's 1%?"                             │
│                                                              │
│   3. ✨ AajKa Challenge (Hero Card)                          │
│      └─► Tailored bite-sized challenge (e.g. 5–15 mins)      │
│      └─► Options: "Complete ✓", "Surprise Me 🎲", "Reroll 🔄" │
│                                                              │
│   4. 👤 My Tasks (Optional)                                  │
│      └─► Create custom tasks in < 10 seconds                 │
│                                                              │
│   5. Complete Action & Win                                   │
│      └─► Earn XP (+25 XP, +10 Bonus, +50 All-Goals Bonus)    │
│      └─► Protect & increment streak (🔥)                     │
│      └─► Level progression & Confetti celebration 🎉          │
│                                                              │
│   6. Leave with a Smile (< 1 minute spent)                   │
│      └─► “Aaj tumne khud ko 1% better banaya. Keep going!”   │
└──────────────────────────────────────────────────────────────┘
```

---

## 🛠️ 3. Technology Stack & Technical Definitions (Till Date)

The following technologies, tools, architectural patterns, and libraries form the backbone of **AajKa 1%**:

### 3.1 Core Framework & Language
* **Flutter `3.44.3` (Channel Stable)**:
  * Cross-platform UI toolkit enabling smooth 60–120 FPS native execution on Android, iOS, Windows, and Web from a single Dart codebase.
  * Leveraged Flutter's native declarative widget tree and hardware-accelerated rendering.
* **Dart `3.12.2`**:
  * Type-safe modern object-oriented language with full sound null safety.
  * Used for domain modeling, strict compile-time checks, and JSON serialization.
* **Material Design 3 (M3)**:
  * Modern Google design system using generous 20px–28px card radii, expressive tonal elevation, dynamic color container contrasts, and clean bottom sheets.

### 3.2 Production Packages & Libraries (`pubspec.yaml`)

| Package | Version | Purpose in "AajKa 1%" | Architectural Rationale |
| :--- | :--- | :--- | :--- |
| **`shared_preferences`** | `^2.5.5` | Local persistent key-value store | **Offline-First & Frictionless Guest Mode:** Instant loading without database spin-up or internet dependency. Caches user XP, levels, streaks, shields, custom tasks, daily challenges, and settings directly on device. |
| **`google_fonts`** | `^8.2.1` | Typography | **Modern Friendly Personality:** Embeds Google’s **`Outfit`** font family across the app for a playful, contemporary, highly readable aesthetic reminiscent of Duolingo & Finch. |
| **`confetti`** | `^0.8.0` | Micro-interaction celebration particles | **Dopamine & Gamification:** Triggers an explosive blast of multi-colored confetti particles on Level-Up dialogs and upon completing all daily goals. |
| **`intl`** | `^0.20.3` | Date, time, and calendar math | **Streak & Habit Calculations:** Formats dates (`yyyy-MM-dd`), tracks midnight transitions, and manages 7-day visual calendar rows (Monday to Sunday). |
| **`uuid`** | `^4.6.0` | Unique identifier generation | **Integrity:** Produces RFC4122 v4 unique IDs for user-created tasks and transaction entries to avoid key collisions. |
| **`flutter_lints`** | `^6.0.0` | Static analysis & code standards | **Code Quality:** Enforces recommended Flutter and Dart best practices. |

### 3.3 State Management & Architectural Patterns
* **Pattern**: Native **`ChangeNotifier`** + **`ListenableBuilder`** (Observer Pattern).
* **Why Chosen**: External state management frameworks (like Bloc, Riverpod, or Redux) add unnecessary boilerplate and package weight for this size of app. Flutter’s built-in `ChangeNotifier` ensures:
  * Zero startup overhead (< 100ms cold launch time).
  * Direct reactive bindings with granular widget re-renders.
  * Complete testability in pure Dart without mocking complex store providers.
* **Key Engines Inside `AppState` (`lib/services/app_state.dart`)**:
  1. **Recommendation Engine**: Analyzes user category preferences and current level tier to present a balanced, un-repeated daily challenge.
  2. **Streak Engine & Shield Protection (🛡️)**: Safely computes consecutive day counts; if a day is missed and the user holds a Streak Shield, it protects the streak without punishment (*"Streak bach gaya! 🔥"*).
  3. **Progressive Level Curve**: Calculates required XP using the cumulative progression formula:
     $$\text{XP}(N) = \sum_{k=1}^{N-1} (50 + 50k)$$
  4. **Anti-Abuse Protection**: Enforces single-completion rules per task occurrence to prevent XP inflation.
  5. **Daily 1% Score Gauge**: Aggregates difficulty points (Easy: 1, Med: 2, Hard: 3, Epic: 5) to display daily progress (e.g. `Score: 4/5`).

---

## 🏗️ 4. Complete Step-by-Step Build Journey

Here is the exact chronicle of what was architected, built, and verified:

### Phase 1: Environment & Dependency Setup
- Analyzed the existing Flutter codebase structure.
- Configured modern Flutter dependencies in `pubspec.yaml`:
  - `shared_preferences`: Robust offline key-value storage for local user profiles, streak history, custom tasks, and preferences.
  - `google_fonts`: Loaded the clean, high-legibility **Outfit** font family.
  - `confetti`: Explosive celebratory particle animations on level-ups and milestones.
  - `intl`: Localized date-time formatting and calendar calculations.
  - `uuid`: Collision-free unique IDs for tasks and events.

---

### Phase 2: Domain Modeling (`lib/models/models.dart`)
We structured the core data models with complete bi-directional JSON serialization:
1. **`TaskCategory` (12 Curated Domains)**:
   - 📚 Learning
   - 💪 Health
   - 🧘 Mindfulness
   - ❤️ Relationships
   - 💰 Money & Finance
   - ⚡ Focus & Productivity
   - 💼 Career & Work
   - 📱 Digital Wellbeing
   - 🎨 Creativity
   - 🧹 Personal Life
   - 🌱 Personal Growth
   - 🤝 Kindness & Gratitude
2. **`TaskDifficulty` & 1% Scoring**:
   - **Easy**: 10 XP | 1 Point (e.g., drink water, 5 deep breaths)
   - **Medium**: 25 XP | 2 Points (e.g., read 5 pages, 15m walk)
   - **Hard**: 50 XP | 3 Points (e.g., 30m workout, 45m study session)
   - **Epic**: 100 XP | 5 Points (e.g., 90m deep work block)
3. **`TaskItem`**:
   - Handles ID, title, description, category, difficulty, duration in minutes, origin source (`suggested` vs `user`), recurrence schedule (`todayOnly`, `daily`, `weekly`), date, and completion state.
4. **`UserProfile`**:
   - Manages username, avatar emoji, level, lifetime XP, current streak, longest streak, available streak shields, preferred categories, and active calendar dates.
   - **Level Curve Algorithm**: Progressively scaled XP curve where Level $N$ requires:
     $$\text{XP}(N) = \sum_{k=1}^{N-1} (50 + 50k)$$
     *(Level 1: 0 XP, Level 2: 100 XP, Level 3: 250 XP, Level 4: 450 XP, Level 5: 700 XP...)*
5. **`Achievement` & `DailyChallengeState`**:
   - Tracks unlock criteria, achievement bonus XP, daily rerolls consumed, and bonus XP claim flags.

---

### Phase 3: The Challenge Database (`lib/data/challenge_database.dart`)
Created a rich database of **120+ curated micro-tasks** across all 12 categories. Examples:
- *“Drink an extra glass of water right now”* (2 min • Health)
- *“Take 5 slow, deep belly breaths”* (3 min • Mindfulness)
- *“Read 3 pages of any book”* (10 min • Learning)
- *“Send a genuine compliment or thank-you message”* (3 min • Relationships)
- *“Save ₹50 or avoid one impulse purchase”* (5 min • Money)
- *“Clean and declutter your work desk”* (5 min • Productivity)
- *“Eat one meal today with zero screens or phone”* (15 min • Digital Wellbeing)
- *“Smile and genuinely greet a service worker”* (2 min • Kindness)

Includes **10 launch achievements**:
- 🌱 *First Step*: Complete 1st task (+50 XP)
- 🔥 *3-Day Fire*: Maintain 3-day streak (+75 XP)
- ⚡ *7-Day Warrior*: Maintain 7-day streak (+150 XP)
- 👑 *30 Days Unstoppable*: 30-day streak (+500 XP)
- 🎯 *Double Digits*: Complete 10 tasks (+100 XP)
- 🚀 *Momentum Master*: Complete 50 tasks (+250 XP)
- 💯 *Century Club*: Complete 100 tasks (+500 XP)
- 🌿 *Growing Strong*: Reach Level 5 (+150 XP)
- ⭐ *Rising Star*: Reach Level 10 (+300 XP)
- 🏆 *1,000 XP Veteran*: Earn 1,000 XP (+200 XP)

---

### Phase 4: State Management & Game Engine (`lib/services/app_state.dart`)
Built a unified `ChangeNotifier` state manager:
1. **Smart Recommendation**: Suggests today's challenge by prioritizing user category preferences, matching the user's level tier (Levels 1–3 receive Easy/Medium; higher levels unlock Hard/Epic), while ensuring variety.
2. **Daily Challenge Reroll**: Users receive 2 rerolls per day (increases to 3 at Level 5, 4 at Level 10).
3. **Surprise Me (🎲)**: Generates random challenges with instant one-tap acceptance.
4. **Streak Engine with Streak Shield (🛡️)**:
   - Evaluates consecutive day activity across midnight boundaries.
   - If a day is missed and the user has $\ge 1$ Streak Shield, the shield is consumed, keeping the streak alive without penalty (*"Streak bach gaya! 🔥"*).
   - If no shield exists, resets gracefully without guilt: *"New streak starts today. 🌱"*.
   - Hitting any 7-day streak milestone awards +1 free Streak Shield & +100 bonus XP.
5. **Anti-Abuse Engine**: Prevents XP double-dipping or spam toggling.
6. **All-Goals-Complete Bonus**: Completing all goals scheduled for today grants a +50 XP bonus.
7. **Event Triggers**: Queues dialog events for Level-Up modals, achievement alerts, and shield warnings.

---

### Phase 5: Storage Layer (`lib/services/storage_service.dart`)
- Asynchronously initializes and provides instant synchronous read/write access to `SharedPreferences`.
- Supports guest mode, onboarding flag, reminder notification switches, theme mode (Light/Dark/System), and a nuclear "Reset All Data" option.

---

### Phase 6: UI Design System (`lib/theme/app_theme.dart`)
- **Color Palette**:
  - Fresh Mint / Emerald: `#10B981`, `#059669` (Growth, Calm, Clean)
  - Streak Fire: `#F59E0B`, `#EF4444` (Consistency, Energy)
  - Dark Surfaces: `#0B0F17`, `#161E2E`, `#1E293B`
  - Light Surfaces: `#F8FAFC`, `#FFFFFF`, `#E2E8F0`
- **Component Styling**:
  - Card corner radius: 20px–28px.
  - Buttons: Pill-shaped elevated & outlined buttons with interactive hover and ripple states.
  - Full Material 3 dark and light theme definitions.

---

### Phase 7: Screens & User Experiences

1. **Onboarding Screen (`lib/screens/onboarding_screen.dart`)**:
   - 4-step welcoming flow:
     - Slide 1: Welcome & name input (*"What should we call you?"*).
     - Slide 2: Category picker chips (Health, Learning, Mind, Career, Money...).
     - Slide 3: Time budget selection (5 min, 10 min, 15 min, 30 min).
     - Slide 4: Philosophy commitment (*"Don't become perfect. Become 1% better."*).
   - Zero registration barriers: guest mode operates immediately.

2. **Home Screen (`lib/screens/home_screen.dart`)**:
   - Time-sensitive greeting: *"Good morning/evening, Rahul 👋"*.
   - **Progress Card**: Level gauge, XP bar to next level, today's completion count, and today's 1% score (e.g. `Score: 4/5`).
   - **✨ AajKa Challenge Hero Card**: Large, colorful card with category emoji, time estimate, +XP badge with bonus indicator, and full-width "Complete ✓" button.
   - Quick action pill buttons: **🎲 Surprise Me** and **🔄 Reroll (X left)**.
   - **👤 My Tasks Section**: User tasks with checkmarks, category tags, recurrence badges, and "+ Create My Task" button.
   - **Friendly Empty State**: Encouraging prompt when no custom tasks exist.

3. **Fast Task Creation Bottom Sheet (`lib/screens/create_task_bottom_sheet.dart`)**:
   - Opens in < 100ms with automatic keyboard focus.
   - Title input + difficulty pills (Easy +10 XP, Medium +25 XP, Hard +50 XP) + horizontal category chips + repeat schedule (Today only, Daily, Weekly).
   - User can create a task in under 10 seconds.

4. **Explore Screen (`lib/screens/explore_screen.dart`)**:
   - Horizontal category filter bar.
   - Card listing of curated challenges showing category, difficulty, duration, and XP.
   - Level gating indicators (*"Unlocks at Level 4"*).
   - One-tap "+ Add to Today" action with feedback snackbar.

5. **Progress Screen (`lib/screens/progress_screen.dart`)**:
   - Large gradient Level & XP summary card.
   - Streak card with active count, longest streak, and Streak Shield tally.
   - 7-Day calendar circle row (M T W T F S S) showing completed days with fire or check icons.
   - **Weekly Review Card**: Weekly tasks count, XP earned, best category focus, and supportive message (*"You showed up 6 out of 7 days. That's real progress. 🌱"*).
   - **Achievements Showcase**: Visual grid of earned and in-progress achievements.

6. **Profile & Settings Screen (`lib/screens/profile_screen.dart`)**:
   - Avatar emoji picker (🌱, 🚀, ⚡, 🦁, 🦉, 🌸, 🧘, 🔥).
   - Lifetime statistics tiles (Tasks completed, current streak, longest streak, shields).
   - Guest mode security reassurance banner.
   - Morning prompt and evening streak warning notification switches with supportive sample copy.
   - Light / Dark / System theme switcher.
   - Data reset with confirmation dialog.

7. **Celebration Dialogs (`lib/widgets/celebration_dialogs.dart`)**:
   - **Level Up Modal**: Explosive multi-colored confetti particles, level badge, and motivational Hinglish toast.
   - **Achievement Unlocked Modal**: Golden trophy animation, description, and claimed bonus XP.
   - **Streak Shield Modal**: Reassuring notice (*"Streak bach gaya! 🔥"*).
   - **Surprise Me Dialog**: Interactive pop-up card to accept or roll another random challenge.

8. **Main Navigation Wrapper (`lib/screens/main_navigation_wrapper.dart`)**:
   - Bottom navigation bar with icons for Home (🏠), Progress (📊), Explore (🎯), Profile (👤), and a prominent floating-style center "+" action button.

9. **Main Entry Point (`lib/main.dart`)**:
   - Immersive status bar configuration.
   - Asynchronous storage loading and reactive theme mode listener.
   - Automatic routing between Onboarding and the main app.

---

## 🧪 5. Quality Assurance & Testing

### Automated Test Suite (`test/widget_test.dart`)
We wrote comprehensive unit and integration tests covering:
1. **XP & Level Progression Math**: Verified base and threshold calculations across Levels 1, 2, 3, and 4.
2. **TaskItem Serialization**: Validated lossless `toMap()` and `fromMap()` conversions.
3. **Daily Challenge & User Task Completion**: Verified XP distribution (+10 challenge bonus, +50 First Step achievement, +50 all-goals daily bonus), streak increments, and 1% score updates.
4. **Reroll Quota Mechanism**: Verified that rerolls decrease quota correctly and lock out when exhausted.
5. **Streak Shield Protection**: Verified that when a user misses a day, a streak shield is consumed and the streak is fully preserved.
6. **Level-Up Event Triggering**: Verified that crossing level boundaries fires the `LevelUpEvent`.
7. **Weekly Review Calculations**: Verified task counting, weekly XP tallying, active days computation, and best-category detection.

**Test Results**:
```bash
flutter test
00:00 +7: All tests passed!
```

### Static Analysis
```bash
flutter analyze
No issues found! (ran in 2.3s)
```
- **0 errors, 0 warnings, 0 lints**.

---

## 📁 6. Complete File Directory

```
lib/
├── data/
│   └── challenge_database.dart       # 120+ curated challenges & 10 achievements
├── models/
│   └── models.dart                   # Data models: TaskItem, UserProfile, Category, Difficulty, etc.
├── screens/
│   ├── create_task_bottom_sheet.dart # Fast < 10s task creation
│   ├── explore_screen.dart           # Category catalog & level-locked challenges
│   ├── home_screen.dart              # Daily challenge hero, user tasks, 1% progress
│   ├── main_navigation_wrapper.dart  # Bottom navigation with center + button
│   ├── onboarding_screen.dart        # 4-step friction-free guest onboarding
│   ├── profile_screen.dart           # Stats, avatar picker, theme & reminders
│   └── progress_screen.dart          # XP level, streak calendar, weekly review, achievements
├── services/
│   ├── app_state.dart                # Central ChangeNotifier game engine
│   └── storage_service.dart          # SharedPreferences persistence
├── theme/
│   └── app_theme.dart                # Emerald/Flame color palette, Outfit typography, dark/light themes
├── widgets/
│   └── celebration_dialogs.dart      # Confetti Level Up, Achievement, Streak Shield, Surprise Me
└── main.dart                         # Entry point, theme listener, route dispatcher
test/
└── widget_test.dart                  # 7 automated tests verifying the entire core engine
```

---

## 🚀 7. How to Run the Application

To launch the application on your connected Android device, emulator, Windows desktop, or browser:

```bash
# 1. Ensure Flutter dependencies are resolved
flutter pub get

# 2. Run the test suite
flutter test

# 3. Launch on your preferred device
flutter run
```

---

## 🔮 8. Future Roadmap

1. **AI Personalized 1% Engine**: Integrate an LLM layer that parses user context (*"I have an exam in 3 days and I'm stressed"*) to generate bespoke 1% actions.
2. **Cloud Sync & Social Accountability**: Optional account creation to sync across Android/iOS devices and share streak milestones with friends.
3. **Smart Push Notifications**: Automated local push reminders scheduled at the user's preferred morning prompt and evening streak warning times.
4. **AajKa 1% Pro**: Custom theme packs, sound effects, unlimited rerolls, and deep analytics.

---

*Made with passion for continuous 1% daily self-improvement.* 🌱🔥
