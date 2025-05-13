import 'package:flutter/material.dart';
import 'package:frontend/screens/chat_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/mypage_screen.dart';
import 'package:frontend/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Pretendard'),
      home: const AuthGate(), // 초기 화면 분기 (로그인 여부에 따라)
      routes: {
        '/home': (context) => const HomeScreen(),
        '/mypage': (context) => const MyPageScreen(),
        '/login': (context) => const LoginScreen(),
        '/history': (context) => const ChatHistoryScreen(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', '')],
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 토큰 불러오기
    _initFuture = context.read<AuthProvider>().loadTokenFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
        return isLoggedIn ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
