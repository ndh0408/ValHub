// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Voir la source des tarifs';

  @override
  String get commonErrorApi =>
      'Riot rencontre un problème. Réessayez dans quelques minutes.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClearFilters => 'Effacer les filtres';

  @override
  String get commonClearSearch => 'Effacer la recherche';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonCopied => 'Copié';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jours',
      one: '$n jour',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'il y a $n jours',
      one: 'il y a $n jour',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEmptyGeneric => 'Rien à afficher ici.';

  @override
  String get commonErrorContentUnavailable =>
      'Impossible de charger les infos des skins, agents et cartes. Vérifiez votre connexion et réessayez.';

  @override
  String get commonErrorGeneric => 'Un problème est survenu. Réessayez.';

  @override
  String get commonErrorMaintenance =>
      'Les serveurs VALORANT sont en maintenance. Revenez plus tard.';

  @override
  String get commonErrorNeedsLogin =>
      'Votre connexion Riot a expiré. Reconnectez-vous pour continuer.';

  @override
  String get commonErrorNeedsLoginTitle => 'Reconnexion requise';

  @override
  String get commonErrorNetwork =>
      'Pas de connexion. Vérifiez votre Wi-Fi ou vos données mobiles et réessayez.';

  @override
  String get commonErrorNoAccount => 'Vous n\'êtes connecté à aucun compte.';

  @override
  String get commonErrorNotFound => 'Contenu introuvable.';

  @override
  String get commonErrorTimeout =>
      'Riot met trop de temps à répondre. Vérifiez votre connexion et réessayez.';

  @override
  String get commonErrorTransient =>
      'Riot est très sollicité. Réessayez dans quelques minutes.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot est très sollicité. Réessayez dans $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Impossible de déterminer votre région Riot. Choisissez-la dans les Paramètres.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Retour à l\'accueil';

  @override
  String commonHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n heures',
      one: '$n heure',
    );
    return '$_temp0';
  }

  @override
  String commonHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'il y a $n heures',
      one: 'il y a $n heure',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'Incident serveur';

  @override
  String get commonJustNow => 'à l\'instant';

  @override
  String get commonLoadMore => 'Charger plus';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonMaintenanceTitle => 'Maintenance des serveurs';

  @override
  String commonMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes',
      one: '$n minute',
    );
    return '$_temp0';
  }

  @override
  String commonMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'il y a $n minutes',
      one: 'il y a $n minute',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'Rien à afficher pour l\'instant';

  @override
  String commonOfflineCached(String time) {
    return 'Hors ligne : affichage de la version enregistrée ($time).';
  }

  @override
  String get commonOpenSettings => 'Ouvrir les paramètres';

  @override
  String get commonPageNotFound => 'Écran introuvable.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Pack le plus avantageux : $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Modifier le prix saisi';

  @override
  String get commonPriceEnterOwn => 'Saisir le prix de votre pack de VP';

  @override
  String get commonPriceEstimateBody =>
      'Le montant « ≈ … » à côté du prix en VP est une estimation, calculée d\'après le pack de VP le plus avantageux. Vous payez en VP dans le jeu ; le montant réel dépend du pack acheté, du moyen de paiement, des taxes et des promotions au moment de l\'achat.';

  @override
  String get commonPriceEstimateTitle => 'Prix converti estimé';

  @override
  String get commonPriceEstimateTooltip =>
      'Prix estimé : touchez pour voir le calcul';

  @override
  String get commonPriceHidden =>
      'Prix convertis masqués. Réactivez-les dans les Paramètres.';

  @override
  String get commonPriceHide => 'Masquer les prix convertis';

  @override
  String get commonPriceOpenSource => 'Ouvrir la source';

  @override
  String get commonPriceOverrideBody =>
      'Saisissez le montant que vous avez réellement payé pour un pack de VP (voir la boutique du jeu ou votre facture). ValHub s\'en sert pour estimer le prix converti de chaque objet ; ce prix est enregistré uniquement sur cet appareil.';

  @override
  String get commonPriceOverrideCurrency => 'Code de devise';

  @override
  String get commonPriceOverrideCurrencyHint => 'Ex. : EUR, USD, CAD, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Exemple d\'estimation : $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Saisissez un code de devise à 3 lettres, par exemple EUR ou USD.';

  @override
  String get commonPriceOverrideInvalidNumber =>
      'Saisissez un nombre supérieur à 0.';

  @override
  String get commonPriceOverridePrice => 'Prix du pack';

  @override
  String get commonPriceOverrideRemove => 'Supprimer le prix saisi';

  @override
  String get commonPriceOverrideRemoved => 'Prix saisi supprimé.';

  @override
  String get commonPriceOverrideSave => 'Enregistrer';

  @override
  String get commonPriceOverrideSaved => 'Prix de votre pack de VP enregistré.';

  @override
  String get commonPriceOverrideTitle => 'Prix de votre pack de VP';

  @override
  String get commonPriceOverrideVp => 'Nombre de VP du pack';

  @override
  String get commonPricePacksTitle => 'Packs de VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'D\'après les tarifs des packs de VP (région : $country)';
  }

  @override
  String get commonPriceSourceUser =>
      'D\'après le prix de pack de VP que vous avez saisi';

  @override
  String get commonPriceUnavailable =>
      'Aucun tarif vérifié pour votre région pour l\'instant. Saisissez le prix d\'un pack de VP que vous avez acheté pour voir une estimation du prix converti.';

  @override
  String commonPriceUpdated(String date) {
    return 'Tarifs mis à jour : $date';
  }

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonRiotDisclaimer =>
      'ValHub n\'est pas approuvé par Riot Games et ne reflète pas les opinions de Riot Games ni de quiconque ayant participé à la production ou à la gestion des produits de Riot Games. Riot Games et tous les éléments associés sont des marques commerciales ou des marques déposées de Riot Games, Inc.';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonSearch => 'Rechercher…';

  @override
  String commonSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n secondes',
      one: '$n seconde',
    );
    return '$_temp0';
  }

  @override
  String get commonShare => 'Partager';

  @override
  String get commonSignInAgain => 'Se reconnecter';

  @override
  String get commonSort => 'Trier';

  @override
  String commonSortBy(String option) {
    return 'Tri : $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'Collection';

  @override
  String get commonTabCommunity => 'Communauté';

  @override
  String get commonTabHome => 'Accueil';

  @override
  String get commonTabProfile => 'Profil';

  @override
  String get commonTabSettings => 'Paramètres';

  @override
  String get commonTabStore => 'Boutique';

  @override
  String get commonTagline => 'Votre compagnon VALORANT';

  @override
  String get commonToday => 'Aujourd\'hui';

  @override
  String get commonTodayLower => 'aujourd\'hui';

  @override
  String get commonTomorrow => 'demain';

  @override
  String get commonUnknownItem => 'Objet sans nom';

  @override
  String commonUpdatedAt(String time) {
    return 'Mis à jour à $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$day à $time';
  }

  @override
  String get commonWeekdaysItem0 => 'Lundi';

  @override
  String get commonWeekdaysItem1 => 'Mardi';

  @override
  String get commonWeekdaysItem2 => 'Mercredi';

  @override
  String get commonWeekdaysItem3 => 'Jeudi';

  @override
  String get commonWeekdaysItem4 => 'Vendredi';

  @override
  String get commonWeekdaysItem5 => 'Samedi';

  @override
  String get commonWeekdaysItem6 => 'Dimanche';

  @override
  String get commonYesterday => 'hier';

  @override
  String get commonYesterdayTitle => 'Hier';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Connexion Riot expirée : affichage de la version enregistrée ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Armes lourdes';

  @override
  String get contentCategoryMelee => 'Mêlée';

  @override
  String get contentCategoryRifle => 'Fusils d\'assaut';

  @override
  String get contentCategoryShotgun => 'Fusils à pompe';

  @override
  String get contentCategorySidearm => 'Armes de poing';

  @override
  String get contentCategorySmg => 'PM';

  @override
  String get contentCategorySniper => 'Fusils de sniper';

  @override
  String get contentCurrencyAgentTokens => 'Jetons d\'agent';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Crédits Kingdom';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Radianite';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT Points';

  @override
  String get contentItemAgent => 'Agent';

  @override
  String get contentItemBuddy => 'Breloque';

  @override
  String get contentItemCard => 'Carte de joueur';

  @override
  String get contentItemChroma => 'Variante';

  @override
  String get contentItemContract => 'Contrat';

  @override
  String get contentItemCurrency => 'Devise';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Tag';

  @override
  String get contentItemTitle => 'Titre de joueur';

  @override
  String contentLevel(int n) {
    return 'Niveau $n';
  }

  @override
  String get contentLevelBase => 'Base';

  @override
  String get contentLevelItemLabelsVFX => 'Effets visuels';

  @override
  String get contentLevelItemLabelsAnimation => 'Animation';

  @override
  String get contentLevelItemLabelsFinisher => 'Coup de grâce';

  @override
  String get contentLevelItemLabelsKillCounter => 'Compteur d\'éliminations';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Effets sonores';

  @override
  String get contentLevelItemLabelsTransformation => 'Transformation';

  @override
  String get contentLevelItemLabelsKillBanner => 'Bannière d\'élimination';

  @override
  String get contentLevelItemLabelsKillEffect => 'Effet d\'élimination';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'Effets d\'inspection et d\'élimination';

  @override
  String get contentLevelItemLabelsVoiceover => 'Doublage';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Changement de musique';

  @override
  String get contentLevelItemLabelsRandomizer => 'Aléatoire';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Selon le camp (attaque/défense)';

  @override
  String get contentLevelItemLabelsTopFrag => 'Effet top frag';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Capteur cardiaque et de carte';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Animation de poisson';

  @override
  String get contentNoTitle => 'Aucun titre';

  @override
  String get contentNotForSale => 'Pas en vente';

  @override
  String get contentQueueNamesCompetitive => 'Compétition';

  @override
  String get contentQueueNamesUnrated => 'Non classé';

  @override
  String get contentQueueNamesSwiftplay => 'Vélocité';

  @override
  String get contentQueueNamesSpikerush => 'Spike Rush';

  @override
  String get contentQueueNamesDeathmatch => 'Combat à mort';

  @override
  String get contentQueueNamesHurm => 'Combat à mort par équipe';

  @override
  String get contentQueueNamesGgteam => 'Intensification';

  @override
  String get contentQueueNamesOnefa => 'Réplication';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Partie personnalisée';

  @override
  String get contentQueueNames => 'Partie personnalisée';

  @override
  String get contentQueueNamesDodgeball => 'K.-O.';

  @override
  String get contentQueueNamesFortcollins => 'Retake';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Escarmouche : 2c2';

  @override
  String get contentQueueNamesSkirmishascension1v1 =>
      'Escarmouche : Ascension 1c1';

  @override
  String get contentQueueNamesSkirmishascension2v2 =>
      'Escarmouche : Ascension 2c2';

  @override
  String get contentQueueNamesValaram => 'All Random One Site';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Bataille de boules de neige';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Compétition';

  @override
  String get contentQueueShortNamesValaram => 'Aléatoire 1 site';

  @override
  String get contentRewardSourceAgent => 'Contrat d\'agent';

  @override
  String get contentRewardSourceBattlePass => 'Récompense du Battle Pass';

  @override
  String get contentRewardSourceEvent => 'Passe d\'événement';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Duelliste';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Initiateur';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Contrôleur';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Sentinelle';

  @override
  String get contentTierDeluxe => 'Deluxe';

  @override
  String get contentTierExclusive => 'Exclusive';

  @override
  String contentTierFull(String shortName) {
    return 'Édition $shortName';
  }

  @override
  String get contentTierPremium => 'Premium';

  @override
  String get contentTierSelect => 'Sélect';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'Non classé';

  @override
  String get accountRegionUnknown => 'Serveur inconnu';

  @override
  String accountRiotCountry(String country) {
    return 'Pays du compte Riot : $country';
  }

  @override
  String get accountRiotCountryUnknown => 'Pays du compte Riot : inconnu';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'COMPTES ($count/$max)';
  }

  @override
  String get accountActive => 'Actif';

  @override
  String accountAddAccount(int count, int max) {
    return 'Ajouter un compte ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Effacer les données locales';

  @override
  String get accountClearLocalDataConfirm =>
      'Effacer l\'historique, les configurations enregistrées et les données des comptes déconnectés sur cet appareil ?';

  @override
  String get accountClearRrHistory => 'Effacer l\'historique RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'Effacer l\'historique RR du compte sélectionné sur cet appareil ?';

  @override
  String get accountCopyPassword => 'Copier le mot de passe';

  @override
  String get accountCopyUsername => 'Copier le nom d\'utilisateur';

  @override
  String get accountDeleteLoginNote => 'Supprimer les identifiants';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Supprimer le nom d\'utilisateur et le mot de passe enregistrés pour ce compte ?';

  @override
  String get accountHidePassword => 'Masquer le mot de passe';

  @override
  String get accountKeepLocalData => 'Conserver les données locales';

  @override
  String get accountKeepLocalDataHint =>
      'Conserver la wishlist, les configurations et l\'historique sur cet appareil';

  @override
  String accountLevelShort(int level) {
    return 'Niv. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'Le compte de cette notification est déconnecté. Reconnectez-vous puis rouvrez la notification.';

  @override
  String get accountLocalDataCleared => 'Données locales effacées';

  @override
  String get accountLoginNote => 'Identifiants';

  @override
  String get accountLoginNoteDeleted => 'Identifiants supprimés';

  @override
  String get accountLoginNoteEmpty => 'Aucun identifiant enregistré';

  @override
  String get accountLoginNoteHint =>
      'Enregistrés uniquement sur cet appareil, sous verrou sécurisé. Pour les revoir ou les saisir rapidement lors de votre prochaine connexion.';

  @override
  String get accountLoginNoteLocked => 'Déverrouiller les identifiants';

  @override
  String get accountLoginNotePassword => 'Mot de passe';

  @override
  String get accountLoginNoteSaved => 'Identifiants enregistrés';

  @override
  String get accountLoginNoteUsername => 'Nom d\'utilisateur Riot';

  @override
  String get accountManageHint =>
      'Supprimez un compte ou modifiez ses identifiants dans les Paramètres.';

  @override
  String accountMaxAccounts(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Limite de $max comptes atteinte.',
      one: 'Limite de $max compte atteinte.',
    );
    return '$_temp0';
  }

  @override
  String get accountNeedsLogin => 'Reconnexion requise';

  @override
  String accountOnlineCount(int count) {
    return '$count en ligne';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'Remplir avec un compte enregistré';

  @override
  String get accountQuickFillDone => 'C\'est rempli. Appuyez sur Se connecter.';

  @override
  String get accountQuickFillNotReady =>
      'La page de connexion n\'a pas fini de charger. Patientez un instant et réessayez.';

  @override
  String get accountQuickFillSubtitle =>
      'Choisissez un compte à remplir sur la page de connexion Riot';

  @override
  String get accountQuickFillTitle => 'Remplir avec un compte enregistré';

  @override
  String get accountRegionAp => 'Asie-Pacifique';

  @override
  String get accountRegionBr => 'Brésil';

  @override
  String get accountRegionEu => 'Europe';

  @override
  String get accountRegionKr => 'Corée';

  @override
  String get accountRegionLatam => 'Amérique latine';

  @override
  String get accountRegionNa => 'Amérique du Nord';

  @override
  String get accountRemoveAccount => 'Supprimer le compte';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Supprimer $account de cet appareil ? Vous pouvez choisir de conserver les données enregistrées.';
  }

  @override
  String get accountRrHistoryCleared => 'Historique RR effacé';

  @override
  String get accountShowPassword => 'Afficher le mot de passe';

  @override
  String get accountSignOutAll => 'Déconnecter tous les comptes';

  @override
  String get accountSignOutAllConfirm =>
      'Se déconnecter et supprimer tous les comptes de cet appareil ? Vous pouvez choisir de conserver les données enregistrées.';

  @override
  String get accountStatusAgentSelect => 'Sélection d\'agent';

  @override
  String get accountStatusInMatch => 'En partie';

  @override
  String get accountStatusOffline => 'Hors ligne';

  @override
  String get accountStatusOnline => 'En ligne';

  @override
  String get accountStatusUnknown => 'Statut inconnu';

  @override
  String accountSwitchTo(String account) {
    return 'Passer à $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Touchez pour changer de compte';

  @override
  String get accountSwitcherTitle => 'Comptes';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Comptes ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Joueur';

  @override
  String get accountUnlockLoginNote =>
      'Authentifiez-vous pour afficher vos identifiants Riot';

  @override
  String get authAddAsNew => 'Ajouter comme nouveau compte';

  @override
  String get authDifferentAccountBody =>
      'Vous venez de vous connecter avec un compte différent de celui à reconnecter. L\'ajouter comme nouveau compte ?';

  @override
  String get authDifferentAccountTitle => 'Compte différent';

  @override
  String get authLoadingAccount => 'Chargement du compte…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot a refusé cette connexion. Réessayez.';

  @override
  String get authLoginFailed => 'Connexion impossible';

  @override
  String get authLoginFailedBody =>
      'Riot n\'a pas confirmé votre connexion. Réessayez.';

  @override
  String get authLoginTitle => 'Connexion Riot';

  @override
  String get authMissingCookies =>
      'Impossible de garder votre connexion sur cet appareil : vous devrez vous reconnecter quand elle expirera.';

  @override
  String get authOfficialHost => 'Page officielle · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Lien ouvert dans le navigateur.';

  @override
  String get authPageLoadFailed =>
      'Impossible de charger la page de connexion Riot. Vérifiez votre connexion et réessayez.';

  @override
  String get authPreparing => 'Préparation de la page de connexion…';

  @override
  String get authReloginDone => 'Reconnecté';

  @override
  String get authSignInCta => 'Se connecter avec un compte Riot';

  @override
  String get authSocialLoginHint =>
      'Si la connexion via Google ou Facebook ne fonctionne pas, utilisez votre nom d\'utilisateur Riot.';

  @override
  String get authStateMismatch =>
      'Cette tentative de connexion n\'est pas valide. Recommencez la connexion depuis le début.';

  @override
  String get notificationSessionExpiredBody =>
      'Reconnectez-vous pour continuer à recevoir les notifications de wishlist.';

  @override
  String get notificationBackgroundTimingHint =>
      'Le mode économie d\'énergie de l\'appareil peut retarder les notifications.';

  @override
  String get notificationChannelAccountDescription =>
      'Rappel quand un compte doit se reconnecter';

  @override
  String get notificationChannelAccountName => 'Comptes';

  @override
  String get notificationChannelBattlePassDescription =>
      'Rappels de progression et de fin du Battle Pass';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'Activité de la communauté quand vous ouvrez ValHub';

  @override
  String get notificationChannelCommunityName => 'Communauté';

  @override
  String get notificationChannelLfgDescription =>
      'Joueurs qui rejoignent votre groupe quand vous ouvrez ValHub';

  @override
  String get notificationChannelLfgName => 'Groupe';

  @override
  String get notificationChannelNightMarketDescription =>
      'Alerte à l\'ouverture du Marché nocturne';

  @override
  String get notificationChannelNightMarketName => 'Marché nocturne';

  @override
  String get notificationChannelRankDescription =>
      'Changements de rang quand vous actualisez votre profil';

  @override
  String get notificationChannelRankName => 'Rang';

  @override
  String get notificationChannelStoreResetDescription =>
      'Rappel au renouvellement de la boutique quotidienne';

  @override
  String get notificationChannelStoreResetName =>
      'Renouvellement de la boutique';

  @override
  String get notificationChannelWishlistDescription =>
      'Alerte quand un skin de votre wishlist apparaît en boutique';

  @override
  String get notificationChannelWishlistName => 'Wishlist';

  @override
  String get notificationLfgJoinedTitle => 'Un joueur a rejoint votre groupe';

  @override
  String get notificationLocalOnlyHint =>
      'Alertes uniquement sur cet appareil, quand ValHub actualise ses données';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Retournez vos cartes d\'offre sur $account ($cards) dès maintenant.';
  }

  @override
  String get notificationNightMarketOpenTitle =>
      'Le Marché nocturne est ouvert !';

  @override
  String get notificationPassEndingBody =>
      'Il reste environ un jour au Battle Pass. Ouvrez ValHub pour voir votre progression.';

  @override
  String get notificationPassEndingTitle => 'Le Battle Pass se termine bientôt';

  @override
  String notificationPassProgressBody(int level) {
    return 'Vous avez atteint le niveau $level du Battle Pass actuel.';
  }

  @override
  String get notificationPassProgressTitle => 'Progression du Battle Pass';

  @override
  String get notificationPrivateAccount => 'votre compte';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Rang actuel : $rank. Données tout juste mises à jour depuis Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Votre rang a changé';

  @override
  String get notificationResetTimingUnknown =>
      'Ouvrez la boutique pour mettre à jour l\'heure de renouvellement sur votre appareil.';

  @override
  String get notificationSessionExpiredTitle => 'Reconnexion requise';

  @override
  String get notificationStoreResetBody =>
      'De nouveaux skins vous attendent en boutique.';

  @override
  String get competitiveDivisionIron => 'Fer';

  @override
  String get competitiveDivisionBronze => 'Bronze';

  @override
  String get competitiveDivisionSilver => 'Argent';

  @override
  String get competitiveDivisionGold => 'Or';

  @override
  String get competitiveDivisionPlatinum => 'Platine';

  @override
  String get competitiveDivisionDiamond => 'Diamant';

  @override
  String get competitiveDivisionAscendant => 'Ascendant';

  @override
  String get competitiveDivisionImmortal => 'Immortel';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Radiant';

  @override
  String get competitiveRankUnknown => 'Rang inconnu';

  @override
  String get competitiveAttack => 'Attaque';

  @override
  String get competitiveCannotEstimate => 'Estimation impossible';

  @override
  String get competitiveDefeat => 'Défaite';

  @override
  String get competitiveDefense => 'Défense';

  @override
  String get competitiveDraw => 'Égalité';

  @override
  String get competitiveIncognitoPlayer => 'Joueur incognito';

  @override
  String get competitiveMatchPending => 'Riot traite la partie…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Encore $n matchs de placement',
      one: 'Encore $n match de placement',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'Spike désamorcé';

  @override
  String get competitiveRoundDetonate => 'Explosion du Spike';

  @override
  String get competitiveRoundElimination => 'Élimination';

  @override
  String get competitiveRoundSurrendered => 'Capitulation';

  @override
  String get competitiveRoundTimeExpired => 'Temps écoulé';

  @override
  String get competitiveUnknownPlayer => 'Joueur';

  @override
  String get competitiveVictory => 'Victoire';

  @override
  String economyAvailableNow(String place) {
    return 'En vente maintenant : $place !';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'bundle $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'bundle';

  @override
  String get economyPlaceDaily => 'boutique quotidienne';

  @override
  String get economyPlaceNightMarket => 'Marché nocturne';

  @override
  String get economyPriceEstimated => 'Prix estimé selon l\'édition';

  @override
  String get economyPriceFromOffers => 'Prix issu des tarifs Riot';

  @override
  String get economyPriceFromStore => 'Prix vu en boutique';

  @override
  String get economyPriceFromTable => 'Prix catalogue';

  @override
  String get economyPriceUnknown => 'Prix inconnu';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Configuration $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Ce changement ne s\'applique pas à votre équipement actuel.';

  @override
  String get loadoutNotPersisted =>
      'Riot n\'a pas enregistré vos changements : votre équipement n\'a pas changé. Réessayez.';

  @override
  String get loadoutSaveFailed => 'Impossible d\'enregistrer l\'équipement';

  @override
  String battlePassActEndsIn(String time) {
    return 'Fin de l\'acte dans $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Fin de l\'acte dans $days jours',
      one: 'Fin de l\'acte dans $days jour',
    );
    return '$_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'Toutes les missions sont terminées';

  @override
  String get battlePassAllWeeklyDone =>
      'Toutes les missions hebdomadaires sont terminées';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Bonus doublés en attente : $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Chapitre $n';
  }

  @override
  String battlePassChapterProgress(int reached, int total) {
    return '$reached/$total';
  }

  @override
  String battlePassCharges(int charges, int needed) {
    return '$charges/$needed';
  }

  @override
  String get battlePassCheckpointHint =>
      'Gagnez des manches pour progresser vers le palier (hors Combat à mort).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Palier $index : $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Chaque palier : +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Paliers atteints : $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'Actuel';

  @override
  String get battlePassDailyAllDone => 'Tous les paliers du jour sont atteints';

  @override
  String get battlePassDailyCaption => 'Récompenses quotidiennes';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Récompenses quotidiennes · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Les paliers de la veille ont expiré. Lancez le jeu ou actualisez ici.';

  @override
  String get battlePassDailyMissions => 'Missions quotidiennes';

  @override
  String get battlePassDailyNotReady =>
      'Les paliers du jour ne sont pas encore prêts. Lancez le jeu ou actualisez ici.';

  @override
  String get battlePassDailyPlayToStart =>
      'Les paliers du jour ne sont pas encore prêts. Lancez le jeu pour démarrer la journée.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours restants',
      one: '$days jour restant',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Se termine $wall';
  }

  @override
  String get battlePassEpilogue => 'Épilogue';

  @override
  String get battlePassEstimateNote =>
      'Estimation d\'environ 4 000 XP par partie, hors missions.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Se termine dans $time';
  }

  @override
  String get battlePassEventPass => 'Passe d\'événement';

  @override
  String get battlePassFilterAll => 'Tout';

  @override
  String get battlePassFilterLocked => 'Verrouillé';

  @override
  String get battlePassFilterUnlocked => 'Débloqué';

  @override
  String get battlePassFree => 'Gratuit';

  @override
  String get battlePassFreeTrack => 'Récompenses gratuites';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Niveau $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Niv. $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString parties',
      one: '$nString partie',
    );
    return '≈ $_temp0 en $queue';
  }

  @override
  String get battlePassMissionDone => 'Terminée';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return 'Terminées : $done/$total';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Nouvelles missions $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Nouvelles missions dans $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Palier suivant : $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Vers le niveau $level';
  }

  @override
  String get battlePassNextReward => 'Suivant';

  @override
  String get battlePassNoBattlePass =>
      'Aucune info sur le Battle Pass de l\'acte en cours. Réessayez plus tard.';

  @override
  String get battlePassNoRewards =>
      'Aucune récompense pour ce Battle Pass pour l\'instant.';

  @override
  String get battlePassNoRewardsInFilter =>
      'Aucune récompense dans cette catégorie.';

  @override
  String get battlePassNoRewardsTitle => 'Aucune récompense';

  @override
  String get battlePassNoWeeklyMissions =>
      'Aucune mission hebdomadaire pour l\'instant.';

  @override
  String get battlePassPassComplete => 'Battle Pass terminé';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'Vous n\'avez pas acheté le Premium : vous ne recevez que les récompenses gratuites. Achetez le Premium en jeu pour débloquer les niveaux atteints.';

  @override
  String get battlePassRenewButton => 'Actualiser les paliers';

  @override
  String get battlePassRenewDone => 'Paliers quotidiens actualisés.';

  @override
  String get battlePassRenewFailed =>
      'Impossible d\'actualiser les paliers. Réessayez plus tard.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Renouvellement $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Renouvellement dans $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Niveau';

  @override
  String get battlePassRewardLocked => 'Verrouillé';

  @override
  String get battlePassRewardNeedsPremium => 'Premium requis';

  @override
  String get battlePassRewardStatusLabel => 'Statut';

  @override
  String get battlePassRewardTrackLabel => 'Type de récompense';

  @override
  String get battlePassRewardTypeLabel => 'Type';

  @override
  String get battlePassRewardUnlocked => 'Débloqué';

  @override
  String get battlePassRewardsTitle => 'Récompenses';

  @override
  String get battlePassShowAllRewards => 'Tout voir';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'XP totale';

  @override
  String get battlePassUnknownMission => 'Nouvelle mission (sans description)';

  @override
  String get battlePassUnknownReward => 'Récompense';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return 'Débloqués : $unlocked/$total';
  }

  @override
  String get battlePassUnratedFallback => 'Non classé';

  @override
  String get battlePassViewAllRewards => 'Voir toutes les récompenses';

  @override
  String get battlePassWeeklyMissions => 'Missions hebdomadaires';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Missions hebdo : encore +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / jour';
  }

  @override
  String get battlePassXpPerDayCaption =>
      'À gagner chaque jour pour finir à temps';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Encore $xp XP nécessaires';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Impossible d\'enregistrer l\'équipement. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Tous vos skins, valorisés au prix de la boutique',
      'buddy': 'Vos breloques et leur nombre d\'exemplaires',
      'spray': 'Les tags que vous pouvez placer sur votre roue d\'expressions',
      'card': 'Cartes de joueur débloquées : touchez pour voir et équiper',
      'title': 'Les titres que vous pouvez afficher sous votre nom',
      'flex': 'Vos flex',
      'other': 'Parcourir la collection',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Emplacement $position';
  }

  @override
  String get collectionApplyPreset => 'Appliquer';

  @override
  String get collectionApplyPresetBody =>
      'Les skins, breloques, roue d\'expressions, carte et titre actuels seront remplacés par cette configuration.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'Appliquer « $name » ?';
  }

  @override
  String get collectionBrowseBuddies => 'Breloques';

  @override
  String get collectionBrowseCards => 'Cartes de joueur';

  @override
  String get collectionBrowseEmpty =>
      'Vous n\'avez encore aucun objet dans cette catégorie.';

  @override
  String get collectionBrowseEmptyTitle => 'Aucun objet';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skins';

  @override
  String get collectionBrowseSprays => 'Tags';

  @override
  String get collectionBrowseTitles => 'Titres';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Dispo : $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Pour $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Choisir une breloque';

  @override
  String get collectionBuddyRemoved => 'Breloque retirée';

  @override
  String get collectionBuddySlot => 'Breloque';

  @override
  String get collectionBuddyUnavailable =>
      'Impossible d\'équiper cette breloque. Actualisez ou choisissez-en une autre.';

  @override
  String get collectionCachedLoadout =>
      'Équipement enregistré affiché. Tirez pour actualiser avant de modifier.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString cartes possédées',
      one: '$nString carte possédée',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'Changer';

  @override
  String collectionChromaCount(int owned, int total) {
    return 'Variantes : $owned/$total';
  }

  @override
  String get collectionClearTiers => 'Effacer le filtre d\'édition';

  @override
  String get collectionCollectionValue => 'Valeur de la collection';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Par défaut';

  @override
  String get collectionDeletePreset => 'Supprimer';

  @override
  String get collectionEmptySlot => 'Vide';

  @override
  String get collectionEquip => 'Équiper';

  @override
  String get collectionEquipped => 'Équipé';

  @override
  String get collectionEquippedCard => 'Carte équipée';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Carte équipée : $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return '$name équipé';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Équipé : $skin';
  }

  @override
  String get collectionExcludedRewards => 'Skins de récompense non comptés';

  @override
  String get collectionExpressionsHint =>
      'Touchez un emplacement pour choisir un tag ou un flex.';

  @override
  String get collectionExpressionsSlots => 'Emplacements de la roue';

  @override
  String get collectionExpressionsTitle => 'Roue d\'expressions';

  @override
  String get collectionHideAccountLevel => 'Masquer le niveau du compte';

  @override
  String get collectionHideAccountLevelHint =>
      'Les autres joueurs ne verront pas le niveau de votre compte.';

  @override
  String get collectionIncognito => 'Mode incognito';

  @override
  String get collectionIncognitoHint =>
      'Masque votre nom aux joueurs hors de votre groupe pendant les parties.';

  @override
  String get collectionLevelBorderAuto => 'Automatique selon le niveau';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'Dès le niveau $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Compte niveau $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Choisir une bordure de niveau';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Niveau $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Niveau $n · $type';
  }

  @override
  String get collectionLevels => 'Niveaux';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return 'Niveaux débloqués : $owned/$total';
  }

  @override
  String get collectionLobbyBanner => 'Image du salon';

  @override
  String get collectionLocked => 'Verrouillé';

  @override
  String get collectionMeleeNoBuddy =>
      'Les armes de mêlée ne peuvent pas recevoir de breloque.';

  @override
  String get collectionMove => 'Déplacer';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return 'La breloque $buddy est sur $from. La déplacer sur $to ?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Déplacer la breloque ?';

  @override
  String get collectionNoBuddies => 'Vous n\'avez encore aucune breloque.';

  @override
  String get collectionNoBuddy => 'Aucune breloque';

  @override
  String get collectionNoFlex => 'Vous n\'avez encore aucun flex.';

  @override
  String get collectionNoResults => 'Aucun résultat correspondant.';

  @override
  String get collectionNoResultsTitle => 'Aucun résultat';

  @override
  String get collectionNoSkinsForWeapon =>
      'Vous n\'avez encore aucun skin pour cette arme.';

  @override
  String get collectionNoSprays => 'Vous n\'avez encore aucun tag.';

  @override
  String get collectionNoTitle => 'Aucun titre';

  @override
  String get collectionOtherWeapons => 'Autres';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins possédés',
      one: '$n skin possédé',
      zero: 'Aucun skin',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString skins possédés',
      one: '$nString skin possédé',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'Voir la vidéo de ce niveau';

  @override
  String get collectionPlayVideo => 'Voir la vidéo';

  @override
  String get collectionPlayerCardSubtitle =>
      'Visible dans le salon, sur le tableau des scores et quand vous éliminez un adversaire.';

  @override
  String get collectionPlayerCardTitle => 'Changer de carte de joueur';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Visible sous votre nom dans le salon et en partie.';

  @override
  String get collectionPlayerTitleTitle => 'Changer de titre';

  @override
  String get collectionPresetActions => 'Options';

  @override
  String collectionPresetApplied(String name) {
    return '« $name » appliquée';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n configurations',
      one: '$n configuration',
      zero: 'Aucune',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '« $name » supprimée';
  }

  @override
  String get collectionPresetNameHint => 'Ex. : Ranked tryhard';

  @override
  String get collectionPresetNameTitle => 'Nom de la configuration';

  @override
  String collectionPresetSaved(String name) {
    return '« $name » enregistrée';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Enregistrée le $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n objets que vous ne possédez plus ont été ignorés.',
      one: '$n objet que vous ne possédez plus a été ignoré.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'Enregistrez votre équipement actuel pour passer rapidement d\'un ensemble de skins, cartes et expressions à l\'autre.';

  @override
  String get collectionPresetsEmptyTitle => 'Aucune configuration';

  @override
  String get collectionPresetsFull =>
      'Limite de 50 configurations atteinte. Supprimez-en pour en enregistrer d\'autres.';

  @override
  String get collectionPresetsNote =>
      'Les configurations sont enregistrées uniquement sur cet appareil, pour le compte sélectionné.';

  @override
  String get collectionPresetsTitle => 'Configurations enregistrées';

  @override
  String get collectionPreview => 'Aperçu';

  @override
  String get collectionRemoveBuddy => 'Retirer la breloque';

  @override
  String get collectionRenamePreset => 'Renommer';

  @override
  String get collectionRowExpressions => 'Roue d\'expressions';

  @override
  String get collectionRowLevelBorder => 'Bordure de niveau';

  @override
  String get collectionRowPresets => 'Configurations enregistrées';

  @override
  String get collectionRowWeapons => 'Équipement des armes';

  @override
  String get collectionRowWishlist => 'Wishlist';

  @override
  String get collectionSaveFailed => 'Impossible d\'enregistrer l\'équipement';

  @override
  String get collectionSavePreset => 'Enregistrer l\'équipement actuel';

  @override
  String get collectionSaving => 'Enregistrement…';

  @override
  String get collectionSearchBuddies => 'Rechercher une breloque…';

  @override
  String get collectionSearchCards => 'Rechercher une carte de joueur…';

  @override
  String get collectionSearchFlex => 'Rechercher un flex…';

  @override
  String get collectionSearchItems => 'Rechercher…';

  @override
  String get collectionSearchSkins => 'Rechercher un skin…';

  @override
  String get collectionSearchSprays => 'Rechercher un tag…';

  @override
  String get collectionSearchTitles => 'Rechercher un titre…';

  @override
  String get collectionSearchWeapons =>
      'Rechercher une arme, un skin ou une breloque…';

  @override
  String get collectionSectionBrowse => 'Parcourir la collection';

  @override
  String get collectionSectionIdentity => 'Visible par les autres joueurs';

  @override
  String get collectionSectionLoadout => 'Équipement';

  @override
  String get collectionSkinCustomizeTitle => 'Personnaliser le skin';

  @override
  String get collectionSkinNotFound => 'Skin introuvable.';

  @override
  String get collectionSkinNotOwned => 'Vous ne possédez pas ce skin.';

  @override
  String get collectionSlotNamesItem0 => 'Haut';

  @override
  String get collectionSlotNamesItem1 => 'Droite';

  @override
  String get collectionSlotNamesItem2 => 'Bas';

  @override
  String get collectionSlotNamesItem3 => 'Gauche';

  @override
  String get collectionSortName => 'Nom';

  @override
  String get collectionSortPrice => 'Prix';

  @override
  String get collectionSortRarity => 'Rareté';

  @override
  String get collectionSortWeapon => 'Arme';

  @override
  String collectionSummaryFiltered(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins',
      one: '$count skin',
    );
    return 'Filtré : $_temp0 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Objets filtrés : $count/$total';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objets',
      one: '$count objet',
    );
    return '$_temp0';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins',
      one: '$count skin',
    );
    return '$_temp0 · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Tags';

  @override
  String get collectionTapToChangeCard => 'Touchez pour changer de carte';

  @override
  String get collectionTitle => 'Collection';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString titres possédés',
      one: '$nString titre possédé',
    );
    return '$_temp0';
  }

  @override
  String get collectionUndo => 'Annuler';

  @override
  String get collectionUnknownCard => 'Carte sans nom';

  @override
  String get collectionValueAtStorePrices => 'Calculée au prix de la boutique';

  @override
  String get collectionValueHasEstimates => 'Inclut des prix estimés (≈)';

  @override
  String collectionValueRewardCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins de récompense non comptés',
      one: '$n skin de récompense non compté',
    );
    return '$_temp0';
  }

  @override
  String get collectionValueSeeSkins => 'Voir les skins';

  @override
  String collectionValueSkinCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Calculée sur $n skins',
      one: 'Calculée sur $n skin',
    );
    return '$_temp0';
  }

  @override
  String get collectionVariants => 'Variantes';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return 'Armes avec un skin : $custom/$total';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Équipement des armes';

  @override
  String get collectionWeaponNotFound => 'Arme introuvable.';

  @override
  String get collectionWeaponSkinsTitle => 'Choisir un skin';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins',
      one: '$n skin',
      zero: 'Vide',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Publication impossible : votre texte contient des termes inappropriés. Modifiez-le et réessayez.';

  @override
  String get communityModerationContentScam =>
      'La Communauté n\'autorise pas la vente de comptes, le boosting ni le partage de numéros de téléphone. Retirez ces contenus et réessayez.';

  @override
  String get communityModerationContentTooComplex =>
      'Votre texte contient trop de caractères isolés. Simplifiez-le et réessayez.';

  @override
  String get communityModerationAccountBanned =>
      'Ce compte n\'a plus accès à la Communauté. Si vous pensez qu\'il s\'agit d\'une erreur, contactez ValHub depuis À propos et mentions légales.';

  @override
  String get communityModerationAccountRestricted =>
      'Ce compte ne peut temporairement plus publier, commenter, chercher des coéquipiers ni voter. Réessayez plus tard ou contactez ValHub depuis À propos et mentions légales.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Compétition',
      'unrated': 'Non classé',
      'swiftplay': 'Vélocité',
      'spikerush': 'Spike Rush',
      'deathmatch': 'Combat à mort',
      'teamdeathmatch': 'Combat à mort par équipe',
      'premier': 'Premier',
      'custom': 'Partie perso',
      'other': 'Autre',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Asie-Pacifique',
      'na': 'Amérique du Nord',
      'eu': 'Europe',
      'kr': 'Corée',
      'latam': 'Amérique latine',
      'br': 'Brésil',
      'other': 'Serveur inconnu',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'Aucun skin dans ce classement';

  @override
  String get communityRankingEmptyVotes =>
      'Aucun favori ne correspond à la portée et aux filtres choisis.';

  @override
  String get communityRankingEmptyRatings =>
      'Aucune note ne correspond à la portée et aux filtres choisis.';

  @override
  String get communityRankingEmptyReviews =>
      'Aucun avis ne correspond à la portée et aux filtres choisis.';

  @override
  String get communityRankingExplore => 'Trouver un skin à voir et à noter';

  @override
  String get communityRankingExploreHint =>
      'Cherchez par nom de skin ou d\'arme. Seules les vraies évaluations de la communauté apparaissent dans le classement.';

  @override
  String get communityRankingClear =>
      'Effacer les filtres d\'arme et de période';

  @override
  String get communityRankingSort => 'Classer par';

  @override
  String get communityRankingWeapon => 'Arme';

  @override
  String get communityRankingNoSearch =>
      'Aucun skin trouvé. Essayez un autre nom ou retirez le filtre d\'arme.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Impossible de charger le catalogue des skins. Fermez ce panneau et réessayez une fois les données synchronisées.';

  @override
  String get communityConsentExitAccount => 'Refuser · Déconnecter ce compte';

  @override
  String get communityRankingGlobalAllTime => 'Mondial · Depuis toujours';

  @override
  String get communityRankingCatalogTitle => 'Tous les skins';

  @override
  String get communityReviewOwnershipRequired =>
      'Le compte doit posséder ce skin pour l\'évaluer. Vous pouvez toujours lire les évaluations et commentaires de la communauté.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Impossible de vérifier que vous possédez ce skin. Rechargez la Collection ou réessayez une fois connecté.';

  @override
  String get communityReviewLegacyOwnership =>
      'Ancien avis · Possession non vérifiée';

  @override
  String get communityReviewVerifiedOwner =>
      'Possession vérifiée lors de l\'avis';

  @override
  String get communitySkinDiscussionHint =>
      'Tout le monde peut commenter. Seuls les propriétaires du skin peuvent le noter et écrire un avis.';

  @override
  String get communityAddPhotos => 'Ajouter des photos';

  @override
  String get communityAllModes => 'Tous';

  @override
  String get communityAllWeapons => 'Toutes les armes';

  @override
  String get communityAnonymousBanner => 'Navigation anonyme';

  @override
  String get communityAnyLanguage => 'Toutes langues';

  @override
  String get communityAnyRank => 'Tous rangs';

  @override
  String get communityAnyRole => 'Tous rôles';

  @override
  String get communityApply => 'Appliquer';

  @override
  String get communityBackToMyCountry => 'Mon pays';

  @override
  String get communityBlockAuthor => 'Bloquer sur cet appareil';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Désélectionner';

  @override
  String get communityCodeAuto =>
      'Laissez vide : ValHub crée le code à partir de votre groupe en jeu quand vous publiez l\'annonce.';

  @override
  String get communityCodeAutoFailed =>
      'Impossible de créer le code de groupe. Ouvrez VALORANT ou saisissez le code manuellement.';

  @override
  String get communityCodeInvalid =>
      'Le code fait exactement 6 lettres majuscules ou chiffres.';

  @override
  String get communityCodeRequired => 'Saisissez ou créez un code de groupe.';

  @override
  String get communityCommentHint => 'Écrire un commentaire…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString commentaires',
      one: '$nString commentaire',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Commentaires · $n';
  }

  @override
  String get communityCommentsTitle => 'Commentaires';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Publications : $posts · Membres : $authors';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString annonces de groupe',
      one: '$nString annonce de groupe',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'Favoris de la communauté';

  @override
  String get communityComposerHint =>
      'Qu\'avez-vous en tête sur VALORANT aujourd\'hui ?';

  @override
  String get communityComposerTitle => 'Nouvelle publication';

  @override
  String communityConsentAccount(String riotId) {
    return 'Compte : $riotId';
  }

  @override
  String get communityConsentAgree => 'Accepter et continuer';

  @override
  String get communityConsentGateAction => 'Rejoindre';

  @override
  String get communityConsentGuidelines => 'Règles de la communauté';

  @override
  String get communityConsentLater => 'Plus tard';

  @override
  String get communityConsentLocal =>
      'Votre mot de passe et vos autres données de connexion restent toujours sur cet appareil. Vous pouvez retirer votre consentement dans les Paramètres.';

  @override
  String get communityConsentPrivacy => 'Politique de confidentialité';

  @override
  String get communityConsentPublic =>
      'Les autres joueurs verront votre Riot ID, votre carte de joueur, votre rang et votre pays.';

  @override
  String get communityConsentTitle => 'Confidentialité et Communauté ValHub';

  @override
  String get communityConsentVerify =>
      'ValHub transmet votre accès Riot au serveur de la Communauté pour vérifier votre Riot ID lors de la connexion et confirmer que vous possédez un skin quand vous enregistrez un avis. Le serveur ne lit que les données nécessaires, puis supprime aussitôt cet accès, sans le conserver.';

  @override
  String get communityConsentWithdrawn =>
      'Consentement retiré. Vous devez accepter de nouveau pour continuer à utiliser l\'app.';

  @override
  String get communityCountriesTitle => 'Communautés par pays';

  @override
  String get communityCountryNamesAE => 'Émirats arabes unis';

  @override
  String get communityCountryNamesAL => 'Albanie';

  @override
  String get communityCountryNamesAM => 'Arménie';

  @override
  String get communityCountryNamesAR => 'Argentine';

  @override
  String get communityCountryNamesAT => 'Autriche';

  @override
  String get communityCountryNamesAU => 'Australie';

  @override
  String get communityCountryNamesAZ => 'Azerbaïdjan';

  @override
  String get communityCountryNamesBA => 'Bosnie-Herzégovine';

  @override
  String get communityCountryNamesBD => 'Bangladesh';

  @override
  String get communityCountryNamesBE => 'Belgique';

  @override
  String get communityCountryNamesBG => 'Bulgarie';

  @override
  String get communityCountryNamesBH => 'Bahreïn';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Bolivie';

  @override
  String get communityCountryNamesBR => 'Brésil';

  @override
  String get communityCountryNamesBY => 'Biélorussie';

  @override
  String get communityCountryNamesCA => 'Canada';

  @override
  String get communityCountryNamesCH => 'Suisse';

  @override
  String get communityCountryNamesCL => 'Chili';

  @override
  String get communityCountryNamesCN => 'Chine';

  @override
  String get communityCountryNamesCO => 'Colombie';

  @override
  String get communityCountryNamesCR => 'Costa Rica';

  @override
  String get communityCountryNamesCU => 'Cuba';

  @override
  String get communityCountryNamesCY => 'Chypre';

  @override
  String get communityCountryNamesCZ => 'Tchéquie';

  @override
  String get communityCountryNamesDE => 'Allemagne';

  @override
  String get communityCountryNamesDK => 'Danemark';

  @override
  String get communityCountryNamesDO => 'République dominicaine';

  @override
  String get communityCountryNamesDZ => 'Algérie';

  @override
  String get communityCountryNamesEC => 'Équateur';

  @override
  String get communityCountryNamesEE => 'Estonie';

  @override
  String get communityCountryNamesEG => 'Égypte';

  @override
  String get communityCountryNamesES => 'Espagne';

  @override
  String get communityCountryNamesET => 'Éthiopie';

  @override
  String get communityCountryNamesFI => 'Finlande';

  @override
  String get communityCountryNamesFR => 'France';

  @override
  String get communityCountryNamesGB => 'Royaume-Uni';

  @override
  String get communityCountryNamesGE => 'Géorgie';

  @override
  String get communityCountryNamesGH => 'Ghana';

  @override
  String get communityCountryNamesGR => 'Grèce';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hong Kong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Croatie';

  @override
  String get communityCountryNamesHU => 'Hongrie';

  @override
  String get communityCountryNamesID => 'Indonésie';

  @override
  String get communityCountryNamesIE => 'Irlande';

  @override
  String get communityCountryNamesIL => 'Israël';

  @override
  String get communityCountryNamesIN => 'Inde';

  @override
  String get communityCountryNamesIQ => 'Irak';

  @override
  String get communityCountryNamesIR => 'Iran';

  @override
  String get communityCountryNamesIS => 'Islande';

  @override
  String get communityCountryNamesIT => 'Italie';

  @override
  String get communityCountryNamesJO => 'Jordanie';

  @override
  String get communityCountryNamesJP => 'Japon';

  @override
  String get communityCountryNamesKE => 'Kenya';

  @override
  String get communityCountryNamesKH => 'Cambodge';

  @override
  String get communityCountryNamesKR => 'Corée du Sud';

  @override
  String get communityCountryNamesKW => 'Koweït';

  @override
  String get communityCountryNamesKZ => 'Kazakhstan';

  @override
  String get communityCountryNamesLA => 'Laos';

  @override
  String get communityCountryNamesLB => 'Liban';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Lituanie';

  @override
  String get communityCountryNamesLU => 'Luxembourg';

  @override
  String get communityCountryNamesLV => 'Lettonie';

  @override
  String get communityCountryNamesLY => 'Libye';

  @override
  String get communityCountryNamesMA => 'Maroc';

  @override
  String get communityCountryNamesMD => 'Moldavie';

  @override
  String get communityCountryNamesME => 'Monténégro';

  @override
  String get communityCountryNamesMK => 'Macédoine du Nord';

  @override
  String get communityCountryNamesMM => 'Myanmar';

  @override
  String get communityCountryNamesMN => 'Mongolie';

  @override
  String get communityCountryNamesMO => 'Macao';

  @override
  String get communityCountryNamesMT => 'Malte';

  @override
  String get communityCountryNamesMX => 'Mexique';

  @override
  String get communityCountryNamesMY => 'Malaisie';

  @override
  String get communityCountryNamesNG => 'Nigeria';

  @override
  String get communityCountryNamesNI => 'Nicaragua';

  @override
  String get communityCountryNamesNL => 'Pays-Bas';

  @override
  String get communityCountryNamesNO => 'Norvège';

  @override
  String get communityCountryNamesNP => 'Népal';

  @override
  String get communityCountryNamesNZ => 'Nouvelle-Zélande';

  @override
  String get communityCountryNamesOM => 'Oman';

  @override
  String get communityCountryNamesPA => 'Panama';

  @override
  String get communityCountryNamesPE => 'Pérou';

  @override
  String get communityCountryNamesPH => 'Philippines';

  @override
  String get communityCountryNamesPK => 'Pakistan';

  @override
  String get communityCountryNamesPL => 'Pologne';

  @override
  String get communityCountryNamesPR => 'Porto Rico';

  @override
  String get communityCountryNamesPT => 'Portugal';

  @override
  String get communityCountryNamesPY => 'Paraguay';

  @override
  String get communityCountryNamesQA => 'Qatar';

  @override
  String get communityCountryNamesRO => 'Roumanie';

  @override
  String get communityCountryNamesRS => 'Serbie';

  @override
  String get communityCountryNamesRU => 'Russie';

  @override
  String get communityCountryNamesSA => 'Arabie saoudite';

  @override
  String get communityCountryNamesSE => 'Suède';

  @override
  String get communityCountryNamesSG => 'Singapour';

  @override
  String get communityCountryNamesSI => 'Slovénie';

  @override
  String get communityCountryNamesSK => 'Slovaquie';

  @override
  String get communityCountryNamesSV => 'Salvador';

  @override
  String get communityCountryNamesTH => 'Thaïlande';

  @override
  String get communityCountryNamesTL => 'Timor oriental';

  @override
  String get communityCountryNamesTN => 'Tunisie';

  @override
  String get communityCountryNamesTR => 'Turquie';

  @override
  String get communityCountryNamesTW => 'Taïwan';

  @override
  String get communityCountryNamesUA => 'Ukraine';

  @override
  String get communityCountryNamesUS => 'États-Unis';

  @override
  String get communityCountryNamesUY => 'Uruguay';

  @override
  String get communityCountryNamesUZ => 'Ouzbékistan';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Viêt Nam';

  @override
  String get communityCountryNamesZA => 'Afrique du Sud';

  @override
  String get communityCreateLfg => 'Créer une annonce de groupe';

  @override
  String get communityCreateLfgShort => 'Publier';

  @override
  String get communityDataDeleted =>
      'Vos données de la Communauté ont été supprimées.';

  @override
  String communityDataFooter(String riotId) {
    return 'S\'applique au compte actif : $riotId. Le fichier téléchargé ne contient ni mot de passe ni données de connexion Riot.';
  }

  @override
  String get communityDataTitle => 'Vos données de la Communauté';

  @override
  String get communityDecrease => 'Diminuer';

  @override
  String get communityDelete => 'Supprimer';

  @override
  String get communityDeleteComment => 'Supprimer le commentaire';

  @override
  String get communityDeleteCommentBody =>
      'Ce commentaire sera supprimé définitivement.';

  @override
  String get communityDeleteCommentTitle => 'Supprimer le commentaire ?';

  @override
  String get communityDeleteDataConfirm => 'Supprimer définitivement';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Toutes les publications, commentaires, avis sur les skins, mentions J\'aime, votes, annonces de groupe et photos de $riotId sur la Communauté ValHub seront supprimés définitivement, sans retour possible. Vous repasserez en navigation anonyme et devrez accepter de nouveau pour participer.\n\nVotre compte Riot et vos données en jeu ne sont pas affectés. Téléchargez vos données avant si vous voulez en garder une copie.';
  }

  @override
  String get communityDeleteDataConfirmTitle =>
      'Supprimer vos données de la Communauté ?';

  @override
  String get communityDeleteDataSubtitle =>
      'Supprime définitivement tout ce que vous avez publié dans la Communauté.';

  @override
  String get communityDeleteDataTitle =>
      'Supprimer mes données de la Communauté';

  @override
  String get communityDeletePost => 'Supprimer la publication';

  @override
  String get communityDeletePostBody =>
      'La publication et tous ses commentaires seront supprimés définitivement.';

  @override
  String get communityDeletePostTitle => 'Supprimer la publication ?';

  @override
  String get communityDeleteReview => 'Supprimer l\'avis';

  @override
  String get communityDeleteReviewBody =>
      'Votre note et votre avis sur ce skin seront supprimés.';

  @override
  String get communityDeleteReviewTitle => 'Supprimer votre avis ?';

  @override
  String get communityDeleted => 'Supprimé.';

  @override
  String get communityDiscard => 'Abandonner';

  @override
  String get communityDiscardBody =>
      'Ce que vous venez d\'écrire ne sera pas enregistré.';

  @override
  String get communityDiscardTitle => 'Abandonner la publication ?';

  @override
  String get communityDownload => 'Télécharger et traduire';

  @override
  String get communityDownloadingModels =>
      'Téléchargement du pack de traduction…';

  @override
  String get communityEditReview => 'Modifier';

  @override
  String get communityEdited => 'modifié';

  @override
  String get communityEmptyPost =>
      'Écrivez quelque chose ou ajoutez une photo.';

  @override
  String get communityExpired => 'Expirée';

  @override
  String communityExpiresIn(String t) {
    return 'Encore $t';
  }

  @override
  String get communityExportPreparing => 'Préparation…';

  @override
  String get communityExportSubject => 'Données de la Communauté ValHub';

  @override
  String get communityExportSubtitle =>
      'Une copie de tout ce que vous avez publié dans la Communauté : publications, commentaires, avis, mentions J\'aime, votes et annonces de groupe.';

  @override
  String get communityExportTitle => 'Télécharger mes données';

  @override
  String get communityExtend => 'Prolonger';

  @override
  String get communityExtended => 'Annonce prolongée de 30 minutes.';

  @override
  String get communityFeedEmptyBody =>
      'Soyez le premier à partager votre boutique, votre Marché nocturne ou vos meilleurs moments !';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Aucune publication correspondante. Changez de langue ou retirez les filtres.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Aucune nouvelle publication. Revenez plus tard ou rejoignez la Communauté pour partager.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Essayez la communauté internationale ou changez de filtre.';

  @override
  String get communityFeedEmptyScopeTitle => 'Aucune publication ici';

  @override
  String get communityFeedEmptyTitle => 'Le fil est vide';

  @override
  String get communityFilters => 'Filtres';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Traduction par Google';

  @override
  String get communityHelpful => 'Utile';

  @override
  String communityHelpfulCount(String n) {
    return 'Utile · $n';
  }

  @override
  String get communityHiddenAuthors => 'Joueurs masqués et bloqués';

  @override
  String get communityHiddenAuthorsEmpty =>
      'Vous n\'avez masqué ni bloqué personne';

  @override
  String get communityHiddenAuthorsHint =>
      'S\'applique uniquement à ce compte sur cet appareil. Leur contenu est masqué ; ils peuvent toujours voir votre contenu public.';

  @override
  String communityImageOf(int i, int n) {
    return 'Image $i/$n';
  }

  @override
  String get communityIncrease => 'Augmenter';

  @override
  String get communityJoin => 'Rejoindre';

  @override
  String get communityJoinCodeExpired =>
      'Le code de groupe a expiré ou n\'est plus valide.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Vous allez quitter votre groupe actuel dans VALORANT pour rejoindre celui de $name.';
  }

  @override
  String get communityJoinConfirmTitle => 'Rejoindre ce groupe ?';

  @override
  String get communityJoinGameNotRunning =>
      'Lancez VALORANT sur votre PC ou votre console, puis réessayez.';

  @override
  String get communityJoinParty => 'Rejoindre le groupe';

  @override
  String get communityJoinPartyFull => 'Ce groupe est complet.';

  @override
  String get communityJoinedHint =>
      'Vous avez rejoint le groupe ! Ouvrez VALORANT pour jouer ensemble.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString demandes pour rejoindre',
      one: '$nString demande pour rejoindre',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'Marché nocturne';

  @override
  String get communityKindStore => 'Boutique du jour';

  @override
  String get communityLanguage => 'Langue';

  @override
  String get communityLanguageFilter => 'Langue du contenu';

  @override
  String get communityLanguageFilterHint =>
      'N\'affiche que le contenu écrit dans les langues choisies. Laissez vide pour tout voir.';

  @override
  String get communityLanguageNamesAr => 'العربية';

  @override
  String get communityLanguageNamesDe => 'Deutsch';

  @override
  String get communityLanguageNamesEn => 'English';

  @override
  String get communityLanguageNamesEs => 'Español';

  @override
  String get communityLanguageNamesFr => 'Français';

  @override
  String get communityLanguageNamesId => 'Bahasa Indonesia';

  @override
  String get communityLanguageNamesIt => 'Italiano';

  @override
  String get communityLanguageNamesJa => '日本語';

  @override
  String get communityLanguageNamesKo => '한국어';

  @override
  String get communityLanguageNamesPl => 'Polski';

  @override
  String get communityLanguageNamesPt => 'Português';

  @override
  String get communityLanguageNamesRu => 'Русский';

  @override
  String get communityLanguageNamesTh => 'ไทย';

  @override
  String get communityLanguageNamesTr => 'Türkçe';

  @override
  String get communityLanguageNamesVi => 'Tiếng Việt';

  @override
  String get communityLanguageNamesZhCN => '简体中文';

  @override
  String get communityLanguageNamesZhTW => '繁體中文';

  @override
  String communityLanguagesSelected(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n langues',
      one: '$n langue',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgEmptyBody =>
      'Publiez une annonce pour que d\'autres joueurs rejoignent votre groupe en un seul geste.';

  @override
  String get communityLfgEmptyTitle => 'Personne ne cherche de coéquipiers';

  @override
  String get communityLfgExpiredRepost =>
      'Votre annonce a expiré. Publiez-en une nouvelle pour trouver des coéquipiers.';

  @override
  String get communityLfgGateBody =>
      'Rejoignez la Communauté (vérification unique du Riot ID) pour voir les annonces des joueurs de votre serveur et publier la vôtre. Le fil et le classement des skins restent accessibles.';

  @override
  String get communityLfgGateTitle =>
      'La recherche de coéquipiers est réservée aux membres';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Vous consultez le serveur $region : seuls les joueurs du même serveur que votre compte peuvent rejoindre un groupe.';
  }

  @override
  String get communityLfgPosted => 'Annonce publiée !';

  @override
  String get communityLfgPreviewTitle =>
      'Trouvez des coéquipiers de votre rang';

  @override
  String get communityLfgRemoved => 'Annonce retirée.';

  @override
  String get communityLfgSameShardNote =>
      'Seuls les joueurs du même serveur peuvent rejoindre le groupe.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Région : $region · L\'annonce expire après 30 minutes.';
  }

  @override
  String get communityLike => 'J\'aime';

  @override
  String get communityLiveMembers => 'Membres';

  @override
  String get communityMatchMyRank => 'Adapté à votre rang';

  @override
  String communityMemberJoined(String name) {
    return '$name a rejoint le groupe';
  }

  @override
  String get communityMemberJoinedBody =>
      'Quelqu\'un vient de rejoindre via votre annonce.';

  @override
  String get communityMic => 'Micro requis';

  @override
  String get communityMicOn => 'Avec micro';

  @override
  String get communityMode => 'Mode';

  @override
  String communityModelSize(int mb) {
    return '$mb Mo';
  }

  @override
  String get communityMoreActions => 'Plus d\'options';

  @override
  String get communityMuteAuthor => 'Masquer ce joueur';

  @override
  String get communityNewPost => 'Publier';

  @override
  String communityNightMarketOf(String date) {
    return 'Marché nocturne du $date';
  }

  @override
  String get communityNoAccountBody =>
      'Ajoutez un compte Riot pour publier, chercher des coéquipiers et voter pour des skins.';

  @override
  String get communityNoAccountTitle => 'Connectez-vous pour participer';

  @override
  String get communityNoComments => 'Aucun commentaire. Lancez la discussion !';

  @override
  String get communityNoRatings => 'Aucun avis';

  @override
  String get communityNote => 'Note';

  @override
  String get communityNoteHint =>
      'Ex. : cherche 1 Contrôleur, avec micro, ambiance détente';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Total : $amount';
  }

  @override
  String get communityOpenReviews => 'Voir les avis';

  @override
  String get communityOutOfRange => 'Hors de la plage de rangs';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Code de groupe';

  @override
  String get communityPartyCodeHint => 'Ex. : A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Code de groupe : $code';
  }

  @override
  String get communityPartySize => 'Taille du groupe';

  @override
  String get communityPartySizeFromGame => 'D\'après votre groupe en jeu';

  @override
  String communityPartySizeValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n joueurs',
      one: '$n joueur',
    );
    return '$_temp0';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return 'Photos : $n/$max';
  }

  @override
  String get communityPlayVideo => 'Voir la vidéo';

  @override
  String get communityPostLfg => 'Publier l\'annonce';

  @override
  String get communityPostNotFound =>
      'Cette publication a été supprimée ou masquée.';

  @override
  String get communityPostTitle => 'Publication';

  @override
  String get communityPosted => 'Publication en ligne !';

  @override
  String get communityPublish => 'Publier';

  @override
  String get communityPublishing => 'Publication…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'De';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Plage de rangs';

  @override
  String get communityRankRangeInvalid =>
      'Le rang minimum ne doit pas dépasser le rang maximum.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'N° $n : $name';
  }

  @override
  String get communityRankTo => 'À';

  @override
  String get communityRateLimitedTitle => 'Patientez un instant';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString avis';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$avg · $nString avis';
  }

  @override
  String get communityRatingWordsItem0 => 'Nul';

  @override
  String get communityRatingWordsItem1 => 'Bof';

  @override
  String get communityRatingWordsItem2 => 'Correct';

  @override
  String get communityRatingWordsItem3 => 'Beau';

  @override
  String get communityRatingWordsItem4 => 'Chef-d\'œuvre';

  @override
  String get communityRefreshList => 'Actualiser';

  @override
  String get communityRegion => 'Région';

  @override
  String get communityRemoveAttachment => 'Retirer la pièce jointe';

  @override
  String get communityRemoveLfg => 'Retirer l\'annonce';

  @override
  String get communityRemoveLfgBody =>
      'Les autres joueurs ne verront plus cette annonce.';

  @override
  String get communityRemoveLfgTitle => 'Retirer l\'annonce ?';

  @override
  String get communityRemovePhoto => 'Retirer la photo';

  @override
  String get communityReport => 'Signaler';

  @override
  String get communityReportConfirmBody =>
      'Un contenu signalé par plusieurs joueurs est masqué de la Communauté.';

  @override
  String get communityReportConfirmTitle => 'Envoyer le signalement ?';

  @override
  String get communityReportPrompt => 'Pourquoi signalez-vous ce contenu ?';

  @override
  String get communityReportReasonsSpam => 'Spam ou publicité';

  @override
  String get communityReportReasonsHarassment => 'Harcèlement, insultes';

  @override
  String get communityReportReasonsInappropriate => 'Contenu inapproprié';

  @override
  String get communityReportReasonsScam => 'Arnaque, vente de comptes';

  @override
  String get communityReportReasonsOther => 'Autre raison';

  @override
  String get communityReportTitle => 'Signaler le contenu';

  @override
  String get communityReported => 'Merci ! Votre signalement a été envoyé.';

  @override
  String get communityReviewDeleted => 'Avis supprimé.';

  @override
  String get communityReviewHint =>
      'Partagez votre ressenti sur ce skin (facultatif)';

  @override
  String get communityReviewSaved => 'Avis enregistré !';

  @override
  String get communityReviewTitle => 'Évaluer le skin';

  @override
  String get communityReviewsEmptyBody =>
      'Aucun avis pour l\'instant : soyez le premier !';

  @override
  String get communityReviewsEmptyTitle => 'Aucun avis';

  @override
  String communityReviewsHeader(String n) {
    return 'Avis · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot rencontre un problème';

  @override
  String get communityRoleFlex => 'Polyvalent';

  @override
  String get communityRoles => 'Rôles recherchés';

  @override
  String get communitySaveReview => 'Enregistrer l\'avis';

  @override
  String get communityScopeCountry => 'Votre pays';

  @override
  String get communityScopeGlobal => 'International';

  @override
  String get communityScopeRegion => 'Région';

  @override
  String get communitySectionFeed => 'Fil';

  @override
  String get communitySectionLfg => 'Coéquipiers';

  @override
  String get communitySectionSkins => 'Top skins';

  @override
  String get communitySend => 'Envoyer';

  @override
  String get communitySendComment => 'Envoyer le commentaire';

  @override
  String get communityShareNightMarketHint =>
      'Montrez votre Marché nocturne à tout le monde';

  @override
  String communitySharePostTitle(String name) {
    return 'Publication de $name sur ValHub';
  }

  @override
  String get communityShareStore => 'Partager dans la Communauté';

  @override
  String get communityShareStoreHint =>
      'Montrez votre boutique du jour à tout le monde';

  @override
  String get communityShowOriginal => 'Voir l\'original';

  @override
  String get communityShowTranslation => 'Voir la traduction';

  @override
  String get communitySignInToReview =>
      'Ajoutez un compte Riot pour évaluer des skins.';

  @override
  String get communitySkinNotFound => 'Skin introuvable.';

  @override
  String get communitySlots => 'Joueurs recherchés';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'il reste $max places.',
      one: 'il reste $max place.',
    );
    return 'Un groupe compte 5 joueurs maximum : $_temp0';
  }

  @override
  String communitySlotsWanted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n joueurs recherchés',
      one: '$n joueur recherché',
    );
    return '$_temp0';
  }

  @override
  String get communitySortHelpful => 'Les plus utiles';

  @override
  String get communitySortNewest => 'Plus récents';

  @override
  String get communitySortRating => 'Mieux notés';

  @override
  String get communitySortReviews => 'Plus d\'avis';

  @override
  String get communitySortVotes => 'Les plus aimés';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n étoiles',
      one: '$n étoile',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg sur 5 étoiles';
  }

  @override
  String get communityStatusFull => 'Complet';

  @override
  String get communityStatusInGame => 'En partie';

  @override
  String get communityStatusOpen => 'Recherche';

  @override
  String communityStoreOf(String date) {
    return 'Boutique du $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Touchez les étoiles pour noter ce skin';

  @override
  String get communityTitle => 'Communauté';

  @override
  String communityTooLong(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '$max caractères maximum.',
      one: '$max caractère maximum.',
    );
    return '$_temp0';
  }

  @override
  String get communityTranslate => 'Traduire avec Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Pour traduire ($from → $to), ValHub doit télécharger un pack de langue Google (environ $size). Un seul téléchargement suffit ; la traduction se fait entièrement sur votre appareil et rien n\'est envoyé à un serveur.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Télécharger le pack de traduction ?';

  @override
  String get communityTranslateFailed => 'Traduction impossible. Réessayez.';

  @override
  String get communityTranslatedByGoogle =>
      'Traduit automatiquement par Google';

  @override
  String get communityTranslating => 'Traduction…';

  @override
  String get communityTrendingTitle => 'Skins préférés dans le monde';

  @override
  String get communityUnavailableBody =>
      'Impossible de se connecter à la Communauté ValHub. Réessayez dans quelques minutes.';

  @override
  String get communityUnavailableTitle => 'Communauté indisponible';

  @override
  String get communityUnhideAuthor => 'Ne plus masquer / débloquer';

  @override
  String get communityUnknownPlayer => 'Joueur';

  @override
  String get communityUnlike => 'Je n\'aime plus';

  @override
  String get communityUnvote => 'Retirer le cœur';

  @override
  String get communityVote => 'Mettre un cœur à ce skin';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString cœurs',
      one: '$nString cœur',
    );
    return '$_temp0';
  }

  @override
  String get communityWithdrawConfirm => 'Retirer';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub cessera d\'utiliser la Communauté avec $riotId : la connexion à la Communauté sur cet appareil sera supprimée et vous repasserez en navigation anonyme.\n\nVos publications, commentaires, avis, votes et annonces de groupe restent dans la Communauté et affichent toujours votre Riot ID, jusqu\'à ce que vous les supprimiez un par un ou choisissiez « Supprimer mes données de la Communauté ». Vous pouvez revenir à tout moment.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Retirer votre consentement ?';

  @override
  String get communityWithdrawSubtitle =>
      'Cesser d\'utiliser la Communauté avec ce compte. Vos publications sont conservées.';

  @override
  String get communityWithdrawTitle => 'Retirer mon consentement';

  @override
  String get communityWriteFirstReview => 'Écrire le premier avis';

  @override
  String get communityYou => 'Vous';

  @override
  String get communityYourCountry => 'Votre pays';

  @override
  String get communityYourReview => 'Votre avis';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Vous : $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Sélection d\'agent';

  @override
  String get liveGameAnonymous => 'Anonyme';

  @override
  String get liveGameAutoRefreshNote =>
      'Actualisation automatique dès qu\'une partie est trouvée.';

  @override
  String get liveGameCurrentGame => 'Partie en cours';

  @override
  String get liveGameEmptyTeam => 'Aucun joueur pour l\'instant.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'L\'équipe adverse apparaîtra au début de la partie.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Agents verrouillés par l\'adversaire : $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'Les éliminations, morts et assistances ne sont pas disponibles en direct. Le tableau des scores s\'affichera quand Riot publiera les données de fin de partie.';

  @override
  String get liveGameFinalScoreboard => 'Tableau des scores final';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'Dans le salon';

  @override
  String get liveGameInMatch => 'En partie';

  @override
  String get liveGameInQueue => 'Recherche de partie';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'Recherche de partie · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Niveau $n';
  }

  @override
  String get liveGameLiveScore => 'Score en direct';

  @override
  String get liveGameLoadoutFromAgentSelect =>
      'Équipement à la sélection d\'agent';

  @override
  String get liveGameLoadoutFromMatch => 'Équipement dans cette partie';

  @override
  String get liveGameLobbyHint =>
      'Dès qu\'une partie est trouvée, ValHub affiche la composition et le rang de chacun.';

  @override
  String get liveGameLockedTag => 'Verrouillé';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub réessaiera automatiquement. Le tableau des scores arrive généralement au bout d\'une minute environ.';

  @override
  String get liveGameNoAgentYet => 'Aucun agent choisi';

  @override
  String get liveGameNoLoadout => 'Aucune info d\'équipement pour ce joueur.';

  @override
  String get liveGameNotInGame => 'Pas en partie';

  @override
  String get liveGameNotInGameHint =>
      'Lancez VALORANT et cherchez une partie : les détails s\'afficheront ici dès la sélection d\'agent.';

  @override
  String get liveGameNotInGameTitle => 'Vous n\'êtes dans aucune partie';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Voir l\'équipement de $name';
  }

  @override
  String get liveGameOpenParty => 'Ouvrir groupe et file';

  @override
  String get liveGameParty => 'Groupe';

  @override
  String liveGamePeak(String rank) {
    return 'Meilleur rang : $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Équipement de $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Équipement';

  @override
  String get liveGameQueueHint =>
      'Gardez l\'app ouverte : les détails s\'afficheront dès qu\'une partie sera trouvée.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Quitter la partie peut entraîner une pénalité (perte de RR, restriction de file). Voulez-vous vraiment quitter ?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Esquiver pendant la sélection d\'agent peut entraîner une pénalité (perte de RR, restriction de file). Voulez-vous vraiment quitter ?';

  @override
  String get liveGameQuitConfirmTitle => 'Quitter la partie ?';

  @override
  String get liveGameQuitDone => 'Vous avez quitté la partie.';

  @override
  String get liveGameQuitFailed => 'Impossible de quitter la partie.';

  @override
  String get liveGameQuitMatch => 'Quitter la partie';

  @override
  String get liveGameQuitMatchChanged =>
      'La partie a changé de phase pendant votre confirmation. Vous ne l\'avez pas quittée : réessayez.';

  @override
  String get liveGameRankUnavailable => 'Rang inconnu';

  @override
  String get liveGameRefresh => 'Actualiser';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Actualisation auto dans $seconds secondes',
      one: 'Actualisation auto dans $seconds seconde',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'Actualiser maintenant';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Détails de la partie';

  @override
  String get liveGameSprays => 'Tags';

  @override
  String get liveGameStatusAgentSelect => 'Sélection d\'agent';

  @override
  String get liveGameStatusEnded => 'Terminée';

  @override
  String get liveGameStatusInProgress => 'En cours';

  @override
  String get liveGameStatusUnavailable =>
      'Impossible de mettre à jour l\'état de la partie';

  @override
  String get liveGameTabAllPlayers => 'Joueurs';

  @override
  String get liveGameTabEnemyTeam => 'Adversaires';

  @override
  String get liveGameTabYourTeam => 'Votre équipe';

  @override
  String liveGameTimeLeft(String t) {
    return 'Encore $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Voir les détails de la partie';

  @override
  String get liveGameWeapons => 'Armes';

  @override
  String get liveGameYou => 'VOUS';

  @override
  String liveGameYouHover(String agent) {
    return 'Vous présélectionnez $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Vous avez verrouillé $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Choisissez et verrouillez votre agent dans VALORANT. ValHub affiche seulement le temps restant et votre équipe.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victoires',
      one: '$wins victoire',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses défaites',
      one: '$losses défaite',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws égalités',
      one: ' – $draws égalité',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown parties au résultat inconnu',
      one: ' – $unknown partie au résultat inconnu',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'l\'heure de l\'appareil ($offset)';
  }

  @override
  String profileKillDescription(
    String killer,
    String victim,
    String hasWeapon,
    String weapon,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasWeapon, {
      'yes': ' avec $weapon',
      'other': '',
    });
    return '$killer a éliminé $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 jours',
      'days7': '7 jours',
      'other': 'Tout',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Agents',
      'maps': 'Cartes',
      'queues': 'Modes',
      'sides': 'Attaque / Défense',
      'trend': 'Tendance',
      'other': 'Modes',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Tous les modes';

  @override
  String get profileAbility => 'Compétence';

  @override
  String profileAboutMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n parties',
      one: '≈ $n partie',
    );
    return '$_temp0';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Score de combat moyen';

  @override
  String profileActRecord(int wins, int games, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victoires',
      one: '$wins victoire',
    );
    String _temp1 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games parties',
      one: '$games partie',
    );
    return 'Cet acte : $_temp0 sur $_temp1 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Tous les joueurs';

  @override
  String get profileAlreadyReached => 'Vous avez déjà atteint ce rang.';

  @override
  String get profileAtCurrentForm => 'Avec votre forme actuelle';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Avec votre forme actuelle ($gain / $loss par partie)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n victoires d\'affilée',
      one: '$n victoire d\'affilée',
    );
    return 'Au mieux : $_temp0';
  }

  @override
  String get profileByWinRateTitle => 'Selon le taux de victoire';

  @override
  String get profileChooseMap => 'Filtrer par carte';

  @override
  String get profileColA => 'A';

  @override
  String get profileColD => 'D';

  @override
  String get profileColK => 'K';

  @override
  String get profileColPlace => '#';

  @override
  String get profileColPlusMinus => '+/−';

  @override
  String get profileCopyRiotId => 'Copier le Riot ID';

  @override
  String get profileCurrentRank => 'Actuel';

  @override
  String get profileDailyRrEmpty =>
      'Aucune partie classée enregistrée sur cet appareil.';

  @override
  String get profileDailyRrFootnote =>
      'L\'historique RR est enregistré sur votre appareil, y compris les parties que Riot ne renvoie plus.';

  @override
  String get profileDailyRrTitle => 'RR par jour';

  @override
  String profileDayBoundary(String zone) {
    return 'Jours calculés selon $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jours joués',
      one: '$n jour joué',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'Toutes les parties sont affichées';

  @override
  String get profileEnemyTeam => 'Équipe adverse';

  @override
  String get profileFallDamage => 'Chute';

  @override
  String get profileFilterAll => 'Tout';

  @override
  String get profileFirstBloods => 'First blood';

  @override
  String get profileFirstDeaths => 'Premières morts';

  @override
  String get profileFirstHalf => '1re mi-temps';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS et HS% ne sont calculés que pour les modes à manches.';

  @override
  String profileFormPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          '$n parties de la liste ne sont pas encore chargées pour le calcul.',
      one: '$n partie de la liste n\'est pas encore chargée pour le calcul.',
    );
    return '$_temp0';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR et HS% : parties à manches uniquement ($roundGames/$games)';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w victoires',
      one: '$w victoire',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l défaites',
      one: '$l défaite',
    );
    return 'Dernières parties ($games) : $_temp0, $_temp1';
  }

  @override
  String get profileFriendsRow => 'Amis et discussion';

  @override
  String get profileHideKills => 'Masquer les éliminations';

  @override
  String get profileHitBody => 'Corps';

  @override
  String get profileHitDistribution => 'Répartition des tirs touchés';

  @override
  String get profileHitHead => 'Tête';

  @override
  String get profileHitLegs => 'Jambes';

  @override
  String profileHitShare(String part, String percent) {
    return '$part $percent';
  }

  @override
  String get profileHs => 'HS%';

  @override
  String get profileKast => 'KAST';

  @override
  String get profileKastHint =>
      'Part des manches où vous avez éliminé, aidé, survécu ou été vengé par un coéquipier';

  @override
  String get profileKd => 'K/D';

  @override
  String get profileKdaLabel => 'K/D/A';

  @override
  String profileKdaValue(int k, int d, int a) {
    return '$k/$d/$a';
  }

  @override
  String profileLastDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n derniers jours',
      one: '$n dernier jour',
    );
    return '$_temp0';
  }

  @override
  String profileLastMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dernières parties',
      one: '$n dernière partie',
    );
    return '$_temp0';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Classement #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Niveau $n';
  }

  @override
  String get profileLevelHidden => 'Niveau masqué';

  @override
  String profileLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n défaites d\'affilée',
      one: '$n défaite d\'affilée',
    );
    return '$_temp0';
  }

  @override
  String profileMapFilter(String map) {
    return 'Carte : $map';
  }

  @override
  String profileMatchCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n parties',
      one: '$n partie',
    );
    return '$_temp0';
  }

  @override
  String get profileMatchDetailTitle => 'Détails de la partie';

  @override
  String get profileMatchHistory => 'Historique des parties';

  @override
  String get profileMatchUnavailable => 'Impossible de charger la partie';

  @override
  String get profileMatchesNeeded => 'Parties nécessaires';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Jamais classé';

  @override
  String get profileNoKillsInRound =>
      'Aucune info d\'élimination pour cette manche.';

  @override
  String get profileNoMatches => 'Aucune partie pour l\'instant.';

  @override
  String get profileNoMatchesMap =>
      'Aucune partie sur cette carte parmi celles chargées.';

  @override
  String get profileNoMatchesQueue => 'Aucune partie dans ce mode.';

  @override
  String get profileNoPlayers => 'Aucune info sur les joueurs de cette partie.';

  @override
  String get profileNoRounds => 'Aucune info sur les manches de cette partie.';

  @override
  String get profileOvertime => 'Prolongations';

  @override
  String get profilePlayHubTitle => 'Partie et groupe';

  @override
  String get profilePeakRank => 'Meilleur rang';

  @override
  String get profilePerformanceAttack => 'Attaque';

  @override
  String get profilePerformanceDefense => 'Défense';

  @override
  String get profilePerformanceEmpty =>
      'Aucune partie enregistrée sur cet appareil. Ouvrez l\'historique des parties pour enregistrer celles que vous avez jouées.';

  @override
  String get profilePerformanceNoMatches =>
      'Aucune partie sur la période choisie.';

  @override
  String profilePerformanceRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n manches enregistrées',
      one: '$n manche enregistrée',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSample =>
      'Les taux s\'affichent à partir de 3 parties. ACS, ADR, HS% et K/D ne comptent que les modes à manches.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Manches dont le camp (attaque ou défense) est identifié : $known/$total.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Historique sur l\'appareil, depuis le $date';
  }

  @override
  String get profilePerformanceTitle => 'Performances';

  @override
  String profilePlacement(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '${n}e place',
      one: '${n}e place',
    );
    return '$_temp0';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike posé en $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Profil du joueur';

  @override
  String get profilePlayerSummary => 'Résumé';

  @override
  String profileProgressTo(String rank) {
    return 'Progression vers $rank';
  }

  @override
  String get profileProgressToTarget => 'Progression vers le rang visé';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Estimation basée sur vos parties classées récentes, sans tenir compte des matchs de placement ni de la protection contre la rétrogradation.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '$matches parties',
      one: '$matches partie',
    );
    return '≈ $_temp0 pour atteindre $rank';
  }

  @override
  String get profileRankUpImmortal =>
      'Vous êtes Immortel ou plus : ce calcul ne va que jusqu\'à Immortel 1.';

  @override
  String get profileRankUpNoForm =>
      'Aucune partie classée récente pour estimer votre forme.';

  @override
  String get profileRankUpOpen => 'Ouvrir le calcul de promotion';

  @override
  String get profileRankUpTitle => 'Calcul de promotion';

  @override
  String get profileRankUpUnranked =>
      'Terminez vos matchs de placement pour utiliser le calcul de promotion.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Tableau des scores classé';

  @override
  String profileRecentForm(int w, int l) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w victoires',
      one: '$w victoire',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l défaites',
      one: '$l défaite',
    );
    return 'Forme récente : $_temp0 – $_temp1';
  }

  @override
  String get profileRecentFormTitle => 'Forme récente';

  @override
  String get profileRecentMatches => 'Parties récentes';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}V · ${l}D · ${d}N',
      one: '${w}V · ${l}D · ${d}N',
      zero: '${w}V · ${l}D',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID copié';

  @override
  String profileRound(int n) {
    return 'Manche $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n éliminations',
      one: '$n élimination',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'Manche perdue';

  @override
  String get profileRoundTimeline => 'Déroulé des manches';

  @override
  String get profileRoundWon => 'Manche gagnée';

  @override
  String get profileRoundsHint =>
      'Touchez une manche pour voir chaque élimination.';

  @override
  String profileRrLeft(String n) {
    return 'Encore $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'Évolution des RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Tableau des scores';

  @override
  String get profileSecondHalf => '2e mi-temps';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Voir les éliminations';

  @override
  String get profileSideSwitch => 'Changement de camp';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Rang visé';

  @override
  String get profileTeamBlue => 'Équipe bleue';

  @override
  String get profileTeamMvp => 'MVP d\'équipe';

  @override
  String get profileTeamRed => 'Équipe rouge';

  @override
  String get profileTitle => 'Profil';

  @override
  String profileToday(String text) {
    return 'Aujourd\'hui : $text';
  }

  @override
  String get profileTodayNone => 'Aucune partie classée aujourd\'hui';

  @override
  String get profileTruePeakLocal => 'D\'après l\'historique de l\'appareil';

  @override
  String get profileWeekdayShortItem0 => 'Lun';

  @override
  String get profileWeekdayShortItem1 => 'Mar';

  @override
  String get profileWeekdayShortItem2 => 'Mer';

  @override
  String get profileWeekdayShortItem3 => 'Jeu';

  @override
  String get profileWeekdayShortItem4 => 'Ven';

  @override
  String get profileWeekdayShortItem5 => 'Sam';

  @override
  String get profileWeekdayShortItem6 => 'Dim';

  @override
  String get profileWinRate => 'Taux de victoire';

  @override
  String profileWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n victoires d\'affilée',
      one: '$n victoire d\'affilée',
    );
    return '$_temp0';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Votre rang';

  @override
  String get profileYourSummary => 'Votre résumé';

  @override
  String get profileYourTeam => 'Votre équipe';

  @override
  String get profileYourWinRate => 'Votre taux de victoire récent';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Mode : $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Filtrer par mode';

  @override
  String get profilePerformancePerMatchTitle => 'Par partie';

  @override
  String get profilePerformancePerMatchHint =>
      'Touchez une barre pour ouvrir la partie.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Moyenne $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Il faut au moins 2 parties à manches avec cette statistique pour afficher le graphique.';

  @override
  String get profilePerformanceOpeningsTitle => 'Duels d\'ouverture';

  @override
  String get profilePerformanceOpeningWin => 'Duels d\'ouverture gagnés';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Parmi les manches où vous avez signé le first blood ou subi la première mort, la part de first bloods.';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'First blood par partie';

  @override
  String get profilePerformanceFirstDeathsPerGame =>
      'Premières morts par partie';

  @override
  String get profilePerformanceMultiKillsTitle =>
      'Éliminations multiples en une manche';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 éliminations',
      'k4': '4 éliminations',
      'ace': 'Ace',
      'other': '2 éliminations',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceMultiKillsNote(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Sur $nString parties avec des données d\'élimination complètes.',
      one: 'Sur $nString partie avec des données d\'élimination complètes.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Manches gagnées';

  @override
  String get profilePerformanceDrillHint =>
      'Touchez une ligne pour voir uniquement cet agent, cette carte ou ce mode.';

  @override
  String get profilePerformanceLoadOlder =>
      'Analyser des parties plus anciennes';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          'ValHub n\'analyse que les parties ouvertes sur cet appareil. Chaque appui ajoute jusqu\'à $nString parties plus anciennes.',
      one:
          'ValHub n\'analyse que les parties ouvertes sur cet appareil. Chaque appui ajoute jusqu\'à $nString partie plus ancienne.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSearchingOlder =>
      'Recherche de parties plus anciennes…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Analyse des parties : $doneString/$totalString…';
  }

  @override
  String profilePerformanceAddedOlder(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString parties ajoutées à l\'analyse.',
      one: '$nString partie ajoutée à l\'analyse.',
      zero: 'Aucune nouvelle partie à ajouter.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot ne conserve plus de parties plus anciennes.';

  @override
  String get profileEconomyTitle => 'Économie de votre équipe';

  @override
  String get profileEconomyHint =>
      'Type d\'achat selon la valeur totale de l\'équipement de votre équipe au début de la manche (convention vlr.gg pour 5 joueurs) : Eco sous 5 000, Semi-eco sous 10 000, Semi-buy sous 20 000, Full buy à partir de 20 000 crédits. La première manche de chaque mi-temps est Pistol.';

  @override
  String profileBuyType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'pistol': 'Pistol',
      'eco': 'Eco',
      'semiEco': 'Semi-eco',
      'semiBuy': 'Semi-buy',
      'fullBuy': 'Full buy',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String profileEconomyWon(int won, int played) {
    final intl.NumberFormat wonNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String wonString = wonNumberFormat.format(won);
    final intl.NumberFormat playedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String playedString = playedNumberFormat.format(played);

    return 'Gagnées $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      'Votre compagnon VALORANT : boutique du jour, wishlist, rang, parties, multicompte et communauté de joueurs, directement sur votre appareil.';

  @override
  String get legalBackToTop => 'Haut de page';

  @override
  String get legalConsentAnd => ' et ';

  @override
  String get legalConsentPrefix => 'En continuant, vous acceptez les ';

  @override
  String get legalConsentPrivacy => 'Politique de confidentialité';

  @override
  String get legalConsentSuffix => ' de ValHub.';

  @override
  String get legalConsentTerms => 'Conditions d\'utilisation';

  @override
  String get legalContact => 'Contact';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'CONTACT';

  @override
  String legalEffectiveFrom(String date) {
    return 'En vigueur depuis le $date';
  }

  @override
  String get legalLegalHeader => 'MENTIONS LÉGALES';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Tous droits réservés.';

  @override
  String get legalThirdPartyLicenses => 'Logiciels tiers';

  @override
  String get legalThirdPartyLicensesBody =>
      'Licences des logiciels open source utilisés par ValHub';

  @override
  String get legalTocTitle => 'SOMMAIRE';

  @override
  String legalVersion(String version) {
    return 'Version $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Ce document est actuellement affiché en : $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Impossible de lire ce document juridique. Réessayez ou contactez l\'assistance.';

  @override
  String get legalTranslationNotice =>
      'Cette traduction est fournie pour votre confort. En cas de divergence, la version vietnamienne prévaut.';

  @override
  String get settingsUiLanguageTitle => 'Langue de l\'interface';

  @override
  String get settingsLanguageFollowDevice => 'Langue de l\'appareil';

  @override
  String get settingsLanguageSaveFailed =>
      'Impossible d\'enregistrer la langue. Réessayez.';

  @override
  String get settingsGeoCountry => 'Pays';

  @override
  String get settingsGeoSearchCountry => 'Rechercher un nom ou un code de pays';

  @override
  String get settingsGeoSupportedOnly => 'Uniquement les pays pris en charge';

  @override
  String get settingsGeoUnknown => 'Prise en charge non vérifiée';

  @override
  String get settingsGeoRestricted => 'Restreint';

  @override
  String get settingsGeoSeparate => 'Service distinct';

  @override
  String get settingsGeoAvailable => 'Pris en charge';

  @override
  String get settingsGeoNotApplicable => 'Non applicable';

  @override
  String get settingsGeoConnection => 'Connexion Riot';

  @override
  String get settingsGeoChooseRegion => 'Choisir une région';

  @override
  String get settingsGeoAuto => 'Automatique selon le compte';

  @override
  String get settingsGeoManual => 'Choix manuel';

  @override
  String get settingsGeoNoRegion => 'Région Riot inconnue';

  @override
  String get settingsGeoManualWarning =>
      'Ce choix modifie uniquement le serveur auquel ValHub se connecte. Il ne change pas la région de votre compte Riot. ValHub vérifie la connexion avant d\'enregistrer.';

  @override
  String get settingsGeoConnectionSaved => 'Mode de connexion enregistré';

  @override
  String get settingsGeoValidationFailed =>
      'Ce compte n\'est pas reconnu sur ce serveur. Choisissez une autre région.';

  @override
  String get settingsGeoHintOnly =>
      'Le pays ne sert qu\'aux recherches et suggestions. La région de connexion dépend de votre compte Riot.';

  @override
  String get settingsGeoSave => 'Vérifier et enregistrer';

  @override
  String get settingsGeoCancel => 'Annuler';

  @override
  String get settingsGeoLoading => 'Vérification de la connexion…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Ce choix sert aux noms de pays, aux suggestions et aux prix VP estimés. Le serveur de connexion et le pays de votre compte Communauté restent déterminés par Riot.';

  @override
  String get settingsGeoCountryAutomatic => 'Pays du compte ou de l\'appareil';

  @override
  String get settingsGeoSaveFailed =>
      'Impossible d\'enregistrer ce choix. Réessayez.';

  @override
  String get settingsGeoAllRegions => 'Toutes les régions';

  @override
  String get settingsGeoSuggestions => 'Suggestions';

  @override
  String get settingsGeoNoCountries => 'Aucun pays ne correspond au filtre.';

  @override
  String get settingsGeoActiveCountries => 'Actifs';

  @override
  String get settingsGeoAllCountries => 'Tous les pays';

  @override
  String get settingsGeoActivityUnavailable =>
      'Impossible de charger l\'activité par pays. Vous pouvez toujours choisir dans Tous les pays.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pays',
      one: '$count pays',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Vous avez choisi $manual, mais Riot associe votre compte à la région $detected. Vérifier quand même cette connexion ?';
  }

  @override
  String get settingsGeoUnverified =>
      'Impossible de vérifier la connexion à cause d\'un problème de serveur ou de réseau. Enregistrer ce choix et réessayer plus tard ?';

  @override
  String get settingsGeoContinue => 'Continuer';

  @override
  String settingsGeoMismatch(String region) {
    return 'La connexion manuelle diffère de votre région Riot : $region. Utiliser la région automatique ?';
  }

  @override
  String get settingsGeoUseAuto => 'Automatique';

  @override
  String get settingsGeoKeepManual => 'Garder manuel';

  @override
  String get settingsGeoReviewConnection => 'Voir la connexion';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Dernière vérification : $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Vérifier à nouveau';

  @override
  String get settingsPlatformMobile => 'Mobile';

  @override
  String get settingsPlatformOther => 'Autre plateforme';

  @override
  String get settingsContentLanguageFollowApp => 'Langue de l\'app';

  @override
  String get settingsContentLanguageHint =>
      'Choisissez la langue des noms d\'objets. Cela ne change ni la langue de l\'interface ni le serveur Riot.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Langue : $language.';
  }

  @override
  String get settingsAboutHeader => 'INFORMATIONS';

  @override
  String get settingsAboutRowSubtitle =>
      'Confidentialité, conditions, droits d\'auteur et contact';

  @override
  String get settingsAboutTitle => 'À propos et mentions légales';

  @override
  String get settingsAppHeader => 'AVANCÉ';

  @override
  String get settingsAppearanceHeader => 'AFFICHAGE';

  @override
  String settingsBuildNumber(String build) {
    return 'Build $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'Espace libéré : $size';
  }

  @override
  String get settingsClearCache => 'Effacer les données temporaires';

  @override
  String get settingsClearCacheFailed =>
      'Impossible d\'effacer les données temporaires. Réessayez.';

  @override
  String get settingsClearCacheSubtitle =>
      'Images et données téléchargées sur l\'appareil, y compris les rapports de bug enregistrés';

  @override
  String get settingsExportLog => 'Envoyer un rapport de bug à ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Rien à envoyer pour l\'instant. Utilisez l\'app un moment puis réessayez.';

  @override
  String get settingsExportLogSubtitle =>
      'Le rapport de bug ne contient ni votre mot de passe ni vos données de connexion Riot.';

  @override
  String get settingsFeedback => 'Donner votre avis sur ValHub';

  @override
  String get settingsFeedbackSubtitle =>
      'Ouvrir la page de suggestions de ValHub';

  @override
  String get settingsItemLanguageEn => 'Anglais';

  @override
  String get settingsItemLanguageLabel => 'Nom des objets';

  @override
  String get settingsItemLanguagePickerTitle => 'Langue des noms d\'objets';

  @override
  String get settingsItemLanguageVi => 'Vietnamien';

  @override
  String get settingsLinkOpenFailed =>
      'Impossible d\'ouvrir le lien. Réessayez.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Rapport de bug';
  }

  @override
  String get settingsLogShareFailed =>
      'Impossible d\'envoyer le rapport de bug. Réessayez.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Ouverture du Marché nocturne';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Vous rappelle de retourner vos cartes d\'offre du Marché nocturne';

  @override
  String get settingsNotifPermissionMissing =>
      'L\'app n\'a pas l\'autorisation d\'envoyer des notifications.';

  @override
  String get settingsNotifStoreReset => 'Renouvellement de la boutique';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Tous les jours à $time';
  }

  @override
  String get settingsNotifWishlist => 'Skin de la wishlist disponible';

  @override
  String get settingsNotifWishlistSubtitle =>
      'Vérifie la boutique de tous vos comptes, même quand l\'app est fermée';

  @override
  String get settingsNotificationsHeader => 'NOTIFICATIONS';

  @override
  String get settingsOptionAutoOpenLiveGame =>
      'Ouvrir automatiquement la partie';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Affiche la partie en cours dès qu\'une partie est trouvée';

  @override
  String get settingsOptionOwnPrice => 'Prix de votre pack de VP';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Non renseigné : tarifs de la région utilisés s\'ils existent';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Plateforme';

  @override
  String get settingsOptionShowLiveScore => 'Afficher le score en direct';

  @override
  String get settingsOptionShowPeakRank =>
      'Afficher le meilleur rang dans les détails de partie';

  @override
  String get settingsOptionShowPrice => 'Afficher le prix converti estimé';

  @override
  String get settingsOptionShowPriceInfo => 'Calcul du prix converti';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'À côté du prix en VP, par ex. $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Aucun tarif vérifié pour votre région : saisissez le prix de votre pack de VP.';

  @override
  String get settingsOptionsHeader => 'OPTIONS';

  @override
  String get settingsPhaseComplete => 'Terminé';

  @override
  String get settingsPhaseInProgress => 'En cours';

  @override
  String get settingsPhaseScheduled => 'Planifié';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'S\'applique à $account';
  }

  @override
  String get settingsPlatformHint =>
      'Choisissez PC, PlayStation ou Xbox selon l\'endroit où vous jouez pour voir le bon historique.';

  @override
  String get settingsPlatformPickerTitle => 'Choisir une plateforme';

  @override
  String get settingsPrimingBody =>
      'Activez les notifications pour savoir quand la boutique se renouvelle et quand un skin de votre wishlist apparaît.';

  @override
  String get settingsPrimingEnable => 'Activer les notifications';

  @override
  String get settingsPrimingFootnote =>
      'Vous pouvez activer ou désactiver chaque type de notification à tout moment dans les Paramètres.';

  @override
  String get settingsPrimingLater => 'Plus tard';

  @override
  String get settingsPrimingPointNightMarket =>
      'Soyez prévenu à l\'ouverture du Marché nocturne';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Pour retourner vos cartes d\'offre avant qu\'il ne ferme';

  @override
  String get settingsPrimingPointStore =>
      'Rappel au renouvellement de la boutique quotidienne';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Rappel après le renouvellement de la boutique de chaque compte';

  @override
  String get settingsPrimingPointWishlist =>
      'Alerte quand le skin que vous visez apparaît';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Vérifie la boutique de tous vos comptes, même quand l\'app est fermée';

  @override
  String get settingsPrimingTitle => 'Ne ratez pas le skin que vous visez';

  @override
  String settingsRemovedAccount(String account) {
    return '$account supprimé';
  }

  @override
  String get settingsServerStatus => 'État des serveurs';

  @override
  String get settingsServerStatusMaintenance => 'En maintenance';

  @override
  String settingsServerStatusNotices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n annonces',
      one: '$n annonce',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Maintenances et incidents VALORANT par serveur';

  @override
  String get settingsSessionLogTitle => 'Rapport de bug ValHub';

  @override
  String get settingsSeverityCritical => 'Critique';

  @override
  String get settingsSeverityInfo => 'Info';

  @override
  String get settingsSeverityWarning => 'Avertissement';

  @override
  String get settingsSignedOutAll => 'Tous les comptes ont été déconnectés';

  @override
  String get settingsStatusAllGood => 'Les serveurs fonctionnent normalement';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'Aucun incident ni maintenance sur le serveur $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Réduire';

  @override
  String get settingsStatusIssues => 'Riot traite un incident';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ce serveur a $n annonces d\'incident.',
      one: 'Ce serveur a $n annonce d\'incident.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'Incident';

  @override
  String get settingsStatusKindMaintenance => 'Maintenance';

  @override
  String get settingsStatusMaintenanceNow => 'Serveurs en maintenance';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Vous ne pourrez peut-être pas vous connecter au jeu, et ValHub pourrait ne pas charger certaines infos pendant un moment.';

  @override
  String settingsStatusMoreUpdates(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Voir $n mises à jour de plus',
      one: 'Voir $n mise à jour de plus',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusScheduled => 'Maintenance à venir';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n maintenances annoncées par Riot.',
      one: '$n maintenance annoncée par Riot.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusSourceNote =>
      'Source : page d\'état officielle de Riot Games. Heures affichées selon le fuseau horaire de l\'appareil.';

  @override
  String settingsStatusStarted(String when) {
    return 'Début : $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Mise à jour : $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'MISES À JOUR DE RIOT';

  @override
  String get settingsSupportHeader => 'ASSISTANCE';

  @override
  String settingsSwitchedTo(String account) {
    return 'Compte actif : $account';
  }

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeLabel => 'Thème';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemePickerTitle => 'Choisir un thème';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Rang, historique et partie en cours';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR de chaque partie, rang des adversaires';

  @override
  String get settingsWelcomeBulletStore =>
      'Boutique du jour, Marché nocturne et bundles';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Prix, rareté, compte à rebours du renouvellement';

  @override
  String get settingsWelcomeBulletWishlist => 'Wishlist et notifications';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Alerte quand le skin que vous visez arrive en boutique';

  @override
  String get settingsWelcomeFootnote =>
      'Vous vous connectez sur la page officielle de Riot. ValHub n\'enregistre votre mot de passe que si vous choisissez d\'enregistrer vos identifiants.';

  @override
  String get settingsWelcomeKicker => 'COMPAGNON VALORANT';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average ($count avis) · ',
      'other': '',
    });
    return 'Communauté : ${_temp0}Cœurs : $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'Ajouter à la wishlist';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'Dans la boutique de : $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      night,
      locale: localeName,
      other: '$night Marchés nocturnes',
      one: '$night Marché nocturne',
    );
    return 'Dans votre boutique : $daily fois en boutique quotidienne, $_temp0. Données de l\'appareil uniquement, enregistrées depuis le $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'Effacer l\'historique de boutique';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Effacer tous les jours de boutique enregistrés pour ce compte sur l\'appareil ?';

  @override
  String get skinDetailInWishlist => 'Dans la wishlist';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Verrouillé';

  @override
  String get skinDetailMute => 'Couper le son';

  @override
  String get skinDetailNotFound => 'Skin introuvable.';

  @override
  String get skinDetailOwned => 'Possédé';

  @override
  String get skinDetailPause => 'Pause';

  @override
  String get skinDetailPlay => 'Lecture';

  @override
  String get skinDetailPlayVideo => 'Voir la vidéo';

  @override
  String get skinDetailRemoveFromWishlist => 'Retirer de la wishlist';

  @override
  String get skinDetailTitle => 'Détails du skin';

  @override
  String get skinDetailUnmute => 'Activer le son';

  @override
  String get skinDetailUpgrades => 'Améliorations';

  @override
  String get skinDetailVariants => 'Variantes';

  @override
  String get skinDetailVideoError =>
      'Lecture de la vidéo impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get socialPresenceInMatch => 'En partie';

  @override
  String get socialPresenceAgentSelect => 'Sélection d\'agent';

  @override
  String get socialPresenceQueue => 'Recherche de partie';

  @override
  String get socialPresenceLobby => 'Dans le salon';

  @override
  String get socialPresenceCustom => 'En partie personnalisée';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Groupe ouvert',
      'other': 'Sur invitation',
    });
    return 'Joueurs : $size/$max · $_temp0';
  }

  @override
  String get socialAccept => 'Accepter';

  @override
  String get socialAcceptInGame => 'Acceptez cette invitation dans le jeu.';

  @override
  String socialActionFailed(String message) {
    return 'Action impossible. $message';
  }

  @override
  String get socialAutoRefresh => 'Actualisation automatique';

  @override
  String get socialAway => 'Absent';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Annuler la recherche · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Annuler la recherche';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Le groupe ne peut pas rejoindre $queue : $reason';
  }

  @override
  String get socialChangeQueue => 'Changer de file';

  @override
  String get socialChatUnavailable => 'La discussion est hors ligne.';

  @override
  String get socialCloseParty => 'Fermer le groupe';

  @override
  String get socialCodeInvalid =>
      'Le code de groupe ne contient que des lettres et des chiffres.';

  @override
  String get socialConnecting => 'Connexion à la discussion…';

  @override
  String get socialCopyCode => 'Copier';

  @override
  String get socialCurrentQueue => 'Sélectionné';

  @override
  String get socialCustomGameLobby =>
      'Le groupe est dans le salon de partie personnalisée.';

  @override
  String get socialDecline => 'Refuser';

  @override
  String get socialDisableCode => 'Désactiver le code';

  @override
  String get socialEmptyChat => 'Aucun message. Dites bonjour !';

  @override
  String get socialEmptyChatTitle => 'Démarrer la discussion';

  @override
  String get socialFailedBadge => 'Non envoyé';

  @override
  String get socialFilterAll => 'Tous';

  @override
  String get socialFilterOnline => 'En ligne';

  @override
  String get socialFilterUnread => 'Non lus';

  @override
  String get socialFriendsPrivacyNote =>
      'Votre liste d\'amis et vos messages proviennent directement de Riot. ValHub ne les enregistre nulle part ailleurs.';

  @override
  String socialFriendsSummary(int total, int online) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total amis',
      one: '$total ami',
    );
    return '$_temp0 · $online en ligne';
  }

  @override
  String get socialFriendsTitle => 'Amis et discussion';

  @override
  String get socialGameNotRunningBody =>
      'Groupe et file ne fonctionnent que quand VALORANT est lancé sur votre PC ou votre console. Lancez le jeu puis tirez vers le bas pour actualiser.';

  @override
  String get socialGameNotRunningTitle =>
      'Lancez VALORANT sur votre PC ou votre console';

  @override
  String get socialGenerateCode => 'Créer un code';

  @override
  String get socialIdleQueue => 'Prêt à chercher une partie';

  @override
  String get socialInMatchBanner =>
      'Vous êtes en partie. La file sera de nouveau disponible à la fin de la partie.';

  @override
  String get socialInValorant => 'Dans VALORANT';

  @override
  String get socialInviteByRiotId => 'Inviter par Riot ID';

  @override
  String get socialInviteByRiotIdHint =>
      'Invitez même des joueurs qui ne sont pas vos amis';

  @override
  String get socialInviteFriends => 'Inviter des amis';

  @override
  String socialInviteFrom(String name) {
    return 'Invitation de $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Inviter $name';
  }

  @override
  String get socialInviteNeedsName =>
      'Riot ID de ce joueur inconnu : impossible de l\'inviter.';

  @override
  String socialInviteSent(String name) {
    return 'Invitation envoyée à $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Invité';
  }

  @override
  String get socialInvitesSection => 'Invitations';

  @override
  String get socialJoin => 'Rejoindre';

  @override
  String get socialJoinConfirmBody =>
      'Vous allez quitter votre groupe actuel pour rejoindre le groupe de ce code.';

  @override
  String get socialJoinConfirmTitle => 'Rejoindre un autre groupe ?';

  @override
  String get socialJoinSection => 'Rejoindre un autre groupe';

  @override
  String get socialJoinWithCode => 'Saisir un code pour rejoindre';

  @override
  String get socialJoined => 'Vous avez rejoint le groupe.';

  @override
  String socialLastOnline(String relative) {
    return 'Actif $relative';
  }

  @override
  String get socialLeader => 'Chef de groupe';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Vous allez quitter votre groupe actuel et revenir dans votre propre groupe.';

  @override
  String get socialLeaveConfirmTitle => 'Quitter le groupe ?';

  @override
  String get socialLeaveParty => 'Quitter le groupe';

  @override
  String socialLevel(int n) {
    return 'Niveau $n';
  }

  @override
  String get socialMatchFound => 'Partie trouvée !';

  @override
  String socialMembersSection(int n, int max) {
    return 'Membres ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Écrire un message…';

  @override
  String get socialMoreActions => 'Plus d\'options';

  @override
  String get socialNoCode =>
      'Créez un code pour que vos amis rejoignent rapidement votre groupe.';

  @override
  String get socialNoCodeMember =>
      'Le chef de groupe peut créer un code pour inviter rapidement.';

  @override
  String get socialNoFilterResults => 'Aucun ami ne correspond à ce filtre.';

  @override
  String get socialNoFriends =>
      'Votre liste d\'amis Riot est vide. Ajoutez des amis dans le jeu.';

  @override
  String get socialNoFriendsTitle => 'Aucun ami';

  @override
  String get socialNoOnlineFriends =>
      'Aucun ami en ligne sur VALORANT pour l\'instant.';

  @override
  String get socialNoSearchResults => 'Aucun ami correspondant.';

  @override
  String get socialNoSearchResultsTitle => 'Aucun résultat';

  @override
  String get socialNotReady => 'Pas prêt';

  @override
  String socialOfflineSection(int n) {
    return 'Hors ligne ($n)';
  }

  @override
  String get socialOfflineStatus => 'Hors ligne';

  @override
  String get socialOnlineMobile => 'En ligne sur mobile';

  @override
  String socialOnlineSection(int n) {
    return 'En ligne ($n)';
  }

  @override
  String get socialOnlineStatus => 'En ligne';

  @override
  String get socialOnlyLeader =>
      'Seul le chef de groupe peut changer de file et lancer la recherche.';

  @override
  String get socialOpenParty => 'Ouvrir le groupe';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Code de groupe';

  @override
  String socialPartyCodeValue(String code) {
    return 'Code de groupe : $code';
  }

  @override
  String get socialPartyInvite => 'Invitation de groupe';

  @override
  String socialPartyOf(int size, int max) {
    return 'Groupe $size/$max';
  }

  @override
  String get socialPartyTitle => 'Groupe et file';

  @override
  String socialPickQueueSubtitle(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'Groupe de $size joueurs',
      one: 'Groupe de $size joueur',
    );
    return '$_temp0';
  }

  @override
  String get socialPickQueueTitle => 'Choisir une file';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Meilleur ping vers les serveurs de jeu';

  @override
  String socialPlayingOther(String game) {
    return 'Joue à $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'En jeu ($n)';
  }

  @override
  String get socialQueueLabel => 'File';

  @override
  String get socialQueueLocked =>
      'Impossible de changer de file pendant une partie.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '$max joueurs maximum',
      one: '$max joueur maximum',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Impossible de vérifier l\'état du jeu. Actualisez pour utiliser Prêt et la file.';

  @override
  String get socialReady => 'Prêt';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Prêts : $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'un membre n\'a pas le niveau de compte requis';

  @override
  String get socialReasonGeneric => 'le groupe ne remplit pas les conditions';

  @override
  String socialReasonPartyTooLarge(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '$max joueurs maximum',
      one: '$max joueur maximum',
    );
    return 'groupe trop grand ($_temp0)';
  }

  @override
  String get socialReasonRankDisparity =>
      'écart de rang trop important pour la Compétition';

  @override
  String socialReasonRestricted(String time) {
    return 'le groupe est interdit de file (encore $time)';
  }

  @override
  String get socialReconnecting => 'Discussion déconnectée. Reconnexion…';

  @override
  String get socialRemoteNote =>
      'Rien n\'est envoyé à Riot sans que vous appuyiez. ValHub ne lance jamais de recherche ni ne verrouille d\'agent à votre place.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name sera retiré de votre groupe.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Retirer du groupe ?';

  @override
  String get socialRemoveMember => 'Retirer du groupe';

  @override
  String socialRequestFrom(String name) {
    return '$name veut rejoindre le groupe';
  }

  @override
  String get socialRequestsSection => 'Demandes pour rejoindre';

  @override
  String get socialRiotIdFieldHint => 'Nom#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Un Riot ID se compose d\'un nom (3 à 16 caractères), d\'un # et d\'un tag (3 à 5 lettres ou chiffres).';

  @override
  String get socialSearchHint => 'Rechercher par Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'Recherche de partie · $elapsed';
  }

  @override
  String get socialSend => 'Envoyer';

  @override
  String get socialSendFailed =>
      'Impossible d\'envoyer le message. Vérifiez votre connexion et réessayez.';

  @override
  String get socialSendInvite => 'Envoyer l\'invitation';

  @override
  String get socialShareCode => 'Partager';

  @override
  String socialShareCodeText(String code) {
    return 'Rejoins mon groupe VALORANT avec ce code : $code';
  }

  @override
  String get socialShootingRange => 'À l\'entraînement';

  @override
  String get socialShowEveryone => 'Tout voir';

  @override
  String get socialStartQueue => 'Lancer la recherche';

  @override
  String get socialSuggestionsItem0 => 'Salut !';

  @override
  String get socialSuggestionsItem1 => 'On fait quelques parties ?';

  @override
  String get socialSuggestionsItem2 => 'Rejoins mon groupe !';

  @override
  String socialUnread(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n messages non lus',
      one: '$n message non lu',
    );
    return '$_temp0';
  }

  @override
  String get socialUnready => 'Annuler Prêt';

  @override
  String get socialViewProfile => 'Voir le profil';

  @override
  String get socialWaitingForConnection =>
      'Connexion… Vous pourrez envoyer des messages une fois connecté.';

  @override
  String get socialYou => 'Vous';

  @override
  String get socialPartyUnavailable =>
      'Impossible de synchroniser le groupe. Actualisez pour réessayer.';

  @override
  String get socialAcceptConfirmBody =>
      'Vous allez quitter votre groupe actuel pour rejoindre le groupe qui vous a envoyé l\'invitation.';

  @override
  String get storeAccessoryEmpty =>
      'La boutique d\'accessoires est vide pour le moment.';

  @override
  String get storeAccessoryEmptyTitle => 'Aucun accessoire';

  @override
  String storeAccessoryFrom(String contract) {
    return 'Source : $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Renouvellement dans $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Renouvellement $wall';
  }

  @override
  String get storeAddToWishlist => 'Ajouter à la wishlist';

  @override
  String get storeBackToBundles => 'Voir les bundles en vente';

  @override
  String get storeBundleBuySeparateLabel => 'À l\'unité';

  @override
  String get storeBundleDetailTitle => 'Détails du bundle';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Expire $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Encore $t';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n objets',
      one: '$n objet',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'Gratuit';

  @override
  String get storeBundleItemsTitle => 'Contenu du bundle';

  @override
  String get storeBundleNotFound =>
      'Bundle introuvable. Il a peut-être expiré.';

  @override
  String get storeBundleNotFoundTitle => 'Bundle expiré';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Objets possédés : $owned/$total';
  }

  @override
  String get storeBundlePriceLabel => 'Prix du bundle';

  @override
  String get storeBundleSavingsLabel => 'Économie';

  @override
  String get storeBundleWholesaleOnly =>
      'Vendu uniquement en lot, pas à l\'unité.';

  @override
  String get storeBundlesEmpty => 'Aucun bundle en vente pour le moment.';

  @override
  String get storeBundlesEmptyTitle => 'Aucun bundle';

  @override
  String get storeDailyEmpty => 'Aucun skin dans la boutique aujourd\'hui.';

  @override
  String get storeDailyEmptyTitle => 'Boutique vide';

  @override
  String storeDailyResetAt(String time) {
    return 'Renouvellement tous les jours à $time';
  }

  @override
  String get storeDailyTotalLabel => 'Total';

  @override
  String get storeNightMarketEmpty => 'Pas de Marché nocturne pour le moment.';

  @override
  String get storeNightMarketEmptyTitle => 'Marché nocturne fermé';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Se termine $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Se termine dans $t';
  }

  @override
  String get storeNightMarketNote =>
      'Les offres du Marché nocturne sont propres à votre compte et ne peuvent pas être renouvelées.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Économie totale : $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Non retournée';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Possédé';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Possédés : $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Retirer de la wishlist';

  @override
  String get storeResetNotificationTitle => 'La boutique a été renouvelée';

  @override
  String storeResetsIn(String t) {
    return 'Renouvellement dans $t';
  }

  @override
  String get storeSegmentAccessories => 'Accessoires';

  @override
  String get storeSegmentBundles => 'Bundles';

  @override
  String get storeSegmentDaily => 'Quotidien';

  @override
  String get storeSegmentNightMarket => 'Marché nocturne';

  @override
  String get storeShareButton => 'Partager';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Boutique du jour';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Marché nocturne';

  @override
  String get storeShareCardPriceNote =>
      'Le prix converti n\'est qu\'une estimation basée sur les packs de VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Économie : $vp';
  }

  @override
  String get storeShareCardTagline => 'Votre compagnon VALORANT';

  @override
  String storeShareCardTotal(String vp) {
    return 'Total : $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Jusqu\'à $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Partager la boutique du jour';

  @override
  String get storeShareFailed => 'Impossible de créer l\'image. Réessayez.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'Partager l\'image';

  @override
  String get storeShareNightMarketTitle => 'Partager le Marché nocturne';

  @override
  String get storeSharePreparing => 'Chargement des images des skins…';

  @override
  String get storeShareShowPrice => 'Afficher le prix converti estimé';

  @override
  String get storeShareShowPriceHint =>
      'Calculé d\'après le pack de VP le plus avantageux.';

  @override
  String get storeShareShowRiotId => 'Afficher le Riot ID sur l\'image';

  @override
  String get storeShareShowRiotIdHint =>
      'Désactivé par défaut pour protéger votre vie privée.';

  @override
  String get storeShareSubjectDaily => 'Ma boutique VALORANT du jour';

  @override
  String get storeShareSubjectNightMarket => 'Mon Marché nocturne VALORANT';

  @override
  String get storeShareSubtitle =>
      'Partagez une image de votre boutique avec vos amis via l\'app de votre choix.';

  @override
  String get storeTitle => 'Boutique';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Solde : $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '$n dans la wishlist';
  }

  @override
  String get storeHistoryTitle => 'Historique de la boutique';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString jours',
      one: '$daysString jour',
    );
    return 'Enregistré sur cet appareil depuis le $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Aucun jour enregistré pour l\'instant. ValHub sauvegarde votre boutique quotidienne chaque fois que vous ouvrez l\'app, uniquement sur cet appareil.';

  @override
  String get storeHistoryMostOffered => 'Les plus proposés';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString fois',
      one: '$nString fois',
    );
    return '$_temp0';
  }

  @override
  String storeHistoryNightMarket(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Marché nocturne · $countString offres',
      one: 'Marché nocturne · $countString offre',
    );
    return '$_temp0';
  }

  @override
  String storeHistoryEntrySubtitle(int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString jours enregistrés sur cet appareil',
      one: '$daysString jour enregistré sur cet appareil',
      zero: 'Enregistrement commencé aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasTime, {
      'yes': '$skin est dans la boutique de $account : encore $left.',
      'other': '$skin est dans la boutique de $account.',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifNightMarketBody(
    String skin,
    String mode,
    String percent,
    String price,
    String account,
  ) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'discount': '$skin à -$percent % : $price ($account).',
      'price': '$skin à seulement $price ($account).',
      'other': '$skin est dans le Marché nocturne de $account.',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifBundleBody(
    String skin,
    String hasName,
    String bundle,
    String account,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasName, {
      'yes': '$skin fait partie du bundle $bundle ($account).',
      'other': '$skin fait partie d\'un bundle en vente ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other:
          'En vente dans la boutique de $account : $names et $more autres skins.',
      one:
          'En vente dans la boutique de $account : $names et $more autre skin.',
      zero: 'En vente dans la boutique de $account : $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', dans la wishlist',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Ajouter des skins';

  @override
  String get wishlistAddToWishlist => 'Ajouter à la wishlist';

  @override
  String get wishlistAllWeapons => 'Toutes les armes';

  @override
  String get wishlistBrowseCatalog => 'Voir tous les skins';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skins',
      one: '$countString skin',
    );
    return '$_temp0';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Impossible de charger la liste des skins. Actualisez pour réessayer.';

  @override
  String get wishlistCatalogEmptyTitle => 'Aucun skin';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'Dans la wishlist : $count';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Touchez ♡ pour ajouter un skin à la wishlist';

  @override
  String get wishlistCatalogTitle => 'Tous les skins';

  @override
  String get wishlistChooseWeapon => 'Choisir une arme';

  @override
  String get wishlistClearFilters => 'Effacer les filtres';

  @override
  String get wishlistEmpty =>
      'Votre wishlist est vide. Touchez ♡ sur n\'importe quel skin pour l\'ajouter.';

  @override
  String get wishlistEmptyTitle => 'Aucun skin';

  @override
  String wishlistEndsIn(String time) {
    return 'Se termine dans $time';
  }

  @override
  String get wishlistExcludedRewards => 'Skins de récompense non comptés';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skins',
      one: '$countString skin',
    );
    return 'Avec filtres : $_temp0 · $value';
  }

  @override
  String get wishlistNoMatch =>
      'Aucun skin correspondant. Retirez des filtres pour en voir plus.';

  @override
  String get wishlistNoMatchTitle => 'Aucun skin trouvé';

  @override
  String get wishlistNotifBundleTitle =>
      'Nouveau bundle avec un skin de votre wishlist';

  @override
  String get wishlistNotifDailyTitle =>
      'Un skin de votre wishlist est arrivé !';

  @override
  String get wishlistNotifNightMarketTitle =>
      'Le Marché nocturne a un skin que vous aimez !';

  @override
  String get wishlistNotifPermissionMissing =>
      'L\'app n\'a pas l\'autorisation d\'envoyer des notifications.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins de votre wishlist sont en vente !',
      one: '$count skin de votre wishlist est en vente !',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'Notifications de wishlist';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Pour ce compte, même quand l\'app est fermée';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Wishlist de $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins de votre wishlist sont en vente !',
      one: '$count skin de votre wishlist est en vente !',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Touchez une ligne en surbrillance pour voir l\'offre.';

  @override
  String get wishlistOpenSettings => 'Ouvrir les paramètres';

  @override
  String get wishlistOwned => 'Possédé';

  @override
  String get wishlistRemoveAction => 'Retirer de la wishlist';

  @override
  String get wishlistRemoveFromWishlist => 'Retirer de la wishlist';

  @override
  String wishlistRemoved(String name) {
    return '$name retiré de la wishlist';
  }

  @override
  String get wishlistSearchHint => 'Rechercher un skin…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString skins',
      one: '$countString skin',
    );
    return '$_temp0';
  }

  @override
  String get wishlistSortName => 'Nom';

  @override
  String get wishlistSortPrice => 'Prix';

  @override
  String get wishlistSortRarity => 'Rareté';

  @override
  String get wishlistSortWeapon => 'Arme';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistTotalValue => 'Valeur totale de la wishlist';

  @override
  String get wishlistUndo => 'Annuler';

  @override
  String get wishlistViewInStore => 'Voir en boutique';

  @override
  String get wishlistWeapon => 'Arme';

  @override
  String get homeLiveScoreSeparator => 'VS';

  @override
  String homeOfferAccessibility(
    String name,
    String price,
    String tier,
    String wished,
  ) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', dans la wishlist',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', dans la wishlist',
      'other': '',
    });
    return '$name, $votes$_temp0';
  }

  @override
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  ) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'gain': 'gain',
      'other': 'perte',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victoires',
      one: '$wins victoire',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses défaites',
      one: '$losses défaite',
    );
    return 'Aujourd\'hui : $_temp0 de $rr RR, $_temp1, $_temp2';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victoires',
      one: '$wins victoire',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses défaites',
      one: '$losses défaite',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws égalités',
      one: ', $draws égalité',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown parties au résultat inconnu',
      one: ', $unknown partie au résultat inconnu',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody =>
      'Ouvrez Personnaliser l\'accueil pour les réafficher.';

  @override
  String get homeAllHiddenTitle => 'Vous avez masqué toutes les cartes';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'Niveau, XP à gagner par jour et missions hebdomadaires.';

  @override
  String get homeCardCommunity => 'Communauté';

  @override
  String get homeCardCommunityDesc =>
      'Coéquipiers de votre rang et skins préférés de la communauté.';

  @override
  String get homeCardFriends => 'Amis en jeu';

  @override
  String get homeCardFriendsDesc => 'Amis en partie ou en recherche de partie.';

  @override
  String homeCardHidden(String name) {
    return '« $name » masquée';
  }

  @override
  String get homeCardLive => 'Partie en cours';

  @override
  String get homeCardLiveDesc =>
      'S\'affiche pendant la recherche, la sélection d\'agent ou la partie.';

  @override
  String get homeCardOtherAccounts => 'Autres comptes';

  @override
  String get homeCardOtherAccountsDesc =>
      'État et wishlist de vos autres comptes.';

  @override
  String get homeCardRank => 'Rang et forme';

  @override
  String get homeCardRankDesc =>
      'Rang, RR du jour, séries et parties avant la promotion.';

  @override
  String get homeCardServerStatus => 'État des serveurs';

  @override
  String get homeCardServerStatusDesc =>
      'S\'affiche uniquement en cas de maintenance ou d\'incident.';

  @override
  String get homeCardStore => 'Boutique du jour';

  @override
  String get homeCardStoreDesc => 'Skins du jour, wishlist et Marché nocturne.';

  @override
  String get homeCustomize => 'Personnaliser l\'accueil';

  @override
  String get homeCustomizeHint =>
      'Faites glisser pour réorganiser. Désactivez pour masquer une carte.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Affichage de : $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Activer';

  @override
  String get homeFriendsConsentBody =>
      'Pour savoir quels amis jouent, ValHub se connecte à la discussion Riot du compte actif à chaque ouverture de l\'accueil. Vos amis vous verront en ligne. Vous pouvez désactiver cette option dans Personnaliser l\'accueil.';

  @override
  String get homeFriendsConsentDecline => 'Non, masquer la carte';

  @override
  String get homeFriendsConsentTitle => 'Voir quels amis jouent ?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n amis en jeu',
      one: '$n ami en jeu',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'Tout voir';

  @override
  String get homeHideCard => 'Masquer cette carte';

  @override
  String homeLeaderboard(String pos) {
    return 'N° $pos du classement';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Encore $time';
  }

  @override
  String homeLfgNeeds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n joueurs recherchés',
      one: '$n joueur recherché',
    );
    return '$_temp0';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Coéquipiers de votre rang';

  @override
  String get homeLiveAllyLabel => 'Alliés';

  @override
  String get homeLiveEnemyLabel => 'Adversaires';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'Recherche de partie depuis $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Votre équipe $ally, adversaires $enemy';
  }

  @override
  String homeLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n défaites classées d\'affilée',
      one: '$n défaite classée d\'affilée',
    );
    return '$_temp0';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n parties',
      one: '$n partie',
    );
    return '≈ $_temp0 pour atteindre $rank';
  }

  @override
  String homeMoreActions(String name) {
    return 'Options pour $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Reconnectez-vous pour mettre à jour la boutique, le rang et le Battle Pass de $riotId. Vous pouvez toujours consulter la version enregistrée sur l\'appareil.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Encore $time';
  }

  @override
  String get homeNightMarketNew => 'Nouveau';

  @override
  String get homeNightMarketTitle => 'Marché nocturne';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n offres à retourner',
      one: '$n offre à retourner',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'Aucune partie classée aujourd\'hui';

  @override
  String get homeOpenLfg => 'Voir toutes les annonces de groupe';

  @override
  String get homeOpenRanking => 'Voir le classement des skins';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Autres comptes ($n)';
  }

  @override
  String homeOtherMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n comptes',
      one: '+$n compte',
    );
    return '$_temp0';
  }

  @override
  String get homeOtherWishlistHit => 'Skin de la wishlist en vente';

  @override
  String homePreviousAct(String rank) {
    return 'Acte précédent : $rank';
  }

  @override
  String get homeQuietBody => 'Tirez vers le bas pour actualiser.';

  @override
  String get homeQuietTitle => 'Rien de nouveau';

  @override
  String homeRankToNext(int rr) {
    return 'Encore $rr RR avant le rang suivant';
  }

  @override
  String get homeResetLayout => 'Rétablir par défaut';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day : $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Aujourd\'hui : $value';
  }

  @override
  String get homeStatusDetails => 'Détails';

  @override
  String homeStatusIncident(String region) {
    return 'Incident serveur · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'En maintenance · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Maintenance à venir · $region';
  }

  @override
  String homeStatusMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n annonces',
      one: '+$n annonce',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreRefreshing => 'Actualisation…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Renouvellement dans $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Total : $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Portefeuille : $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins',
      one: '$n skin',
    );
    return 'Portefeuille : $vp · de quoi acheter jusqu\'à $_temp0';
  }

  @override
  String get homeStoreWishlistHit => 'Skin de la wishlist en vente !';

  @override
  String homeStoreWishlistHits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins de la wishlist en vente',
      one: '$n skin de la wishlist en vente',
    );
    return '$_temp0';
  }

  @override
  String get homeTitle => 'Accueil';

  @override
  String get homeTrendingTitle => 'Skins préférés dans le monde';

  @override
  String homeTrendingVotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cœurs',
      one: '$n cœur',
    );
    return '$_temp0';
  }

  @override
  String get homeUndo => 'Annuler';

  @override
  String homeWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n victoires classées d\'affilée',
      one: '$n victoire classée d\'affilée',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreOutdated =>
      'La boutique a changé. ValHub n\'a pas encore pu charger la nouvelle.';

  @override
  String get homeOfflineTitle => 'Hors ligne';

  @override
  String get homeOfflineBody =>
      'Affichage des données enregistrées sur l\'appareil. ValHub se met à jour dès le retour de la connexion.';

  @override
  String get homeCardOffline => 'S\'affichera dès le retour de la connexion.';

  @override
  String get communityErrorConsent =>
      'Acceptez de partager votre Riot ID avec la Communauté pour continuer.';

  @override
  String get communityErrorForbidden =>
      'Vous ne pouvez pas effectuer cette action. Consultez les Règles de la communauté ou contactez ValHub.';

  @override
  String get communityErrorGeneric => 'Un problème est survenu. Réessayez.';

  @override
  String get communityErrorImageTooLarge =>
      'Image trop lourde (2 Mo maximum). Choisissez-en une autre.';

  @override
  String get communityErrorImageType =>
      'Choisissez une image JPEG, PNG ou WebP.';

  @override
  String get communityErrorInvalid =>
      'Contenu refusé. Vérifiez-le et réessayez.';

  @override
  String get communityErrorNetwork =>
      'Impossible de se connecter à la Communauté ValHub. Vérifiez votre connexion et réessayez.';

  @override
  String get communityErrorNotFound => 'Ce contenu n\'existe plus.';

  @override
  String get communityErrorPickImage =>
      'Impossible d\'ouvrir la galerie. Réessayez.';

  @override
  String get communityErrorRateLimited =>
      'La Communauté reçoit trop de demandes. Réessayez dans quelques minutes.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'La Communauté reçoit trop de demandes. Réessayez dans $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot n\'a pas pu vérifier votre compte. Reconnectez-vous à votre compte Riot et réessayez.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot rencontre un problème. Réessayez dans quelques minutes.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot rencontre un problème. Réessayez dans $duration.';
  }

  @override
  String get communityErrorServer =>
      'La Communauté ValHub rencontre un problème. Réessayez dans quelques minutes.';

  @override
  String get communityErrorStorageFull =>
      'L\'espace photo de la Communauté est plein. Vous pouvez publier, mais sans photo pour l\'instant. Réessayez plus tard.';

  @override
  String get communityErrorTimeout =>
      'La Communauté ValHub met trop de temps à répondre. Réessayez.';

  @override
  String get communityErrorTitle => 'Action non terminée';

  @override
  String get communityErrorUnauthorized =>
      'Votre connexion à la Communauté a expiré. Réessayez.';

  @override
  String get communityErrorImageQuota =>
      'Vous avez utilisé tout votre espace pour les images. Supprimez quelques publications avec images, puis réessayez.';

  @override
  String get smokePlain => 'Test de génération';

  @override
  String smokeGreeting(String name) {
    return 'Bonjour, $name !';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n éléments',
      one: '$n élément',
    );
    return '$_temp0';
  }
}
