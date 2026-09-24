import 'package:go_router/go_router.dart';

import 'core/auth_controller.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/auth/sign_up_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

const _publicRoutes = {'/login', '/signup'};

/// Route guard: signed-out users can only see /login and /signup; signed-in
/// users are bounced from those to /dashboard. Re-evaluated whenever [auth]
/// notifies (login, logout, or a 401 that clears the session).
GoRouter buildRouter(AuthController auth) => GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: auth,
      redirect: (context, state) {
        final isPublic = _publicRoutes.contains(state.matchedLocation);
        if (!auth.isAuthenticated && !isPublic) return '/login';
        if (auth.isAuthenticated && isPublic) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/dashboard'),
        GoRoute(path: '/login', builder: (_, __) => const SignInScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      ],
    );
