import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:trans_bridge/views/app_view.dart';
import 'package:trans_bridge/views/home_view/home_view.dart';
import 'package:trans_bridge/views/live_support_view/live_support_view.dart'; // Mevcut canlı destek view'ı
import 'package:trans_bridge/views/past_view/past_view.dart';
import 'package:trans_bridge/views/profile_view/profile_view.dart';
import 'package:trans_bridge/features/sign_language_translation/sign_language_translation_page.dart'; // Senin yeni sayfan
import 'package:trans_bridge/features/live_support/live_support_page.dart'; // Senin yeni canlı destek sayfası
import 'package:trans_bridge/features/live_support/live_video_call_page.dart'; // Senin yeni canlı video çağrı sayfası

// Arkadaşının eklediği login/register/forgot password view'ları
import 'package:trans_bridge/views/login_view.dart';
import 'package:trans_bridge/views/register_view.dart';
import 'package:trans_bridge/views/forgot_password_view.dart';


final _routerKey = GlobalKey<NavigatorState>();

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String past = '/past';
  static const String livesupport = '/livesupport';
  static const String profile = '/profile';
  static const String signLanguage = '/sign_language'; // Senin yeni rota
  static const String liveVideoCall = 'call'; // livesupport altında nested rota olacak

  // Arkadaşının eklediği login/register/forgot password rotaları
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
}

final router = GoRouter(
  navigatorKey: _routerKey,
  initialLocation: AppRoutes.login, // Uygulamanın başlangıç rotası (login olarak ayarlandı)
  routes: [
    // Arkadaşının eklediği login/register/forgot password rotaları
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterView(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordView(),
    ),
    
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppView(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.past,
              builder: (context, state) => const PastView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.livesupport,
              builder: (context, state) => const LiveSupportPage(), // Burayı LiveSupportView yerine LiveSupportPage olarak güncelliyoruz
              routes: [
                GoRoute(
                  path: AppRoutes.liveVideoCall + '/:volunteerName', // /livesupport/call/:volunteerName
                  builder: (BuildContext context, GoRouterState state) {
                    final volunteerName = state.pathParameters['volunteerName']!;
                    return LiveVideoCallPage(volunteerName: volunteerName);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileView(),
            ),
          ],
        ),
      ],
    ),
    // Senin yeni işaret dili çeviri sayfasını doğrudan routes listesine ekle (StatefulShellRoute dışında)
    GoRoute(
      path: AppRoutes.signLanguage,
      builder: (BuildContext context, GoRouterState state) {
        return const SignLanguageTranslationPage();
      },
    ),
  ],
);
