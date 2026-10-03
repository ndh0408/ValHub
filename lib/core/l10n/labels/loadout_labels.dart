import '../../domain/loadout/loadout_repository.dart';
import '../l10n.dart';

extension LoadoutFailureDisplay on LoadoutSaveException {
  String message(AppLocalizations l10n) => l10n.loadoutSaveFailed;

  String? detail(AppLocalizations l10n) => switch (failure) {
    LoadoutSaveFailure.notPersisted => l10n.loadoutNotPersisted,
    LoadoutSaveFailure.invalidChange ||
    LoadoutSaveFailure.invalidLoadout => l10n.loadoutInvalidChange,
    LoadoutSaveFailure.request => null,
  };
}
