import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final storage = await StorageService.init();
  final appState = AppState(storage);

  runApp(AajKaApp(storage: storage, appState: appState));
}

class AajKaApp extends StatefulWidget {
  final StorageService storage;
  final AppState appState;

  const AajKaApp({
    super.key,
    required this.storage,
    required this.appState,
  });

  @override
  State<AajKaApp> createState() => _AajKaAppState();
}

class _AajKaAppState extends State<AajKaApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    final savedMode = widget.storage.getThemeMode();
    if (savedMode == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedMode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  void _onThemeModeChanged(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final isOnboardingDone = widget.storage.isOnboardingCompleted();

    return MaterialApp(
      title: 'AajKa 1%',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: isOnboardingDone
          ? MainNavigationWrapper(
              appState: widget.appState,
              storage: widget.storage,
              onThemeModeChanged: _onThemeModeChanged,
            )
          : OnboardingScreen(
              appState: widget.appState,
              storage: widget.storage,
              onThemeModeChanged: _onThemeModeChanged,
            ),
    );
  }
}
