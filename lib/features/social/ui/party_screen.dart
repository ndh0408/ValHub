import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../social_strings.dart';

/// S55 "Tổ đội & hàng chờ". Route `/profile/party`.
class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SocialStrings.partyTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
