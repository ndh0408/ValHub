import 'package:valvn/core/l10n/labels/community_labels.dart';

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/util/format.dart';
import '../../data/community_models.dart';
import '../../providers/skin_review_providers.dart';
import '../widgets/community_widgets.dart';
import 'star_rating.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Opens the review editor (create or edit). Resolves to `true` when saved.
Future<bool> showReviewEditor(
  BuildContext context, {
  required String puuid,
  required String skinUuid,
  String? weaponUuid,
  int initialRating = 0,
  String initialBody = '',
}) async {
  final saved = await showValSheet<bool>(
    context,
    title: context.l10n.communityYourReview,
    builder: (_, _) => ReviewEditorSheet(
      puuid: puuid,
      skinUuid: skinUuid,
      weaponUuid: weaponUuid,
      initialRating: initialRating,
      initialBody: initialBody,
    ),
  );
  return saved ?? false;
}

/// Stars (1–5) + optional text (≤ 500) + "Lưu đánh giá".
class ReviewEditorSheet extends ConsumerStatefulWidget {
  const ReviewEditorSheet({
    super.key,
    required this.puuid,
    required this.skinUuid,
    this.weaponUuid,
    this.initialRating = 0,
    this.initialBody = '',
  });

  final String puuid;
  final String skinUuid;
  final String? weaponUuid;
  final int initialRating;
  final String initialBody;

  @override
  ConsumerState<ReviewEditorSheet> createState() => _ReviewEditorSheetState();
}

class _ReviewEditorSheetState extends ConsumerState<ReviewEditorSheet> {
  late int _rating = widget.initialRating;
  late final _body = TextEditingController(text: widget.initialBody);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _body.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final problem = validateReview(rating: _rating, body: _body.text);
    final length = _body.text.trim().runes.length;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: StarRatingInput(
                  value: _rating,
                  onChanged: (v) => setState(() => _rating = v),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  _rating == 0
                      ? context.l10n.communityTapToRate
                      : context.l10n.communityRatingWord(_rating),
                  key: ValueKey(_rating),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _rating == 0 ? muted : starColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('review-body'),
              controller: _body,
              minLines: 3,
              maxLines: 6,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.l10n.communityReviewHint,
                errorText: problem == ReviewProblem.tooLong
                    ? context.l10n.communityTooLong(kMaxReviewLength)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                context.l10n.communityCharCount(
                  formatNumber(length),
                  formatNumber(kMaxReviewLength),
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: problem == ReviewProblem.tooLong
                      ? ValColors.red
                      : muted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: problem == null && !_saving
                    ? () => unawaited(_save())
                    : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.l10n.communitySaveReview),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await submitSkinReview(
        ref,
        puuid: widget.puuid,
        skinUuid: widget.skinUuid,
        weaponUuid: widget.weaponUuid,
        rating: _rating,
        body: _body.text,
      );
      Haptics.light();
      if (mounted) Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showCommunityError(context, e);
    }
  }
}
