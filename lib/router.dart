import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/main.dart';
import 'package:template/src/services/auth_service.dart';
import 'package:template/src/views/add_friend_view.dart';
import 'package:template/src/views/chat_view.dart';
import 'package:template/src/views/home_view.dart';
import 'package:template/src/views/login_view.dart';
import 'package:template/src/views/profile_view.dart';
import 'package:template/src/views/register_view.dart';
import 'package:template/src/views/reset_password_view.dart';
import 'package:template/src/views/splash_view.dart';
import 'package:template/src/views/updates_view.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const SplashView(),
      ),
      redirect: (context, state) async {
        await Future.delayed(const Duration(seconds: 2)); // Splash delay
        final isLoggedIn = await AuthService().isLoggedIn();
        if (isLoggedIn) {
          return '/home';
        } else {
          return '/login';
        }
      },
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const LoginView(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => MaterialPage(
        child: const RegisterView(),
      ),
    ),
    GoRoute(
      path: '/reset-password',
      pageBuilder: (context, state) => MaterialPage(
        child: const ResetPasswordView(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const HomeView(),
      ),
      routes: [
        GoRoute(
          path: 'chats',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const HomeView(initialTab: 0),
          ),
        ),
        GoRoute(
          path: 'updates',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const HomeView(initialTab: 1),
          ),
        ),
        GoRoute(
          path: 'profile',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const HomeView(initialTab: 2),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/chat/:id',
      pageBuilder: (context, state) => MaterialPage(
        child: ChatView(
          chatId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/profile/:id',
      pageBuilder: (context, state) => MaterialPage(
        child: ProfileView(
          userId: state.pathParameters['id'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: '/add-friend',
      pageBuilder: (context, state) => MaterialPage(
        child: const AddFriendView(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);