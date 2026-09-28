import 'package:material_ui/material_ui.dart';

/// Global hook mounted by the app shell around the tab content. The
/// live_game feature uses it to poll for agent select / matches while the
/// app is in the foreground and to auto-open the "Chi tiết trận" sheet (G2).
///
/// Stub: a passthrough.
class LiveGameOverlayHost extends StatelessWidget {
  const LiveGameOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
