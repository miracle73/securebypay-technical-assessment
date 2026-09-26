import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/api_client.dart';
import 'core/auth_controller.dart';
import 'core/auth_scope.dart';
import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  wakeBackend();

  final auth = AuthController();
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
      controller: widget.auth,
      child: MaterialApp.router(
        title: 'Myafrimall',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }
}
