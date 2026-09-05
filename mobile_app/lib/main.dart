import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'logic/ai_chat/ai_chat_bloc.dart';
import 'logic/ai_chat/ai_chat_repository.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/auth/auth_repository.dart';
import 'logic/camera/camera_bloc.dart';
import 'logic/camera/camera_repository.dart';
import 'logic/leaderboard/leaderboard_bloc.dart';
import 'logic/leaderboard/leaderboard_repository.dart';
import 'logic/map/map_bloc.dart';
import 'logic/map/map_repository.dart';
import 'presentation/screens/ai_chat_screen.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/leaderboard_screen.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/quest_screen.dart';

void main() {
  runApp(const CleanShoreApp());
}

class CleanShoreApp extends StatelessWidget {
  const CleanShoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final mapRepository = MapRepository();
    final leaderboardRepository = LeaderboardRepository();
    final cameraRepository = CameraRepository();
    final aiChatRepository = AiChatRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository: authRepository)
            ..add(const AuthCheckRequested()),
        ),
        BlocProvider<MapBloc>(
          create: (_) => MapBloc(mapRepository: mapRepository),
        ),
        BlocProvider<LeaderboardBloc>(
          create: (_) => LeaderboardBloc(leaderboardRepository: leaderboardRepository),
        ),
        BlocProvider<CameraBloc>(
          create: (_) => CameraBloc(cameraRepository: cameraRepository),
        ),
        BlocProvider<AiChatBloc>(
          create: (_) => AiChatBloc(aiChatRepository: aiChatRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Чистый берег',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          return const _MainTabScaffold();
        }

        return const AuthScreen();
      },
    );
  }
}

class _MainTabScaffold extends StatefulWidget {
  const _MainTabScaffold();

  @override
  State<_MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<_MainTabScaffold> {
  int _currentIndex = 0;

  static const _screens = [
    MapScreen(),
    QuestScreen(),
    AiChatScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Карта'),
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), label: 'Квесты'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'Эко-Ассистент'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), label: 'Рейтинг'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
        ],
      ),
    );
  }
}