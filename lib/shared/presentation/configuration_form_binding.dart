import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/auth_context.dart';
import '../navigation/form_navigation_guard.dart';

/// Owns the guard independently of BLoC rebuilds and stale page disposal.
class ConfigurationFormBinding extends StatefulWidget {
  const ConfigurationFormBinding({
    super.key,
    required this.guard,
    required this.account,
    required this.dirty,
    required this.saving,
    required this.child,
  });
  final FormNavigationGuard guard;
  final AuthContext account;
  final bool dirty, saving;
  final Widget child;
  @override
  State<ConfigurationFormBinding> createState() => _Binding();
}

class _Binding extends State<ConfigurationFormBinding> {
  @override
  void initState() {
    super.initState();
    widget.guard.attach(this, widget.account);
    _update();
  }

  @override
  void didUpdateWidget(ConfigurationFormBinding old) {
    super.didUpdateWidget(old);
    _update();
  }

  void _update() {
    if (identical(widget.guard.owner, this)) {
      widget.guard.dirty = widget.dirty;
      widget.guard.saving = widget.saving;
    }
  }

  @override
  void dispose() {
    widget.guard.detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
