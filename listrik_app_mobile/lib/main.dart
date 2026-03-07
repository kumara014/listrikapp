import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/customer/home_screen.dart';
import 'presentation/screens/customer/order_screen.dart';
import 'presentation/screens/customer/tracking_screen.dart';
import 'presentation/screens/partner/partner_home_screen.dart';
import 'presentation/screens/partner/work_order_screen.dart';
import 'presentation/screens/partner/partner_profile_screen.dart';
import 'presentation/screens/customer/certificate_screen.dart';
import 'presentation/screens/notification_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final loggedIn = authState != null;
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!loggedIn) {
          return isAuthRoute ? null : '/login';
        }

        if (isAuthRoute) {
          return authState.isPartner ? '/partner' : '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/order',
          builder: (context, state) => OrderScreen(serviceType: state.uri.queryParameters['serviceType']),
        ),
        GoRoute(
          path: '/tracking/:id',
          builder: (context, state) => TrackingScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/partner',
          builder: (context, state) => const PartnerHomeScreen(),
        ),
        GoRoute(
          path: '/partner/orders/:id',
          builder: (context, state) => WorkOrderScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/partner/profile',
          builder: (context, state) => const PartnerProfileScreen(),
        ),
        GoRoute(
          path: '/certificates',
          builder: (context, state) => const CertificateScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Listrik App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
