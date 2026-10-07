// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Ver fuente de precios';

  @override
  String get commonErrorApi =>
      'Riot tiene problemas ahora mismo. Vuelve a intentarlo en unos minutos.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClearFilters => 'Quitar filtros';

  @override
  String get commonClearSearch => 'Borrar búsqueda';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonCopied => 'Copiado';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n días',
      one: '$n día',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'hace $n días',
      one: 'hace $n día',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEmptyGeneric => 'Aún no hay nada aquí.';

  @override
  String get commonErrorContentUnavailable =>
      'No se pudo cargar la información de skins, agentes y mapas. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get commonErrorGeneric => 'Algo ha fallado. Vuelve a intentarlo.';

  @override
  String get commonErrorMaintenance =>
      'Los servidores de VALORANT están en mantenimiento. Vuelve más tarde.';

  @override
  String get commonErrorNeedsLogin =>
      'Tu sesión de Riot ha caducado. Vuelve a iniciar sesión para continuar.';

  @override
  String get commonErrorNeedsLoginTitle => 'Inicia sesión de nuevo';

  @override
  String get commonErrorNetwork =>
      'No hay conexión. Revisa el wifi o los datos móviles y vuelve a intentarlo.';

  @override
  String get commonErrorNoAccount =>
      'Todavía no has iniciado sesión con ninguna cuenta.';

  @override
  String get commonErrorNotFound => 'No se ha encontrado este contenido.';

  @override
  String get commonErrorTimeout =>
      'Riot está tardando demasiado en responder. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get commonErrorTransient =>
      'Riot está saturado. Vuelve a intentarlo en unos minutos.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot está saturado. Vuelve a intentarlo dentro de $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'No se ha podido determinar tu región de Riot. Elige una región en Ajustes.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Ir a Inicio';

  @override
  String commonHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n horas',
      one: '$n hora',
    );
    return '$_temp0';
  }

  @override
  String commonHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'hace $n horas',
      one: 'hace $n hora',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'Incidencia en el servidor';

  @override
  String get commonJustNow => 'justo ahora';

  @override
  String get commonLoadMore => 'Cargar más';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get commonMaintenanceTitle => 'Mantenimiento del servidor';

  @override
  String commonMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutos',
      one: '$n minuto',
    );
    return '$_temp0';
  }

  @override
  String commonMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'hace $n minutos',
      one: 'hace $n minuto',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'Aún no hay nada que ver';

  @override
  String commonOfflineCached(String time) {
    return 'Sin conexión: mostrando la versión guardada ($time).';
  }

  @override
  String get commonOpenSettings => 'Abrir ajustes';

  @override
  String get commonPageNotFound => 'No se ha encontrado esta pantalla.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Paquete más rentable: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Editar el precio que introdujiste';

  @override
  String get commonPriceEnterOwn => 'Introduce el precio de tu paquete de VP';

  @override
  String get commonPriceEstimateBody =>
      'El importe «≈ …» junto al precio en VP es una estimación según el paquete de VP más rentable. En el juego pagas con VP; el importe real depende del paquete, el método de pago, los impuestos y las ofertas en el momento de la compra.';

  @override
  String get commonPriceEstimateTitle => 'Precio estimado';

  @override
  String get commonPriceEstimateTooltip =>
      'Precio estimado: toca para ver cómo se calcula';

  @override
  String get commonPriceHidden =>
      'Precio estimado oculto. Puedes volver a activarlo en Ajustes.';

  @override
  String get commonPriceHide => 'Ocultar precio estimado';

  @override
  String get commonPriceOpenSource => 'Abrir página de origen';

  @override
  String get commonPriceOverrideBody =>
      'Introduce lo que pagaste realmente por un paquete de VP (consúltalo en la tienda del juego o en tu factura). ValHub usa este precio para estimar el precio de cada objeto; solo se guarda en este dispositivo.';

  @override
  String get commonPriceOverrideCurrency => 'Código de moneda';

  @override
  String get commonPriceOverrideCurrencyHint => 'Ejemplo: EUR, USD, MXN, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Ejemplo de estimación: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Introduce un código de moneda de 3 letras, por ejemplo EUR o USD.';

  @override
  String get commonPriceOverrideInvalidNumber =>
      'Introduce un número mayor que 0.';

  @override
  String get commonPriceOverridePrice => 'Precio del paquete';

  @override
  String get commonPriceOverrideRemove => 'Borrar precio introducido';

  @override
  String get commonPriceOverrideRemoved =>
      'Se ha borrado el precio que introdujiste.';

  @override
  String get commonPriceOverrideSave => 'Guardar precio';

  @override
  String get commonPriceOverrideSaved =>
      'Se ha guardado el precio de tu paquete de VP.';

  @override
  String get commonPriceOverrideTitle => 'Precio de tu paquete de VP';

  @override
  String get commonPriceOverrideVp => 'VP del paquete';

  @override
  String get commonPricePacksTitle => 'Paquetes de VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'Según los precios de paquetes de VP en la región $country';
  }

  @override
  String get commonPriceSourceUser =>
      'Según el precio de paquete de VP que introdujiste';

  @override
  String get commonPriceUnavailable =>
      'Aún no hay precios verificados para tu región. Introduce el precio de un paquete de VP que hayas comprado para ver el precio estimado.';

  @override
  String commonPriceUpdated(String date) {
    return 'Precios actualizados: $date';
  }

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonRiotDisclaimer =>
      'ValHub no está respaldado por Riot Games y no refleja las opiniones de Riot Games ni de ninguna persona implicada oficialmente en la producción o gestión de las propiedades de Riot Games. Riot Games y todas las propiedades asociadas son marcas comerciales o marcas registradas de Riot Games, Inc.';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonSearch => 'Buscar…';

  @override
  String commonSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n segundos',
      one: '$n segundo',
    );
    return '$_temp0';
  }

  @override
  String get commonShare => 'Compartir';

  @override
  String get commonSignInAgain => 'Volver a iniciar sesión';

  @override
  String get commonSort => 'Ordenar';

  @override
  String commonSortBy(String option) {
    return 'Ordenar: $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'Colección';

  @override
  String get commonTabCommunity => 'Comunidad';

  @override
  String get commonTabHome => 'Inicio';

  @override
  String get commonTabProfile => 'Perfil';

  @override
  String get commonTabSettings => 'Ajustes';

  @override
  String get commonTabStore => 'Tienda';

  @override
  String get commonTagline => 'Tu compañero de VALORANT';

  @override
  String get commonToday => 'Hoy';

  @override
  String get commonTodayLower => 'hoy';

  @override
  String get commonTomorrow => 'mañana';

  @override
  String get commonUnknownItem => 'Objeto sin nombre';

  @override
  String commonUpdatedAt(String time) {
    return 'Actualizado a las $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'Lunes';

  @override
  String get commonWeekdaysItem1 => 'Martes';

  @override
  String get commonWeekdaysItem2 => 'Miércoles';

  @override
  String get commonWeekdaysItem3 => 'Jueves';

  @override
  String get commonWeekdaysItem4 => 'Viernes';

  @override
  String get commonWeekdaysItem5 => 'Sábado';

  @override
  String get commonWeekdaysItem6 => 'Domingo';

  @override
  String get commonYesterday => 'ayer';

  @override
  String get commonYesterdayTitle => 'Ayer';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'El inicio de sesión de Riot ha caducado: mostrando la versión guardada ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Armas pesadas';

  @override
  String get contentCategoryMelee => 'Cuerpo a cuerpo';

  @override
  String get contentCategoryRifle => 'Rifles de asalto';

  @override
  String get contentCategoryShotgun => 'Escopetas';

  @override
  String get contentCategorySidearm => 'Armas de mano';

  @override
  String get contentCategorySmg => 'Subfusiles';

  @override
  String get contentCategorySniper => 'Fusiles de francotirador';

  @override
  String get contentCurrencyAgentTokens => 'Fichas de agente';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Créditos Kingdom';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Radianita';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'Puntos de VALORANT';

  @override
  String get contentItemAgent => 'Agente';

  @override
  String get contentItemBuddy => 'Colgante';

  @override
  String get contentItemCard => 'Tarjeta de jugador';

  @override
  String get contentItemChroma => 'Variante';

  @override
  String get contentItemContract => 'Contrato';

  @override
  String get contentItemCurrency => 'Moneda';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Grafiti';

  @override
  String get contentItemTitle => 'Título';

  @override
  String contentLevel(int n) {
    return 'Nivel $n';
  }

  @override
  String get contentLevelBase => 'Básico';

  @override
  String get contentLevelItemLabelsVFX => 'Efectos visuales';

  @override
  String get contentLevelItemLabelsAnimation => 'Animación';

  @override
  String get contentLevelItemLabelsFinisher => 'Remate';

  @override
  String get contentLevelItemLabelsKillCounter => 'Contador de bajas';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Efectos de sonido';

  @override
  String get contentLevelItemLabelsTransformation => 'Transformación';

  @override
  String get contentLevelItemLabelsKillBanner => 'Estandarte de baja';

  @override
  String get contentLevelItemLabelsKillEffect => 'Efecto de baja';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'Efecto de inspección y baja';

  @override
  String get contentLevelItemLabelsVoiceover => 'Voces';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Cambio de canción';

  @override
  String get contentLevelItemLabelsRandomizer => 'Aleatorio';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Cambio atacante/defensor';

  @override
  String get contentLevelItemLabelsTopFrag => 'Efecto de mejor jugador';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Sensor de latidos y mapa';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Animación de pez';

  @override
  String get contentNoTitle => 'Sin título';

  @override
  String get contentNotForSale => 'No está a la venta';

  @override
  String get contentQueueNamesCompetitive => 'Competitivo';

  @override
  String get contentQueueNamesUnrated => 'No competitivo';

  @override
  String get contentQueueNamesSwiftplay => 'Modo rápido';

  @override
  String get contentQueueNamesSpikerush => 'Fiebre de la Spike';

  @override
  String get contentQueueNamesDeathmatch => 'Combate a muerte';

  @override
  String get contentQueueNamesHurm => 'Combate a muerte por equipos';

  @override
  String get contentQueueNamesGgteam => 'Carrera armamentística';

  @override
  String get contentQueueNamesOnefa => 'Copia';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Personalizada';

  @override
  String get contentQueueNames => 'Personalizada';

  @override
  String get contentQueueNamesDodgeball => 'Eliminación';

  @override
  String get contentQueueNamesFortcollins => 'Reconquista';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Escaramuza: 2v2';

  @override
  String get contentQueueNamesSkirmishascension1v1 =>
      'Escaramuza: Ascensión 1v1';

  @override
  String get contentQueueNamesSkirmishascension2v2 =>
      'Escaramuza: Ascensión 2v2';

  @override
  String get contentQueueNamesValaram => 'All Random One Site';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Pelea de bolas de nieve';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Competitivo';

  @override
  String get contentQueueShortNamesValaram => 'Todo aleatorio';

  @override
  String get contentRewardSourceAgent => 'Contrato de agente';

  @override
  String get contentRewardSourceBattlePass => 'Recompensa del Battle Pass';

  @override
  String get contentRewardSourceEvent => 'Pase de evento';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Duelista';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Iniciador';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Controlador';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Centinela';

  @override
  String get contentTierDeluxe => 'De lujo';

  @override
  String get contentTierExclusive => 'Exclusiva';

  @override
  String contentTierFull(String shortName) {
    return 'Edición $shortName';
  }

  @override
  String get contentTierPremium => 'Prémium';

  @override
  String get contentTierSelect => 'Selecta';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'Sin clasificar';

  @override
  String get accountRegionUnknown => 'Servidor desconocido';

  @override
  String accountRiotCountry(String country) {
    return 'País de la cuenta de Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown =>
      'País de la cuenta de Riot: desconocido';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'CUENTAS ($count/$max)';
  }

  @override
  String get accountActive => 'En uso';

  @override
  String accountAddAccount(int count, int max) {
    return 'Añadir cuenta ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Borrar datos locales';

  @override
  String get accountClearLocalDataConfirm =>
      '¿Borrar el historial, los conjuntos de equipamiento guardados y los datos de las cuentas cerradas en este dispositivo?';

  @override
  String get accountClearRrHistory => 'Borrar historial de RR';

  @override
  String get accountClearRrHistoryConfirm =>
      '¿Borrar el historial de RR de la cuenta seleccionada en este dispositivo?';

  @override
  String get accountCopyPassword => 'Copiar contraseña';

  @override
  String get accountCopyUsername => 'Copiar nombre de usuario';

  @override
  String get accountDeleteLoginNote => 'Borrar datos';

  @override
  String get accountDeleteLoginNoteConfirm =>
      '¿Borrar el nombre de usuario y la contraseña guardados de esta cuenta?';

  @override
  String get accountHidePassword => 'Ocultar contraseña';

  @override
  String get accountKeepLocalData => 'Conservar datos locales';

  @override
  String get accountKeepLocalDataHint =>
      'Conserva la lista de deseos, los conjuntos de equipamiento y el historial en este dispositivo';

  @override
  String accountLevelShort(int level) {
    return 'Nv. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'Se ha cerrado la sesión de la cuenta de la notificación. Vuelve a iniciar sesión y abre la notificación.';

  @override
  String get accountLocalDataCleared => 'Datos locales borrados';

  @override
  String get accountLoginNote => 'Datos de inicio de sesión';

  @override
  String get accountLoginNoteDeleted => 'Datos de inicio de sesión borrados';

  @override
  String get accountLoginNoteEmpty =>
      'No hay datos de inicio de sesión guardados';

  @override
  String get accountLoginNoteHint =>
      'Solo se guardan en este dispositivo, protegidos de forma segura. Sirven para consultarlos o rellenarlos rápido al volver a iniciar sesión.';

  @override
  String get accountLoginNoteLocked => 'Desbloquear datos de inicio de sesión';

  @override
  String get accountLoginNotePassword => 'Contraseña';

  @override
  String get accountLoginNoteSaved => 'Datos de inicio de sesión guardados';

  @override
  String get accountLoginNoteUsername => 'Nombre de usuario de Riot';

  @override
  String get accountManageHint =>
      'Elimina cuentas o edita los datos de inicio de sesión en Ajustes.';

  @override
  String accountMaxAccounts(int max) {
    return 'Has alcanzado el máximo de cuentas ($max).';
  }

  @override
  String get accountNeedsLogin => 'Inicia sesión de nuevo';

  @override
  String accountOnlineCount(int count) {
    return '$count en línea';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'Rellenar cuenta guardada';

  @override
  String get accountQuickFillDone => 'Datos rellenados. Pulsa Iniciar sesión.';

  @override
  String get accountQuickFillNotReady =>
      'La página de inicio de sesión aún no ha cargado. Espera un momento y vuelve a intentarlo.';

  @override
  String get accountQuickFillSubtitle =>
      'Elige una cuenta para rellenar la página de inicio de sesión de Riot';

  @override
  String get accountQuickFillTitle => 'Rellenar cuenta guardada';

  @override
  String get accountRegionAp => 'Asia-Pacífico';

  @override
  String get accountRegionBr => 'Brasil';

  @override
  String get accountRegionEu => 'Europa';

  @override
  String get accountRegionKr => 'Corea';

  @override
  String get accountRegionLatam => 'Latinoamérica';

  @override
  String get accountRegionNa => 'Norteamérica';

  @override
  String get accountRemoveAccount => 'Eliminar cuenta';

  @override
  String accountRemoveAccountConfirm(String account) {
    return '¿Eliminar $account de este dispositivo? Puedes conservar los datos guardados.';
  }

  @override
  String get accountRrHistoryCleared => 'Historial de RR borrado';

  @override
  String get accountShowPassword => 'Mostrar contraseña';

  @override
  String get accountSignOutAll => 'Cerrar sesión en todas las cuentas';

  @override
  String get accountSignOutAllConfirm =>
      '¿Cerrar sesión y eliminar todas las cuentas de este dispositivo? Puedes conservar los datos guardados.';

  @override
  String get accountStatusAgentSelect => 'Seleccionando agente';

  @override
  String get accountStatusInMatch => 'En partida';

  @override
  String get accountStatusOffline => 'Desconectado';

  @override
  String get accountStatusOnline => 'En línea';

  @override
  String get accountStatusUnknown => 'Estado desconocido';

  @override
  String accountSwitchTo(String account) {
    return 'Cambiar a $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Toca para cambiar de cuenta';

  @override
  String get accountSwitcherTitle => 'Cuentas';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Cuentas ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Jugador';

  @override
  String get accountUnlockLoginNote =>
      'Verifica tu identidad para ver los datos de inicio de sesión de Riot';

  @override
  String accountMoreActions(String riotId) {
    return 'Opciones de $riotId';
  }

  @override
  String get accountLoginNoteAdd => 'Guardar datos de inicio de sesión';

  @override
  String get accountClearRrHistorySubtitle => 'Solo la cuenta seleccionada';

  @override
  String get accountClearLocalDataSubtitle =>
      'Historial, equipamientos guardados y datos de cuentas cerradas';

  @override
  String get accountQuickFillLocked =>
      'Desbloquea con tu huella, tu cara o el PIN del dispositivo para usar una cuenta guardada. Si tu móvil no tiene bloqueo de pantalla, configura uno y vuelve a intentarlo.';

  @override
  String get authAddAsNew => 'Añadir como cuenta nueva';

  @override
  String get authDifferentAccountBody =>
      'Has iniciado sesión con una cuenta distinta de la que tenía que volver a iniciar sesión. ¿Quieres añadirla como cuenta nueva?';

  @override
  String get authDifferentAccountTitle => 'Otra cuenta';

  @override
  String get authLoadingAccount => 'Cargando cuenta…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot ha rechazado este inicio de sesión. Vuelve a intentarlo.';

  @override
  String get authLoginFailed => 'No se ha podido completar el inicio de sesión';

  @override
  String get authLoginFailedBody =>
      'Riot no ha confirmado tu inicio de sesión. Vuelve a intentarlo.';

  @override
  String get authLoginTitle => 'Iniciar sesión en Riot';

  @override
  String get authMissingCookies =>
      'No se puede guardar el inicio de sesión en este dispositivo, así que tendrás que volver a iniciar sesión cuando caduque.';

  @override
  String get authOfficialHost => 'Página oficial · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Enlace abierto en el navegador.';

  @override
  String get authPageLoadFailed =>
      'No se ha podido cargar la página de inicio de sesión de Riot. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get authPreparing => 'Preparando la página de inicio de sesión…';

  @override
  String get authReloginDone => 'Sesión iniciada de nuevo';

  @override
  String get authSignInCta => 'Iniciar sesión con tu cuenta de Riot';

  @override
  String get authSocialLoginHint =>
      'Si no puedes iniciar sesión con Google o Facebook, usa tu nombre de usuario de Riot.';

  @override
  String get authStateMismatch =>
      'Este inicio de sesión no es válido. Vuelve a iniciar sesión desde el principio.';

  @override
  String get notificationSessionExpiredBody =>
      'Vuelve a iniciar sesión para seguir recibiendo avisos de tu lista de deseos.';

  @override
  String get notificationBackgroundTimingHint =>
      'El modo de ahorro de batería del dispositivo puede retrasar las notificaciones.';

  @override
  String get notificationChannelAccountDescription =>
      'Avisa cuando una cuenta necesita volver a iniciar sesión';

  @override
  String get notificationChannelAccountName => 'Cuentas';

  @override
  String get notificationChannelBattlePassDescription =>
      'Avisos del progreso y del final del Battle Pass';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'Avisos de actividad de la comunidad al abrir ValHub';

  @override
  String get notificationChannelCommunityName => 'Comunidad';

  @override
  String get notificationChannelLfgDescription =>
      'Avisa cuando alguien se une a tu grupo al abrir ValHub';

  @override
  String get notificationChannelLfgName => 'Grupo';

  @override
  String get notificationChannelNightMarketDescription =>
      'Avisa cuando abre el Mercado nocturno';

  @override
  String get notificationChannelNightMarketName => 'Mercado nocturno';

  @override
  String get notificationChannelRankDescription =>
      'Avisa de cambios de rango al actualizar tu perfil';

  @override
  String get notificationChannelRankName => 'Rango';

  @override
  String get notificationChannelStoreResetDescription =>
      'Avisa cuando se renueva la tienda diaria';

  @override
  String get notificationChannelStoreResetName => 'Renovación de la tienda';

  @override
  String get notificationChannelWishlistDescription =>
      'Avisa cuando una skin de tu lista de deseos aparece en la tienda';

  @override
  String get notificationChannelWishlistName => 'Lista de deseos';

  @override
  String get notificationLfgJoinedTitle => 'Alguien se ha unido a tu grupo';

  @override
  String get notificationLocalOnlyHint =>
      'Solo avisa en este dispositivo cuando ValHub actualiza los datos';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Cartas de oferta de $account por descubrir: $cards. ¡Dales la vuelta ya!';
  }

  @override
  String get notificationNightMarketOpenTitle =>
      '¡El Mercado nocturno ha abierto!';

  @override
  String get notificationPassEndingBody =>
      'Al Battle Pass le queda aproximadamente un día. Abre ValHub para ver tu progreso actualizado.';

  @override
  String get notificationPassEndingTitle => 'El Battle Pass termina pronto';

  @override
  String notificationPassProgressBody(int level) {
    return 'Has alcanzado el nivel $level del Battle Pass actual.';
  }

  @override
  String get notificationPassProgressTitle => 'Progreso del Battle Pass';

  @override
  String get notificationPrivateAccount => 'tu cuenta';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Rango actual: $rank. Datos recién actualizados desde Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Tu rango ha cambiado';

  @override
  String get notificationResetTimingUnknown =>
      'Abre la tienda para actualizar la hora de renovación en tu dispositivo.';

  @override
  String get notificationSessionExpiredTitle => 'Inicia sesión de nuevo';

  @override
  String get notificationStoreResetBody =>
      'Hay skins nuevas esperándote en la tienda.';

  @override
  String get competitiveDivisionIron => 'Hierro';

  @override
  String get competitiveDivisionBronze => 'Bronce';

  @override
  String get competitiveDivisionSilver => 'Plata';

  @override
  String get competitiveDivisionGold => 'Oro';

  @override
  String get competitiveDivisionPlatinum => 'Platino';

  @override
  String get competitiveDivisionDiamond => 'Diamante';

  @override
  String get competitiveDivisionAscendant => 'Ascendente';

  @override
  String get competitiveDivisionImmortal => 'Inmortal';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Radiante';

  @override
  String get competitiveRankUnknown => 'Rango desconocido';

  @override
  String get competitiveAttack => 'Ataque';

  @override
  String get competitiveCannotEstimate => 'No se puede estimar';

  @override
  String get competitiveDefeat => 'Derrota';

  @override
  String get competitiveDefense => 'Defensa';

  @override
  String get competitiveDraw => 'Empate';

  @override
  String get competitiveIncognitoPlayer => 'Jugador de incógnito';

  @override
  String get competitiveMatchPending => 'Riot está procesando la partida…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Quedan $n partidas de clasificación',
      one: 'Queda $n partida de clasificación',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'Spike desactivada';

  @override
  String get competitiveRoundDetonate => 'Spike detonada';

  @override
  String get competitiveRoundElimination => 'Equipo eliminado';

  @override
  String get competitiveRoundSurrendered => 'Rendición';

  @override
  String get competitiveRoundTimeExpired => 'Tiempo agotado';

  @override
  String get competitiveUnknownPlayer => 'Jugador';

  @override
  String get competitiveVictory => 'Victoria';

  @override
  String economyAvailableNow(String place) {
    return '¡Ya disponible en $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'lote $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'lote';

  @override
  String get economyPlaceDaily => 'tienda diaria';

  @override
  String get economyPlaceNightMarket => 'Mercado nocturno';

  @override
  String get economyPriceEstimated => 'Precio estimado según la edición';

  @override
  String get economyPriceFromOffers => 'Precio de la tabla de precios de Riot';

  @override
  String get economyPriceFromStore => 'Precio visto en la tienda';

  @override
  String get economyPriceFromTable => 'Precio de catálogo';

  @override
  String get economyPriceUnknown => 'Precio desconocido';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Conjunto $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Este cambio no se puede aplicar a tu equipamiento actual.';

  @override
  String get loadoutNotPersisted =>
      'Riot no ha guardado tus cambios, así que tu equipamiento sigue igual. Vuelve a intentarlo.';

  @override
  String get loadoutSaveFailed => 'No se ha podido guardar el equipamiento';

  @override
  String battlePassActEndsIn(String time) {
    return 'El acto termina en $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'El acto termina en $days días',
      one: 'El acto termina en $days día',
    );
    return '$_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'Has completado todas las misiones';

  @override
  String get battlePassAllWeeklyDone =>
      'Has completado todas las misiones semanales';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Bonificación doble pendiente: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Capítulo $n';
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
      'Gana rondas para avanzar hacia el hito (Combate a muerte no cuenta).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Hito $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Cada hito: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Hitos alcanzados: $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'Actual';

  @override
  String get battlePassDailyAllDone => 'Has alcanzado todos los hitos de hoy';

  @override
  String get battlePassDailyCaption => 'Recompensas diarias';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Recompensas diarias · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Los hitos del día anterior han caducado. Entra en el juego o actualízalos aquí.';

  @override
  String get battlePassDailyMissions => 'Misiones diarias';

  @override
  String get battlePassDailyNotReady =>
      'Los hitos de hoy aún no están listos. Entra en el juego o actualízalos aquí.';

  @override
  String get battlePassDailyPlayToStart =>
      'Los hitos de hoy aún no están listos. Entra en el juego para empezar el nuevo día.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Quedan $days días',
      one: 'Queda $days día',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Termina: $wall';
  }

  @override
  String get battlePassEpilogue => 'Epílogo';

  @override
  String get battlePassEstimateNote =>
      'Estimación de unos 4000 XP por partida, sin contar misiones.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Termina en $time';
  }

  @override
  String get battlePassEventPass => 'Pase de evento';

  @override
  String get battlePassFilterAll => 'Todo';

  @override
  String get battlePassFilterLocked => 'Bloqueadas';

  @override
  String get battlePassFilterUnlocked => 'Desbloqueadas';

  @override
  String get battlePassFree => 'Gratis';

  @override
  String get battlePassFreeTrack => 'Recompensas gratuitas';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Nivel $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Nivel $n';
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
      other: '$nString partidas',
      one: '$nString partida',
    );
    return '≈ $_temp0 de $queue';
  }

  @override
  String get battlePassMissionDone => 'Completada';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total completadas';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Nuevas misiones: $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Nuevas misiones en $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Siguiente hito: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Hasta el nivel $level';
  }

  @override
  String get battlePassNextReward => 'Siguiente';

  @override
  String get battlePassNoBattlePass =>
      'Aún no hay información del Battle Pass del acto actual. Vuelve a intentarlo más tarde.';

  @override
  String get battlePassNoRewards =>
      'Este Battle Pass todavía no tiene recompensas.';

  @override
  String get battlePassNoRewardsInFilter =>
      'No hay recompensas en esta sección.';

  @override
  String get battlePassNoRewardsTitle => 'Sin recompensas';

  @override
  String get battlePassNoWeeklyMissions =>
      'Ahora mismo no hay misiones semanales.';

  @override
  String get battlePassPassComplete => 'Battle Pass completado';

  @override
  String get battlePassPremium => 'Prémium';

  @override
  String get battlePassPremiumHint =>
      'No has comprado el Prémium: solo recibes las recompensas gratuitas. Cómpralo en el juego para desbloquear los niveles que ya has alcanzado.';

  @override
  String get battlePassRenewButton => 'Actualizar hitos';

  @override
  String get battlePassRenewDone => 'Hitos diarios actualizados.';

  @override
  String get battlePassRenewFailed =>
      'No se han podido actualizar los hitos. Vuelve a intentarlo más tarde.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Se renueva: $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Se renueva en $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Nivel';

  @override
  String get battlePassRewardLocked => 'Bloqueada';

  @override
  String get battlePassRewardNeedsPremium => 'Requiere Prémium';

  @override
  String get battlePassRewardStatusLabel => 'Estado';

  @override
  String get battlePassRewardTrackLabel => 'Tipo de recompensa';

  @override
  String get battlePassRewardTypeLabel => 'Tipo';

  @override
  String get battlePassRewardUnlocked => 'Desbloqueada';

  @override
  String get battlePassRewardsTitle => 'Recompensas';

  @override
  String get battlePassShowAllRewards => 'Ver todo';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'XP total';

  @override
  String get battlePassUnknownMission => 'Nueva misión (sin descripción)';

  @override
  String get battlePassUnknownReward => 'Recompensa';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total desbloqueadas';
  }

  @override
  String get battlePassUnratedFallback => 'No competitivo';

  @override
  String get battlePassViewAllRewards => 'Ver todas las recompensas';

  @override
  String get battlePassWeeklyMissions => 'Misiones semanales';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Misiones semanales pendientes: +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / día';
  }

  @override
  String get battlePassXpPerDayCaption =>
      'Necesarios cada día para completarlo a tiempo';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Faltan $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'No se ha podido guardar el equipamiento. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Todas tus skins, valoradas según el precio de la tienda',
      'buddy': 'Colgantes que tienes y número de copias',
      'spray': 'Grafitis que puedes poner en tu rueda de expresiones',
      'card':
          'Tarjetas de jugador desbloqueadas: toca para verlas y equiparlas',
      'title': 'Títulos que puedes mostrar bajo tu nombre',
      'flex': 'Flex que tienes',
      'other': 'Explorar colección',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Espacio $position';
  }

  @override
  String get collectionApplyPreset => 'Aplicar';

  @override
  String get collectionApplyPresetBody =>
      'Las skins, colgantes, rueda de expresiones, tarjeta y título que llevas ahora se sustituirán por los de este conjunto.';

  @override
  String collectionApplyPresetTitle(String name) {
    return '¿Aplicar «$name»?';
  }

  @override
  String get collectionBrowseBuddies => 'Colgantes';

  @override
  String get collectionBrowseCards => 'Tarjetas de jugador';

  @override
  String get collectionBrowseEmpty =>
      'Todavía no tienes objetos en esta sección.';

  @override
  String get collectionBrowseEmptyTitle => 'Sin objetos';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skins';

  @override
  String get collectionBrowseSprays => 'Grafitis';

  @override
  String get collectionBrowseTitles => 'Títulos';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Libres: $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Para $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Elegir colgante';

  @override
  String get collectionBuddyRemoved => 'Colgante quitado';

  @override
  String get collectionBuddySlot => 'Colgante';

  @override
  String get collectionBuddyUnavailable =>
      'No se ha podido poner este colgante. Actualiza o elige otro.';

  @override
  String get collectionCachedLoadout =>
      'Mostrando el equipamiento guardado. Desliza hacia abajo para actualizar antes de hacer cambios.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString tarjetas en tu colección',
      one: '$nString tarjeta en tu colección',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'Cambiar';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total variantes';
  }

  @override
  String get collectionClearTiers => 'Quitar filtro de edición';

  @override
  String get collectionCollectionValue => 'Valor de la colección';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Predeterminado';

  @override
  String get collectionDeletePreset => 'Eliminar';

  @override
  String get collectionEmptySlot => 'Vacío';

  @override
  String get collectionEquip => 'Equipar';

  @override
  String get collectionEquipped => 'Equipado';

  @override
  String get collectionEquippedCard => 'Tarjeta equipada';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Tarjeta equipada: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return '$name equipado';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Equipado: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Sin contar skins de recompensa';

  @override
  String get collectionExpressionsHint =>
      'Toca un espacio para elegir un grafiti o un Flex.';

  @override
  String get collectionExpressionsSlots => 'Espacios de la rueda';

  @override
  String get collectionExpressionsTitle => 'Rueda de expresiones';

  @override
  String get collectionHideAccountLevel => 'Ocultar nivel de cuenta';

  @override
  String get collectionHideAccountLevelHint =>
      'Los demás jugadores no verán tu nivel de cuenta.';

  @override
  String get collectionIncognito => 'Modo incógnito';

  @override
  String get collectionIncognitoHint =>
      'Oculta tu nombre a los jugadores que no están en tu grupo durante la partida.';

  @override
  String get collectionLevelBorderAuto => 'Automático según el nivel';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'Desde el nivel $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Cuenta de nivel $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Elegir borde de nivel';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Nivel $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Nivel $n · $type';
  }

  @override
  String get collectionLevels => 'Niveles';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '$owned/$total niveles desbloqueados';
  }

  @override
  String get collectionLobbyBanner => 'Imagen de la sala';

  @override
  String get collectionLocked => 'Bloqueado';

  @override
  String get collectionMeleeNoBuddy =>
      'No se pueden poner colgantes en el arma cuerpo a cuerpo.';

  @override
  String get collectionMove => 'Mover';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy está puesto en $from. ¿Moverlo a $to?';
  }

  @override
  String get collectionMoveBuddyTitle => '¿Mover colgante?';

  @override
  String get collectionNoBuddies => 'Todavía no tienes colgantes.';

  @override
  String get collectionNoBuddy => 'Sin colgante';

  @override
  String get collectionNoFlex => 'Todavía no tienes ningún Flex.';

  @override
  String get collectionNoResults => 'No se han encontrado resultados.';

  @override
  String get collectionNoResultsTitle => 'Sin resultados';

  @override
  String get collectionNoSkinsForWeapon =>
      'Todavía no tienes skins para esta arma.';

  @override
  String get collectionNoSprays => 'Todavía no tienes grafitis.';

  @override
  String get collectionNoTitle => 'Sin título';

  @override
  String get collectionOtherWeapons => 'Otras';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Tienes $n skins',
      one: 'Tienes $n skin',
      zero: 'Aún no tienes skins',
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
      other: '$nString skins en tu colección',
      one: '$nString skin en tu colección',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'Ver vídeo de este nivel';

  @override
  String get collectionPlayVideo => 'Ver vídeo';

  @override
  String get collectionPlayerCardSubtitle =>
      'Se muestra en la sala, en la tabla de puntuación y cuando eliminas a un rival.';

  @override
  String get collectionPlayerCardTitle => 'Cambiar tarjeta de jugador';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Se muestra bajo tu nombre en la sala y en la partida.';

  @override
  String get collectionPlayerTitleTitle => 'Cambiar título';

  @override
  String get collectionPresetActions => 'Opciones';

  @override
  String collectionPresetApplied(String name) {
    return '«$name» aplicado';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n conjuntos',
      one: '$n conjunto',
      zero: 'Ninguno',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '«$name» eliminado';
  }

  @override
  String get collectionPresetNameHint => 'Ejemplo: Subir de rango';

  @override
  String get collectionPresetNameTitle => 'Nombre del conjunto';

  @override
  String collectionPresetSaved(String name) {
    return '«$name» guardado';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Guardado el $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Se han omitido $n objetos que ya no tienes.',
      one: 'Se ha omitido $n objeto que ya no tienes.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'Guarda tu equipamiento actual para cambiar rápido entre conjuntos de skins, tarjetas y ruedas de expresiones más adelante.';

  @override
  String get collectionPresetsEmptyTitle => 'No hay conjuntos';

  @override
  String get collectionPresetsFull =>
      'Has alcanzado el máximo de 50 conjuntos. Elimina alguno para guardar más.';

  @override
  String get collectionPresetsNote =>
      'Los conjuntos solo se guardan en este dispositivo, para la cuenta seleccionada.';

  @override
  String get collectionPresetsTitle => 'Conjuntos guardados';

  @override
  String get collectionPreview => 'Vista previa';

  @override
  String get collectionRemoveBuddy => 'Quitar colgante';

  @override
  String get collectionRenamePreset => 'Cambiar nombre';

  @override
  String get collectionRowExpressions => 'Rueda de expresiones';

  @override
  String get collectionRowLevelBorder => 'Borde de nivel';

  @override
  String get collectionRowPresets => 'Conjuntos guardados';

  @override
  String get collectionRowWeapons => 'Equipamiento de armas';

  @override
  String get collectionRowWishlist => 'Lista de deseos';

  @override
  String get collectionSaveFailed => 'No se ha podido guardar el equipamiento';

  @override
  String get collectionSavePreset => 'Guardar equipamiento actual';

  @override
  String get collectionSaving => 'Guardando…';

  @override
  String get collectionSearchBuddies => 'Buscar colgantes…';

  @override
  String get collectionSearchCards => 'Buscar tarjetas de jugador…';

  @override
  String get collectionSearchFlex => 'Buscar Flex…';

  @override
  String get collectionSearchItems => 'Buscar…';

  @override
  String get collectionSearchSkins => 'Buscar skins…';

  @override
  String get collectionSearchSprays => 'Buscar grafitis…';

  @override
  String get collectionSearchTitles => 'Buscar títulos…';

  @override
  String get collectionSearchWeapons => 'Buscar armas, skins o colgantes…';

  @override
  String get collectionSectionBrowse => 'Explorar colección';

  @override
  String get collectionSectionIdentity => 'Lo que ven otros jugadores';

  @override
  String get collectionSectionLoadout => 'Equipamiento';

  @override
  String get collectionSkinCustomizeTitle => 'Personalizar skin';

  @override
  String get collectionSkinNotFound => 'No se ha encontrado esta skin.';

  @override
  String get collectionSkinNotOwned => 'Todavía no tienes esta skin.';

  @override
  String get collectionSlotNamesItem0 => 'Arriba';

  @override
  String get collectionSlotNamesItem1 => 'Derecha';

  @override
  String get collectionSlotNamesItem2 => 'Abajo';

  @override
  String get collectionSlotNamesItem3 => 'Izquierda';

  @override
  String get collectionSortName => 'Nombre';

  @override
  String get collectionSortPrice => 'Precio';

  @override
  String get collectionSortRarity => 'Rareza';

  @override
  String get collectionSortWeapon => 'Arma';

  @override
  String collectionSummaryFiltered(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filtrado: $count skins · $value',
      one: 'Filtrado: $count skin · $value',
    );
    return '$_temp0';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Filtrado: $count/$total objetos';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objetos',
      one: '$count objeto',
    );
    return '$_temp0';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins · $value',
      one: '$count skin · $value',
    );
    return '$_temp0';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Grafitis';

  @override
  String get collectionTapToChangeCard => 'Toca para cambiar la tarjeta';

  @override
  String get collectionTitle => 'Colección';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString títulos en tu colección',
      one: '$nString título en tu colección',
    );
    return '$_temp0';
  }

  @override
  String get collectionUndo => 'Deshacer';

  @override
  String get collectionUnknownCard => 'Tarjeta sin nombre';

  @override
  String get collectionValueAtStorePrices => 'Según los precios de la tienda';

  @override
  String get collectionValueHasEstimates => 'Incluye precios estimados (≈)';

  @override
  String collectionValueRewardCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins de recompensa no se incluyen',
      one: '$n skin de recompensa no se incluye',
    );
    return '$_temp0';
  }

  @override
  String get collectionValueSeeSkins => 'Ver las skins';

  @override
  String collectionValueSkinCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Calculado con $n skins',
      one: 'Calculado con $n skin',
    );
    return '$_temp0';
  }

  @override
  String get collectionVariants => 'Variantes';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$total armas con skin';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Equipamiento de armas';

  @override
  String get collectionWeaponNotFound => 'No se ha encontrado esta arma.';

  @override
  String get collectionWeaponSkinsTitle => 'Elegir skin';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins',
      one: '$n skin',
      zero: 'Vacía',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'No se ha podido publicar porque contiene lenguaje inapropiado. Edita el texto y vuelve a intentarlo.';

  @override
  String get communityModerationContentScam =>
      'La comunidad no permite anunciar la compraventa de cuentas, servicios de boosting ni dejar números de teléfono. Quita ese contenido y vuelve a intentarlo.';

  @override
  String get communityModerationContentTooComplex =>
      'El texto tiene demasiados caracteres sueltos. Escríbelo de forma más clara y vuelve a intentarlo.';

  @override
  String get communityModerationAccountBanned =>
      'Esta cuenta ha perdido el acceso a la Comunidad. Si crees que es un error, contacta con ValHub en Acerca de y legal.';

  @override
  String get communityModerationAccountRestricted =>
      'Esta cuenta tiene restringido publicar, comentar, buscar compañeros y votar. Vuelve a intentarlo más tarde o contacta con ValHub en Acerca de y legal.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Competitivo',
      'unrated': 'No competitivo',
      'swiftplay': 'Modo rápido',
      'spikerush': 'Fiebre de la Spike',
      'deathmatch': 'Combate a muerte',
      'teamdeathmatch': 'Combate a muerte por equipos',
      'premier': 'Premier',
      'custom': 'Personalizada',
      'other': 'Otro',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Asia-Pacífico',
      'na': 'Norteamérica',
      'eu': 'Europa',
      'kr': 'Corea',
      'latam': 'Latinoamérica',
      'br': 'Brasil',
      'other': 'Servidor desconocido',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle =>
      'Todavía no hay skins en esta clasificación';

  @override
  String get communityRankingEmptyVotes =>
      'Todavía no hay favoritos que coincidan con el alcance y los filtros seleccionados.';

  @override
  String get communityRankingEmptyRatings =>
      'Todavía no hay valoraciones con estrellas que coincidan con el alcance y los filtros seleccionados.';

  @override
  String get communityRankingEmptyReviews =>
      'Todavía no hay reseñas que coincidan con el alcance y los filtros seleccionados.';

  @override
  String get communityRankingExplore => 'Busca skins para verlas y valorarlas';

  @override
  String get communityRankingExploreHint =>
      'Busca por nombre de skin o de arma. En la clasificación solo aparecen valoraciones reales de la comunidad.';

  @override
  String get communityRankingClear => 'Quitar filtros de arma y periodo';

  @override
  String get communityRankingSort => 'Clasificar por';

  @override
  String get communityRankingWeapon => 'Arma';

  @override
  String get communityRankingNoSearch =>
      'No se han encontrado skins. Prueba con otro nombre o quita el filtro de arma.';

  @override
  String get communityRankingCatalogUnavailable =>
      'No se ha podido cargar el catálogo de skins. Cierra el panel y vuelve a intentarlo cuando se sincronicen los datos.';

  @override
  String get communityConsentExitAccount =>
      'No acepto · Cerrar sesión en esta cuenta';

  @override
  String get communityRankingGlobalAllTime => 'Global · Histórico';

  @override
  String get communityRankingCatalogTitle => 'Todas las skins';

  @override
  String get communityReviewOwnershipRequired =>
      'Tu cuenta debe tener esta skin para valorarla. Aun así, puedes ver las valoraciones y comentarios de la comunidad.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'No se ha podido verificar que tengas esta skin. Vuelve a cargar la Colección o inténtalo de nuevo cuando tengas conexión.';

  @override
  String get communityReviewLegacyOwnership =>
      'Reseña antigua · Propiedad sin verificar';

  @override
  String get communityReviewVerifiedOwner => 'Propiedad verificada al valorar';

  @override
  String get communitySkinDiscussionHint =>
      'Cualquiera puede comentar. Solo quienes tienen la skin pueden puntuar con estrellas y escribir reseñas.';

  @override
  String get communityAddPhotos => 'Añadir fotos';

  @override
  String get communityAllModes => 'Todos';

  @override
  String get communityAllWeapons => 'Todas las armas';

  @override
  String get communityAnonymousBanner => 'Navegando de forma anónima';

  @override
  String get communityAnyLanguage => 'Cualquier idioma';

  @override
  String get communityAnyRank => 'Cualquier rango';

  @override
  String get communityAnyRole => 'Cualquier rol';

  @override
  String get communityApply => 'Aplicar';

  @override
  String get communityBackToMyCountry => 'Volver a mi país';

  @override
  String get communityBlockAuthor => 'Bloquear en este dispositivo';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Quitar selección';

  @override
  String get communityCodeAuto =>
      'Déjalo vacío: ValHub creará el código a partir de tu grupo en el juego al publicar el anuncio.';

  @override
  String get communityCodeAutoFailed =>
      'No se ha podido crear el código de grupo. Abre VALORANT o introduce el código a mano.';

  @override
  String get communityCodeInvalid =>
      'El código debe tener exactamente 6 letras mayúsculas o números.';

  @override
  String get communityCodeRequired => 'Introduce o crea un código de grupo.';

  @override
  String get communityCommentHint => 'Escribe un comentario…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString comentarios',
      one: '$nString comentario',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Comentarios · $n';
  }

  @override
  String get communityCommentsTitle => 'Comentarios';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Publicaciones: $posts · Jugadores: $authors';
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
      other: '$nString anuncios de búsqueda',
      one: '$nString anuncio de búsqueda',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'Favoritas de la comunidad';

  @override
  String get communityComposerHint => '¿Qué piensas hoy de VALORANT?';

  @override
  String get communityComposerTitle => 'Nueva publicación';

  @override
  String communityConsentAccount(String riotId) {
    return 'Cuenta: $riotId';
  }

  @override
  String get communityConsentAgree => 'Aceptar y continuar';

  @override
  String get communityConsentGateAction => 'Unirse';

  @override
  String get communityConsentGuidelines => 'Normas de la comunidad';

  @override
  String get communityConsentLater => 'Más tarde';

  @override
  String get communityConsentLocal =>
      'Tu contraseña y el resto de tus datos de inicio de sesión se quedan siempre en este dispositivo. Puedes retirar tu consentimiento en Ajustes.';

  @override
  String get communityConsentPrivacy => 'Política de privacidad';

  @override
  String get communityConsentPublic =>
      'Los demás verán tu Riot ID, tu tarjeta de jugador, tu rango y tu país.';

  @override
  String get communityConsentTitle => 'Privacidad y Comunidad de ValHub';

  @override
  String get communityConsentVerify =>
      'ValHub envía tu acceso de Riot al servidor de la Comunidad para verificar tu Riot ID al conectarte y comprobar que tienes una skin cuando guardas una reseña. El servidor solo lee los datos necesarios, descarta el acceso en cuanto termina y no lo guarda.';

  @override
  String get communityConsentWithdrawn =>
      'Has retirado tu consentimiento. Debes volver a aceptarlo para seguir usando la app.';

  @override
  String get communityCountriesTitle => 'Comunidades por país';

  @override
  String get communityCountryNamesAE => 'Emiratos Árabes Unidos';

  @override
  String get communityCountryNamesAL => 'Albania';

  @override
  String get communityCountryNamesAM => 'Armenia';

  @override
  String get communityCountryNamesAR => 'Argentina';

  @override
  String get communityCountryNamesAT => 'Austria';

  @override
  String get communityCountryNamesAU => 'Australia';

  @override
  String get communityCountryNamesAZ => 'Azerbaiyán';

  @override
  String get communityCountryNamesBA => 'Bosnia y Herzegovina';

  @override
  String get communityCountryNamesBD => 'Bangladés';

  @override
  String get communityCountryNamesBE => 'Bélgica';

  @override
  String get communityCountryNamesBG => 'Bulgaria';

  @override
  String get communityCountryNamesBH => 'Baréin';

  @override
  String get communityCountryNamesBN => 'Brunéi';

  @override
  String get communityCountryNamesBO => 'Bolivia';

  @override
  String get communityCountryNamesBR => 'Brasil';

  @override
  String get communityCountryNamesBY => 'Bielorrusia';

  @override
  String get communityCountryNamesCA => 'Canadá';

  @override
  String get communityCountryNamesCH => 'Suiza';

  @override
  String get communityCountryNamesCL => 'Chile';

  @override
  String get communityCountryNamesCN => 'China';

  @override
  String get communityCountryNamesCO => 'Colombia';

  @override
  String get communityCountryNamesCR => 'Costa Rica';

  @override
  String get communityCountryNamesCU => 'Cuba';

  @override
  String get communityCountryNamesCY => 'Chipre';

  @override
  String get communityCountryNamesCZ => 'Chequia';

  @override
  String get communityCountryNamesDE => 'Alemania';

  @override
  String get communityCountryNamesDK => 'Dinamarca';

  @override
  String get communityCountryNamesDO => 'República Dominicana';

  @override
  String get communityCountryNamesDZ => 'Argelia';

  @override
  String get communityCountryNamesEC => 'Ecuador';

  @override
  String get communityCountryNamesEE => 'Estonia';

  @override
  String get communityCountryNamesEG => 'Egipto';

  @override
  String get communityCountryNamesES => 'España';

  @override
  String get communityCountryNamesET => 'Etiopía';

  @override
  String get communityCountryNamesFI => 'Finlandia';

  @override
  String get communityCountryNamesFR => 'Francia';

  @override
  String get communityCountryNamesGB => 'Reino Unido';

  @override
  String get communityCountryNamesGE => 'Georgia';

  @override
  String get communityCountryNamesGH => 'Ghana';

  @override
  String get communityCountryNamesGR => 'Grecia';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hong Kong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Croacia';

  @override
  String get communityCountryNamesHU => 'Hungría';

  @override
  String get communityCountryNamesID => 'Indonesia';

  @override
  String get communityCountryNamesIE => 'Irlanda';

  @override
  String get communityCountryNamesIL => 'Israel';

  @override
  String get communityCountryNamesIN => 'India';

  @override
  String get communityCountryNamesIQ => 'Irak';

  @override
  String get communityCountryNamesIR => 'Irán';

  @override
  String get communityCountryNamesIS => 'Islandia';

  @override
  String get communityCountryNamesIT => 'Italia';

  @override
  String get communityCountryNamesJO => 'Jordania';

  @override
  String get communityCountryNamesJP => 'Japón';

  @override
  String get communityCountryNamesKE => 'Kenia';

  @override
  String get communityCountryNamesKH => 'Camboya';

  @override
  String get communityCountryNamesKR => 'Corea del Sur';

  @override
  String get communityCountryNamesKW => 'Kuwait';

  @override
  String get communityCountryNamesKZ => 'Kazajistán';

  @override
  String get communityCountryNamesLA => 'Laos';

  @override
  String get communityCountryNamesLB => 'Líbano';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Lituania';

  @override
  String get communityCountryNamesLU => 'Luxemburgo';

  @override
  String get communityCountryNamesLV => 'Letonia';

  @override
  String get communityCountryNamesLY => 'Libia';

  @override
  String get communityCountryNamesMA => 'Marruecos';

  @override
  String get communityCountryNamesMD => 'Moldavia';

  @override
  String get communityCountryNamesME => 'Montenegro';

  @override
  String get communityCountryNamesMK => 'Macedonia del Norte';

  @override
  String get communityCountryNamesMM => 'Myanmar';

  @override
  String get communityCountryNamesMN => 'Mongolia';

  @override
  String get communityCountryNamesMO => 'Macao';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'México';

  @override
  String get communityCountryNamesMY => 'Malasia';

  @override
  String get communityCountryNamesNG => 'Nigeria';

  @override
  String get communityCountryNamesNI => 'Nicaragua';

  @override
  String get communityCountryNamesNL => 'Países Bajos';

  @override
  String get communityCountryNamesNO => 'Noruega';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'Nueva Zelanda';

  @override
  String get communityCountryNamesOM => 'Omán';

  @override
  String get communityCountryNamesPA => 'Panamá';

  @override
  String get communityCountryNamesPE => 'Perú';

  @override
  String get communityCountryNamesPH => 'Filipinas';

  @override
  String get communityCountryNamesPK => 'Pakistán';

  @override
  String get communityCountryNamesPL => 'Polonia';

  @override
  String get communityCountryNamesPR => 'Puerto Rico';

  @override
  String get communityCountryNamesPT => 'Portugal';

  @override
  String get communityCountryNamesPY => 'Paraguay';

  @override
  String get communityCountryNamesQA => 'Catar';

  @override
  String get communityCountryNamesRO => 'Rumanía';

  @override
  String get communityCountryNamesRS => 'Serbia';

  @override
  String get communityCountryNamesRU => 'Rusia';

  @override
  String get communityCountryNamesSA => 'Arabia Saudí';

  @override
  String get communityCountryNamesSE => 'Suecia';

  @override
  String get communityCountryNamesSG => 'Singapur';

  @override
  String get communityCountryNamesSI => 'Eslovenia';

  @override
  String get communityCountryNamesSK => 'Eslovaquia';

  @override
  String get communityCountryNamesSV => 'El Salvador';

  @override
  String get communityCountryNamesTH => 'Tailandia';

  @override
  String get communityCountryNamesTL => 'Timor Oriental';

  @override
  String get communityCountryNamesTN => 'Túnez';

  @override
  String get communityCountryNamesTR => 'Turquía';

  @override
  String get communityCountryNamesTW => 'Taiwán';

  @override
  String get communityCountryNamesUA => 'Ucrania';

  @override
  String get communityCountryNamesUS => 'Estados Unidos';

  @override
  String get communityCountryNamesUY => 'Uruguay';

  @override
  String get communityCountryNamesUZ => 'Uzbekistán';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Vietnam';

  @override
  String get communityCountryNamesZA => 'Sudáfrica';

  @override
  String get communityCreateLfg => 'Crear anuncio para buscar compañeros';

  @override
  String get communityCreateLfgShort => 'Crear anuncio';

  @override
  String get communityDataDeleted =>
      'Se han eliminado tus datos de la Comunidad.';

  @override
  String communityDataFooter(String riotId) {
    return 'Se aplica a la cuenta en uso: $riotId. El archivo descargado no incluye contraseñas ni datos de inicio de sesión de Riot.';
  }

  @override
  String get communityDataTitle => 'Tus datos de la Comunidad';

  @override
  String get communityDecrease => 'Reducir';

  @override
  String get communityDelete => 'Eliminar';

  @override
  String get communityDeleteComment => 'Eliminar comentario';

  @override
  String get communityDeleteCommentBody =>
      'Este comentario se eliminará para siempre.';

  @override
  String get communityDeleteCommentTitle => '¿Eliminar comentario?';

  @override
  String get communityDeleteDataConfirm => 'Eliminar para siempre';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Todas las publicaciones, comentarios, reseñas de skins, me gusta, votos, anuncios de búsqueda de compañeros y fotos de $riotId en la Comunidad de ValHub se eliminarán para siempre y no se podrán recuperar. Para seguir usando esta cuenta en ValHub tendrás que volver a aceptar; aun así puedes cambiar a otra cuenta o cerrar la sesión de esta.\n\nTu cuenta de Riot y tus datos del juego no se verán afectados. Descarga tus datos antes si quieres conservar una copia.';
  }

  @override
  String get communityDeleteDataConfirmTitle =>
      '¿Eliminar datos de la Comunidad?';

  @override
  String get communityDeleteDataSubtitle =>
      'Elimina para siempre todo lo que has publicado en la Comunidad.';

  @override
  String get communityDeleteDataTitle => 'Eliminar mis datos de la Comunidad';

  @override
  String get communityDeletePost => 'Eliminar publicación';

  @override
  String get communityDeletePostBody =>
      'La publicación y todos sus comentarios se eliminarán para siempre.';

  @override
  String get communityDeletePostTitle => '¿Eliminar publicación?';

  @override
  String get communityDeleteReview => 'Eliminar reseña';

  @override
  String get communityDeleteReviewBody =>
      'Se eliminarán tu puntuación y tu reseña de esta skin.';

  @override
  String get communityDeleteReviewTitle => '¿Eliminar tu reseña?';

  @override
  String get communityDeleted => 'Eliminado.';

  @override
  String get communityDiscard => 'Descartar';

  @override
  String get communityDiscardBody =>
      'Lo que acabas de escribir no se guardará.';

  @override
  String get communityDiscardTitle => '¿Descartar publicación?';

  @override
  String get communityDownload => 'Descargar y traducir';

  @override
  String get communityDownloadingModels => 'Descargando paquete de traducción…';

  @override
  String get communityEditReview => 'Editar';

  @override
  String get communityEdited => 'editado';

  @override
  String get communityEmptyPost => 'Escribe algo o añade una foto.';

  @override
  String get communityExpired => 'Caducado';

  @override
  String communityExpiresIn(String t) {
    return 'Quedan $t';
  }

  @override
  String get communityExportPreparing => 'Preparando…';

  @override
  String get communityExportSubject => 'Datos de la Comunidad de ValHub';

  @override
  String get communityExportSubtitle =>
      'Una copia de todo lo que has publicado en la Comunidad: publicaciones, comentarios, reseñas, me gusta, votos y anuncios de búsqueda de compañeros.';

  @override
  String get communityExportTitle => 'Descargar mis datos';

  @override
  String get communityExtend => 'Ampliar';

  @override
  String get communityExtended => 'Anuncio ampliado 30 minutos más.';

  @override
  String get communityFeedEmptyBody =>
      '¡Sé el primero en compartir tu tienda, tu Mercado nocturno o tus mejores momentos!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'No hay publicaciones que coincidan. Prueba con otro idioma o quita los filtros.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Aún no hay publicaciones nuevas. Vuelve más tarde o únete para compartir.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Prueba a ver publicaciones de la comunidad internacional o cambia los filtros.';

  @override
  String get communityFeedEmptyScopeTitle => 'Aún no hay publicaciones aquí';

  @override
  String get communityFeedEmptyTitle => 'El feed está vacío';

  @override
  String get communityFilters => 'Filtros';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Traducción de Google';

  @override
  String get communityHelpful => 'Útil';

  @override
  String communityHelpfulCount(String n) {
    return 'Útil · $n';
  }

  @override
  String get communityHiddenAuthors => 'Jugadores ocultos y bloqueados';

  @override
  String get communityHiddenAuthorsEmpty =>
      'No has ocultado ni bloqueado a nadie';

  @override
  String get communityHiddenAuthorsHint =>
      'Solo se aplica a esta cuenta en este dispositivo. Su contenido queda oculto; ellos pueden seguir viendo tu contenido público.';

  @override
  String communityImageOf(int i, int n) {
    return 'Foto $i de $n';
  }

  @override
  String get communityIncrease => 'Aumentar';

  @override
  String get communityJoin => 'Unirse';

  @override
  String get communityJoinCodeExpired =>
      'El código de grupo ha caducado o ya no es válido.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Saldrás de tu grupo actual en VALORANT para unirte al grupo de $name.';
  }

  @override
  String get communityJoinConfirmTitle => '¿Unirte a este grupo?';

  @override
  String get communityJoinGameNotRunning =>
      'Abre VALORANT en tu ordenador o consola y vuelve a intentarlo.';

  @override
  String get communityJoinParty => 'Unirse al grupo';

  @override
  String get communityJoinPartyFull => 'Este grupo está completo.';

  @override
  String get communityJoinedHint =>
      '¡Te has unido al grupo! Abre VALORANT para jugar juntos.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString solicitudes para unirse',
      one: '$nString solicitud para unirse',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'Mercado nocturno';

  @override
  String get communityKindStore => 'Tienda de hoy';

  @override
  String get communityLanguage => 'Idioma';

  @override
  String get communityLanguageFilter => 'Idioma del contenido';

  @override
  String get communityLanguageFilterHint =>
      'Solo se muestra el contenido escrito en los idiomas seleccionados. Déjalo vacío para verlo todo.';

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
      other: '$n idiomas',
      one: '$n idioma',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgEmptyBody =>
      'Crea un anuncio para que otros jugadores se unan a tu grupo con un solo toque.';

  @override
  String get communityLfgEmptyTitle => 'Nadie está buscando compañeros';

  @override
  String get communityLfgExpiredRepost =>
      'Tu anuncio ha caducado. Publica uno nuevo para buscar compañeros.';

  @override
  String get communityLfgGateBody =>
      'Únete (verificando tu Riot ID una sola vez) para ver los anuncios de jugadores de tu servidor y publicar los tuyos. Puedes seguir viendo el feed y la clasificación de skins con normalidad.';

  @override
  String get communityLfgGateTitle => 'Buscar compañeros es para miembros';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Estás viendo el servidor $region: solo los jugadores del mismo servidor que tu cuenta pueden unirse al grupo.';
  }

  @override
  String get communityLfgPosted => '¡Anuncio publicado!';

  @override
  String get communityLfgPreviewTitle => 'Busca compañeros de tu rango';

  @override
  String get communityLfgRemoved => 'Anuncio retirado.';

  @override
  String get communityLfgSameShardNote =>
      'Solo pueden unirse jugadores del mismo servidor.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Región: $region · El anuncio caduca a los 30 minutos.';
  }

  @override
  String get communityLike => 'Me gusta';

  @override
  String get communityLiveMembers => 'Miembros';

  @override
  String get communityMatchMyRank => 'Acorde a tu rango';

  @override
  String communityMemberJoined(String name) {
    return '$name se ha unido al grupo';
  }

  @override
  String get communityMemberJoinedBody =>
      'Alguien acaba de unirse desde tu anuncio.';

  @override
  String get communityMic => 'Micro necesario';

  @override
  String get communityMicOn => 'Con micro';

  @override
  String get communityMode => 'Modo';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'Más opciones';

  @override
  String get communityMuteAuthor => 'Ocultar a este jugador';

  @override
  String get communityNewPost => 'Publicar';

  @override
  String communityNightMarketOf(String date) {
    return 'Mercado nocturno del $date';
  }

  @override
  String get communityNoAccountBody =>
      'Añade una cuenta de Riot para publicar, buscar compañeros y votar skins.';

  @override
  String get communityNoAccountTitle => 'Inicia sesión para participar';

  @override
  String get communityNoComments => 'Aún no hay comentarios. ¡Sé el primero!';

  @override
  String get communityNoRatings => 'Sin valoraciones';

  @override
  String get communityNote => 'Nota';

  @override
  String get communityNoteHint =>
      'Ej.: falta 1 Controlador, con micro, buen rollo ante todo';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get communityOpenReviews => 'Ver reseñas';

  @override
  String get communityOutOfRange => 'Fuera de rango';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Código de grupo';

  @override
  String get communityPartyCodeHint => 'Ej.: A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Código de grupo: $code';
  }

  @override
  String get communityPartySize => 'Jugadores en el grupo';

  @override
  String get communityPartySizeFromGame => 'Según tu grupo en el juego';

  @override
  String communityPartySizeValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jugadores',
      one: '$n jugador',
    );
    return '$_temp0';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max fotos';
  }

  @override
  String get communityPlayVideo => 'Ver vídeo';

  @override
  String get communityPostLfg => 'Publicar anuncio';

  @override
  String get communityPostNotFound =>
      'Esta publicación se ha eliminado u ocultado.';

  @override
  String get communityPostTitle => 'Publicación';

  @override
  String get communityPosted => '¡Publicado!';

  @override
  String get communityPublish => 'Publicar';

  @override
  String get communityPublishing => 'Publicando…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'Desde';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Rangos admitidos';

  @override
  String get communityRankRangeInvalid =>
      'El rango mínimo no puede ser superior al rango máximo.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Puesto $n: $name';
  }

  @override
  String get communityRankTo => 'Hasta';

  @override
  String get communityRateLimitedTitle => 'Espera un momento';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString valoraciones',
      one: '$nString valoración',
    );
    return '$_temp0';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString valoraciones',
      one: '$nString valoración',
    );
    return '$avg · $_temp0';
  }

  @override
  String get communityRatingWordsItem0 => 'Mala';

  @override
  String get communityRatingWordsItem1 => 'Floja';

  @override
  String get communityRatingWordsItem2 => 'Correcta';

  @override
  String get communityRatingWordsItem3 => 'Bonita';

  @override
  String get communityRatingWordsItem4 => 'Obra maestra';

  @override
  String get communityRefreshList => 'Actualizar';

  @override
  String get communityRegion => 'Región';

  @override
  String get communityRemoveAttachment => 'Quitar adjunto';

  @override
  String get communityRemoveLfg => 'Retirar anuncio';

  @override
  String get communityRemoveLfgBody => 'Los demás ya no verán este anuncio.';

  @override
  String get communityRemoveLfgTitle => '¿Retirar el anuncio?';

  @override
  String get communityRemovePhoto => 'Quitar foto';

  @override
  String get communityReport => 'Denunciar';

  @override
  String get communityReportConfirmBody =>
      'El contenido denunciado por muchos jugadores se ocultará de la Comunidad.';

  @override
  String get communityReportConfirmTitle => '¿Enviar denuncia?';

  @override
  String get communityReportPrompt => '¿Por qué denuncias este contenido?';

  @override
  String get communityReportReasonsSpam => 'Spam o publicidad';

  @override
  String get communityReportReasonsHarassment => 'Acoso o insultos';

  @override
  String get communityReportReasonsInappropriate => 'Contenido inapropiado';

  @override
  String get communityReportReasonsScam => 'Estafa o compraventa de cuentas';

  @override
  String get communityReportReasonsOther => 'Otro motivo';

  @override
  String get communityReportTitle => 'Denunciar contenido';

  @override
  String get communityReported => '¡Gracias! Hemos recibido tu denuncia.';

  @override
  String get communityReviewDeleted => 'Reseña eliminada.';

  @override
  String get communityReviewHint => 'Cuenta qué te parece esta skin (opcional)';

  @override
  String get communityReviewSaved => '¡Reseña guardada!';

  @override
  String get communityReviewTitle => 'Valorar skin';

  @override
  String get communityReviewsEmptyBody => 'Aún no hay reseñas. ¡Sé el primero!';

  @override
  String get communityReviewsEmptyTitle => 'Sin reseñas';

  @override
  String communityReviewsHeader(String n) {
    return 'Reseñas · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot tiene problemas';

  @override
  String get communityRoleFlex => 'Flexible';

  @override
  String get communityRoles => 'Roles buscados';

  @override
  String get communitySaveReview => 'Guardar reseña';

  @override
  String get communityScopeCountry => 'Tu país';

  @override
  String get communityScopeGlobal => 'Internacional';

  @override
  String get communityScopeRegion => 'Región';

  @override
  String get communitySectionFeed => 'Feed';

  @override
  String get communitySectionLfg => 'Buscar equipo';

  @override
  String get communitySectionSkins => 'Top de skins';

  @override
  String get communitySend => 'Enviar';

  @override
  String get communitySendComment => 'Enviar comentario';

  @override
  String get communityShareNightMarketHint => 'Presume de tu Mercado nocturno';

  @override
  String communitySharePostTitle(String name) {
    return 'Publicación de $name en ValHub';
  }

  @override
  String get communityShareStore => 'Compartir en la Comunidad';

  @override
  String get communityShareStoreHint => 'Presume de tu tienda de hoy';

  @override
  String get communityShowOriginal => 'Ver original';

  @override
  String get communityShowTranslation => 'Ver traducción';

  @override
  String get communitySignInToReview =>
      'Añade una cuenta de Riot para valorar skins.';

  @override
  String get communitySkinNotFound => 'No se ha encontrado esta skin.';

  @override
  String get communitySlots => 'Jugadores buscados';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Un grupo tiene como máximo 5 jugadores: solo quedan $max huecos.',
      one: 'Un grupo tiene como máximo 5 jugadores: solo queda $max hueco.',
    );
    return '$_temp0';
  }

  @override
  String communitySlotsWanted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Se buscan $n jugadores',
      one: 'Se busca $n jugador',
    );
    return '$_temp0';
  }

  @override
  String get communitySortHelpful => 'Más útiles';

  @override
  String get communitySortNewest => 'Más recientes';

  @override
  String get communitySortRating => 'Mejor valoradas';

  @override
  String get communitySortReviews => 'Más reseñas';

  @override
  String get communitySortVotes => 'Más favoritas';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n estrellas',
      one: '$n estrella',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg de 5 estrellas';
  }

  @override
  String get communityStatusFull => 'Completo';

  @override
  String get communityStatusInGame => 'En partida';

  @override
  String get communityStatusOpen => 'Buscando';

  @override
  String communityStoreOf(String date) {
    return 'Tienda del $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Toca las estrellas para puntuar esta skin';

  @override
  String get communityTitle => 'Comunidad';

  @override
  String communityTooLong(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Máximo $max caracteres.',
      one: 'Máximo $max carácter.',
    );
    return '$_temp0';
  }

  @override
  String get communityTranslate => 'Traducir con Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Para traducir de $from a $to, ValHub tiene que descargar un paquete de idioma de Google (unos $size). Solo se descarga una vez; el contenido se traduce por completo en tu dispositivo y no se envía a ningún servidor.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      '¿Descargar paquete de traducción?';

  @override
  String get communityTranslateFailed =>
      'No se ha podido traducir. Vuelve a intentarlo.';

  @override
  String get communityTranslatedByGoogle => 'Traducción automática de Google';

  @override
  String get communityTranslating => 'Traduciendo…';

  @override
  String get communityTrendingTitle => 'Skins favoritas en todo el mundo';

  @override
  String get communityUnavailableBody =>
      'No se ha podido conectar con la Comunidad de ValHub. Vuelve a intentarlo en unos minutos.';

  @override
  String get communityUnavailableTitle =>
      'No se ha podido conectar con la Comunidad';

  @override
  String get communityUnhideAuthor => 'Mostrar / desbloquear';

  @override
  String get communityUnknownPlayer => 'Jugador';

  @override
  String get communityUnlike => 'Ya no me gusta';

  @override
  String get communityUnvote => 'Quitar corazón';

  @override
  String get communityVote => 'Dar corazón a esta skin';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString me gusta';
  }

  @override
  String get communityWithdrawConfirm => 'Retirar';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub dejará de usar la Comunidad con $riotId y borrará la conexión con la Comunidad en este dispositivo. Para seguir usando esta cuenta en ValHub tendrás que volver a aceptar; aun así puedes cambiar a otra cuenta o cerrar la sesión de esta.\n\nLas publicaciones, comentarios, reseñas, votos y anuncios de búsqueda de compañeros que ya hayas publicado seguirán en la Comunidad mostrando tu Riot ID hasta que los elimines uno a uno o elijas \"Eliminar mis datos de la Comunidad\".';
  }

  @override
  String get communityWithdrawConfirmTitle => '¿Retirar el consentimiento?';

  @override
  String get communityWithdrawSubtitle =>
      'Deja de usar la Comunidad con esta cuenta. Lo que hayas publicado se conserva.';

  @override
  String get communityWithdrawTitle => 'Retirar consentimiento';

  @override
  String get communityWriteFirstReview => 'Escribir la primera reseña';

  @override
  String get communityYou => 'Tú';

  @override
  String get communityYourCountry => 'Tu país';

  @override
  String get communityYourReview => 'Tu reseña';

  @override
  String communityHiddenAuthorsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString personas ocultas',
      one: '$nString persona oculta',
    );
    return '$_temp0';
  }

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Tú: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Selección de agente';

  @override
  String get liveGameAnonymous => 'Anónimo';

  @override
  String get liveGameAutoRefreshNote =>
      'Se actualiza automáticamente cuando haya partida.';

  @override
  String get liveGameCurrentGame => 'Partida actual';

  @override
  String get liveGameEmptyTeam => 'Aún no hay jugadores.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'El equipo enemigo aparecerá cuando empiece la partida.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Agentes enemigos fijados: $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'Esta fuente de partidas en directo no ofrece bajas, muertes ni asistencias. La tabla de puntuación aparecerá cuando Riot publique los datos tras la partida.';

  @override
  String get liveGameFinalScoreboard => 'Tabla de puntuación final';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'En la sala';

  @override
  String get liveGameInMatch => 'En partida';

  @override
  String get liveGameInQueue => 'Buscando partida';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'Buscando partida · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Nivel $n';
  }

  @override
  String get liveGameLiveScore => 'Marcador en directo';

  @override
  String get liveGameLoadoutFromAgentSelect =>
      'Equipamiento en la selección de agente';

  @override
  String get liveGameLoadoutFromMatch => 'Equipamiento en esta partida';

  @override
  String get liveGameLobbyHint =>
      'Cuando se encuentre partida, ValHub mostrará las alineaciones y los rangos de todos.';

  @override
  String get liveGameLockedTag => 'Fijado';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub lo volverá a intentar automáticamente. La tabla de puntuación suele estar disponible en un minuto.';

  @override
  String get liveGameNoAgentYet => 'Sin agente';

  @override
  String get liveGameNoLoadout =>
      'No hay información del equipamiento de este jugador.';

  @override
  String get liveGameNotInGame => 'Fuera de partida';

  @override
  String get liveGameNotInGameHint =>
      'Abre VALORANT y busca partida: los detalles aparecerán aquí automáticamente cuando llegues a la selección de agente.';

  @override
  String get liveGameNotInGameTitle => 'No estás en ninguna partida';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Ver el equipamiento de $name';
  }

  @override
  String get liveGameOpenParty => 'Abrir grupo y cola';

  @override
  String get liveGameParty => 'Grupo';

  @override
  String liveGamePeak(String rank) {
    return 'Máximo: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Equipamiento de $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Equipamiento';

  @override
  String get liveGameQueueHint =>
      'Mantén la app abierta: los detalles de la partida aparecerán en cuanto se encuentre una.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Abandonar la partida puede conllevar una penalización (pérdida de RR, bloqueo de cola). ¿Seguro que quieres salir?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Abandonar durante la selección de agente puede conllevar una penalización (pérdida de RR, bloqueo de cola). ¿Seguro que quieres salir?';

  @override
  String get liveGameQuitConfirmTitle => '¿Abandonar la partida?';

  @override
  String get liveGameQuitDone => 'Has abandonado la partida.';

  @override
  String get liveGameQuitFailed => 'No se ha podido abandonar la partida.';

  @override
  String get liveGameQuitMatch => 'Abandonar partida';

  @override
  String get liveGameQuitMatchChanged =>
      'La partida ha cambiado de fase mientras confirmabas. No has salido; vuelve a intentarlo.';

  @override
  String get liveGameRankUnavailable => 'Rango desconocido';

  @override
  String get liveGameRefresh => 'Actualizar';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Se actualiza en $seconds segundos',
      one: 'Se actualiza en $seconds segundo',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'Actualizar ahora';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Detalles de la partida';

  @override
  String get liveGameSprays => 'Grafitis';

  @override
  String get liveGameStatusAgentSelect => 'Selección de agente';

  @override
  String get liveGameStatusEnded => 'Terminada';

  @override
  String get liveGameStatusInProgress => 'En curso';

  @override
  String get liveGameStatusUnavailable =>
      'No se ha podido actualizar el estado de la partida';

  @override
  String get liveGameTabAllPlayers => 'Jugadores';

  @override
  String get liveGameTabEnemyTeam => 'Enemigos';

  @override
  String get liveGameTabYourTeam => 'Tu equipo';

  @override
  String liveGameTimeLeft(String t) {
    return 'Quedan $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Ver detalles de la partida';

  @override
  String get liveGameWeapons => 'Armas';

  @override
  String get liveGameYou => 'TÚ';

  @override
  String liveGameYouHover(String agent) {
    return 'Estás seleccionando a $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Has fijado a $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Elige y fija tu agente en VALORANT. ValHub solo muestra el tiempo restante y tu equipo.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victorias',
      one: '$wins victoria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses derrotas',
      one: '$losses derrota',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws empates',
      one: ' – $draws empate',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown partidas sin resultado conocido',
      one: ' – $unknown partida sin resultado conocido',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'hora del dispositivo ($offset)';
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
      'yes': ' con $weapon',
      'other': '',
    });
    return '$killer eliminó a $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 días',
      'days7': '7 días',
      'other': 'Todo',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Agentes',
      'maps': 'Mapas',
      'queues': 'Modos',
      'sides': 'Ataque / Defensa',
      'trend': 'Tendencia',
      'other': 'Modos',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Todos los modos';

  @override
  String get profileAbility => 'Habilidad';

  @override
  String profileAboutMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n partidas',
      one: '≈ $n partida',
    );
    return '$_temp0';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Puntuación de combate media';

  @override
  String profileActRecord(int wins, int games, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victorias',
      one: '$wins victoria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games partidas',
      one: '$games partida',
    );
    return 'Este acto: $_temp0 / $_temp1 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Todos los jugadores';

  @override
  String get profileAlreadyReached => 'Ya has alcanzado este rango.';

  @override
  String get profileAtCurrentForm => 'Con tu forma actual';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Con tu forma actual ($gain / $loss por partida)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'En el mejor caso: $n victorias seguidas',
      one: 'En el mejor caso: $n victoria seguida',
    );
    return '$_temp0';
  }

  @override
  String get profileByWinRateTitle => 'Según el porcentaje de victorias';

  @override
  String get profileChooseMap => 'Filtrar por mapa';

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
  String get profileCopyRiotId => 'Copiar Riot ID';

  @override
  String get profileCurrentRank => 'Actual';

  @override
  String get profileDailyRrEmpty =>
      'Todavía no hay partidas competitivas guardadas en este dispositivo.';

  @override
  String get profileDailyRrFootnote =>
      'El historial de RR se guarda en tu dispositivo, incluidas las partidas que Riot ya no devuelve.';

  @override
  String get profileDailyRrTitle => 'RR por día';

  @override
  String profileDayBoundary(String zone) {
    return 'Días según $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n días con partidas',
      one: '$n día con partidas',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'Se muestran todas las partidas';

  @override
  String get profileEnemyTeam => 'Equipo enemigo';

  @override
  String get profileFallDamage => 'Caída';

  @override
  String get profileFilterAll => 'Todo';

  @override
  String get profileFirstBloods => 'Primeras bajas';

  @override
  String get profileFirstDeaths => 'Primeras muertes';

  @override
  String get profileFirstHalf => 'Primera mitad';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS y HS% solo se calculan en los modos por rondas.';

  @override
  String profileFormPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltan cargar $n partidas de la lista para el cálculo.',
      one: 'Falta cargar $n partida de la lista para el cálculo.',
    );
    return '$_temp0';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR y HS% solo cuentan $roundGames/$games partidas por rondas';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: 'Últimas $games partidas',
      one: 'Última partida',
    );
    String _temp1 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w victorias',
      one: '$w victoria',
    );
    String _temp2 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l derrotas',
      one: '$l derrota',
    );
    return '$_temp0: $_temp1, $_temp2';
  }

  @override
  String get profileFriendsRow => 'Amigos y chat';

  @override
  String get profileHideKills => 'Ocultar bajas';

  @override
  String get profileHitBody => 'Cuerpo';

  @override
  String get profileHitDistribution => 'Distribución de impactos';

  @override
  String get profileHitHead => 'Cabeza';

  @override
  String get profileHitLegs => 'Piernas';

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
      'Porcentaje de rondas en las que consigues una baja, una asistencia, sobrevives o un compañero elimina a quien te mató';

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
      other: 'Últimos $n días',
      one: 'Último $n día',
    );
    return '$_temp0';
  }

  @override
  String profileLastMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Últimas $n partidas',
      one: 'Última $n partida',
    );
    return '$_temp0';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Clasificación #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Nivel $n';
  }

  @override
  String get profileLevelHidden => 'Nivel oculto';

  @override
  String profileLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Racha de $n derrotas',
      one: 'Racha de $n derrota',
    );
    return '$_temp0';
  }

  @override
  String profileMapFilter(String map) {
    return 'Mapa: $map';
  }

  @override
  String profileMatchCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n partidas',
      one: '$n partida',
    );
    return '$_temp0';
  }

  @override
  String get profileMatchDetailTitle => 'Detalles de la partida';

  @override
  String get profileMatchHistory => 'Historial de partidas';

  @override
  String get profileMatchUnavailable => 'No se ha podido cargar la partida';

  @override
  String get profileMatchesNeeded => 'Partidas necesarias';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Nunca ha tenido rango';

  @override
  String get profileNoKillsInRound =>
      'No hay información de bajas en esta ronda.';

  @override
  String get profileNoMatches => 'Todavía no hay partidas.';

  @override
  String get profileNoMatchesMap =>
      'No hay partidas en este mapa entre las partidas cargadas.';

  @override
  String get profileNoMatchesQueue => 'No hay partidas en este modo.';

  @override
  String get profileNoPlayers =>
      'No hay información de los jugadores de esta partida.';

  @override
  String get profileNoRounds =>
      'No hay información de las rondas de esta partida.';

  @override
  String get profileOvertime => 'Prórroga';

  @override
  String get profilePlayHubTitle => 'Partida y grupo';

  @override
  String get profilePeakRank => 'Máximo';

  @override
  String get profilePerformanceAttack => 'Ataque';

  @override
  String get profilePerformanceDefense => 'Defensa';

  @override
  String get profilePerformanceEmpty =>
      'Todavía no hay partidas registradas en este dispositivo. Abre el historial de partidas para registrar las que has jugado.';

  @override
  String get profilePerformanceNoMatches =>
      'No hay partidas en el periodo seleccionado.';

  @override
  String profilePerformanceRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n rondas registradas',
      one: '$n ronda registrada',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSample =>
      'Los porcentajes solo se muestran con al menos 3 partidas. ACS, ADR, HS% y K/D solo cuentan los modos por rondas.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Se ha identificado el lado atacante o defensor en $known/$total rondas.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Historial del dispositivo desde el $date';
  }

  @override
  String get profilePerformanceTitle => 'Rendimiento';

  @override
  String profilePlacement(int n) {
    return 'Puesto $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike plantada en $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Perfil del jugador';

  @override
  String get profilePlayerSummary => 'Resumen';

  @override
  String profileProgressTo(String rank) {
    return 'Progreso hacia $rank';
  }

  @override
  String get profileProgressToTarget => 'Progreso hacia el rango objetivo';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Estimación basada en tus partidas competitivas recientes, sin contar las partidas de clasificación ni la protección contra el descenso.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '≈ $matches partidas para llegar a $rank',
      one: '≈ $matches partida para llegar a $rank',
    );
    return '$_temp0';
  }

  @override
  String get profileRankUpImmortal =>
      'Ya estás en Inmortal o más: esta función solo calcula hasta Inmortal 1.';

  @override
  String get profileRankUpNoForm =>
      'No hay partidas competitivas recientes para estimar tu forma.';

  @override
  String get profileRankUpOpen => 'Abrir calculadora de ascenso';

  @override
  String get profileRankUpTitle => 'Calculadora de ascenso';

  @override
  String get profileRankUpUnranked =>
      'Completa tus partidas de clasificación para usar la calculadora de ascenso.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Tabla de puntuación competitiva';

  @override
  String profileRecentForm(int w, int l) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w victorias',
      one: '$w victoria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l derrotas',
      one: '$l derrota',
    );
    return 'Forma reciente: $_temp0 – $_temp1';
  }

  @override
  String get profileRecentFormTitle => 'Forma reciente';

  @override
  String get profileRecentMatches => 'Partidas recientes';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}V · ${l}D · ${d}E',
      one: '${w}V · ${l}D · ${d}E',
      zero: '${w}V · ${l}D',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID copiado';

  @override
  String profileRound(int n) {
    return 'Ronda $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bajas',
      one: '$n baja',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'Ronda perdida';

  @override
  String get profileRoundTimeline => 'Desarrollo de las rondas';

  @override
  String get profileRoundWon => 'Ronda ganada';

  @override
  String get profileRoundsHint => 'Toca una ronda para ver cada baja.';

  @override
  String profileRrLeft(String n) {
    return 'Faltan $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'Evolución de RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Tabla de puntuación';

  @override
  String get profileSecondHalf => 'Segunda mitad';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Ver bajas';

  @override
  String get profileSideSwitch => 'Cambio de lado';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Rango objetivo';

  @override
  String get profileTeamBlue => 'Equipo azul';

  @override
  String get profileTeamMvp => 'MVP del equipo';

  @override
  String get profileTeamRed => 'Equipo rojo';

  @override
  String get profileTitle => 'Perfil';

  @override
  String profileToday(String text) {
    return 'Hoy: $text';
  }

  @override
  String get profileTodayNone => 'Hoy aún no hay partidas competitivas';

  @override
  String get profileTruePeakLocal => 'Según el historial del dispositivo';

  @override
  String get profileWeekdayShortItem0 => 'Lu';

  @override
  String get profileWeekdayShortItem1 => 'Ma';

  @override
  String get profileWeekdayShortItem2 => 'Mi';

  @override
  String get profileWeekdayShortItem3 => 'Ju';

  @override
  String get profileWeekdayShortItem4 => 'Vi';

  @override
  String get profileWeekdayShortItem5 => 'Sá';

  @override
  String get profileWeekdayShortItem6 => 'Do';

  @override
  String get profileWinRate => 'Porcentaje de victorias';

  @override
  String profileWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Racha de $n victorias',
      one: 'Racha de $n victoria',
    );
    return '$_temp0';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Tu rango';

  @override
  String get profileYourSummary => 'Tu resumen';

  @override
  String get profileYourTeam => 'Tu equipo';

  @override
  String get profileYourWinRate => 'Tu porcentaje de victorias reciente';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Modo: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Filtrar por modo';

  @override
  String get profilePerformancePerMatchTitle => 'Por partida';

  @override
  String get profilePerformancePerMatchHint =>
      'Toca una barra para abrir esa partida.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Media $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Se necesitan al menos 2 partidas por rondas con esta estadística para dibujar el gráfico.';

  @override
  String get profilePerformanceOpeningsTitle => 'Duelos iniciales';

  @override
  String get profilePerformanceOpeningWin => 'Duelos iniciales ganados';

  @override
  String get profilePerformanceOpeningWinHint =>
      'De las rondas en las que conseguiste la primera baja o caíste primero, el porcentaje en que conseguiste la baja.';

  @override
  String get profilePerformanceFirstBloodsPerGame =>
      'Primeras bajas por partida';

  @override
  String get profilePerformanceFirstDeathsPerGame =>
      'Primeras muertes por partida';

  @override
  String get profilePerformanceMultiKillsTitle =>
      'Bajas múltiples en una ronda';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 bajas',
      'k4': '4 bajas',
      'ace': 'Ace',
      'other': '2 bajas',
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
      other: 'Basado en $nString partidas con datos de bajas completos.',
      one: 'Basado en $nString partida con datos de bajas completos.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Rondas ganadas';

  @override
  String get profilePerformanceDrillHint =>
      'Toca una fila para ver solo ese agente, mapa o modo.';

  @override
  String get profilePerformanceLoadOlder => 'Analizar partidas anteriores';

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
          'ValHub solo analiza las partidas abiertas en este dispositivo. Cada toque añade hasta $nString partidas anteriores.',
      one:
          'ValHub solo analiza las partidas abiertas en este dispositivo. Cada toque añade hasta $nString partida anterior.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSearchingOlder =>
      'Buscando partidas anteriores…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Analizando partidas: $doneString/$totalString…';
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
      other: 'Se han añadido $nString partidas al análisis.',
      one: 'Se ha añadido $nString partida al análisis.',
      zero: 'No hay partidas nuevas que añadir.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot ya no guarda partidas más antiguas.';

  @override
  String get profileEconomyTitle => 'Economía de tu equipo';

  @override
  String get profileEconomyHint =>
      'Tipo de compra según el valor total del equipo de tu equipo al empezar la ronda (convención de vlr.gg para 5 jugadores): Eco por debajo de 5.000, Semi-eco por debajo de 10.000, Semi-buy por debajo de 20.000, Full buy desde 20.000 créditos. La primera ronda de cada mitad es Pistol.';

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

    return 'Ganadas $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get profileSessionTitle => 'Última sesión';

  @override
  String profileSessionDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString h $minutesString min';
  }

  @override
  String profileSessionTopAgent(String agent, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Más jugado: $agent ×$countString';
  }

  @override
  String get legalAboutIntro =>
      'Tu compañero de VALORANT: tienda diaria, lista de deseos, rango, partidas, varias cuentas y una comunidad de jugadores, todo en tu dispositivo.';

  @override
  String get legalBackToTop => 'Volver arriba';

  @override
  String get legalConsentAnd => ' y la ';

  @override
  String get legalConsentPrefix => 'Al continuar, aceptas los ';

  @override
  String get legalConsentPrivacy => 'Política de privacidad';

  @override
  String get legalConsentSuffix => ' de ValHub.';

  @override
  String get legalConsentTerms => 'Términos de uso';

  @override
  String get legalContact => 'Contacto';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'CONTACTO';

  @override
  String legalEffectiveFrom(String date) {
    return 'En vigor desde el $date';
  }

  @override
  String get legalLegalHeader => 'LEGAL';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Todos los derechos reservados.';

  @override
  String get legalThirdPartyLicenses => 'Software de terceros';

  @override
  String get legalThirdPartyLicensesBody =>
      'Licencias del software de código abierto que usa ValHub';

  @override
  String get legalTocTitle => 'ÍNDICE';

  @override
  String legalVersion(String version) {
    return 'Versión $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Este documento se muestra actualmente en $language.';
  }

  @override
  String get legalContentUnavailable =>
      'No se ha podido leer el documento legal. Vuelve a intentarlo o contacta con el soporte.';

  @override
  String get legalTranslationNotice =>
      'Esta traducción se ofrece para tu comodidad. En caso de diferencia, prevalece la versión en vietnamita.';

  @override
  String get settingsUiLanguageTitle => 'Idioma de la interfaz';

  @override
  String get settingsLanguageFollowDevice => 'Según el dispositivo';

  @override
  String get settingsLanguageSaveFailed =>
      'No se ha podido guardar el idioma. Vuelve a intentarlo.';

  @override
  String get settingsGeoCountry => 'País';

  @override
  String get settingsGeoSearchCountry => 'Busca el nombre o código del país';

  @override
  String get settingsGeoSupportedOnly => 'Solo lugares con soporte confirmado';

  @override
  String get settingsGeoUnknown => 'Soporte sin verificar';

  @override
  String get settingsGeoRestricted => 'Restringido';

  @override
  String get settingsGeoSeparate => 'Servicio independiente';

  @override
  String get settingsGeoAvailable => 'Disponible';

  @override
  String get settingsGeoNotApplicable => 'No aplicable';

  @override
  String get settingsGeoConnection => 'Conexión con Riot';

  @override
  String get settingsGeoChooseRegion => 'Elegir región';

  @override
  String get settingsGeoAuto => 'Automático según la cuenta';

  @override
  String get settingsGeoManual => 'Elegir manualmente';

  @override
  String get settingsGeoNoRegion =>
      'No se ha podido determinar la región de Riot';

  @override
  String get settingsGeoManualWarning =>
      'Esta opción solo cambia el servidor al que se conecta ValHub. No cambia la región de tu cuenta de Riot. ValHub comprobará la conexión antes de guardar.';

  @override
  String get settingsGeoConnectionSaved => 'Conexión guardada';

  @override
  String get settingsGeoValidationFailed =>
      'La cuenta no se ha confirmado en este servidor. Vuelve a elegir la región.';

  @override
  String get settingsGeoHintOnly =>
      'El país solo se usa para búsquedas y sugerencias. La región de conexión depende de tu cuenta de Riot.';

  @override
  String get settingsGeoSave => 'Comprobar y guardar';

  @override
  String get settingsGeoCancel => 'Cancelar';

  @override
  String get settingsGeoLoading => 'Comprobando la conexión…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Esta opción se usa para los nombres de países, las sugerencias y el precio estimado en VP. El servidor de conexión y el país de tu cuenta en la Comunidad siguen dependiendo de Riot.';

  @override
  String get settingsGeoCountryAutomatic =>
      'Usar el país de la cuenta o del dispositivo';

  @override
  String get settingsGeoSaveFailed =>
      'No se ha podido guardar la selección. Vuelve a intentarlo.';

  @override
  String get settingsGeoAllRegions => 'Todas las regiones';

  @override
  String get settingsGeoSuggestions => 'Sugerencias';

  @override
  String get settingsGeoNoCountries => 'Ningún país coincide con el filtro.';

  @override
  String get settingsGeoActiveCountries => 'Con actividad';

  @override
  String get settingsGeoAllCountries => 'Todos los países';

  @override
  String get settingsGeoActivityUnavailable =>
      'No se ha podido cargar la actividad por país. Puedes elegir igualmente en Todos los países.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count países',
      one: '$count país',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Has elegido $manual, pero Riot sitúa tu cuenta en $detected. ¿Quieres comprobar esta conexión de todos modos?';
  }

  @override
  String get settingsGeoUnverified =>
      'No se ha podido verificar la conexión porque el servidor o la red tienen problemas. ¿Guardar esta opción y volver a intentarlo más tarde?';

  @override
  String get settingsGeoContinue => 'Continuar';

  @override
  String settingsGeoMismatch(String region) {
    return 'La conexión manual no coincide con la región de Riot: $region. ¿Quieres usar la región automática?';
  }

  @override
  String get settingsGeoUseAuto => 'Usar automática';

  @override
  String get settingsGeoKeepManual => 'Mantener manual';

  @override
  String get settingsGeoReviewConnection => 'Revisar conexión';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Última comprobación: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Volver a comprobar';

  @override
  String get settingsPlatformMobile => 'Móvil';

  @override
  String get settingsPlatformOther => 'Otra plataforma';

  @override
  String get settingsContentLanguageFollowApp => 'Según el idioma de la app';

  @override
  String get settingsContentLanguageHint =>
      'Elige el idioma de los nombres de objetos. No cambia el idioma de la interfaz ni el servidor de Riot.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Idioma: $language.';
  }

  @override
  String get settingsAboutHeader => 'INFORMACIÓN';

  @override
  String get settingsAboutRowSubtitle =>
      'Privacidad, términos, derechos de autor y contacto';

  @override
  String get settingsAboutTitle => 'Acerca de y legal';

  @override
  String get settingsAppHeader => 'AVANZADO';

  @override
  String get settingsAppearanceHeader => 'APARIENCIA';

  @override
  String settingsBuildNumber(String build) {
    return 'Compilación $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'Se han liberado $size';
  }

  @override
  String get settingsClearCache => 'Borrar datos temporales';

  @override
  String get settingsClearCacheFailed =>
      'No se han podido borrar los datos temporales. Vuelve a intentarlo.';

  @override
  String get settingsClearCacheSubtitle =>
      'Imágenes y datos descargados, incluidos los informes de errores registrados';

  @override
  String get settingsExportLog => 'Enviar informe de errores a ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Aún no hay nada que enviar. Usa la app un rato y vuelve a intentarlo.';

  @override
  String get settingsExportLogSubtitle =>
      'El informe de errores no incluye tu contraseña ni tus datos de inicio de sesión de Riot.';

  @override
  String get settingsFeedback => 'Enviar sugerencias a ValHub';

  @override
  String get settingsFeedbackSubtitle =>
      'Abre la página de sugerencias de ValHub';

  @override
  String get settingsItemLanguageEn => 'Inglés';

  @override
  String get settingsItemLanguageLabel => 'Nombres de objetos';

  @override
  String get settingsItemLanguagePickerTitle =>
      'Idioma de los nombres de objetos';

  @override
  String get settingsItemLanguageVi => 'Vietnamita';

  @override
  String get settingsLinkOpenFailed =>
      'No se ha podido abrir el enlace. Vuelve a intentarlo.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Informe de errores';
  }

  @override
  String get settingsLogShareFailed =>
      'No se ha podido enviar el informe de errores. Vuelve a intentarlo.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Cuando abra el Mercado nocturno';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Te recuerda descubrir las ofertas del Mercado nocturno';

  @override
  String get settingsNotifPermissionMissing =>
      'La app no tiene permiso para enviar notificaciones.';

  @override
  String get settingsNotifStoreReset => 'Cuando se renueve la tienda';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Cada día a las $time';
  }

  @override
  String get settingsNotifWishlist =>
      'Cuando aparezca una skin de tu lista de deseos';

  @override
  String get settingsNotifWishlistSubtitle =>
      'Comprueba la tienda de todas tus cuentas, incluso si no abres la app';

  @override
  String get settingsNotificationsHeader => 'NOTIFICACIONES';

  @override
  String get settingsOptionAutoOpenLiveGame =>
      'Abrir detalles de partida automáticamente';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Abre el panel de la partida actual en cuanto se encuentre una';

  @override
  String get settingsOptionOwnPrice => 'Precio de tu paquete de VP';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Sin introducir: se usan los precios de tu región si los hay';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Plataforma';

  @override
  String get settingsOptionShowLiveScore => 'Mostrar marcador en directo';

  @override
  String get settingsOptionShowPeakRank =>
      'Mostrar rango máximo en los detalles de la partida';

  @override
  String get settingsOptionShowPrice => 'Mostrar precio estimado';

  @override
  String get settingsOptionShowPriceInfo =>
      'Cómo se calcula el precio estimado';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Junto al precio en VP, por ejemplo $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Aún no hay precios verificados para tu región: introduce el precio de tu paquete de VP.';

  @override
  String get settingsOptionsHeader => 'OPCIONES';

  @override
  String get settingsPhaseComplete => 'Completado';

  @override
  String get settingsPhaseInProgress => 'En curso';

  @override
  String get settingsPhaseScheduled => 'Programado';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Se aplica a $account';
  }

  @override
  String get settingsPlatformHint =>
      'Elige PC, PlayStation o Xbox según dónde juegues para ver el historial de partidas correcto.';

  @override
  String get settingsPlatformPickerTitle => 'Elegir plataforma';

  @override
  String get settingsPrimingBody =>
      'Activa las notificaciones para saber cuándo se renueva la tienda y cuándo aparece una skin de tu lista de deseos.';

  @override
  String get settingsPrimingEnable => 'Activar notificaciones';

  @override
  String get settingsPrimingFootnote =>
      'Puedes activar o desactivar cada tipo de notificación cuando quieras en Ajustes.';

  @override
  String get settingsPrimingLater => 'Más tarde';

  @override
  String get settingsPrimingPointNightMarket =>
      'Entérate de cuándo abre el Mercado nocturno';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Para descubrir tus ofertas antes de que caduquen';

  @override
  String get settingsPrimingPointStore =>
      'Aviso cuando se renueva la tienda diaria';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Te avisa cuando se renueva la tienda de tu cuenta';

  @override
  String get settingsPrimingPointWishlist =>
      'Aviso cuando aparece la skin que buscas';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Comprueba la tienda de todas tus cuentas, incluso si no abres la app';

  @override
  String get settingsPrimingTitle => 'No te pierdas la skin que buscas';

  @override
  String settingsRemovedAccount(String account) {
    return 'Se ha eliminado $account';
  }

  @override
  String get settingsServerStatus => 'Estado de los servidores';

  @override
  String get settingsServerStatusMaintenance => 'En mantenimiento';

  @override
  String settingsServerStatusNotices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n avisos',
      one: '$n aviso',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Mantenimientos e incidencias de VALORANT por servidor';

  @override
  String get settingsSessionLogTitle => 'Informe de errores de ValHub';

  @override
  String get settingsSeverityCritical => 'Crítico';

  @override
  String get settingsSeverityInfo => 'Información';

  @override
  String get settingsSeverityWarning => 'Advertencia';

  @override
  String get settingsSignedOutAll =>
      'Se ha cerrado sesión en todas las cuentas';

  @override
  String get settingsStatusAllGood => 'Los servidores funcionan con normalidad';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'No hay incidencias ni mantenimientos en el servidor $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Ver menos';

  @override
  String get settingsStatusIssues => 'Riot está solucionando una incidencia';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Este servidor tiene $n avisos de incidencia.',
      one: 'Este servidor tiene $n aviso de incidencia.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'Incidencia';

  @override
  String get settingsStatusKindMaintenance => 'Mantenimiento';

  @override
  String get settingsStatusMaintenanceNow => 'Servidor en mantenimiento';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Es posible que no puedas entrar en el juego y que ValHub no pueda cargar la información por ahora.';

  @override
  String settingsStatusMoreUpdates(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ver $n actualizaciones más',
      one: 'Ver $n actualización más',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusScheduled => 'Mantenimiento próximo';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Riot ha anunciado $n mantenimientos programados.',
      one: 'Riot ha anunciado $n mantenimiento programado.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusSourceNote =>
      'Fuente: página de estado oficial de Riot Games. Las horas se muestran en la zona horaria del dispositivo.';

  @override
  String settingsStatusStarted(String when) {
    return 'Inicio: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Actualizado: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'ACTUALIZACIONES DE RIOT';

  @override
  String get settingsSupportHeader => 'SOPORTE';

  @override
  String settingsSwitchedTo(String account) {
    return 'Has cambiado a $account';
  }

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemePickerTitle => 'Elegir tema';

  @override
  String get settingsThemeSystem => 'Según el sistema';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Rango, historial y partida en curso';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR de cada partida, rango de los rivales';

  @override
  String get settingsWelcomeBulletStore =>
      'Tienda diaria, Mercado nocturno y lotes';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Precios, rareza y cuenta atrás de renovación';

  @override
  String get settingsWelcomeBulletWishlist => 'Lista de deseos y avisos';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Te avisa cuando la skin que buscas llega a la tienda';

  @override
  String get settingsWelcomeFootnote =>
      'Inicias sesión en la página oficial de Riot. ValHub solo guarda tu contraseña si eliges guardar tus datos de inicio de sesión.';

  @override
  String get settingsWelcomeKicker => 'TU COMPAÑERO DE VALORANT';

  @override
  String get settingsCountryPriceHeader => 'País y precios';

  @override
  String get settingsDataHeader => 'Datos en el dispositivo';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (valoraciones: $count) · ',
      'other': '',
    });
    return 'Comunidad: ${_temp0}Me gusta: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'Añadir a la lista de deseos';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'En la tienda de: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      daily,
      locale: localeName,
      other: '$daily veces en la tienda diaria',
      one: '$daily vez en la tienda diaria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      night,
      locale: localeName,
      other: '$night Mercados nocturnos',
      one: '$night Mercado nocturno',
    );
    return 'En tu tienda: $_temp0, $_temp1. Solo cuenta los datos de este dispositivo, registrados desde el $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'Borrar historial de la tienda';

  @override
  String get skinDetailHistoryDeleteBody =>
      '¿Borrar todos los días de tienda registrados para esta cuenta en este dispositivo?';

  @override
  String get skinDetailInWishlist => 'En tu lista de deseos';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Bloqueado';

  @override
  String get skinDetailMute => 'Silenciar';

  @override
  String get skinDetailNotFound => 'No se ha encontrado esta skin.';

  @override
  String get skinDetailOwned => 'En propiedad';

  @override
  String get skinDetailPause => 'Pausar';

  @override
  String get skinDetailPlay => 'Reproducir';

  @override
  String get skinDetailPlayVideo => 'Ver vídeo';

  @override
  String get skinDetailRemoveFromWishlist => 'Quitar de la lista de deseos';

  @override
  String get skinDetailTitle => 'Detalles de la skin';

  @override
  String get skinDetailUnmute => 'Activar sonido';

  @override
  String get skinDetailUpgrades => 'Mejoras';

  @override
  String get skinDetailVariants => 'Variantes';

  @override
  String get skinDetailVideoError =>
      'No se ha podido reproducir el vídeo. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get socialPresenceInMatch => 'En partida';

  @override
  String get socialPresenceAgentSelect => 'Seleccionando agente';

  @override
  String get socialPresenceQueue => 'Buscando partida';

  @override
  String get socialPresenceLobby => 'En la sala';

  @override
  String get socialPresenceCustom => 'En partida personalizada';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Grupo abierto',
      'other': 'Solo por invitación',
    });
    return '$size/$max jugadores · $_temp0';
  }

  @override
  String get socialAccept => 'Aceptar';

  @override
  String get socialAcceptInGame => 'Acepta esta invitación en el juego.';

  @override
  String socialActionFailed(String message) {
    return 'No se ha podido completar la acción. $message';
  }

  @override
  String get socialAutoRefresh => 'Actualización automática';

  @override
  String get socialAway => 'Ausente';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Cancelar búsqueda · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Cancelar búsqueda';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'El grupo aún no puede entrar en $queue: $reason';
  }

  @override
  String get socialChangeQueue => 'Cambiar cola';

  @override
  String get socialChatUnavailable => 'El chat está desconectado.';

  @override
  String get socialCloseParty => 'Cerrar grupo';

  @override
  String get socialCodeInvalid =>
      'El código de grupo solo puede tener letras y números.';

  @override
  String get socialConnecting => 'Conectando al chat…';

  @override
  String get socialCopyCode => 'Copiar';

  @override
  String get socialCurrentQueue => 'Seleccionada';

  @override
  String get socialCustomGameLobby =>
      'El grupo está en la sala de partida personalizada.';

  @override
  String get socialDecline => 'Rechazar';

  @override
  String get socialDisableCode => 'Desactivar código';

  @override
  String get socialEmptyChat => 'Aún no hay mensajes. ¡Saluda!';

  @override
  String get socialEmptyChatTitle => 'Empieza a chatear';

  @override
  String get socialFailedBadge => 'No enviado';

  @override
  String get socialFilterAll => 'Todos';

  @override
  String get socialFilterOnline => 'En línea';

  @override
  String get socialFilterUnread => 'Sin leer';

  @override
  String get socialFriendsPrivacyNote =>
      'Tu lista de amigos y tus mensajes se obtienen directamente de Riot. ValHub no los guarda en ningún otro sitio.';

  @override
  String socialFriendsSummary(int total, int online) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total amigos',
      one: '$total amigo',
    );
    return '$_temp0 · $online en línea';
  }

  @override
  String get socialFriendsTitle => 'Amigos y chat';

  @override
  String get socialGameNotRunningBody =>
      'Grupo y cola solo funciona cuando VALORANT se está ejecutando en tu ordenador o consola. Abre el juego y desliza hacia abajo para actualizar.';

  @override
  String get socialGameNotRunningTitle =>
      'Abre VALORANT en tu ordenador o consola';

  @override
  String get socialGenerateCode => 'Crear código';

  @override
  String get socialIdleQueue => 'Listo para buscar partida';

  @override
  String get socialInMatchBanner =>
      'Estás en una partida. La cola volverá a estar disponible cuando termine.';

  @override
  String get socialInValorant => 'En VALORANT';

  @override
  String get socialInviteByRiotId => 'Invitar por Riot ID';

  @override
  String get socialInviteByRiotIdHint =>
      'Invita también a quien no es tu amigo';

  @override
  String get socialInviteFriends => 'Invitar amigos';

  @override
  String socialInviteFrom(String name) {
    return 'Invitación de $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Invitar a $name';
  }

  @override
  String get socialInviteNeedsName =>
      'No se conoce el Riot ID de este jugador, así que aún no puedes invitarlo.';

  @override
  String socialInviteSent(String name) {
    return 'Invitación enviada a $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Invitado';
  }

  @override
  String get socialInvitesSection => 'Invitaciones';

  @override
  String get socialJoin => 'Unirse';

  @override
  String get socialJoinConfirmBody =>
      'Saldrás de tu grupo actual para unirte al grupo con este código.';

  @override
  String get socialJoinConfirmTitle => '¿Unirte a otro grupo?';

  @override
  String get socialJoinSection => 'Unirse a otro grupo';

  @override
  String get socialJoinWithCode => 'Introduce un código para unirte';

  @override
  String get socialJoined => 'Te has unido al grupo.';

  @override
  String socialLastOnline(String relative) {
    return 'Activo $relative';
  }

  @override
  String get socialLeader => 'Líder';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Saldrás de tu grupo actual y volverás a un grupo propio.';

  @override
  String get socialLeaveConfirmTitle => '¿Salir del grupo?';

  @override
  String get socialLeaveParty => 'Salir del grupo';

  @override
  String socialLevel(int n) {
    return 'Nivel $n';
  }

  @override
  String get socialMatchFound => '¡Partida encontrada!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Miembros ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Escribe un mensaje…';

  @override
  String get socialMoreActions => 'Más opciones';

  @override
  String get socialNoCode =>
      'Crea un código para que tus amigos se unan rápido a tu grupo.';

  @override
  String get socialNoCodeMember =>
      'El líder puede crear un código para invitar rápido.';

  @override
  String get socialNoFilterResults => 'Ningún amigo coincide con este filtro.';

  @override
  String get socialNoFriends =>
      'Tu lista de amigos de Riot está vacía. Añade amigos en el juego.';

  @override
  String get socialNoFriendsTitle => 'Sin amigos todavía';

  @override
  String get socialNoOnlineFriends => 'Ningún amigo está en línea en VALORANT.';

  @override
  String get socialNoSearchResults => 'No se ha encontrado ningún amigo.';

  @override
  String get socialNoSearchResultsTitle => 'Sin resultados';

  @override
  String get socialNotReady => 'No listo';

  @override
  String socialOfflineSection(int n) {
    return 'Desconectados ($n)';
  }

  @override
  String get socialOfflineStatus => 'Desconectado';

  @override
  String get socialOnlineMobile => 'En línea en el móvil';

  @override
  String socialOnlineSection(int n) {
    return 'En línea ($n)';
  }

  @override
  String get socialOnlineStatus => 'En línea';

  @override
  String get socialOnlyLeader =>
      'Solo el líder puede cambiar la cola y empezar a buscar partida.';

  @override
  String get socialOpenParty => 'Abrir grupo';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Código de grupo';

  @override
  String socialPartyCodeValue(String code) {
    return 'Código de grupo: $code';
  }

  @override
  String get socialPartyInvite => 'Invitación de grupo';

  @override
  String socialPartyOf(int size, int max) {
    return 'Grupo $size/$max';
  }

  @override
  String get socialPartyTitle => 'Grupo y cola';

  @override
  String socialPickQueueSubtitle(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'Grupo de $size jugadores',
      one: 'Grupo de $size jugador',
    );
    return '$_temp0';
  }

  @override
  String get socialPickQueueTitle => 'Elegir cola';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Mejor ping a los servidores de partida';

  @override
  String socialPlayingOther(String game) {
    return 'Jugando a $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'Jugando ($n)';
  }

  @override
  String get socialQueueLabel => 'Cola';

  @override
  String get socialQueueLocked =>
      'No puedes cambiar de cola mientras estás en una partida.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Máximo $max jugadores',
      one: 'Máximo $max jugador',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'No se ha podido verificar el estado del juego. Actualiza para usar Listo y la cola.';

  @override
  String get socialReady => 'Listo';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Listos $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'algún miembro no tiene el nivel de cuenta necesario';

  @override
  String get socialReasonGeneric => 'el grupo no cumple los requisitos';

  @override
  String socialReasonPartyTooLarge(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'el grupo es demasiado grande (máximo $max jugadores)',
      one: 'el grupo es demasiado grande (máximo $max jugador)',
    );
    return '$_temp0';
  }

  @override
  String get socialReasonRankDisparity =>
      'la diferencia de rango es demasiado grande para jugar Competitivo';

  @override
  String socialReasonRestricted(String time) {
    return 'el grupo tiene restringida la búsqueda de partida (quedan $time)';
  }

  @override
  String get socialReconnecting =>
      'Se ha perdido la conexión con el chat. Reconectando…';

  @override
  String get socialRemoteNote =>
      'Los cambios solo se envían a Riot cuando tú pulsas. ValHub nunca busca partida ni fija agentes por ti.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name será expulsado de tu grupo.';
  }

  @override
  String get socialRemoveConfirmTitle => '¿Expulsar del grupo?';

  @override
  String get socialRemoveMember => 'Expulsar del grupo';

  @override
  String socialRequestFrom(String name) {
    return '$name quiere unirse al grupo';
  }

  @override
  String get socialRequestsSection => 'Solicitudes para unirse';

  @override
  String get socialRiotIdFieldHint => 'Nombre#TAG';

  @override
  String get socialRiotIdInvalid =>
      'El Riot ID tiene un nombre (3–16 caracteres), el símbolo # y un tag (3–5 letras o números).';

  @override
  String get socialSearchHint => 'Buscar por Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'Buscando partida · $elapsed';
  }

  @override
  String get socialSend => 'Enviar';

  @override
  String get socialSendFailed =>
      'No se ha podido enviar el mensaje. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get socialSendInvite => 'Enviar invitación';

  @override
  String get socialShareCode => 'Compartir';

  @override
  String socialShareCodeText(String code) {
    return 'Únete a mi grupo de VALORANT con el código: $code';
  }

  @override
  String get socialShootingRange => 'En el Campo de tiro';

  @override
  String get socialShowEveryone => 'Ver todos';

  @override
  String get socialStartQueue => 'Buscar partida';

  @override
  String get socialSuggestionsItem0 => '¡Hola!';

  @override
  String get socialSuggestionsItem1 => '¿Echamos unas partidas?';

  @override
  String get socialSuggestionsItem2 => '¡Únete a mi grupo!';

  @override
  String socialUnread(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mensajes sin leer',
      one: '$n mensaje sin leer',
    );
    return '$_temp0';
  }

  @override
  String get socialUnready => 'Cancelar listo';

  @override
  String get socialViewProfile => 'Ver perfil';

  @override
  String get socialWaitingForConnection =>
      'Conectando… Podrás enviar mensajes cuando termine.';

  @override
  String get socialYou => 'Tú';

  @override
  String get socialPartyUnavailable =>
      'No se ha podido sincronizar el grupo. Actualiza para volver a intentarlo.';

  @override
  String get socialAcceptConfirmBody =>
      'Saldrás de tu grupo actual para unirte al grupo que te invitó.';

  @override
  String get storeAccessoryEmpty =>
      'La tienda de accesorios no tiene nada ahora mismo.';

  @override
  String get storeAccessoryEmptyTitle => 'Sin accesorios';

  @override
  String storeAccessoryFrom(String contract) {
    return 'De: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Se renueva en $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Se renueva: $wall';
  }

  @override
  String get storeAddToWishlist => 'Añadir a la lista de deseos';

  @override
  String get storeBackToBundles => 'Ver los lotes a la venta';

  @override
  String get storeBundleBuySeparateLabel => 'Por separado';

  @override
  String get storeBundleDetailTitle => 'Detalles del lote';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Caduca: $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Quedan $t';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n objetos',
      one: '$n objeto',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'Gratis';

  @override
  String get storeBundleItemsTitle => 'Objetos del lote';

  @override
  String get storeBundleNotFound =>
      'No se ha encontrado este lote. Es posible que haya caducado.';

  @override
  String get storeBundleNotFoundTitle => 'Lote caducado';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Tienes $owned/$total objetos';
  }

  @override
  String get storeBundlePriceLabel => 'Precio del lote';

  @override
  String get storeBundleSavingsLabel => 'Ahorro';

  @override
  String get storeBundleWholesaleOnly =>
      'Solo se vende completo, no por separado.';

  @override
  String get storeBundlesEmpty => 'Ahora mismo no hay lotes a la venta.';

  @override
  String get storeBundlesEmptyTitle => 'Sin lotes';

  @override
  String get storeDailyEmpty => 'Hoy la tienda no tiene skins.';

  @override
  String get storeDailyEmptyTitle => 'Tienda vacía';

  @override
  String storeDailyResetAt(String time) {
    return 'Se renueva cada día a las $time';
  }

  @override
  String get storeDailyTotalLabel => 'Total';

  @override
  String get storeNightMarketEmpty => 'Ahora mismo no hay Mercado nocturno.';

  @override
  String get storeNightMarketEmptyTitle =>
      'El Mercado nocturno no está abierto';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Termina: $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Termina en $t';
  }

  @override
  String get storeNightMarketNote =>
      'Las ofertas del Mercado nocturno son exclusivas de tu cuenta y no se pueden renovar.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Ahorro total: $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Sin descubrir';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'En propiedad';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'En propiedad: $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Quitar de la lista de deseos';

  @override
  String get storeResetNotificationTitle => 'La tienda se ha renovado';

  @override
  String storeResetsIn(String t) {
    return 'Se renueva en $t';
  }

  @override
  String get storeSegmentAccessories => 'Accesorios';

  @override
  String get storeSegmentBundles => 'Lotes';

  @override
  String get storeSegmentDaily => 'Diaria';

  @override
  String get storeSegmentNightMarket => 'Mercado nocturno';

  @override
  String get storeShareButton => 'Compartir';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Tienda de hoy';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Mercado nocturno';

  @override
  String get storeShareCardPriceNote =>
      'El precio es solo una estimación según los paquetes de VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Ahorro: $vp';
  }

  @override
  String get storeShareCardTagline => 'Tu compañero de VALORANT';

  @override
  String storeShareCardTotal(String vp) {
    return 'Total: $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Hasta: $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Compartir la tienda de hoy';

  @override
  String get storeShareFailed =>
      'No se ha podido crear la imagen. Vuelve a intentarlo.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-tienda-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-mercado-nocturno-$stamp.png';
  }

  @override
  String get storeShareImage => 'Compartir imagen';

  @override
  String get storeShareNightMarketTitle => 'Compartir Mercado nocturno';

  @override
  String get storeSharePreparing => 'Cargando imágenes de skins…';

  @override
  String get storeShareShowPrice => 'Mostrar precio estimado';

  @override
  String get storeShareShowPriceHint => 'Según el paquete de VP más rentable.';

  @override
  String get storeShareShowRiotId => 'Mostrar Riot ID en la imagen';

  @override
  String get storeShareShowRiotIdHint =>
      'Desactivado por defecto para proteger tu privacidad.';

  @override
  String get storeShareSubjectDaily => 'Mi tienda de VALORANT de hoy';

  @override
  String get storeShareSubjectNightMarket => 'Mi Mercado nocturno de VALORANT';

  @override
  String get storeShareSubtitle =>
      'Comparte una imagen de tu tienda con tus amigos en la app que elijas.';

  @override
  String get storeTitle => 'Tienda';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Saldo: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '$n en tu lista de deseos';
  }

  @override
  String get storeHistoryTitle => 'Historial de la tienda';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString días',
      one: '$daysString día',
    );
    return 'Registrado en este dispositivo desde el $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Aún no hay días registrados. ValHub guarda tu tienda diaria cada vez que abres la app, solo en este dispositivo.';

  @override
  String get storeHistoryMostOffered => 'Los que más aparecen';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString veces',
      one: '$nString vez',
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
      other: 'Mercado nocturno · $countString ofertas',
      one: 'Mercado nocturno · $countString oferta',
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
      other: '$daysString días registrados en este dispositivo',
      one: '$daysString día registrado en este dispositivo',
      zero: 'Registro iniciado hoy',
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
      'yes': '$skin está en la tienda de $account; quedan $left.',
      'other': '$skin está en la tienda de $account.',
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
      'discount': '$skin con un $percent% de descuento: $price ($account).',
      'price': '$skin por solo $price ($account).',
      'other': '$skin está en el Mercado nocturno de $account.',
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
      'yes': '$skin está en el lote $bundle ($account).',
      'other': '$skin está en un lote a la venta ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$names y $more skins más están en la tienda de $account.',
      one: '$names y $more skin más están en la tienda de $account.',
      zero: 'Disponible en la tienda de $account: $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', en tu lista de deseos',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Añadir skins';

  @override
  String get wishlistAddToWishlist => 'Añadir a la lista de deseos';

  @override
  String get wishlistAllWeapons => 'Todas las armas';

  @override
  String get wishlistBrowseCatalog => 'Ver todas las skins';

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
      'No se ha podido cargar la lista de skins. Actualiza para volver a intentarlo.';

  @override
  String get wishlistCatalogEmptyTitle => 'Sin skins';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'En tu lista de deseos: $count';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Toca ♡ para añadir una skin a tu lista de deseos';

  @override
  String get wishlistCatalogTitle => 'Todas las skins';

  @override
  String get wishlistChooseWeapon => 'Elegir arma';

  @override
  String get wishlistClearFilters => 'Quitar filtros';

  @override
  String get wishlistEmpty =>
      'Tu lista de deseos está vacía. Toca ♡ en cualquier skin para añadirla.';

  @override
  String get wishlistEmptyTitle => 'Aún no hay skins';

  @override
  String wishlistEndsIn(String time) {
    return 'Termina en $time';
  }

  @override
  String get wishlistExcludedRewards => 'Sin contar skins de recompensa';

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
    return 'Filtrado: $_temp0 · $value';
  }

  @override
  String get wishlistNoMatch =>
      'No hay skins que coincidan. Quita los filtros para ver más.';

  @override
  String get wishlistNoMatchTitle => 'No se han encontrado skins';

  @override
  String get wishlistNotifBundleTitle =>
      'Nuevo lote con una skin de tu lista de deseos';

  @override
  String get wishlistNotifDailyTitle =>
      '¡Ha aparecido una skin de tu lista de deseos!';

  @override
  String get wishlistNotifNightMarketTitle =>
      '¡Hay una skin que te gusta en el Mercado nocturno!';

  @override
  String get wishlistNotifPermissionMissing =>
      'La app no tiene permiso para enviar notificaciones.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡$count skins de tu lista de deseos están a la venta!',
      one: '¡$count skin de tu lista de deseos está a la venta!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'Avisos de la lista de deseos';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Para esta cuenta, incluso si no abres la app';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Lista de deseos de $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡$count skins de tu lista de deseos están a la venta!',
      one: '¡$count skin de tu lista de deseos está a la venta!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Toca las filas marcadas para ver las ofertas.';

  @override
  String get wishlistOpenSettings => 'Abrir ajustes';

  @override
  String get wishlistOwned => 'En propiedad';

  @override
  String get wishlistRemoveAction => 'Quitar de la lista de deseos';

  @override
  String get wishlistRemoveFromWishlist => 'Quitar de la lista de deseos';

  @override
  String wishlistRemoved(String name) {
    return '$name quitada de la lista de deseos';
  }

  @override
  String get wishlistSearchHint => 'Buscar skins…';

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
  String get wishlistSortName => 'Nombre';

  @override
  String get wishlistSortPrice => 'Precio';

  @override
  String get wishlistSortRarity => 'Rareza';

  @override
  String get wishlistSortWeapon => 'Arma';

  @override
  String get wishlistTitle => 'Lista de deseos';

  @override
  String get wishlistTotalValue => 'Valor total de la lista de deseos';

  @override
  String get wishlistUndo => 'Deshacer';

  @override
  String get wishlistViewInStore => 'Ver en la tienda';

  @override
  String get wishlistWeapon => 'Arma';

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
      'yes': ', en tu lista de deseos',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', en tu lista de deseos',
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
      'gain': 'has subido',
      'other': 'has bajado',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victorias',
      one: '$wins victoria',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses derrotas',
      one: '$losses derrota',
    );
    return 'Hoy $_temp0 $rr RR, $_temp1, $_temp2';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victorias',
      one: '$wins victoria',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses derrotas',
      one: '$losses derrota',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws empates',
      one: ', $draws empate',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown partidas sin resultado conocido',
      one: ', $unknown partida sin resultado conocido',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody =>
      'Abre Personalizar Inicio para volver a mostrarlas.';

  @override
  String get homeAllHiddenTitle => 'Has ocultado todas las tarjetas';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'Nivel, XP necesaria por día y misiones semanales.';

  @override
  String get homeCardCommunity => 'Comunidad';

  @override
  String get homeCardCommunityDesc =>
      'Compañeros de tu rango y las skins favoritas de la comunidad.';

  @override
  String get homeCardFriends => 'Amigos jugando';

  @override
  String get homeCardFriendsDesc => 'Amigos en partida o buscando partida.';

  @override
  String homeCardHidden(String name) {
    return 'Se ha ocultado \"$name\"';
  }

  @override
  String get homeCardLive => 'Partida actual';

  @override
  String get homeCardLiveDesc =>
      'Aparece cuando buscas partida, seleccionas agente o estás en partida.';

  @override
  String get homeCardOtherAccounts => 'Otras cuentas';

  @override
  String get homeCardOtherAccountsDesc =>
      'Estado y lista de deseos del resto de tus cuentas.';

  @override
  String get homeCardRank => 'Rango y forma';

  @override
  String get homeCardRankDesc =>
      'Rango, RR de hoy, rachas y partidas para subir de rango.';

  @override
  String get homeCardServerStatus => 'Estado de los servidores';

  @override
  String get homeCardServerStatusDesc =>
      'Solo aparece si hay mantenimiento o una incidencia.';

  @override
  String get homeCardStore => 'Tienda de hoy';

  @override
  String get homeCardStoreDesc =>
      'Skins diarias, lista de deseos y Mercado nocturno.';

  @override
  String get homeCustomize => 'Personalizar Inicio';

  @override
  String get homeCustomizeHint =>
      'Arrastra para ordenar. Desactiva para ocultar una tarjeta.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Has ido a $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Activar';

  @override
  String get homeFriendsConsentBody =>
      'Para saber qué amigos están jugando, ValHub se conectará al chat de Riot de la cuenta en uso cada vez que abras Inicio. Tus amigos te verán en línea. Puedes desactivarlo en Personalizar Inicio.';

  @override
  String get homeFriendsConsentDecline => 'No, ocultar tarjeta';

  @override
  String get homeFriendsConsentTitle => '¿Ver qué amigos están jugando?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n amigos jugando',
      one: '$n amigo jugando',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'Ver todos';

  @override
  String get homeHideCard => 'Ocultar esta tarjeta';

  @override
  String homeLeaderboard(String pos) {
    return 'Puesto $pos en la clasificación';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Quedan $time';
  }

  @override
  String homeLfgNeeds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Se buscan $n jugadores',
      one: 'Se busca $n jugador',
    );
    return '$_temp0';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Compañeros de tu rango';

  @override
  String get homeLiveAllyLabel => 'Tu equipo';

  @override
  String get homeLiveEnemyLabel => 'Enemigos';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'Buscando partida, esperando desde hace $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Tu equipo $ally, equipo enemigo $enemy';
  }

  @override
  String homeLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Racha de $n derrotas en Competitivo',
      one: 'Racha de $n derrota en Competitivo',
    );
    return '$_temp0';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n partidas para llegar a $rank',
      one: '≈ $n partida para llegar a $rank',
    );
    return '$_temp0';
  }

  @override
  String homeMoreActions(String name) {
    return 'Opciones de $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Vuelve a iniciar sesión para actualizar la tienda, el rango y el Battle Pass de $riotId. Mientras tanto, puedes ver la versión guardada en el dispositivo.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Quedan $time';
  }

  @override
  String get homeNightMarketNew => 'Nuevo';

  @override
  String get homeNightMarketTitle => 'Mercado nocturno';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ofertas te esperan por descubrir',
      one: '$n oferta te espera por descubrir',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'Hoy aún no has jugado Competitivo';

  @override
  String get homeOpenLfg => 'Ver todos los anuncios de búsqueda';

  @override
  String get homeOpenRanking => 'Ver la clasificación de skins';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Otras cuentas ($n)';
  }

  @override
  String homeOtherMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n cuentas',
      one: '+$n cuenta',
    );
    return '$_temp0';
  }

  @override
  String get homeOtherWishlistHit => 'Hay una skin de tu lista de deseos';

  @override
  String homePreviousAct(String rank) {
    return 'Acto anterior: $rank';
  }

  @override
  String get homeQuietBody => 'Desliza hacia abajo para actualizar.';

  @override
  String get homeQuietTitle => 'Nada nuevo por ahora';

  @override
  String homeRankToNext(int rr) {
    return 'Faltan $rr RR para subir de rango';
  }

  @override
  String get homeResetLayout => 'Restablecer valores predeterminados';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Hoy $value';
  }

  @override
  String get homeStatusDetails => 'Detalles';

  @override
  String homeStatusIncident(String region) {
    return 'Incidencia en el servidor · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'En mantenimiento · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Mantenimiento próximo · $region';
  }

  @override
  String homeStatusMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n avisos',
      one: '+$n aviso',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreRefreshing => 'Actualizando…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Se renueva en $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Total: $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Monedero: $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Monedero: $vp · alcanza para $n skins como máximo',
      one: 'Monedero: $vp · alcanza para $n skin como máximo',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreWishlistHit => '¡Hay una skin de tu lista de deseos!';

  @override
  String homeStoreWishlistHits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins de tu lista de deseos a la venta',
      one: '$n skin de tu lista de deseos a la venta',
    );
    return '$_temp0';
  }

  @override
  String get homeTitle => 'Inicio';

  @override
  String get homeTrendingTitle => 'Skins favoritas en todo el mundo';

  @override
  String homeTrendingVotes(int n) {
    return '$n me gusta';
  }

  @override
  String get homeUndo => 'Deshacer';

  @override
  String homeWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Racha de $n victorias en Competitivo',
      one: 'Racha de $n victoria en Competitivo',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreOutdated =>
      'La tienda ha cambiado. ValHub aún no ha podido cargar la nueva.';

  @override
  String get homeOfflineTitle => 'Sin conexión';

  @override
  String get homeOfflineBody =>
      'Mostrando lo guardado en este dispositivo. ValHub se actualizará cuando vuelva la conexión.';

  @override
  String get homeCardOffline => 'Aparecerá cuando haya conexión.';

  @override
  String get communityErrorConsent =>
      'Acepta compartir tu Riot ID con la Comunidad para continuar.';

  @override
  String get communityErrorForbidden =>
      'Todavía no puedes hacer esto. Consulta las Normas de la comunidad o contacta con ValHub.';

  @override
  String get communityErrorGeneric => 'Algo ha fallado. Vuelve a intentarlo.';

  @override
  String get communityErrorImageTooLarge =>
      'La imagen es demasiado grande (máximo 2 MB). Elige otra.';

  @override
  String get communityErrorImageType => 'Elige una imagen JPEG, PNG o WebP.';

  @override
  String get communityErrorInvalid =>
      'El contenido no se ha aceptado. Revísalo y vuelve a intentarlo.';

  @override
  String get communityErrorNetwork =>
      'No se ha podido conectar con la Comunidad de ValHub. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get communityErrorNotFound => 'Este contenido ya no existe.';

  @override
  String get communityErrorPickImage =>
      'No se ha podido abrir la galería. Vuelve a intentarlo.';

  @override
  String get communityErrorRateLimited =>
      'La Comunidad está recibiendo demasiadas solicitudes. Vuelve a intentarlo en unos minutos.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'La Comunidad está recibiendo demasiadas solicitudes. Vuelve a intentarlo dentro de $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot no ha podido verificar tu cuenta. Vuelve a iniciar sesión en tu cuenta de Riot e inténtalo de nuevo.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot tiene problemas. Vuelve a intentarlo en unos minutos.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot tiene problemas. Vuelve a intentarlo dentro de $duration.';
  }

  @override
  String get communityErrorServer =>
      'La Comunidad de ValHub tiene problemas. Vuelve a intentarlo en unos minutos.';

  @override
  String get communityErrorStorageFull =>
      'El almacenamiento de fotos de la Comunidad está lleno. Puedes publicar igualmente, pero aún no puedes adjuntar fotos. Vuelve a intentarlo más tarde.';

  @override
  String get communityErrorTimeout =>
      'La Comunidad de ValHub está tardando demasiado en responder. Vuelve a intentarlo.';

  @override
  String get communityErrorTitle => 'No completado';

  @override
  String get communityErrorUnauthorized =>
      'La conexión con la Comunidad ha caducado. Vuelve a intentarlo.';

  @override
  String get communityErrorImageQuota =>
      'Has agotado tu espacio para imágenes. Borra algunas publicaciones con imágenes y vuelve a intentarlo.';

  @override
  String get smokePlain => 'Prueba de generación de código';

  @override
  String smokeGreeting(String name) {
    return '¡Hola, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n elementos',
      one: '$n elemento',
    );
    return '$_temp0';
  }
}

/// The translations for Spanish Castilian, as used in Mexico (`es_MX`).
class AppLocalizationsEsMx extends AppLocalizationsEs {
  AppLocalizationsEsMx() : super('es_MX');

  @override
  String get commonErrorGeneric => 'Algo salió mal. Vuelve a intentarlo.';

  @override
  String get commonErrorNeedsLogin =>
      'Tu sesión de Riot expiró. Vuelve a iniciar sesión para continuar.';

  @override
  String get commonErrorNotFound => 'No se encontró este contenido.';

  @override
  String get commonErrorUnsupportedRegion =>
      'No se pudo determinar tu región de Riot. Elige una región en Configuración.';

  @override
  String get commonIncidentTitle => 'Incidente en el servidor';

  @override
  String get commonOpenSettings => 'Abrir configuración';

  @override
  String get commonPageNotFound => 'No se encontró esta pantalla.';

  @override
  String get commonPriceEditOwn => 'Editar el precio que ingresaste';

  @override
  String get commonPriceEnterOwn => 'Ingresa el precio de tu paquete de VP';

  @override
  String get commonPriceEstimateBody =>
      'El monto «≈ …» junto al precio en VP es una estimación según el paquete de VP más rentable. En el juego pagas con VP; el monto real depende del paquete, el método de pago, los impuestos y las ofertas al momento de la compra.';

  @override
  String get commonPriceHidden =>
      'Precio estimado oculto. Puedes volver a activarlo en Configuración.';

  @override
  String get commonPriceOverrideBody =>
      'Ingresa lo que pagaste realmente por un paquete de VP (consúltalo en la tienda del juego o en tu recibo). ValHub usa este precio para estimar el precio de cada objeto; solo se guarda en este dispositivo.';

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Ingresa un código de moneda de 3 letras, por ejemplo USD o MXN.';

  @override
  String get commonPriceOverrideInvalidNumber =>
      'Ingresa un número mayor que 0.';

  @override
  String get commonPriceOverrideRemove => 'Borrar precio ingresado';

  @override
  String get commonPriceOverrideRemoved => 'Se borró el precio que ingresaste.';

  @override
  String get commonPriceOverrideSaved =>
      'Se guardó el precio de tu paquete de VP.';

  @override
  String get commonPriceSourceUser =>
      'Según el precio de paquete de VP que ingresaste';

  @override
  String get commonPriceUnavailable =>
      'Aún no hay precios verificados para tu región. Ingresa el precio de un paquete de VP que hayas comprado para ver el precio estimado.';

  @override
  String get commonTabSettings => 'Configuración';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'El inicio de sesión de Riot expiró: mostrando la versión guardada ($time).';
  }

  @override
  String get contentCategorySmg => 'Subametralladoras';

  @override
  String get contentCategorySniper => 'Rifles de francotirador';

  @override
  String get contentCurrencyRpFull => 'Radianite Points';

  @override
  String get contentCurrencyVpFull => 'VALORANT Points';

  @override
  String get contentItemBuddy => 'Buddy';

  @override
  String get contentItemSpray => 'Spray';

  @override
  String get contentQueueNamesUnrated => 'Normal';

  @override
  String get contentQueueNamesSwiftplay => 'Swiftplay';

  @override
  String get contentQueueNamesSpikerush => 'Spike Rush';

  @override
  String get contentQueueNamesDeathmatch => 'Deathmatch';

  @override
  String get contentQueueNamesHurm => 'Deathmatch Definitivo';

  @override
  String get contentQueueNamesGgteam => 'Carrera de Armas';

  @override
  String get contentQueueNamesOnefa => 'Réplica';

  @override
  String get contentQueueNamesDodgeball => 'Quemados';

  @override
  String get contentQueueNamesFortcollins => 'Recaptura';

  @override
  String get contentQueueNamesSnowball => 'Pelea de Bolas de Nieve';

  @override
  String get contentTierDeluxe => 'Deluxe';

  @override
  String accountAddAccount(int count, int max) {
    return 'Agregar cuenta ($count/$max)';
  }

  @override
  String get accountLinkAccountMissing =>
      'Se cerró la sesión de la cuenta de la notificación. Vuelve a iniciar sesión y abre la notificación.';

  @override
  String get accountLoginNoteHint =>
      'Solo se guardan en este dispositivo, protegidos de forma segura. Sirven para consultarlos o completarlos rápido al volver a iniciar sesión.';

  @override
  String get accountManageHint =>
      'Elimina cuentas o edita los datos de inicio de sesión en Configuración.';

  @override
  String accountMaxAccounts(int max) {
    return 'Alcanzaste el máximo de cuentas ($max).';
  }

  @override
  String get accountQuickFill => 'Autocompletar cuenta guardada';

  @override
  String get accountQuickFillDone => 'Datos completados. Toca Iniciar sesión.';

  @override
  String get accountQuickFillNotReady =>
      'La página de inicio de sesión aún no carga. Espera un momento y vuelve a intentarlo.';

  @override
  String get accountQuickFillSubtitle =>
      'Elige una cuenta para completar la página de inicio de sesión de Riot';

  @override
  String get accountQuickFillTitle => 'Autocompletar cuenta guardada';

  @override
  String get accountQuickFillLocked =>
      'Desbloquea con tu huella, tu cara o el PIN del dispositivo para usar una cuenta guardada. Si tu celular no tiene bloqueo de pantalla, configura uno e inténtalo de nuevo.';

  @override
  String get authAddAsNew => 'Agregar como cuenta nueva';

  @override
  String get authDifferentAccountBody =>
      'Iniciaste sesión con una cuenta distinta de la que tenía que volver a iniciar sesión. ¿Quieres agregarla como cuenta nueva?';

  @override
  String get authLoginCancelledByRiot =>
      'Riot rechazó este inicio de sesión. Vuelve a intentarlo.';

  @override
  String get authLoginFailed => 'No se pudo completar el inicio de sesión';

  @override
  String get authLoginFailedBody =>
      'Riot no confirmó tu inicio de sesión. Vuelve a intentarlo.';

  @override
  String get authMissingCookies =>
      'No se puede guardar el inicio de sesión en este dispositivo, así que tendrás que volver a iniciar sesión cuando expire.';

  @override
  String get authPageLoadFailed =>
      'No se pudo cargar la página de inicio de sesión de Riot. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get notificationLfgJoinedTitle => 'Alguien se unió a tu grupo';

  @override
  String get notificationNightMarketOpenTitle => '¡Abrió el Mercado nocturno!';

  @override
  String notificationPassProgressBody(int level) {
    return 'Alcanzaste el nivel $level del Battle Pass actual.';
  }

  @override
  String get notificationRankChangedTitle => 'Tu rango cambió';

  @override
  String get loadoutNotPersisted =>
      'Riot no guardó tus cambios, así que tu equipamiento sigue igual. Vuelve a intentarlo.';

  @override
  String get loadoutSaveFailed => 'No se pudo guardar el equipamiento';

  @override
  String get battlePassAllMissionsDone => 'Completaste todas las misiones';

  @override
  String get battlePassAllWeeklyDone =>
      'Completaste todas las misiones semanales';

  @override
  String get battlePassCheckpointHint =>
      'Gana rondas para avanzar hacia el hito (Deathmatch no cuenta).';

  @override
  String get battlePassDailyAllDone => 'Alcanzaste todos los hitos de hoy';

  @override
  String get battlePassDailyExpired =>
      'Los hitos del día anterior expiraron. Entra al juego o actualízalos aquí.';

  @override
  String get battlePassDailyNotReady =>
      'Los hitos de hoy aún no están listos. Entra al juego o actualízalos aquí.';

  @override
  String get battlePassDailyPlayToStart =>
      'Los hitos de hoy aún no están listos. Entra al juego para empezar el nuevo día.';

  @override
  String get battlePassPremiumHint =>
      'No compraste el Prémium: solo recibes las recompensas gratuitas. Cómpralo en el juego para desbloquear los niveles que ya alcanzaste.';

  @override
  String get battlePassRenewFailed =>
      'No se pudieron actualizar los hitos. Vuelve a intentarlo más tarde.';

  @override
  String get battlePassUnratedFallback => 'Normal';

  @override
  String collectionSaveFailedWith(String detail) {
    return 'No se pudo guardar el equipamiento. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Todas tus skins, valoradas según el precio de la tienda',
      'buddy': 'Buddies que tienes y número de copias',
      'spray': 'Sprays que puedes poner en tu rueda de expresiones',
      'card':
          'Tarjetas de jugador desbloqueadas: toca para verlas y equiparlas',
      'title': 'Títulos que puedes mostrar bajo tu nombre',
      'flex': 'Flex que tienes',
      'other': 'Explorar colección',
    });
    return '$_temp0';
  }

  @override
  String get collectionApplyPresetBody =>
      'Las skins, buddies, rueda de expresiones, tarjeta y título que llevas ahora se reemplazarán por los de este conjunto.';

  @override
  String get collectionBrowseBuddies => 'Buddies';

  @override
  String get collectionBrowseSprays => 'Sprays';

  @override
  String get collectionBuddyPickerTitle => 'Elegir buddy';

  @override
  String get collectionBuddyRemoved => 'Buddy quitado';

  @override
  String get collectionBuddySlot => 'Buddy';

  @override
  String get collectionBuddyUnavailable =>
      'No se pudo poner este buddy. Actualiza o elige otro.';

  @override
  String get collectionExpressionsHint =>
      'Toca un espacio para elegir un spray o un Flex.';

  @override
  String get collectionMeleeNoBuddy =>
      'No se pueden poner buddies en el arma cuerpo a cuerpo.';

  @override
  String get collectionMoveBuddyTitle => '¿Mover buddy?';

  @override
  String get collectionNoBuddies => 'Todavía no tienes buddies.';

  @override
  String get collectionNoBuddy => 'Sin buddy';

  @override
  String get collectionNoResults => 'No se encontraron resultados.';

  @override
  String get collectionNoSprays => 'Todavía no tienes sprays.';

  @override
  String get collectionPlayLevelVideo => 'Ver video de este nivel';

  @override
  String get collectionPlayVideo => 'Ver video';

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Se omitieron $n objetos que ya no tienes.',
      one: 'Se omitió $n objeto que ya no tienes.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsFull =>
      'Alcanzaste el máximo de 50 conjuntos. Elimina alguno para guardar más.';

  @override
  String get collectionRemoveBuddy => 'Quitar buddy';

  @override
  String get collectionSaveFailed => 'No se pudo guardar el equipamiento';

  @override
  String get collectionSearchBuddies => 'Buscar buddies…';

  @override
  String get collectionSearchSprays => 'Buscar sprays…';

  @override
  String get collectionSearchWeapons => 'Buscar armas, skins o buddies…';

  @override
  String get collectionSkinNotFound => 'No se encontró esta skin.';

  @override
  String get collectionTabSprays => 'Sprays';

  @override
  String get collectionWeaponNotFound => 'No se encontró esta arma.';

  @override
  String get communityModerationContentInappropriate =>
      'No se pudo publicar porque contiene lenguaje inapropiado. Edita el texto y vuelve a intentarlo.';

  @override
  String get communityModerationAccountBanned =>
      'Esta cuenta perdió el acceso a la Comunidad. Si crees que es un error, contacta a ValHub en Acerca de y legal.';

  @override
  String get communityModerationAccountRestricted =>
      'Esta cuenta tiene restringido publicar, comentar, buscar compañeros y votar. Vuelve a intentarlo más tarde o contacta a ValHub en Acerca de y legal.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Competitivo',
      'unrated': 'Normal',
      'swiftplay': 'Swiftplay',
      'spikerush': 'Spike Rush',
      'deathmatch': 'Deathmatch',
      'teamdeathmatch': 'Deathmatch Definitivo',
      'premier': 'Premier',
      'custom': 'Personalizada',
      'other': 'Otro',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingNoSearch =>
      'No se encontraron skins. Prueba con otro nombre o quita el filtro de arma.';

  @override
  String get communityRankingCatalogUnavailable =>
      'No se pudo cargar el catálogo de skins. Cierra el panel y vuelve a intentarlo cuando se sincronicen los datos.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'No se pudo verificar que tengas esta skin. Vuelve a cargar la Colección o inténtalo de nuevo cuando tengas conexión.';

  @override
  String get communityAddPhotos => 'Agregar fotos';

  @override
  String get communityCodeAutoFailed =>
      'No se pudo crear el código de grupo. Abre VALORANT o ingresa el código manualmente.';

  @override
  String get communityCodeRequired => 'Ingresa o crea un código de grupo.';

  @override
  String get communityConsentLocal =>
      'Tu contraseña y el resto de tus datos de inicio de sesión se quedan siempre en este dispositivo. Puedes retirar tu consentimiento en Configuración.';

  @override
  String get communityConsentWithdrawn =>
      'Retiraste tu consentimiento. Debes volver a aceptarlo para seguir usando la app.';

  @override
  String get communityCountryNamesBD => 'Bangladesh';

  @override
  String get communityCountryNamesBH => 'Bahréin';

  @override
  String get communityCountryNamesCZ => 'República Checa';

  @override
  String get communityCountryNamesQA => 'Qatar';

  @override
  String get communityCountryNamesRO => 'Rumania';

  @override
  String get communityCountryNamesSA => 'Arabia Saudita';

  @override
  String get communityDataDeleted => 'Se eliminaron tus datos de la Comunidad.';

  @override
  String get communityDeleteDataSubtitle =>
      'Elimina para siempre todo lo que publicaste en la Comunidad.';

  @override
  String get communityEmptyPost => 'Escribe algo o agrega una foto.';

  @override
  String get communityExpired => 'Expirado';

  @override
  String get communityExportSubtitle =>
      'Una copia de todo lo que publicaste en la Comunidad: publicaciones, comentarios, reseñas, me gusta, votos y anuncios de búsqueda de compañeros.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Intenta ver publicaciones de la comunidad internacional o cambia los filtros.';

  @override
  String get communityHiddenAuthorsEmpty =>
      'No ocultaste ni bloqueaste a nadie';

  @override
  String get communityJoinCodeExpired =>
      'El código de grupo expiró o ya no es válido.';

  @override
  String get communityJoinGameNotRunning =>
      'Abre VALORANT en tu computadora o consola y vuelve a intentarlo.';

  @override
  String get communityJoinedHint =>
      '¡Te uniste al grupo! Abre VALORANT para jugar juntos.';

  @override
  String get communityLfgExpiredRepost =>
      'Tu anuncio expiró. Publica uno nuevo para buscar compañeros.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Región: $region · El anuncio expira a los 30 minutos.';
  }

  @override
  String communityMemberJoined(String name) {
    return '$name se unió al grupo';
  }

  @override
  String get communityNoAccountBody =>
      'Agrega una cuenta de Riot para publicar, buscar compañeros y votar skins.';

  @override
  String get communityNoteHint =>
      'Ej.: falta 1 Controlador, con micro, buena onda ante todo';

  @override
  String get communityPlayVideo => 'Ver video';

  @override
  String get communityPostNotFound =>
      'Esta publicación se eliminó o se ocultó.';

  @override
  String get communityReport => 'Reportar';

  @override
  String get communityReportConfirmBody =>
      'El contenido reportado por muchos jugadores se ocultará de la Comunidad.';

  @override
  String get communityReportConfirmTitle => '¿Enviar reporte?';

  @override
  String get communityReportPrompt => '¿Por qué reportas este contenido?';

  @override
  String get communityReportTitle => 'Reportar contenido';

  @override
  String get communityReported => '¡Gracias! Recibimos tu reporte.';

  @override
  String get communityShareNightMarketHint => 'Presume tu Mercado nocturno';

  @override
  String get communityShareStoreHint => 'Presume tu tienda de hoy';

  @override
  String get communitySignInToReview =>
      'Agrega una cuenta de Riot para valorar skins.';

  @override
  String get communitySkinNotFound => 'No se encontró esta skin.';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other:
          'Un grupo tiene como máximo 5 jugadores: solo quedan $max lugares.',
      one: 'Un grupo tiene como máximo 5 jugadores: solo queda $max lugar.',
    );
    return '$_temp0';
  }

  @override
  String get communityTranslateFailed =>
      'No se pudo traducir. Vuelve a intentarlo.';

  @override
  String get communityUnavailableBody =>
      'No se pudo conectar con la Comunidad de ValHub. Vuelve a intentarlo en unos minutos.';

  @override
  String get communityUnavailableTitle =>
      'No se pudo conectar con la Comunidad';

  @override
  String get liveGameLiveStatsUnavailable =>
      'Esta fuente de partidas en vivo no ofrece bajas, muertes ni asistencias. La tabla de puntuación aparecerá cuando Riot publique los datos tras la partida.';

  @override
  String get liveGameLiveScore => 'Marcador en vivo';

  @override
  String get liveGameQuitDone => 'Abandonaste la partida.';

  @override
  String get liveGameQuitFailed => 'No se pudo abandonar la partida.';

  @override
  String get liveGameQuitMatchChanged =>
      'La partida cambió de fase mientras confirmabas. No saliste; vuelve a intentarlo.';

  @override
  String get liveGameSprays => 'Sprays';

  @override
  String get liveGameStatusUnavailable =>
      'No se pudo actualizar el estado de la partida';

  @override
  String liveGameYouLocked(String agent) {
    return 'Fijaste a $agent';
  }

  @override
  String get profileAlreadyReached => 'Ya alcanzaste este rango.';

  @override
  String get profileMatchUnavailable => 'No se pudo cargar la partida';

  @override
  String get profileOvertime => 'Tiempo extra';

  @override
  String get profilePerformanceEmpty =>
      'Todavía no hay partidas registradas en este dispositivo. Abre el historial de partidas para registrar las que jugaste.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Se identificó el lado atacante o defensor en $known/$total rondas.';
  }

  @override
  String profilePerformanceAverage(String value) {
    return 'Promedio $value';
  }

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
          'ValHub solo analiza las partidas abiertas en este dispositivo. Cada toque agrega hasta $nString partidas anteriores.',
      one:
          'ValHub solo analiza las partidas abiertas en este dispositivo. Cada toque agrega hasta $nString partida anterior.',
    );
    return '$_temp0';
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
      other: 'Se agregaron $nString partidas al análisis.',
      one: 'Se agregó $nString partida al análisis.',
      zero: 'No hay partidas nuevas para agregar.',
    );
    return '$_temp0';
  }

  @override
  String get legalContentUnavailable =>
      'No se pudo leer el documento legal. Vuelve a intentarlo o contacta al soporte.';

  @override
  String get settingsLanguageSaveFailed =>
      'No se pudo guardar el idioma. Vuelve a intentarlo.';

  @override
  String get settingsGeoNoRegion => 'No se pudo determinar la región de Riot';

  @override
  String get settingsGeoValidationFailed =>
      'La cuenta no se confirmó en este servidor. Vuelve a elegir la región.';

  @override
  String get settingsGeoSaveFailed =>
      'No se pudo guardar la selección. Vuelve a intentarlo.';

  @override
  String get settingsGeoActivityUnavailable =>
      'No se pudo cargar la actividad por país. Puedes elegir de todos modos en Todos los países.';

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Elegiste $manual, pero Riot ubica tu cuenta en $detected. ¿Quieres comprobar esta conexión de todos modos?';
  }

  @override
  String get settingsGeoUnverified =>
      'No se pudo verificar la conexión porque el servidor o la red tienen problemas. ¿Guardar esta opción y volver a intentarlo más tarde?';

  @override
  String settingsCacheCleared(String size) {
    return 'Se liberaron $size';
  }

  @override
  String get settingsClearCacheFailed =>
      'No se pudieron borrar los datos temporales. Vuelve a intentarlo.';

  @override
  String get settingsLinkOpenFailed =>
      'No se pudo abrir el enlace. Vuelve a intentarlo.';

  @override
  String get settingsLogShareFailed =>
      'No se pudo enviar el informe de errores. Vuelve a intentarlo.';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Sin ingresar: se usan los precios de tu región si los hay';

  @override
  String get settingsOptionShowLiveScore => 'Mostrar marcador en vivo';

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Aún no hay precios verificados para tu región: ingresa el precio de tu paquete de VP.';

  @override
  String get settingsPrimingFootnote =>
      'Puedes activar o desactivar cada tipo de notificación cuando quieras en Configuración.';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Para descubrir tus ofertas antes de que expiren';

  @override
  String settingsRemovedAccount(String account) {
    return 'Se eliminó $account';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Mantenimientos e incidentes de VALORANT por servidor';

  @override
  String get settingsSignedOutAll => 'Se cerró sesión en todas las cuentas';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'No hay incidentes ni mantenimientos en el servidor $region.';
  }

  @override
  String get settingsStatusIssues => 'Riot está solucionando un incidente';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Este servidor tiene $n avisos de incidentes.',
      one: 'Este servidor tiene $n aviso de incidente.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'Incidente';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Es posible que no puedas entrar al juego y que ValHub no pueda cargar la información por ahora.';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Riot anunció $n mantenimientos programados.',
      one: 'Riot anunció $n mantenimiento programado.',
    );
    return '$_temp0';
  }

  @override
  String settingsSwitchedTo(String account) {
    return 'Cambiaste a $account';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Precios, rareza y cuenta regresiva de renovación';

  @override
  String get skinDetailAddToWishlist => 'Agregar a la lista de deseos';

  @override
  String get skinDetailNotFound => 'No se encontró esta skin.';

  @override
  String get skinDetailPlayVideo => 'Ver video';

  @override
  String get skinDetailVideoError =>
      'No se pudo reproducir el video. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String socialActionFailed(String message) {
    return 'No se pudo completar la acción. $message';
  }

  @override
  String get socialFriendsPrivacyNote =>
      'Tu lista de amigos y tus mensajes se obtienen directamente de Riot. ValHub no los guarda en ningún otro lugar.';

  @override
  String get socialGameNotRunningBody =>
      'Grupo y cola solo funciona cuando VALORANT se está ejecutando en tu computadora o consola. Abre el juego y desliza hacia abajo para actualizar.';

  @override
  String get socialGameNotRunningTitle =>
      'Abre VALORANT en tu computadora o consola';

  @override
  String get socialJoinWithCode => 'Ingresa un código para unirte';

  @override
  String get socialJoined => 'Te uniste al grupo.';

  @override
  String get socialNoFriends =>
      'Tu lista de amigos de Riot está vacía. Agrega amigos en el juego.';

  @override
  String get socialNoSearchResults => 'No se encontró ningún amigo.';

  @override
  String get socialOnlineMobile => 'En línea en el celular';

  @override
  String socialPlayingOther(String game) {
    return 'Jugando $game';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'No se pudo verificar el estado del juego. Actualiza para usar Listo y la cola.';

  @override
  String get socialReconnecting =>
      'Se perdió la conexión con el chat. Reconectando…';

  @override
  String get socialRemoteNote =>
      'Los cambios solo se envían a Riot cuando tú tocas. ValHub nunca busca partida ni fija agentes por ti.';

  @override
  String get socialSendFailed =>
      'No se pudo enviar el mensaje. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get socialShootingRange => 'En La Galería';

  @override
  String get socialSuggestionsItem1 => '¿Jugamos unas partidas?';

  @override
  String get socialPartyUnavailable =>
      'No se pudo sincronizar el grupo. Actualiza para volver a intentarlo.';

  @override
  String get storeAddToWishlist => 'Agregar a la lista de deseos';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Expira: $wall';
  }

  @override
  String get storeBundleNotFound =>
      'No se encontró este lote. Es posible que haya expirado.';

  @override
  String get storeBundleNotFoundTitle => 'Lote expirado';

  @override
  String get storeResetNotificationTitle => 'La tienda se renovó';

  @override
  String get storeShareFailed =>
      'No se pudo crear la imagen. Vuelve a intentarlo.';

  @override
  String get storeShareShowRiotIdHint =>
      'Desactivado de forma predeterminada para proteger tu privacidad.';

  @override
  String get wishlistAddSkins => 'Agregar skins';

  @override
  String get wishlistAddToWishlist => 'Agregar a la lista de deseos';

  @override
  String get wishlistCatalogEmpty =>
      'No se pudo cargar la lista de skins. Actualiza para volver a intentarlo.';

  @override
  String get wishlistCatalogSubtitle =>
      'Toca ♡ para agregar una skin a tu lista de deseos';

  @override
  String get wishlistEmpty =>
      'Tu lista de deseos está vacía. Toca ♡ en cualquier skin para agregarla.';

  @override
  String get wishlistNoMatchTitle => 'No se encontraron skins';

  @override
  String get wishlistNotifDailyTitle =>
      '¡Apareció una skin de tu lista de deseos!';

  @override
  String get wishlistOpenSettings => 'Abrir configuración';

  @override
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  ) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'gain': 'subiste',
      'other': 'bajaste',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins victorias',
      one: '$wins victoria',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses derrotas',
      one: '$losses derrota',
    );
    return 'Hoy $_temp0 $rr RR, $_temp1, $_temp2';
  }

  @override
  String get homeAllHiddenTitle => 'Ocultaste todas las tarjetas';

  @override
  String homeCardHidden(String name) {
    return 'Se ocultó \"$name\"';
  }

  @override
  String get homeCardServerStatusDesc =>
      'Solo aparece si hay mantenimiento o un incidente.';

  @override
  String homeFocused(String name) {
    return 'Fuiste a $name';
  }

  @override
  String get homeNoRankedToday => 'Hoy aún no jugaste Competitivo';

  @override
  String homeStatusIncident(String region) {
    return 'Incidente en el servidor · $region';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Billetera: $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Billetera: $vp · alcanza para $n skins como máximo',
      one: 'Billetera: $vp · alcanza para $n skin como máximo',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreOutdated =>
      'La tienda cambió. ValHub todavía no pudo cargar la nueva.';

  @override
  String get communityErrorForbidden =>
      'Todavía no puedes hacer esto. Consulta las Normas de la comunidad o contacta a ValHub.';

  @override
  String get communityErrorGeneric => 'Algo salió mal. Vuelve a intentarlo.';

  @override
  String get communityErrorInvalid =>
      'El contenido no se aceptó. Revísalo y vuelve a intentarlo.';

  @override
  String get communityErrorNetwork =>
      'No se pudo conectar con la Comunidad de ValHub. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get communityErrorPickImage =>
      'No se pudo abrir la galería. Vuelve a intentarlo.';

  @override
  String get communityErrorRiotRejected =>
      'Riot no pudo verificar tu cuenta. Vuelve a iniciar sesión en tu cuenta de Riot e inténtalo de nuevo.';

  @override
  String get communityErrorUnauthorized =>
      'La conexión con la Comunidad expiró. Vuelve a intentarlo.';
}
