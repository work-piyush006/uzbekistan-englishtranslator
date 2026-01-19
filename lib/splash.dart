import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AppStage {
  splash,
  permission,
  auth,
  menu,
  live,
}

class SplashFlow extends StatefulWidget {
  const SplashFlow({super.key});

  @override
  State<SplashFlow> createState() => _SplashFlowState();
}

class _SplashFlowState extends State<SplashFlow> {
  AppStage stage = AppStage.splash;
  String liveMode = ""; // listen | speak

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => stage = AppStage.permission);
  }

  @override
  Widget build(BuildContext context) {
    switch (stage) {
      case AppStage.splash:
        return _splashScreen();
      case AppStage.permission:
        return _permissionScreen();
      case AppStage.auth:
        return _authScreen();
      case AppStage.menu:
        return _menuScreen();
      case AppStage.live:
        return _liveScreen();
    }
  }

  // ───────────────── SPLASH ─────────────────
  Widget _splashScreen() {
    return const Scaffold(
      body: Center(
        child: Text(
          "English ↔ Uzbek\nLive Interpreter",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ─────────────── PERMISSION ───────────────
  Widget _permissionScreen() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "We need microphone access\nfor live translation",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text("Allow & Continue"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    final mic = await Permission.microphone.request();
    if (mic.isGranted) {
      setState(() => stage = AppStage.auth);
    }
  }

  // ─────────────── AUTH SCREEN ───────────────
  Widget _authScreen() {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Continue with Google"),
          onPressed: _googleLogin,
        ),
      ),
    );
  }

  Future<void> _googleLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    setState(() => stage = AppStage.menu);
  }

  // ─────────────── MAIN MENU ───────────────
  Widget _menuScreen() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Live Interpreter",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              liveMode = "listen";
              setState(() => stage = AppStage.live);
            },
            child: const Text("👂 Listen Them\nUzbek → English"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              liveMode = "speak";
              setState(() => stage = AppStage.live);
            },
            child: const Text("🗣️ Speak for Me\nEnglish → Uzbek"),
          ),
        ],
      ),
    );
  }

  // ─────────────── LIVE SCREEN ───────────────
  Widget _liveScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("● Live"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => stage = AppStage.menu),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mic, size: 80),
          const SizedBox(height: 20),
          Text(
            liveMode == "listen"
                ? "Listening Uzbek → English"
                : "Speaking English → Uzbek",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          const Text(
            "🎤 Live interpreter running",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
