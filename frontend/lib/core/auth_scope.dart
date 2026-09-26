import 'package:flutter/widgets.dart';

import 'auth_controller.dart';

/// Exposes the [AuthController] to the widget tree.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({super.key, required AuthController controller, required super.child}) : super(notifier: controller);

  /// Subscribes the caller to session changes.
  static AuthController of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;

  /// Reads the controller without subscribing; use from callbacks and initState.
  static AuthController read(BuildContext context) => context.getInheritedWidgetOfExactType<AuthScope>()!.notifier!;
}
