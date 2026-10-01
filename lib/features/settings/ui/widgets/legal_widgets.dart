import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../../legal/legal_documents.dart';
import '../legal_document_screen.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Opens Flutter's licence page for the third-party open-source libraries
/// bundled in the app (attribution required by their licences). VanHub
/// itself is proprietary — see [LegalDocuments.license].
void showThirdPartyLicenses(BuildContext context, {String? version}) =>
    showLicensePage(
      context: context,
      applicationName: context.l10n.commonAppName,
      applicationVersion: version,
      applicationLegalese:
          '${context.l10n.legalLicensePageLegalese}\n\n'
          '${context.l10n.commonRiotDisclaimer}',
    );

/// Pushes [doc] as a pageless route on the nearest navigator. Used where the
/// settings routes are not reachable (e.g. `/welcome` before sign-in, which
/// the router redirect keeps outside the tab shell).
Future<void> pushLegalDocument(BuildContext context, LegalDocument doc) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => LegalDocumentScreen(document: doc)),
    );

/// "Bằng việc tiếp tục, bạn đồng ý với Điều khoản sử dụng và Chính sách
/// quyền riêng tư của VanHub." with both names tappable.
class LegalConsentText extends StatefulWidget {
  const LegalConsentText({super.key, this.style, this.textAlign});

  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<LegalConsentText> createState() => _LegalConsentTextState();
}

class _LegalConsentTextState extends State<LegalConsentText> {
  late final _terms = TapGestureRecognizer()
    ..onTap = () => unawaited(pushLegalDocument(context, LegalDocuments.terms));
  late final _privacy = TapGestureRecognizer()
    ..onTap = () =>
        unawaited(pushLegalDocument(context, LegalDocuments.privacy));

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final link = TextStyle(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: scheme.primary.withValues(alpha: 0.5),
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: context.l10n.legalConsentPrefix),
          TextSpan(
            text: context.l10n.legalConsentTerms,
            style: link,
            recognizer: _terms,
          ),
          TextSpan(text: context.l10n.legalConsentAnd),
          TextSpan(
            text: context.l10n.legalConsentPrivacy,
            style: link,
            recognizer: _privacy,
          ),
          TextSpan(text: context.l10n.legalConsentSuffix),
        ],
      ),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
