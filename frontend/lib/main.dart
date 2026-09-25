import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/api_client.dart';
import 'core/auth_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // clean URLs (/login) instead of /#/login
  wakeBackend();
  final auth = AuthController();
  // Restore before the first frame so the router never flashes the wrong screen.
  await auth.restore();
  runApp(App(auth: auth));
}

class App extends StatefulWidget {
  const App({super.key, required this.auth});

  final AuthController auth;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final _router = buildRouter(widget.auth);

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: widget.auth,
      child: MaterialApp.router(
        title: 'Myafrimall',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }
}

/// Exposes the [AuthController] to the widget tree without a DI package.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({super.key, required super.notifier, required super.child});

  static AuthController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;

  /// Access without subscribing to rebuilds (for callbacks).
  static AuthController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AuthScope>()!.notifier!;
}
