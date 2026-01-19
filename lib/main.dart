import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InterpreterApp());
}

/// ===============================
/// GLOBAL ENUMS & CONSTANTS
/// ===============================

enum AppStage { splash, onboarding, setup, home }

enum LanguageMode { uzEn, enUz }

const String methodChannelName = 'interpreter/native';

final MethodChannel nativeChannel =
    MethodChannel(methodChannelName);

/// ===============================
/// ROOT APP
/// ===============================

class InterpreterApp extends StatefulWidget {
  const InterpreterApp({super.key});

  @override
  State<InterpreterApp> createState() => _InterpreterAppState();
}

class _InterpreterAppState extends State<InterpreterApp> {
  AppStage stage = AppStage.splash;
  bool onboardingDone = false;
  bool setupDone = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      stage = onboardingDone
          ? (setupDone ? AppStage.home : AppStage.setup)
          : AppStage.onboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;
    switch (stage) {
      case AppStage.splash:
        screen = const SplashScreen();
        break;
      case AppStage.onboarding:
        screen = OnboardingScreen(onFinish: () {
          setState(() {
            onboardingDone = true;
            stage = AppStage.setup;
          });
        });
        break;
      case AppStage.setup:
        screen = SetupScreen(onFinish: () {
          setState(() {
            setupDone = true;
            stage = AppStage.home;
          });
        });
        break;
      case AppStage.home:
        screen = const HomeScreen();
        break;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Interpreter',
      theme: ThemeData.dark(),
      home: screen,
    );
  }
}

/// ===============================
/// SPLASH SCREEN
/// ===============================

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 140),
            const SizedBox(height: 20),
            const Text('🇮🇳 🤝 🇺🇿', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            const Text(
              'Offline Live Interpreter',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// ONBOARDING SCREEN
/// ===============================

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({required this.onFinish, super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int index = 0;

  final pages = const [
    _OnboardPage(
        title: 'Offline Interpreter',
        description: 'Works without internet.',
        icon: Icons.offline_bolt),
    _OnboardPage(
        title: 'Sentence-wise',
        description: 'Speak one sentence only.',
        icon: Icons.record_voice_over),
    _OnboardPage(
        title: 'Privacy First',
        description: 'No server, no data sharing.',
        icon: Icons.lock),
  ];

  void next() {
    if (index < pages.length - 1) {
      setState(() => index++);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pages[index];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(p.icon, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(p.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(p.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: next,
              child: Text(index == pages.length - 1 ? 'Start' : 'Next'),
            )
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String title;
  final String description;
  final IconData icon;
  const _OnboardPage(
      {required this.title, required this.description, required this.icon});
}

/// ===============================
/// SETUP SCREEN
/// ===============================

class SetupScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SetupScreen({required this.onFinish, super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool mic = false, model = false, tts = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      mic = true;
      model = true;
      tts = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _tile("Microphone", mic),
            _tile("Whisper Model", model),
            _tile("Text to Speech", tts),
            const Spacer(),
            ElevatedButton(
              onPressed: mic && model && tts ? widget.onFinish : null,
              child: const Text("Continue"),
            )
          ],
        ),
      ),
    );
  }

  Widget _tile(String t, bool ok) => ListTile(
        leading: Icon(ok ? Icons.check_circle : Icons.hourglass_bottom,
            color: ok ? Colors.green : Colors.orange),
        title: Text(t),
      );
}

/// ===============================
/// HOME + BOTTOM NAV
/// ===============================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int i = 0;
  final pages = const [
    InterpreterTab(),
    ConversationTab(),
    SettingsTab(),
    AboutTab()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: i,
        onTap: (x) => setState(() => i = x),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Interpreter"),
          BottomNavigationBarItem(icon: Icon(Icons.sync), label: "Conversation"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
      ),
    );
  }
}

/// ===============================
/// INTERPRETER TAB
/// ===============================

class InterpreterTab extends StatefulWidget {
  const InterpreterTab({super.key});
  @override
  State<InterpreterTab> createState() => _InterpreterTabState();
}

class _InterpreterTabState extends State<InterpreterTab> {
  LanguageMode mode = LanguageMode.uzEn;
  String status = "Hold mic and speak one sentence";
  bool listening = false;

  Future<void> start() async {
    setState(() {
      listening = true;
      status = "Listening...";
    });
    try {
      await nativeChannel.invokeMethod("startListening", {
        "mode": mode == LanguageMode.uzEn ? "UZ_EN" : "EN_UZ"
      });
    } catch (_) {
      setState(() => status = "Native not ready");
    }
  }

  Future<void> stop() async {
    setState(() => status = "Processing...");
    try {
      final r =
          await nativeChannel.invokeMethod<String>("stopListening");
      setState(() {
        listening = false;
        status = r ?? "Done";
      });
    } catch (_) {
      setState(() {
        listening = false;
        status = "Failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interpreter"),
        actions: [
          PopupMenuButton<LanguageMode>(
            onSelected: (m) => setState(() => mode = m),
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: LanguageMode.uzEn,
                  child: Text("Uzbek → English")),
              PopupMenuItem(
                  value: LanguageMode.enUz,
                  child: Text("English → Uzbek")),
            ],
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(status),
          const SizedBox(height: 30),
          GestureDetector(
            onLongPressStart: (_) => start(),
            onLongPressEnd: (_) => stop(),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: listening ? Colors.red : Colors.green,
              child: const Icon(Icons.mic, size: 44, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// CONVERSATION TAB
/// ===============================

class ConversationTab extends StatefulWidget {
  const ConversationTab({super.key});
  @override
  State<ConversationTab> createState() => _ConversationTabState();
}

class _ConversationTabState extends State<ConversationTab> {
  bool uzTurn = true;
  String text = "Uzbek speaker, your turn";

  Future<void> start() async {
    await nativeChannel.invokeMethod("startListening", {
      "mode": uzTurn ? "UZ_EN" : "EN_UZ"
    });
  }

  Future<void> stop() async {
    await nativeChannel.invokeMethod("stopListening");
    setState(() {
      uzTurn = !uzTurn;
      text = uzTurn
          ? "Uzbek speaker, your turn"
          : "English speaker, your turn";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversation")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          const SizedBox(height: 30),
          GestureDetector(
            onLongPressStart: (_) => start(),
            onLongPressEnd: (_) => stop(),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.record_voice_over,
                  size: 40, color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}

/// ===============================
/// SETTINGS TAB
/// ===============================

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
            leading: Icon(Icons.memory),
            title: Text("Whisper Model")),
        ListTile(
            leading: Icon(Icons.volume_up),
            title: Text("Voice Settings")),
        ListTile(
            leading: Icon(Icons.delete),
            title: Text("Clear Cache")),
      ],
    );
  }
}

/// ===============================
/// ABOUT TAB
/// ===============================

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "🇮🇳 🤝 🇺🇿\nOffline Live Interpreter\nPrivacy First",
        textAlign: TextAlign.center,
      ),
    );
  }
}
