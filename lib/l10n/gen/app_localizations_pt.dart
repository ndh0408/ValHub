// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Ver fonte da tabela de preços';

  @override
  String get commonErrorApi =>
      'A Riot está com problemas. Tente de novo em alguns minutos.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClearFilters => 'Limpar filtros';

  @override
  String get commonClearSearch => 'Limpar busca';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonCopied => 'Copiado';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dias',
      one: '$n dia',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'há $n dias',
      one: 'há $n dia',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonEmptyGeneric => 'Nada por aqui ainda.';

  @override
  String get commonErrorContentUnavailable =>
      'Não foi possível carregar as informações de skins, agentes e mapas. Verifique sua conexão e tente de novo.';

  @override
  String get commonErrorGeneric => 'Algo deu errado. Tente de novo.';

  @override
  String get commonErrorMaintenance =>
      'Os servidores do VALORANT estão em manutenção. Volte mais tarde.';

  @override
  String get commonErrorNeedsLogin =>
      'Seu login da Riot expirou. Entre novamente para continuar.';

  @override
  String get commonErrorNeedsLoginTitle => 'Entre novamente';

  @override
  String get commonErrorNetwork =>
      'Sem conexão. Verifique o Wi-Fi ou os dados móveis e tente de novo.';

  @override
  String get commonErrorNoAccount => 'Você ainda não entrou em nenhuma conta.';

  @override
  String get commonErrorNotFound => 'Conteúdo não encontrado.';

  @override
  String get commonErrorTimeout =>
      'A Riot está demorando para responder. Verifique sua conexão e tente de novo.';

  @override
  String get commonErrorTransient =>
      'A Riot está ocupada. Tente de novo em alguns minutos.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'A Riot está ocupada. Tente de novo em $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Não foi possível identificar sua região da Riot. Escolha a região nas Configurações.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'Ir para o Início';

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
      other: 'há $n horas',
      one: 'há $n hora',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'Problema nos servidores';

  @override
  String get commonJustNow => 'agora mesmo';

  @override
  String get commonLoadMore => 'Carregar mais';

  @override
  String get commonLoading => 'Carregando…';

  @override
  String get commonMaintenanceTitle => 'Manutenção dos servidores';

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
      other: 'há $n minutos',
      one: 'há $n minuto',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'Nada para ver ainda';

  @override
  String commonOfflineCached(String time) {
    return 'Sem conexão — mostrando a versão salva ($time).';
  }

  @override
  String get commonOpenSettings => 'Abrir configurações';

  @override
  String get commonPageNotFound => 'Tela não encontrada.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Pacote mais vantajoso: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Editar o preço que você inseriu';

  @override
  String get commonPriceEnterOwn => 'Insira o preço do seu pacote de VP';

  @override
  String get commonPriceEstimateBody =>
      'O valor “≈ …” ao lado do preço em VP é uma estimativa, convertida pelo pacote de VP mais vantajoso. Você paga em VP no jogo; o valor real depende do pacote, do meio de pagamento, de impostos e de promoções no momento da compra.';

  @override
  String get commonPriceEstimateTitle => 'Preço convertido estimado';

  @override
  String get commonPriceEstimateTooltip =>
      'Preço estimado — toque para ver o cálculo';

  @override
  String get commonPriceHidden =>
      'Preço convertido oculto. Ative de novo nas Configurações.';

  @override
  String get commonPriceHide => 'Ocultar preço convertido';

  @override
  String get commonPriceOpenSource => 'Abrir página da fonte';

  @override
  String get commonPriceOverrideBody =>
      'Insira o valor que você realmente pagou por um pacote de VP (veja na loja do jogo ou no recibo). O ValHub usa esse preço para estimar o valor convertido de todos os itens; ele fica salvo apenas neste dispositivo.';

  @override
  String get commonPriceOverrideCurrency => 'Código da moeda';

  @override
  String get commonPriceOverrideCurrencyHint => 'Ex.: BRL, USD, EUR, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Exemplo de estimativa: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Insira um código de moeda de 3 letras, como BRL ou USD.';

  @override
  String get commonPriceOverrideInvalidNumber =>
      'Insira um número maior que 0.';

  @override
  String get commonPriceOverridePrice => 'Preço do pacote';

  @override
  String get commonPriceOverrideRemove => 'Remover preço inserido';

  @override
  String get commonPriceOverrideRemoved =>
      'O preço que você inseriu foi removido.';

  @override
  String get commonPriceOverrideSave => 'Salvar preço';

  @override
  String get commonPriceOverrideSaved => 'Preço do seu pacote de VP salvo.';

  @override
  String get commonPriceOverrideTitle => 'Preço do seu pacote de VP';

  @override
  String get commonPriceOverrideVp => 'VP do pacote';

  @override
  String get commonPricePacksTitle => 'Pacotes de VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'Pela tabela de preços de VP da região $country';
  }

  @override
  String get commonPriceSourceUser => 'Pelo preço de VP que você inseriu';

  @override
  String get commonPriceUnavailable =>
      'Ainda não há uma tabela de preços verificada para sua região. Insira o preço de um pacote de VP que você já comprou para ver o preço convertido estimado.';

  @override
  String commonPriceUpdated(String date) {
    return 'Tabela de preços atualizada em: $date';
  }

  @override
  String get commonRetry => 'Tentar de novo';

  @override
  String get commonRiotDisclaimer =>
      'O ValHub não é endossado pela Riot Games e não reflete as opiniões da Riot Games nem de qualquer pessoa envolvida na produção ou gestão dos produtos da Riot Games. Riot Games e todos os ativos associados são marcas comerciais ou marcas registradas da Riot Games, Inc.';

  @override
  String get commonSave => 'Salvar';

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
  String get commonShare => 'Compartilhar';

  @override
  String get commonSignInAgain => 'Entrar novamente';

  @override
  String get commonSort => 'Ordenar';

  @override
  String commonSortBy(String option) {
    return 'Ordenar: $option';
  }

  @override
  String get commonTabBattlePass => 'Passe';

  @override
  String get commonTabCollection => 'Coleção';

  @override
  String get commonTabCommunity => 'Comunidade';

  @override
  String get commonTabHome => 'Início';

  @override
  String get commonTabProfile => 'Perfil';

  @override
  String get commonTabSettings => 'Configurações';

  @override
  String get commonTabStore => 'Loja';

  @override
  String get commonTagline => 'Seu parceiro de VALORANT';

  @override
  String get commonToday => 'Hoje';

  @override
  String get commonTodayLower => 'hoje';

  @override
  String get commonTomorrow => 'amanhã';

  @override
  String get commonUnknownItem => 'Item sem nome';

  @override
  String commonUpdatedAt(String time) {
    return 'Atualizado às $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'Segunda-feira';

  @override
  String get commonWeekdaysItem1 => 'Terça-feira';

  @override
  String get commonWeekdaysItem2 => 'Quarta-feira';

  @override
  String get commonWeekdaysItem3 => 'Quinta-feira';

  @override
  String get commonWeekdaysItem4 => 'Sexta-feira';

  @override
  String get commonWeekdaysItem5 => 'Sábado';

  @override
  String get commonWeekdaysItem6 => 'Domingo';

  @override
  String get commonYesterday => 'ontem';

  @override
  String get commonYesterdayTitle => 'Ontem';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'O login da Riot expirou — mostrando a versão salva ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Armas Pesadas';

  @override
  String get contentCategoryMelee => 'Corpo a corpo';

  @override
  String get contentCategoryRifle => 'Fuzis';

  @override
  String get contentCategoryShotgun => 'Escopetas';

  @override
  String get contentCategorySidearm => 'Armas Leves';

  @override
  String get contentCategorySmg => 'Submetralhadoras';

  @override
  String get contentCategorySniper => 'Fuzis de Precisão';

  @override
  String get contentCurrencyAgentTokens => 'Tokens de Agente';

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
  String get contentCurrencyVpFull => 'VALORANT Points';

  @override
  String get contentItemAgent => 'Agente';

  @override
  String get contentItemBuddy => 'Chaveiro';

  @override
  String get contentItemCard => 'Cartão de Jogador';

  @override
  String get contentItemChroma => 'Variante';

  @override
  String get contentItemContract => 'Contrato';

  @override
  String get contentItemCurrency => 'Moeda';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Spray';

  @override
  String get contentItemTitle => 'Título de Jogador';

  @override
  String contentLevel(int n) {
    return 'Nível $n';
  }

  @override
  String get contentLevelBase => 'Básico';

  @override
  String get contentLevelItemLabelsVFX => 'Efeitos visuais';

  @override
  String get contentLevelItemLabelsAnimation => 'Animação';

  @override
  String get contentLevelItemLabelsFinisher => 'Finalizador';

  @override
  String get contentLevelItemLabelsKillCounter => 'Contador de abates';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Efeitos sonoros';

  @override
  String get contentLevelItemLabelsTransformation => 'Transformação';

  @override
  String get contentLevelItemLabelsKillBanner => 'Faixa de abate';

  @override
  String get contentLevelItemLabelsKillEffect => 'Efeito de abate';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'Efeito de inspeção e abate';

  @override
  String get contentLevelItemLabelsVoiceover => 'Dublagem';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Troca de música';

  @override
  String get contentLevelItemLabelsRandomizer => 'Aleatorização';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Muda com o lado (ataque/defesa)';

  @override
  String get contentLevelItemLabelsTopFrag => 'Efeito de top frag';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Sensor de batimentos e mapa';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Animação de peixe';

  @override
  String get contentNoTitle => 'Sem título';

  @override
  String get contentNotForSale => 'Não está à venda';

  @override
  String get contentQueueNamesCompetitive => 'Competitivo';

  @override
  String get contentQueueNamesUnrated => 'Sem classificação';

  @override
  String get contentQueueNamesSwiftplay => 'Frenético';

  @override
  String get contentQueueNamesSpikerush => 'Disputa da Spike';

  @override
  String get contentQueueNamesDeathmatch => 'Mata-Mata';

  @override
  String get contentQueueNamesHurm => 'Mata-Mata em Equipe';

  @override
  String get contentQueueNamesGgteam => 'Disparada';

  @override
  String get contentQueueNamesOnefa => 'Replicação';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Jogo Personalizado';

  @override
  String get contentQueueNames => 'Jogo Personalizado';

  @override
  String get contentQueueNamesDodgeball => 'Nocaute';

  @override
  String get contentQueueNamesFortcollins => 'Retomada';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Duelo: 2x2';

  @override
  String get contentQueueNamesSkirmishascension1v1 => 'Duelo: Ascensão 1x1';

  @override
  String get contentQueueNamesSkirmishascension2v2 => 'Duelo: Ascensão 2x2';

  @override
  String get contentQueueNamesValaram => 'Tudo Aleatório Um Ponto';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Batalha Nevada';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Competitivo';

  @override
  String get contentQueueShortNamesValaram => 'Aleatório 1 Ponto';

  @override
  String get contentRewardSourceAgent => 'Contrato de agente';

  @override
  String get contentRewardSourceBattlePass => 'Recompensa do Passe de Batalha';

  @override
  String get contentRewardSourceEvent => 'Passe de evento';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Duelista';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Iniciador';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Controlador';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Sentinela';

  @override
  String get contentTierDeluxe => 'Deluxe';

  @override
  String get contentTierExclusive => 'Exclusiva';

  @override
  String contentTierFull(String shortName) {
    return 'Edição $shortName';
  }

  @override
  String get contentTierPremium => 'Premium';

  @override
  String get contentTierSelect => 'Selecionada';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'Sem classificação';

  @override
  String get accountRegionUnknown => 'Servidor desconhecido';

  @override
  String accountRiotCountry(String country) {
    return 'País da conta Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown =>
      'País da conta Riot: não identificado';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'CONTAS ($count/$max)';
  }

  @override
  String get accountActive => 'Em uso';

  @override
  String accountAddAccount(int count, int max) {
    return 'Adicionar conta ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Apagar dados locais';

  @override
  String get accountClearLocalDataConfirm =>
      'Apagar o histórico, os loadouts salvos e os dados das contas desconectadas neste dispositivo?';

  @override
  String get accountClearRrHistory => 'Apagar histórico de RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'Apagar o histórico de RR da conta selecionada neste dispositivo?';

  @override
  String get accountCopyPassword => 'Copiar senha';

  @override
  String get accountCopyUsername => 'Copiar nome de usuário';

  @override
  String get accountDeleteLoginNote => 'Apagar dados';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Apagar o nome de usuário e a senha salvos desta conta?';

  @override
  String get accountHidePassword => 'Ocultar senha';

  @override
  String get accountKeepLocalData => 'Manter dados locais';

  @override
  String get accountKeepLocalDataHint =>
      'Manter wishlist, loadouts e histórico neste dispositivo';

  @override
  String accountLevelShort(int level) {
    return 'Nv. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'A conta da notificação foi desconectada. Entre novamente e abra a notificação.';

  @override
  String get accountLocalDataCleared => 'Dados locais apagados';

  @override
  String get accountLoginNote => 'Dados de login';

  @override
  String get accountLoginNoteDeleted => 'Dados de login apagados';

  @override
  String get accountLoginNoteEmpty => 'Nenhum dado de login salvo';

  @override
  String get accountLoginNoteHint =>
      'Salvo apenas neste dispositivo, com bloqueio seguro. Use para consultar ou preencher rápido quando entrar novamente.';

  @override
  String get accountLoginNoteLocked => 'Desbloquear dados de login';

  @override
  String get accountLoginNotePassword => 'Senha';

  @override
  String get accountLoginNoteSaved => 'Dados de login salvos';

  @override
  String get accountLoginNoteUsername => 'Nome de usuário Riot';

  @override
  String get accountManageHint =>
      'Remova contas ou edite os dados de login nas Configurações.';

  @override
  String accountMaxAccounts(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '$max contas',
      one: '$max conta',
    );
    return 'Você atingiu o limite de $_temp0.';
  }

  @override
  String get accountNeedsLogin => 'Entre novamente';

  @override
  String accountOnlineCount(int count) {
    return '$count online';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'Preencher conta salva';

  @override
  String get accountQuickFillDone => 'Preenchido. Toque em Entrar.';

  @override
  String get accountQuickFillNotReady =>
      'A página de login ainda não carregou. Aguarde um pouco e tente de novo.';

  @override
  String get accountQuickFillSubtitle =>
      'Escolha uma conta para preencher na página de login da Riot';

  @override
  String get accountQuickFillTitle => 'Preencher conta salva';

  @override
  String get accountRegionAp => 'Ásia-Pacífico';

  @override
  String get accountRegionBr => 'Brasil';

  @override
  String get accountRegionEu => 'Europa';

  @override
  String get accountRegionKr => 'Coreia';

  @override
  String get accountRegionLatam => 'América Latina';

  @override
  String get accountRegionNa => 'América do Norte';

  @override
  String get accountRemoveAccount => 'Remover conta';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Remover $account deste dispositivo? Você pode optar por manter os dados salvos.';
  }

  @override
  String get accountRrHistoryCleared => 'Histórico de RR apagado';

  @override
  String get accountShowPassword => 'Mostrar senha';

  @override
  String get accountSignOutAll => 'Sair de todas as contas';

  @override
  String get accountSignOutAllConfirm =>
      'Sair e remover todas as contas deste dispositivo? Você pode optar por manter os dados salvos.';

  @override
  String get accountStatusAgentSelect => 'Na seleção de agentes';

  @override
  String get accountStatusInMatch => 'Em partida';

  @override
  String get accountStatusOffline => 'Offline';

  @override
  String get accountStatusOnline => 'Online';

  @override
  String get accountStatusUnknown => 'Status desconhecido';

  @override
  String accountSwitchTo(String account) {
    return 'Trocar para $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Toque para trocar de conta';

  @override
  String get accountSwitcherTitle => 'Contas';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Contas ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Jogador';

  @override
  String get accountUnlockLoginNote =>
      'Confirme sua identidade para ver os dados de login Riot';

  @override
  String get authAddAsNew => 'Adicionar como nova conta';

  @override
  String get authDifferentAccountBody =>
      'Você entrou com uma conta diferente da que precisava entrar novamente. Adicionar esta conta como uma nova conta?';

  @override
  String get authDifferentAccountTitle => 'Outra conta';

  @override
  String get authLoadingAccount => 'Carregando conta…';

  @override
  String get authLoginCancelledByRiot =>
      'A Riot recusou este login. Tente de novo.';

  @override
  String get authLoginFailed => 'Não foi possível concluir o login';

  @override
  String get authLoginFailedBody =>
      'A Riot ainda não confirmou seu login. Tente de novo.';

  @override
  String get authLoginTitle => 'Entrar com a Riot';

  @override
  String get authMissingCookies =>
      'Não foi possível manter o login neste dispositivo, então você vai precisar entrar novamente quando ele expirar.';

  @override
  String get authOfficialHost => 'Página oficial · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Link aberto no navegador.';

  @override
  String get authPageLoadFailed =>
      'Não foi possível carregar a página de login da Riot. Verifique sua conexão e tente de novo.';

  @override
  String get authPreparing => 'Preparando a página de login…';

  @override
  String get authReloginDone => 'Login renovado';

  @override
  String get authSignInCta => 'Entrar com a conta Riot';

  @override
  String get authSocialLoginHint =>
      'Se o login com Google ou Facebook não funcionar, use seu nome de usuário Riot.';

  @override
  String get authStateMismatch =>
      'Este login não é válido. Comece o login novamente do início.';

  @override
  String get notificationSessionExpiredBody =>
      'Entre novamente para continuar recebendo alertas da wishlist.';

  @override
  String get notificationBackgroundTimingHint =>
      'O modo de economia de bateria do dispositivo pode atrasar as notificações.';

  @override
  String get notificationChannelAccountDescription =>
      'Avisa quando uma conta precisa entrar novamente';

  @override
  String get notificationChannelAccountName => 'Contas';

  @override
  String get notificationChannelBattlePassDescription =>
      'Lembretes de progresso e do fim do Passe de Batalha';

  @override
  String get notificationChannelBattlePassName => 'Passe de Batalha';

  @override
  String get notificationChannelCommunityDescription =>
      'Avisa sobre a atividade da comunidade quando você abre o ValHub';

  @override
  String get notificationChannelCommunityName => 'Comunidade';

  @override
  String get notificationChannelLfgDescription =>
      'Avisa quando jogadores entram no seu grupo enquanto o ValHub está aberto';

  @override
  String get notificationChannelLfgName => 'Grupo';

  @override
  String get notificationChannelNightMarketDescription =>
      'Avisa quando o Mercado Noturno abrir';

  @override
  String get notificationChannelNightMarketName => 'Mercado Noturno';

  @override
  String get notificationChannelRankDescription =>
      'Avisa sobre mudanças de ranque quando você atualiza o perfil';

  @override
  String get notificationChannelRankName => 'Ranque';

  @override
  String get notificationChannelStoreResetDescription =>
      'Avisa quando a loja diária for atualizada';

  @override
  String get notificationChannelStoreResetName => 'Atualização da loja';

  @override
  String get notificationChannelWishlistDescription =>
      'Avisa quando uma skin da wishlist aparecer na loja';

  @override
  String get notificationChannelWishlistName => 'Wishlist';

  @override
  String get notificationLfgJoinedTitle => 'Um jogador entrou no seu grupo';

  @override
  String get notificationLocalOnlyHint =>
      'Avisa só neste dispositivo, quando o ValHub atualiza os dados';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Revele agora as ofertas de $account. Cartas: $cards.';
  }

  @override
  String get notificationNightMarketOpenTitle => 'O Mercado Noturno abriu!';

  @override
  String get notificationPassEndingBody =>
      'Falta cerca de um dia para o Passe de Batalha acabar. Abra o ValHub para ver seu progresso mais recente.';

  @override
  String get notificationPassEndingTitle => 'O Passe de Batalha está acabando';

  @override
  String notificationPassProgressBody(int level) {
    return 'Você chegou ao nível $level do Passe de Batalha atual.';
  }

  @override
  String get notificationPassProgressTitle => 'Progresso do Passe de Batalha';

  @override
  String get notificationPrivateAccount => 'sua conta';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Ranque atual: $rank. Dados recém-atualizados da Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Seu ranque mudou';

  @override
  String get notificationResetTimingUnknown =>
      'Abra a loja para atualizar o horário de renovação no seu dispositivo.';

  @override
  String get notificationSessionExpiredTitle => 'Entre novamente';

  @override
  String get notificationStoreResetBody =>
      'Skins novas esperam por você na loja.';

  @override
  String get competitiveDivisionIron => 'Ferro';

  @override
  String get competitiveDivisionBronze => 'Bronze';

  @override
  String get competitiveDivisionSilver => 'Prata';

  @override
  String get competitiveDivisionGold => 'Ouro';

  @override
  String get competitiveDivisionPlatinum => 'Platina';

  @override
  String get competitiveDivisionDiamond => 'Diamante';

  @override
  String get competitiveDivisionAscendant => 'Ascendente';

  @override
  String get competitiveDivisionImmortal => 'Imortal';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Radiante';

  @override
  String get competitiveRankUnknown => 'Ranque desconhecido';

  @override
  String get competitiveAttack => 'Ataque';

  @override
  String get competitiveCannotEstimate => 'Não dá para estimar';

  @override
  String get competitiveDefeat => 'Derrota';

  @override
  String get competitiveDefense => 'Defesa';

  @override
  String get competitiveDraw => 'Empate';

  @override
  String get competitiveIncognitoPlayer => 'Jogador anônimo';

  @override
  String get competitiveMatchPending => 'A Riot está processando a partida…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Faltam $n partidas de posicionamento',
      one: 'Falta $n partida de posicionamento',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'Spike desarmada';

  @override
  String get competitiveRoundDetonate => 'Spike detonada';

  @override
  String get competitiveRoundElimination => 'Equipe eliminada';

  @override
  String get competitiveRoundSurrendered => 'Rendição';

  @override
  String get competitiveRoundTimeExpired => 'Tempo esgotado';

  @override
  String get competitiveUnknownPlayer => 'Jogador';

  @override
  String get competitiveVictory => 'Vitória';

  @override
  String economyAvailableNow(String place) {
    return 'Disponível agora $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'no pacote $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'em um pacote';

  @override
  String get economyPlaceDaily => 'na loja diária';

  @override
  String get economyPlaceNightMarket => 'no Mercado Noturno';

  @override
  String get economyPriceEstimated => 'Preço estimado pela edição';

  @override
  String get economyPriceFromOffers => 'Preço da tabela da Riot';

  @override
  String get economyPriceFromStore => 'Preço visto na loja';

  @override
  String get economyPriceFromTable => 'Preço de tabela';

  @override
  String get economyPriceUnknown => 'Preço desconhecido';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Loadout $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Esta alteração não se aplica ao loadout atual.';

  @override
  String get loadoutNotPersisted =>
      'A Riot não salvou sua alteração, então o loadout continua igual. Tente de novo.';

  @override
  String get loadoutSaveFailed => 'Não foi possível salvar o loadout';

  @override
  String battlePassActEndsIn(String time) {
    return 'O ato termina em $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '$days dia',
    );
    return 'O ato termina em $_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'Todas as missões concluídas';

  @override
  String get battlePassAllWeeklyDone => 'Todas as missões semanais concluídas';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Bônus em dobro pendentes: $n';
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
      'Vença rodadas para avançar nos marcos (Mata-Mata não conta).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Marco $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Cada marco: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Marcos alcançados: $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'Atual';

  @override
  String get battlePassDailyAllDone => 'Todos os marcos de hoje concluídos';

  @override
  String get battlePassDailyCaption => 'Recompensas diárias';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Recompensas diárias · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Os marcos do dia anterior expiraram. Entre no jogo ou atualize aqui.';

  @override
  String get battlePassDailyMissions => 'Missões diárias';

  @override
  String get battlePassDailyNotReady =>
      'Os marcos de hoje ainda não estão prontos. Entre no jogo ou atualize aqui.';

  @override
  String get battlePassDailyPlayToStart =>
      'Os marcos de hoje ainda não estão prontos. Entre no jogo para começar o novo dia.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltam $days dias',
      one: 'Falta $days dia',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Termina às $wall';
  }

  @override
  String get battlePassEpilogue => 'Epílogo';

  @override
  String get battlePassEstimateNote =>
      'Estimativa de cerca de 4.000 XP por partida, sem contar missões.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Termina em $time';
  }

  @override
  String get battlePassEventPass => 'Passe de evento';

  @override
  String get battlePassFilterAll => 'Tudo';

  @override
  String get battlePassFilterLocked => 'Bloqueadas';

  @override
  String get battlePassFilterUnlocked => 'Desbloqueadas';

  @override
  String get battlePassFree => 'Grátis';

  @override
  String get battlePassFreeTrack => 'Recompensas grátis';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Nível $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Nível $n';
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
  String get battlePassMissionDone => 'Concluída';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total concluídas';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Novas missões às $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Novas missões em $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Próximo marco: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Até o nível $level';
  }

  @override
  String get battlePassNextReward => 'Próxima';

  @override
  String get battlePassNoBattlePass =>
      'Ainda não há informações do Passe de Batalha do ato atual. Tente de novo mais tarde.';

  @override
  String get battlePassNoRewards =>
      'Este Passe de Batalha ainda não tem recompensas.';

  @override
  String get battlePassNoRewardsInFilter =>
      'Nenhuma recompensa nesta categoria.';

  @override
  String get battlePassNoRewardsTitle => 'Nenhuma recompensa ainda';

  @override
  String get battlePassNoWeeklyMissions => 'Ainda não há missões semanais.';

  @override
  String get battlePassPassComplete => 'Passe de Batalha concluído';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'Você não comprou o Premium: só recebe as recompensas grátis. Compre o Premium no jogo para desbloquear os níveis já alcançados.';

  @override
  String get battlePassRenewButton => 'Atualizar marcos';

  @override
  String get battlePassRenewDone => 'Marcos diários atualizados.';

  @override
  String get battlePassRenewFailed =>
      'Não foi possível atualizar os marcos. Tente de novo mais tarde.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Renova às $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Renova em $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Nível';

  @override
  String get battlePassRewardLocked => 'Bloqueada';

  @override
  String get battlePassRewardNeedsPremium => 'Requer Premium';

  @override
  String get battlePassRewardStatusLabel => 'Status';

  @override
  String get battlePassRewardTrackLabel => 'Tipo de recompensa';

  @override
  String get battlePassRewardTypeLabel => 'Tipo';

  @override
  String get battlePassRewardUnlocked => 'Desbloqueada';

  @override
  String get battlePassRewardsTitle => 'Recompensas';

  @override
  String get battlePassShowAllRewards => 'Ver tudo';

  @override
  String get battlePassTitle => 'Passe de Batalha';

  @override
  String get battlePassTotalXpCaption => 'XP total';

  @override
  String get battlePassUnknownMission => 'Nova missão (sem descrição)';

  @override
  String get battlePassUnknownReward => 'Recompensa';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total desbloqueadas';
  }

  @override
  String get battlePassUnratedFallback => 'Sem classificação';

  @override
  String get battlePassViewAllRewards => 'Ver todas as recompensas';

  @override
  String get battlePassWeeklyMissions => 'Missões semanais';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Missões semanais: +$xp XP restantes';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / dia';
  }

  @override
  String get battlePassXpPerDayCaption =>
      'Necessário por dia para concluir a tempo';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Faltam $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Não foi possível salvar o loadout. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Todas as skins que você possui, com valor pelo preço da loja',
      'buddy': 'Chaveiros que você possui e o número de cópias',
      'spray': 'Sprays que você pode colocar na roda de expressões',
      'card': 'Cartões de Jogador desbloqueados, toque para ver e equipar',
      'title': 'Títulos que você pode exibir abaixo do nome',
      'flex': 'Itens Flex que você possui',
      'other': 'Explorar a coleção',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Espaço $position';
  }

  @override
  String get collectionApplyPreset => 'Aplicar';

  @override
  String get collectionApplyPresetBody =>
      'As skins, chaveiros, roda de expressões, cartão e título em uso serão substituídos por este loadout.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'Aplicar “$name”?';
  }

  @override
  String get collectionBrowseBuddies => 'Chaveiros';

  @override
  String get collectionBrowseCards => 'Cartões de Jogador';

  @override
  String get collectionBrowseEmpty =>
      'Você ainda não tem itens nesta categoria.';

  @override
  String get collectionBrowseEmptyTitle => 'Nenhum item ainda';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skins';

  @override
  String get collectionBrowseSprays => 'Sprays';

  @override
  String get collectionBrowseTitles => 'Títulos';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Livres: $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Para $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Escolher chaveiro';

  @override
  String get collectionBuddyRemoved => 'Chaveiro removido';

  @override
  String get collectionBuddySlot => 'Chaveiro';

  @override
  String get collectionBuddyUnavailable =>
      'Não foi possível equipar este chaveiro. Atualize ou escolha outro.';

  @override
  String get collectionCachedLoadout =>
      'Mostrando o loadout salvo. Puxe para atualizar antes de fazer alterações.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString cartões obtidos',
      one: '$nString cartão obtido',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'Trocar';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total variantes';
  }

  @override
  String get collectionClearTiers => 'Limpar filtro de edição';

  @override
  String get collectionCollectionValue => 'Valor da coleção';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Padrão';

  @override
  String get collectionDeletePreset => 'Excluir';

  @override
  String get collectionEmptySlot => 'Vazio';

  @override
  String get collectionEquip => 'Equipar';

  @override
  String get collectionEquipped => 'Equipado';

  @override
  String get collectionEquippedCard => 'Cartão equipado';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Cartão equipado: $name';
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
  String get collectionExcludedRewards => 'Sem contar skins de recompensa';

  @override
  String get collectionExpressionsHint =>
      'Toque em um espaço para escolher um spray ou item Flex.';

  @override
  String get collectionExpressionsSlots => 'Espaços da roda';

  @override
  String get collectionExpressionsTitle => 'Roda de expressões';

  @override
  String get collectionHideAccountLevel => 'Ocultar nível da conta';

  @override
  String get collectionHideAccountLevelHint =>
      'Outros jogadores não verão o nível da sua conta.';

  @override
  String get collectionIncognito => 'Modo anônimo';

  @override
  String get collectionIncognitoHint =>
      'Oculta seu nome para jogadores que não estão no seu grupo durante a partida.';

  @override
  String get collectionLevelBorderAuto => 'Automática pelo nível';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'A partir do nível $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Conta nível $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Escolher borda de nível';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Nível $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Nível $n · $type';
  }

  @override
  String get collectionLevels => 'Níveis';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '$owned/$total níveis desbloqueados';
  }

  @override
  String get collectionLobbyBanner => 'Imagem do saguão';

  @override
  String get collectionLocked => 'Bloqueado';

  @override
  String get collectionMeleeNoBuddy =>
      'Armas corpo a corpo não podem ter chaveiro.';

  @override
  String get collectionMove => 'Mover';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy está equipado em $from. Mover para $to?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Mover chaveiro?';

  @override
  String get collectionNoBuddies => 'Você ainda não tem chaveiros.';

  @override
  String get collectionNoBuddy => 'Sem chaveiro';

  @override
  String get collectionNoFlex => 'Você ainda não tem itens Flex.';

  @override
  String get collectionNoResults => 'Nenhum resultado encontrado.';

  @override
  String get collectionNoResultsTitle => 'Nada encontrado';

  @override
  String get collectionNoSkinsForWeapon =>
      'Você ainda não tem skins para esta arma.';

  @override
  String get collectionNoSprays => 'Você ainda não tem sprays.';

  @override
  String get collectionNoTitle => 'Sem título';

  @override
  String get collectionOtherWeapons => 'Outras';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins obtidas',
      one: '$n skin obtida',
      zero: 'Nenhuma skin ainda',
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
      other: '$nString skins obtidas',
      one: '$nString skin obtida',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'Ver vídeo deste nível';

  @override
  String get collectionPlayVideo => 'Ver vídeo';

  @override
  String get collectionPlayerCardSubtitle =>
      'Aparece no saguão, no placar e quando você abate um inimigo.';

  @override
  String get collectionPlayerCardTitle => 'Trocar Cartão de Jogador';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Aparece abaixo do seu nome no saguão e na partida.';

  @override
  String get collectionPlayerTitleTitle => 'Trocar título';

  @override
  String get collectionPresetActions => 'Opções';

  @override
  String collectionPresetApplied(String name) {
    return '“$name” aplicado';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n loadouts',
      one: '$n loadout',
      zero: 'Nenhum',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '“$name” excluído';
  }

  @override
  String get collectionPresetNameHint => 'Ex.: Subir de ranque';

  @override
  String get collectionPresetNameTitle => 'Nome do loadout';

  @override
  String collectionPresetSaved(String name) {
    return '“$name” salvo';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Salvo em $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n itens que você não possui mais foram ignorados.',
      one: '$n item que você não possui mais foi ignorado.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'Salve o loadout atual para alternar rápido entre conjuntos de skins, cartões e roda de expressões depois.';

  @override
  String get collectionPresetsEmptyTitle => 'Nenhum loadout salvo';

  @override
  String get collectionPresetsFull =>
      'Você atingiu o limite de 50 loadouts. Exclua alguns para salvar mais.';

  @override
  String get collectionPresetsNote =>
      'Os loadouts ficam salvos só neste dispositivo, para a conta selecionada.';

  @override
  String get collectionPresetsTitle => 'Loadouts salvos';

  @override
  String get collectionPreview => 'Visualizar';

  @override
  String get collectionRemoveBuddy => 'Remover chaveiro';

  @override
  String get collectionRenamePreset => 'Renomear';

  @override
  String get collectionRowExpressions => 'Roda de expressões';

  @override
  String get collectionRowLevelBorder => 'Borda de Nível';

  @override
  String get collectionRowPresets => 'Loadouts salvos';

  @override
  String get collectionRowWeapons => 'Loadout de armas';

  @override
  String get collectionRowWishlist => 'Wishlist';

  @override
  String get collectionSaveFailed => 'Não foi possível salvar o loadout';

  @override
  String get collectionSavePreset => 'Salvar loadout atual';

  @override
  String get collectionSaving => 'Salvando…';

  @override
  String get collectionSearchBuddies => 'Buscar chaveiros…';

  @override
  String get collectionSearchCards => 'Buscar Cartões de Jogador…';

  @override
  String get collectionSearchFlex => 'Buscar Flex…';

  @override
  String get collectionSearchItems => 'Buscar…';

  @override
  String get collectionSearchSkins => 'Buscar skins…';

  @override
  String get collectionSearchSprays => 'Buscar sprays…';

  @override
  String get collectionSearchTitles => 'Buscar títulos…';

  @override
  String get collectionSearchWeapons => 'Buscar armas, skins ou chaveiros…';

  @override
  String get collectionSectionBrowse => 'Explorar a coleção';

  @override
  String get collectionSectionIdentity => 'Visível para outros jogadores';

  @override
  String get collectionSectionLoadout => 'Loadout';

  @override
  String get collectionSkinCustomizeTitle => 'Personalizar skin';

  @override
  String get collectionSkinNotFound => 'Skin não encontrada.';

  @override
  String get collectionSkinNotOwned => 'Você ainda não possui esta skin.';

  @override
  String get collectionSlotNamesItem0 => 'Superior';

  @override
  String get collectionSlotNamesItem1 => 'Direito';

  @override
  String get collectionSlotNamesItem2 => 'Inferior';

  @override
  String get collectionSlotNamesItem3 => 'Esquerdo';

  @override
  String get collectionSortName => 'Nome';

  @override
  String get collectionSortPrice => 'Preço';

  @override
  String get collectionSortRarity => 'Raridade';

  @override
  String get collectionSortWeapon => 'Arma';

  @override
  String collectionSummaryFiltered(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins',
      one: '$count skin',
    );
    return 'Filtrando: $_temp0 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Filtrando: $count/$total itens';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '$count item',
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
  String get collectionTabSprays => 'Sprays';

  @override
  String get collectionTapToChangeCard => 'Toque para trocar o cartão';

  @override
  String get collectionTitle => 'Coleção';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString títulos obtidos',
      one: '$nString título obtido',
    );
    return '$_temp0';
  }

  @override
  String get collectionUndo => 'Desfazer';

  @override
  String get collectionUnknownCard => 'Cartão sem nome';

  @override
  String get collectionValueAtStorePrices => 'Pelo preço da loja';

  @override
  String get collectionValueHasEstimates => 'Inclui preços estimados (≈)';

  @override
  String collectionValueRewardCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins de recompensa não contabilizadas',
      one: '$n skin de recompensa não contabilizada',
    );
    return '$_temp0';
  }

  @override
  String get collectionValueSeeSkins => 'Ver as skins';

  @override
  String collectionValueSkinCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins',
      one: '$n skin',
    );
    return 'Com base em $_temp0';
  }

  @override
  String get collectionVariants => 'Variantes';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$total armas com skin';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Loadout de armas';

  @override
  String get collectionWeaponNotFound => 'Arma não encontrada.';

  @override
  String get collectionWeaponSkinsTitle => 'Escolher skin';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins',
      one: '$n skin',
      zero: 'Vazia',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Não foi possível publicar porque há palavras inadequadas. Edite o texto e tente de novo.';

  @override
  String get communityModerationContentScam =>
      'A comunidade não permite anúncios de compra e venda de contas, serviços de elojob ou números de telefone. Remova esse conteúdo e tente de novo.';

  @override
  String get communityModerationContentTooComplex =>
      'O texto tem caracteres soltos demais. Escreva de forma mais simples e tente de novo.';

  @override
  String get communityModerationAccountBanned =>
      'Esta conta foi bloqueada na Comunidade. Se achar que é um engano, entre em contato com o ValHub em Sobre e informações legais.';

  @override
  String get communityModerationAccountRestricted =>
      'Esta conta está impedida de publicar, comentar, procurar parceiros e votar. Tente de novo mais tarde ou entre em contato com o ValHub em Sobre e informações legais.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Competitivo',
      'unrated': 'Sem classificação',
      'swiftplay': 'Frenético',
      'spikerush': 'Disputa da Spike',
      'deathmatch': 'Mata-Mata',
      'teamdeathmatch': 'Mata-Mata em Equipe',
      'premier': 'Premier',
      'custom': 'Personalizado',
      'other': 'Outro',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Ásia-Pacífico',
      'na': 'América do Norte',
      'eu': 'Europa',
      'kr': 'Coreia',
      'latam': 'América Latina',
      'br': 'Brasil',
      'other': 'Servidor desconhecido',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'Ainda não há skins neste ranking';

  @override
  String get communityRankingEmptyVotes =>
      'Ainda não há curtidas para o alcance e os filtros selecionados.';

  @override
  String get communityRankingEmptyRatings =>
      'Ainda não há avaliações por estrelas para o alcance e os filtros selecionados.';

  @override
  String get communityRankingEmptyReviews =>
      'Ainda não há comentários de avaliação para o alcance e os filtros selecionados.';

  @override
  String get communityRankingExplore => 'Encontre skins para ver e avaliar';

  @override
  String get communityRankingExploreHint =>
      'Busque pelo nome da skin ou da arma. Só avaliações reais da comunidade aparecem no ranking.';

  @override
  String get communityRankingClear => 'Limpar filtros de arma e período';

  @override
  String get communityRankingSort => 'Classificar por';

  @override
  String get communityRankingWeapon => 'Arma';

  @override
  String get communityRankingNoSearch =>
      'Nenhuma skin encontrada. Tente outro nome ou remova o filtro de arma.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Não foi possível carregar o catálogo de skins. Feche e tente de novo depois que os dados forem sincronizados.';

  @override
  String get communityConsentExitAccount => 'Não concordo · Sair desta conta';

  @override
  String get communityRankingGlobalAllTime => 'Global · Desde sempre';

  @override
  String get communityRankingCatalogTitle => 'Todas as skins';

  @override
  String get communityReviewOwnershipRequired =>
      'A conta precisa possuir esta skin para avaliar. Você ainda pode ver as avaliações e os comentários da comunidade.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Não foi possível confirmar que você possui a skin. Recarregue a Coleção ou tente de novo quando estiver conectado.';

  @override
  String get communityReviewLegacyOwnership =>
      'Avaliação antiga · Posse não confirmada';

  @override
  String get communityReviewVerifiedOwner =>
      'Posse confirmada no momento da avaliação';

  @override
  String get communitySkinDiscussionHint =>
      'Todos podem comentar. Só quem possui a skin pode dar estrelas e escrever avaliações.';

  @override
  String get communityAddPhotos => 'Adicionar fotos';

  @override
  String get communityAllModes => 'Todos';

  @override
  String get communityAllWeapons => 'Todas as armas';

  @override
  String get communityAnonymousBanner => 'Navegando anonimamente';

  @override
  String get communityAnyLanguage => 'Qualquer idioma';

  @override
  String get communityAnyRank => 'Qualquer ranque';

  @override
  String get communityAnyRole => 'Qualquer função';

  @override
  String get communityApply => 'Aplicar';

  @override
  String get communityBackToMyCountry => 'Voltar ao meu país';

  @override
  String get communityBlockAuthor => 'Bloquear neste dispositivo';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Limpar';

  @override
  String get communityCodeAuto =>
      'Deixe em branco: o ValHub cria o código a partir do seu grupo no jogo quando você publicar.';

  @override
  String get communityCodeAutoFailed =>
      'Não foi possível criar o código do grupo. Abra o VALORANT ou digite o código manualmente.';

  @override
  String get communityCodeInvalid =>
      'O código tem exatamente 6 letras maiúsculas ou números.';

  @override
  String get communityCodeRequired => 'Digite ou crie um código de grupo.';

  @override
  String get communityCommentHint => 'Escreva um comentário…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString comentários',
      one: '$nString comentário',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Comentários · $n';
  }

  @override
  String get communityCommentsTitle => 'Comentários';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'Publicações: $posts · Autores: $authors';
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
      other: '$nString anúncios de grupo',
      one: '$nString anúncio de grupo',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'Favoritas da comunidade';

  @override
  String get communityComposerHint =>
      'O que você está pensando sobre VALORANT hoje?';

  @override
  String get communityComposerTitle => 'Nova publicação';

  @override
  String communityConsentAccount(String riotId) {
    return 'Conta: $riotId';
  }

  @override
  String get communityConsentAgree => 'Concordar e continuar';

  @override
  String get communityConsentGateAction => 'Participar';

  @override
  String get communityConsentGuidelines => 'Diretrizes da comunidade';

  @override
  String get communityConsentLater => 'Mais tarde';

  @override
  String get communityConsentLocal =>
      'Sua senha e outros dados de login ficam sempre neste dispositivo. Você pode retirar seu consentimento nas Configurações.';

  @override
  String get communityConsentPrivacy => 'Política de privacidade';

  @override
  String get communityConsentPublic =>
      'Outras pessoas verão seu Riot ID, Cartão de Jogador, ranque e país.';

  @override
  String get communityConsentTitle => 'Privacidade e Comunidade ValHub';

  @override
  String get communityConsentVerify =>
      'O ValHub envia seu acesso Riot ao servidor da Comunidade para confirmar seu Riot ID ao conectar e verificar se você possui a skin quando salva uma avaliação. O servidor lê só os dados necessários, descarta o acesso logo em seguida e não o guarda.';

  @override
  String get communityConsentWithdrawn =>
      'Consentimento retirado. É preciso concordar novamente para continuar usando o app.';

  @override
  String get communityCountriesTitle => 'Comunidades por país';

  @override
  String get communityCountryNamesAE => 'Emirados Árabes Unidos';

  @override
  String get communityCountryNamesAL => 'Albânia';

  @override
  String get communityCountryNamesAM => 'Armênia';

  @override
  String get communityCountryNamesAR => 'Argentina';

  @override
  String get communityCountryNamesAT => 'Áustria';

  @override
  String get communityCountryNamesAU => 'Austrália';

  @override
  String get communityCountryNamesAZ => 'Azerbaijão';

  @override
  String get communityCountryNamesBA => 'Bósnia e Herzegovina';

  @override
  String get communityCountryNamesBD => 'Bangladesh';

  @override
  String get communityCountryNamesBE => 'Bélgica';

  @override
  String get communityCountryNamesBG => 'Bulgária';

  @override
  String get communityCountryNamesBH => 'Bahrein';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Bolívia';

  @override
  String get communityCountryNamesBR => 'Brasil';

  @override
  String get communityCountryNamesBY => 'Belarus';

  @override
  String get communityCountryNamesCA => 'Canadá';

  @override
  String get communityCountryNamesCH => 'Suíça';

  @override
  String get communityCountryNamesCL => 'Chile';

  @override
  String get communityCountryNamesCN => 'China';

  @override
  String get communityCountryNamesCO => 'Colômbia';

  @override
  String get communityCountryNamesCR => 'Costa Rica';

  @override
  String get communityCountryNamesCU => 'Cuba';

  @override
  String get communityCountryNamesCY => 'Chipre';

  @override
  String get communityCountryNamesCZ => 'Tchéquia';

  @override
  String get communityCountryNamesDE => 'Alemanha';

  @override
  String get communityCountryNamesDK => 'Dinamarca';

  @override
  String get communityCountryNamesDO => 'República Dominicana';

  @override
  String get communityCountryNamesDZ => 'Argélia';

  @override
  String get communityCountryNamesEC => 'Equador';

  @override
  String get communityCountryNamesEE => 'Estônia';

  @override
  String get communityCountryNamesEG => 'Egito';

  @override
  String get communityCountryNamesES => 'Espanha';

  @override
  String get communityCountryNamesET => 'Etiópia';

  @override
  String get communityCountryNamesFI => 'Finlândia';

  @override
  String get communityCountryNamesFR => 'França';

  @override
  String get communityCountryNamesGB => 'Reino Unido';

  @override
  String get communityCountryNamesGE => 'Geórgia';

  @override
  String get communityCountryNamesGH => 'Gana';

  @override
  String get communityCountryNamesGR => 'Grécia';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hong Kong';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Croácia';

  @override
  String get communityCountryNamesHU => 'Hungria';

  @override
  String get communityCountryNamesID => 'Indonésia';

  @override
  String get communityCountryNamesIE => 'Irlanda';

  @override
  String get communityCountryNamesIL => 'Israel';

  @override
  String get communityCountryNamesIN => 'Índia';

  @override
  String get communityCountryNamesIQ => 'Iraque';

  @override
  String get communityCountryNamesIR => 'Irã';

  @override
  String get communityCountryNamesIS => 'Islândia';

  @override
  String get communityCountryNamesIT => 'Itália';

  @override
  String get communityCountryNamesJO => 'Jordânia';

  @override
  String get communityCountryNamesJP => 'Japão';

  @override
  String get communityCountryNamesKE => 'Quênia';

  @override
  String get communityCountryNamesKH => 'Camboja';

  @override
  String get communityCountryNamesKR => 'Coreia do Sul';

  @override
  String get communityCountryNamesKW => 'Kuwait';

  @override
  String get communityCountryNamesKZ => 'Cazaquistão';

  @override
  String get communityCountryNamesLA => 'Laos';

  @override
  String get communityCountryNamesLB => 'Líbano';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Lituânia';

  @override
  String get communityCountryNamesLU => 'Luxemburgo';

  @override
  String get communityCountryNamesLV => 'Letônia';

  @override
  String get communityCountryNamesLY => 'Líbia';

  @override
  String get communityCountryNamesMA => 'Marrocos';

  @override
  String get communityCountryNamesMD => 'Moldávia';

  @override
  String get communityCountryNamesME => 'Montenegro';

  @override
  String get communityCountryNamesMK => 'Macedônia do Norte';

  @override
  String get communityCountryNamesMM => 'Mianmar';

  @override
  String get communityCountryNamesMN => 'Mongólia';

  @override
  String get communityCountryNamesMO => 'Macau';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'México';

  @override
  String get communityCountryNamesMY => 'Malásia';

  @override
  String get communityCountryNamesNG => 'Nigéria';

  @override
  String get communityCountryNamesNI => 'Nicarágua';

  @override
  String get communityCountryNamesNL => 'Países Baixos';

  @override
  String get communityCountryNamesNO => 'Noruega';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'Nova Zelândia';

  @override
  String get communityCountryNamesOM => 'Omã';

  @override
  String get communityCountryNamesPA => 'Panamá';

  @override
  String get communityCountryNamesPE => 'Peru';

  @override
  String get communityCountryNamesPH => 'Filipinas';

  @override
  String get communityCountryNamesPK => 'Paquistão';

  @override
  String get communityCountryNamesPL => 'Polônia';

  @override
  String get communityCountryNamesPR => 'Porto Rico';

  @override
  String get communityCountryNamesPT => 'Portugal';

  @override
  String get communityCountryNamesPY => 'Paraguai';

  @override
  String get communityCountryNamesQA => 'Catar';

  @override
  String get communityCountryNamesRO => 'Romênia';

  @override
  String get communityCountryNamesRS => 'Sérvia';

  @override
  String get communityCountryNamesRU => 'Rússia';

  @override
  String get communityCountryNamesSA => 'Arábia Saudita';

  @override
  String get communityCountryNamesSE => 'Suécia';

  @override
  String get communityCountryNamesSG => 'Singapura';

  @override
  String get communityCountryNamesSI => 'Eslovênia';

  @override
  String get communityCountryNamesSK => 'Eslováquia';

  @override
  String get communityCountryNamesSV => 'El Salvador';

  @override
  String get communityCountryNamesTH => 'Tailândia';

  @override
  String get communityCountryNamesTL => 'Timor-Leste';

  @override
  String get communityCountryNamesTN => 'Tunísia';

  @override
  String get communityCountryNamesTR => 'Turquia';

  @override
  String get communityCountryNamesTW => 'Taiwan';

  @override
  String get communityCountryNamesUA => 'Ucrânia';

  @override
  String get communityCountryNamesUS => 'Estados Unidos';

  @override
  String get communityCountryNamesUY => 'Uruguai';

  @override
  String get communityCountryNamesUZ => 'Uzbequistão';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Vietnã';

  @override
  String get communityCountryNamesZA => 'África do Sul';

  @override
  String get communityCreateLfg => 'Criar anúncio de grupo';

  @override
  String get communityCreateLfgShort => 'Criar anúncio';

  @override
  String get communityDataDeleted =>
      'Seus dados da Comunidade foram excluídos.';

  @override
  String communityDataFooter(String riotId) {
    return 'Vale para a conta em uso: $riotId. O arquivo baixado não contém senha nem dados de login da Riot.';
  }

  @override
  String get communityDataTitle => 'Seus dados da Comunidade';

  @override
  String get communityDecrease => 'Diminuir';

  @override
  String get communityDelete => 'Excluir';

  @override
  String get communityDeleteComment => 'Excluir comentário';

  @override
  String get communityDeleteCommentBody =>
      'Este comentário será excluído permanentemente.';

  @override
  String get communityDeleteCommentTitle => 'Excluir comentário?';

  @override
  String get communityDeleteDataConfirm => 'Excluir permanentemente';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Todas as publicações, comentários, avaliações de skins, curtidas, votos, anúncios de grupo e fotos de $riotId na Comunidade ValHub serão excluídos permanentemente e não poderão ser recuperados. Você volta ao modo de visualização anônima e precisará concordar de novo se quiser participar outra vez.\n\nSua conta Riot e seus dados no jogo não são afetados. Baixe seus dados antes se quiser guardar uma cópia.';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'Excluir dados da Comunidade?';

  @override
  String get communityDeleteDataSubtitle =>
      'Exclui permanentemente tudo o que você publicou na Comunidade.';

  @override
  String get communityDeleteDataTitle => 'Excluir meus dados da Comunidade';

  @override
  String get communityDeletePost => 'Excluir publicação';

  @override
  String get communityDeletePostBody =>
      'A publicação e todos os comentários serão excluídos permanentemente.';

  @override
  String get communityDeletePostTitle => 'Excluir publicação?';

  @override
  String get communityDeleteReview => 'Excluir avaliação';

  @override
  String get communityDeleteReviewBody =>
      'Sua nota e seu comentário sobre esta skin serão excluídos.';

  @override
  String get communityDeleteReviewTitle => 'Excluir sua avaliação?';

  @override
  String get communityDeleted => 'Excluído.';

  @override
  String get communityDiscard => 'Descartar';

  @override
  String get communityDiscardBody => 'O que você escreveu não será salvo.';

  @override
  String get communityDiscardTitle => 'Descartar publicação?';

  @override
  String get communityDownload => 'Baixar e traduzir';

  @override
  String get communityDownloadingModels => 'Baixando pacote de tradução…';

  @override
  String get communityEditReview => 'Editar';

  @override
  String get communityEdited => 'editado';

  @override
  String get communityEmptyPost => 'Escreva algo ou adicione uma foto.';

  @override
  String get communityExpired => 'Expirado';

  @override
  String communityExpiresIn(String t) {
    return 'Expira em $t';
  }

  @override
  String get communityExportPreparing => 'Preparando…';

  @override
  String get communityExportSubject => 'Dados da Comunidade ValHub';

  @override
  String get communityExportSubtitle =>
      'Uma cópia de tudo o que você publicou na Comunidade: publicações, comentários, avaliações, curtidas, votos e anúncios de grupo.';

  @override
  String get communityExportTitle => 'Baixar meus dados';

  @override
  String get communityExtend => 'Estender';

  @override
  String get communityExtended => 'Anúncio estendido por mais 30 minutos.';

  @override
  String get communityFeedEmptyBody =>
      'Seja o primeiro a compartilhar sua loja, seu Mercado Noturno ou seus melhores momentos!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Nenhuma publicação encontrada. Tente mudar o idioma ou remover os filtros.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Nenhuma publicação nova. Volte mais tarde ou participe para compartilhar.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Tente ver publicações da comunidade internacional ou mudar os filtros.';

  @override
  String get communityFeedEmptyScopeTitle => 'Nenhuma publicação neste alcance';

  @override
  String get communityFeedEmptyTitle => 'O feed está vazio';

  @override
  String get communityFilters => 'Filtros';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Tradução do Google';

  @override
  String get communityHelpful => 'Útil';

  @override
  String communityHelpfulCount(String n) {
    return 'Útil · $n';
  }

  @override
  String get communityHiddenAuthors => 'Pessoas ocultadas e bloqueadas';

  @override
  String get communityHiddenAuthorsEmpty =>
      'Você não ocultou nem bloqueou ninguém';

  @override
  String get communityHiddenAuthorsHint =>
      'Vale só para esta conta neste dispositivo. O conteúdo dessas pessoas fica oculto; elas ainda podem ver o seu conteúdo público.';

  @override
  String communityImageOf(int i, int n) {
    return 'Foto $i/$n';
  }

  @override
  String get communityIncrease => 'Aumentar';

  @override
  String get communityJoin => 'Entrar';

  @override
  String get communityJoinCodeExpired =>
      'O código do grupo expirou ou não é mais válido.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Você vai sair do seu grupo atual no VALORANT para entrar no grupo de $name.';
  }

  @override
  String get communityJoinConfirmTitle => 'Entrar neste grupo?';

  @override
  String get communityJoinGameNotRunning =>
      'Abra o VALORANT no computador ou no console e tente de novo.';

  @override
  String get communityJoinParty => 'Entrar no grupo';

  @override
  String get communityJoinPartyFull => 'Este grupo já está cheio.';

  @override
  String get communityJoinedHint =>
      'Você entrou no grupo! Abra o VALORANT para jogarem juntos.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString pedidos para entrar',
      one: '$nString pedido para entrar',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'Mercado Noturno';

  @override
  String get communityKindStore => 'Loja de hoje';

  @override
  String get communityLanguage => 'Idioma';

  @override
  String get communityLanguageFilter => 'Idioma do conteúdo';

  @override
  String get communityLanguageFilterHint =>
      'Mostra só conteúdo escrito nos idiomas selecionados. Deixe em branco para ver tudo.';

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
      'Crie um anúncio para que outros jogadores entrem no seu grupo com um toque.';

  @override
  String get communityLfgEmptyTitle => 'Ninguém procurando parceiros ainda';

  @override
  String get communityLfgExpiredRepost =>
      'Seu anúncio expirou. Publique um novo para procurar parceiros.';

  @override
  String get communityLfgGateBody =>
      'Participe (confirmando seu Riot ID uma vez) para ver anúncios de jogadores do mesmo servidor e publicar o seu. Você continua vendo o Feed e o Ranking de skins normalmente.';

  @override
  String get communityLfgGateTitle => 'Procurar parceiros é para membros';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Você está vendo o servidor $region — só jogadores do mesmo servidor da sua conta podem entrar no grupo.';
  }

  @override
  String get communityLfgPosted => 'Anúncio de grupo publicado!';

  @override
  String get communityLfgPreviewTitle => 'Encontre parceiros do seu ranque';

  @override
  String get communityLfgRemoved => 'Anúncio removido.';

  @override
  String get communityLfgSameShardNote =>
      'Só jogadores do mesmo servidor podem entrar no grupo.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Região: $region · O anúncio expira após 30 minutos.';
  }

  @override
  String get communityLike => 'Curtir';

  @override
  String get communityLiveMembers => 'Membros';

  @override
  String get communityMatchMyRank => 'Combina com seu ranque';

  @override
  String communityMemberJoined(String name) {
    return '$name entrou no grupo';
  }

  @override
  String get communityMemberJoinedBody =>
      'Alguém acabou de entrar pelo seu anúncio de grupo.';

  @override
  String get communityMic => 'Precisa de mic';

  @override
  String get communityMicOn => 'Com mic';

  @override
  String get communityMode => 'Modo';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'Mais opções';

  @override
  String get communityMuteAuthor => 'Ocultar esta pessoa';

  @override
  String get communityNewPost => 'Publicar';

  @override
  String communityNightMarketOf(String date) {
    return 'Mercado Noturno de $date';
  }

  @override
  String get communityNoAccountBody =>
      'Adicione uma conta Riot para publicar, procurar parceiros e votar em skins.';

  @override
  String get communityNoAccountTitle => 'Entre para participar';

  @override
  String get communityNoComments => 'Nenhum comentário ainda. Seja o primeiro!';

  @override
  String get communityNoRatings => 'Nenhuma avaliação ainda';

  @override
  String get communityNote => 'Observação';

  @override
  String get communityNoteHint =>
      'Ex.: falta 1 Controlador, com mic, só diversão';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get communityOpenReviews => 'Ver avaliações';

  @override
  String get communityOutOfRange => 'Fora da faixa de ranque';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Código do grupo';

  @override
  String get communityPartyCodeHint => 'Ex.: A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Código do grupo: $code';
  }

  @override
  String get communityPartySize => 'Jogadores no grupo';

  @override
  String get communityPartySizeFromGame => 'Pegar do grupo no jogo';

  @override
  String communityPartySizeValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n jogadores',
      one: '$n jogador',
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
  String get communityPostLfg => 'Publicar anúncio';

  @override
  String get communityPostNotFound =>
      'Esta publicação foi excluída ou ocultada.';

  @override
  String get communityPostTitle => 'Publicação';

  @override
  String get communityPosted => 'Publicado!';

  @override
  String get communityPublish => 'Publicar';

  @override
  String get communityPublishing => 'Publicando…';

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
  String get communityRankRange => 'Faixa de ranque';

  @override
  String get communityRankRangeInvalid =>
      'O ranque mínimo não pode ser maior que o ranque máximo.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Posição $n: $name';
  }

  @override
  String get communityRankTo => 'Até';

  @override
  String get communityRateLimitedTitle => 'Aguarde um pouco';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString avaliações',
      one: '$nString avaliação',
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
      other: '$nString avaliações',
      one: '$nString avaliação',
    );
    return '$avg · $_temp0';
  }

  @override
  String get communityRatingWordsItem0 => 'Ruim';

  @override
  String get communityRatingWordsItem1 => 'Fraca';

  @override
  String get communityRatingWordsItem2 => 'Boa';

  @override
  String get communityRatingWordsItem3 => 'Linda';

  @override
  String get communityRatingWordsItem4 => 'Obra-prima';

  @override
  String get communityRefreshList => 'Atualizar';

  @override
  String get communityRegion => 'Região';

  @override
  String get communityRemoveAttachment => 'Remover anexo';

  @override
  String get communityRemoveLfg => 'Remover anúncio';

  @override
  String get communityRemoveLfgBody =>
      'Outras pessoas não verão mais este anúncio.';

  @override
  String get communityRemoveLfgTitle => 'Remover anúncio de grupo?';

  @override
  String get communityRemovePhoto => 'Remover foto';

  @override
  String get communityReport => 'Denunciar';

  @override
  String get communityReportConfirmBody =>
      'Conteúdo denunciado por muitas pessoas será ocultado da Comunidade.';

  @override
  String get communityReportConfirmTitle => 'Enviar denúncia?';

  @override
  String get communityReportPrompt =>
      'Por que você está denunciando este conteúdo?';

  @override
  String get communityReportReasonsSpam => 'Spam ou propaganda';

  @override
  String get communityReportReasonsHarassment => 'Assédio, ofensas';

  @override
  String get communityReportReasonsInappropriate => 'Conteúdo inadequado';

  @override
  String get communityReportReasonsScam => 'Golpe, compra e venda de contas';

  @override
  String get communityReportReasonsOther => 'Outro motivo';

  @override
  String get communityReportTitle => 'Denunciar conteúdo';

  @override
  String get communityReported => 'Obrigado! Sua denúncia foi enviada.';

  @override
  String get communityReviewDeleted => 'Avaliação excluída.';

  @override
  String get communityReviewHint =>
      'Conte o que você acha desta skin (opcional)';

  @override
  String get communityReviewSaved => 'Avaliação salva!';

  @override
  String get communityReviewTitle => 'Avaliar skin';

  @override
  String get communityReviewsEmptyBody =>
      'Nenhuma avaliação ainda — seja o primeiro!';

  @override
  String get communityReviewsEmptyTitle => 'Nenhuma avaliação ainda';

  @override
  String communityReviewsHeader(String n) {
    return 'Avaliações · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'A Riot está com problemas';

  @override
  String get communityRoleFlex => 'Flexível';

  @override
  String get communityRoles => 'Funções procuradas';

  @override
  String get communitySaveReview => 'Salvar avaliação';

  @override
  String get communityScopeCountry => 'Seu país';

  @override
  String get communityScopeGlobal => 'Internacional';

  @override
  String get communityScopeRegion => 'Região';

  @override
  String get communitySectionFeed => 'Feed';

  @override
  String get communitySectionLfg => 'Parceiros';

  @override
  String get communitySectionSkins => 'Top skins';

  @override
  String get communitySend => 'Enviar';

  @override
  String get communitySendComment => 'Enviar comentário';

  @override
  String get communityShareNightMarketHint =>
      'Mostre seu Mercado Noturno para todo mundo';

  @override
  String communitySharePostTitle(String name) {
    return 'Publicação de $name no ValHub';
  }

  @override
  String get communityShareStore => 'Mostrar na Comunidade';

  @override
  String get communityShareStoreHint =>
      'Mostre sua loja de hoje para todo mundo';

  @override
  String get communityShowOriginal => 'Ver original';

  @override
  String get communityShowTranslation => 'Ver tradução';

  @override
  String get communitySignInToReview =>
      'Adicione uma conta Riot para avaliar skins.';

  @override
  String get communitySkinNotFound => 'Skin não encontrada.';

  @override
  String get communitySlots => 'Jogadores procurados';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'só restam $max vagas',
      one: 'só resta $max vaga',
    );
    return 'O grupo tem no máximo 5 jogadores: $_temp0.';
  }

  @override
  String communitySlotsWanted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Procura $n jogadores',
      one: 'Procura $n jogador',
    );
    return '$_temp0';
  }

  @override
  String get communitySortHelpful => 'Mais úteis';

  @override
  String get communitySortNewest => 'Mais recentes';

  @override
  String get communitySortRating => 'Melhor avaliadas';

  @override
  String get communitySortReviews => 'Mais avaliadas';

  @override
  String get communitySortVotes => 'Mais curtidas';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n estrelas',
      one: '$n estrela',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg de 5 estrelas';
  }

  @override
  String get communityStatusFull => 'Grupo cheio';

  @override
  String get communityStatusInGame => 'Em partida';

  @override
  String get communityStatusOpen => 'Procurando';

  @override
  String communityStoreOf(String date) {
    return 'Loja de $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Toque nas estrelas para avaliar esta skin';

  @override
  String get communityTitle => 'Comunidade';

  @override
  String communityTooLong(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Máximo de $max caracteres.',
      one: 'Máximo de $max caractere.',
    );
    return '$_temp0';
  }

  @override
  String get communityTranslate => 'Traduzir com o Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Para traduzir de $from para $to, o ValHub precisa baixar um pacote de idioma do Google (cerca de $size). O download é feito uma vez só; o conteúdo é traduzido inteiramente no seu aparelho e não é enviado a nenhum servidor.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'Baixar pacote de tradução no aparelho?';

  @override
  String get communityTranslateFailed =>
      'Não foi possível traduzir. Tente de novo.';

  @override
  String get communityTranslatedByGoogle => 'Tradução automática do Google';

  @override
  String get communityTranslating => 'Traduzindo…';

  @override
  String get communityTrendingTitle => 'Skins favoritas no mundo';

  @override
  String get communityUnavailableBody =>
      'Não foi possível conectar à Comunidade ValHub. Tente de novo em alguns minutos.';

  @override
  String get communityUnavailableTitle => 'Sem conexão com a Comunidade';

  @override
  String get communityUnhideAuthor => 'Mostrar / desbloquear';

  @override
  String get communityUnknownPlayer => 'Jogador';

  @override
  String get communityUnlike => 'Descurtir';

  @override
  String get communityUnvote => 'Remover curtida';

  @override
  String get communityVote => 'Curtir esta skin';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString curtidas',
      one: '$nString curtida',
    );
    return '$_temp0';
  }

  @override
  String get communityWithdrawConfirm => 'Retirar';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'O ValHub vai parar de usar a Comunidade com $riotId: a conexão com a Comunidade neste dispositivo será removida e você voltará ao modo de visualização anônima.\n\nPublicações, comentários, avaliações, votos e anúncios de grupo já publicados continuam na Comunidade e mostram seu Riot ID até você excluí-los um por um ou escolher “Excluir meus dados da Comunidade”. Você pode participar de novo a qualquer momento.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Retirar consentimento?';

  @override
  String get communityWithdrawSubtitle =>
      'Pare de usar a Comunidade com esta conta. As publicações feitas continuam lá.';

  @override
  String get communityWithdrawTitle => 'Retirar consentimento';

  @override
  String get communityWriteFirstReview => 'Escreva a primeira avaliação';

  @override
  String get communityYou => 'Você';

  @override
  String get communityYourCountry => 'Seu país';

  @override
  String get communityYourReview => 'Sua avaliação';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Você: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'Seleção de agentes';

  @override
  String get liveGameAnonymous => 'Anônimo';

  @override
  String get liveGameAutoRefreshNote =>
      'Atualiza sozinho quando houver partida.';

  @override
  String get liveGameCurrentGame => 'Partida atual';

  @override
  String get liveGameEmptyTeam => 'Nenhum jogador ainda.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'A equipe inimiga aparece quando a partida começar.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Inimigos confirmados: $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'Os dados ao vivo desta partida não incluem abates/mortes/assistências. O placar aparece quando a Riot publicar os dados após a partida.';

  @override
  String get liveGameFinalScoreboard => 'Placar final';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'No saguão';

  @override
  String get liveGameInMatch => 'Em partida';

  @override
  String get liveGameInQueue => 'Na fila';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'Na fila · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Nível $n';
  }

  @override
  String get liveGameLiveScore => 'Placar ao vivo';

  @override
  String get liveGameLoadoutFromAgentSelect => 'Loadout da seleção de agentes';

  @override
  String get liveGameLoadoutFromMatch => 'Loadout nesta partida';

  @override
  String get liveGameLobbyHint =>
      'Quando a partida for encontrada, o ValHub mostra as equipes e o ranque de todos.';

  @override
  String get liveGameLockedTag => 'Confirmado';

  @override
  String get liveGameMatchPendingHint =>
      'O ValHub vai tentar de novo sozinho. O placar costuma sair em cerca de um minuto.';

  @override
  String get liveGameNoAgentYet => 'Agente não escolhido';

  @override
  String get liveGameNoLoadout =>
      'Não há informações de loadout deste jogador.';

  @override
  String get liveGameNotInGame => 'Fora de partida';

  @override
  String get liveGameNotInGameHint =>
      'Abra o VALORANT e entre na fila — os detalhes da partida aparecem aqui quando você chegar à seleção de agentes.';

  @override
  String get liveGameNotInGameTitle => 'Você não está em nenhuma partida';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Ver loadout de $name';
  }

  @override
  String get liveGameOpenParty => 'Abrir grupo e fila';

  @override
  String get liveGameParty => 'Grupo';

  @override
  String liveGamePeak(String rank) {
    return 'Mais alto: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Loadout de $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Loadout';

  @override
  String get liveGameQueueHint =>
      'Deixe o app aberto — os detalhes aparecem assim que a partida for encontrada.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Sair da partida pode gerar penalidades (perda de RR, bloqueio de fila). Quer sair mesmo assim?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Sair na seleção de agentes (dodge) pode gerar penalidades (perda de RR, bloqueio de fila). Quer sair mesmo assim?';

  @override
  String get liveGameQuitConfirmTitle => 'Sair da partida?';

  @override
  String get liveGameQuitDone => 'Você saiu da partida.';

  @override
  String get liveGameQuitFailed => 'Não foi possível sair da partida.';

  @override
  String get liveGameQuitMatch => 'Sair da partida';

  @override
  String get liveGameQuitMatchChanged =>
      'A partida mudou de fase enquanto você confirmava. Você não saiu; tente de novo.';

  @override
  String get liveGameRankUnavailable => 'Ranque desconhecido';

  @override
  String get liveGameRefresh => 'Atualizar';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Atualiza em $seconds segundos',
      one: 'Atualiza em $seconds segundo',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'Atualizar agora';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'Detalhes da partida';

  @override
  String get liveGameSprays => 'Sprays';

  @override
  String get liveGameStatusAgentSelect => 'Seleção de agentes';

  @override
  String get liveGameStatusEnded => 'Encerrada';

  @override
  String get liveGameStatusInProgress => 'Em andamento';

  @override
  String get liveGameStatusUnavailable =>
      'Não foi possível atualizar o status da partida';

  @override
  String get liveGameTabAllPlayers => 'Jogadores';

  @override
  String get liveGameTabEnemyTeam => 'Inimigos';

  @override
  String get liveGameTabYourTeam => 'Sua equipe';

  @override
  String liveGameTimeLeft(String t) {
    return 'Restam $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Ver detalhes da partida';

  @override
  String get liveGameWeapons => 'Armas';

  @override
  String get liveGameYou => 'VOCÊ';

  @override
  String liveGameYouHover(String agent) {
    return 'Você está selecionando $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Você confirmou $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Escolha e confirme seu agente no VALORANT. O ValHub só mostra o tempo restante e o seu time.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins vitórias',
      one: '$wins vitória',
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
      other: ' – $unknown partidas sem resultado conhecido',
      one: ' – $unknown partida sem resultado conhecido',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'horário do dispositivo ($offset)';
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
      'yes': ' com $weapon',
      'other': '',
    });
    return '$killer abateu $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 dias',
      'days7': '7 dias',
      'other': 'Tudo',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Agentes',
      'maps': 'Mapas',
      'queues': 'Modos',
      'sides': 'Ataque / Defesa',
      'trend': 'Tendência',
      'other': 'Modos',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Todos os modos';

  @override
  String get profileAbility => 'Habilidade';

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
  String get profileAcsHint => 'Pontuação média de combate';

  @override
  String profileActRecord(int wins, int games, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins vitórias',
      one: '$wins vitória',
    );
    String _temp1 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games partidas',
      one: '$games partida',
    );
    return 'Este ato: $_temp0 / $_temp1 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Todos os jogadores';

  @override
  String get profileAlreadyReached => 'Você já alcançou este ranque.';

  @override
  String get profileAtCurrentForm => 'Com o desempenho atual';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Com o desempenho atual ($gain / $loss por partida)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n vitórias seguidas',
      one: '$n vitória seguida',
    );
    return 'Melhor caso: $_temp0';
  }

  @override
  String get profileByWinRateTitle => 'Por taxa de vitória';

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
  String get profileCurrentRank => 'Atual';

  @override
  String get profileDailyRrEmpty =>
      'Nenhuma partida competitiva salva neste dispositivo ainda.';

  @override
  String get profileDailyRrFootnote =>
      'O histórico de RR fica salvo no seu dispositivo, inclusive partidas que a Riot não mostra mais.';

  @override
  String get profileDailyRrTitle => 'RR por dia';

  @override
  String profileDayBoundary(String zone) {
    return 'Dias contados pelo $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dias com partidas',
      one: '$n dia com partidas',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'Todas as partidas foram exibidas';

  @override
  String get profileEnemyTeam => 'Equipe inimiga';

  @override
  String get profileFallDamage => 'Dano de queda';

  @override
  String get profileFilterAll => 'Tudo';

  @override
  String get profileFirstBloods => 'Primeiros abates';

  @override
  String get profileFirstDeaths => 'Primeiras mortes';

  @override
  String get profileFirstHalf => '1º tempo';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS e HS% só contam nos modos por rodadas.';

  @override
  String profileFormPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n partidas da lista ainda não foram carregadas para o cálculo.',
      one: '$n partida da lista ainda não foi carregada para o cálculo.',
    );
    return '$_temp0';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR e HS% contam só $roundGames/$games partidas por rodadas';
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
      other: '$w vitórias',
      one: '$w vitória',
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
  String get profileFriendsRow => 'Amigos e chat';

  @override
  String get profileHideKills => 'Ocultar abates';

  @override
  String get profileHitBody => 'Corpo';

  @override
  String get profileHitDistribution => 'Distribuição de acertos';

  @override
  String get profileHitHead => 'Cabeça';

  @override
  String get profileHitLegs => 'Pernas';

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
      'Porcentagem de rodadas em que você abateu, deu assistência, sobreviveu ou foi vingado por um aliado';

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
      other: 'Últimos $n dias',
      one: 'Último $n dia',
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
    return 'Ranking #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Nível $n';
  }

  @override
  String get profileLevelHidden => 'Nível oculto';

  @override
  String profileLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n derrotas',
      one: '$n derrota',
    );
    return 'Sequência de $_temp0';
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
  String get profileMatchDetailTitle => 'Detalhes da partida';

  @override
  String get profileMatchHistory => 'Histórico';

  @override
  String get profileMatchUnavailable => 'Não foi possível carregar a partida';

  @override
  String get profileMatchesNeeded => 'Partidas necessárias';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Nunca ranqueado';

  @override
  String get profileNoKillsInRound => 'Sem informações de abates nesta rodada.';

  @override
  String get profileNoMatches => 'Nenhuma partida ainda.';

  @override
  String get profileNoMatchesMap =>
      'Nenhuma partida neste mapa entre as partidas carregadas.';

  @override
  String get profileNoMatchesQueue => 'Nenhuma partida neste modo.';

  @override
  String get profileNoPlayers => 'Sem informações dos jogadores desta partida.';

  @override
  String get profileNoRounds => 'Sem informações das rodadas desta partida.';

  @override
  String get profileOvertime => 'Prorrogação';

  @override
  String get profilePlayHubTitle => 'Partida e grupo';

  @override
  String get profilePeakRank => 'Mais alto';

  @override
  String get profilePerformanceAttack => 'Ataque';

  @override
  String get profilePerformanceDefense => 'Defesa';

  @override
  String get profilePerformanceEmpty =>
      'Nenhuma partida registrada neste dispositivo ainda. Abra o histórico de partidas para registrar as partidas que você jogou.';

  @override
  String get profilePerformanceNoMatches =>
      'Nenhuma partida no período selecionado.';

  @override
  String profilePerformanceRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n rodadas registradas',
      one: '$n rodada registrada',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSample =>
      'As taxas só aparecem com pelo menos 3 partidas. ACS, ADR, HS% e K/D só contam nos modos por rodadas.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Lado de ataque ou defesa identificado em $known/$total rodadas.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Histórico no dispositivo, desde $date';
  }

  @override
  String get profilePerformanceTitle => 'Desempenho';

  @override
  String profilePlacement(int n) {
    return '$nº lugar';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Spike plantada em $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Perfil do jogador';

  @override
  String get profilePlayerSummary => 'Desempenho';

  @override
  String profileProgressTo(String rank) {
    return 'Progresso até $rank';
  }

  @override
  String get profileProgressToTarget => 'Progresso até o ranque desejado';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Estimativa baseada nas partidas competitivas recentes, sem contar partidas de posicionamento nem a proteção contra rebaixamento.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '≈ $matches partidas para chegar a $rank',
      one: '≈ $matches partida para chegar a $rank',
    );
    return '$_temp0';
  }

  @override
  String get profileRankUpImmortal =>
      'Você já está no Imortal ou acima — este recurso só calcula até Imortal 1.';

  @override
  String get profileRankUpNoForm =>
      'Não há partidas competitivas recentes para estimar seu desempenho.';

  @override
  String get profileRankUpOpen => 'Abrir calculadora de ranque';

  @override
  String get profileRankUpTitle => 'Calculadora de ranque';

  @override
  String get profileRankUpUnranked =>
      'Conclua as partidas de posicionamento para usar a calculadora de ranque.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Placar competitivo';

  @override
  String profileRecentForm(int w, int l) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w vitórias',
      one: '$w vitória',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l derrotas',
      one: '$l derrota',
    );
    return 'Desempenho recente: $_temp0 – $_temp1';
  }

  @override
  String get profileRecentFormTitle => 'Desempenho recente';

  @override
  String get profileRecentMatches => 'Partidas recentes';

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
    return 'Rodada $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n abates',
      one: '$n abate',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'Rodada perdida';

  @override
  String get profileRoundTimeline => 'Linha do tempo das rodadas';

  @override
  String get profileRoundWon => 'Rodada vencida';

  @override
  String get profileRoundsHint => 'Toque em uma rodada para ver cada abate.';

  @override
  String profileRrLeft(String n) {
    return 'Faltam $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'Evolução de RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Placar';

  @override
  String get profileSecondHalf => '2º tempo';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Ver abates';

  @override
  String get profileSideSwitch => 'Troca de lado';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Ranque desejado';

  @override
  String get profileTeamBlue => 'Equipe Azul';

  @override
  String get profileTeamMvp => 'MVP da equipe';

  @override
  String get profileTeamRed => 'Equipe Vermelha';

  @override
  String get profileTitle => 'Perfil';

  @override
  String profileToday(String text) {
    return 'Hoje: $text';
  }

  @override
  String get profileTodayNone => 'Nenhuma partida competitiva hoje';

  @override
  String get profileTruePeakLocal => 'Pelo histórico no dispositivo';

  @override
  String get profileWeekdayShortItem0 => 'Seg';

  @override
  String get profileWeekdayShortItem1 => 'Ter';

  @override
  String get profileWeekdayShortItem2 => 'Qua';

  @override
  String get profileWeekdayShortItem3 => 'Qui';

  @override
  String get profileWeekdayShortItem4 => 'Sex';

  @override
  String get profileWeekdayShortItem5 => 'Sáb';

  @override
  String get profileWeekdayShortItem6 => 'Dom';

  @override
  String get profileWinRate => 'Taxa de vitória';

  @override
  String profileWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n vitórias',
      one: '$n vitória',
    );
    return 'Sequência de $_temp0';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Seu ranque';

  @override
  String get profileYourSummary => 'Seu desempenho';

  @override
  String get profileYourTeam => 'Sua equipe';

  @override
  String get profileYourWinRate => 'Sua taxa de vitória recente';

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
      'Toque em uma barra para abrir a partida.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Média $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'São necessárias pelo menos 2 partidas por rodadas com essa estatística para montar o gráfico.';

  @override
  String get profilePerformanceOpeningsTitle => 'Duelos de abertura';

  @override
  String get profilePerformanceOpeningWin => 'Duelos de abertura vencidos';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Entre as rodadas em que você fez o primeiro abate ou morreu primeiro, a porcentagem em que você fez o abate.';

  @override
  String get profilePerformanceFirstBloodsPerGame =>
      'Primeiros abates por partida';

  @override
  String get profilePerformanceFirstDeathsPerGame =>
      'Primeiras mortes por partida';

  @override
  String get profilePerformanceMultiKillsTitle =>
      'Abates múltiplos em uma rodada';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 abates',
      'k4': '4 abates',
      'ace': 'Ace',
      'other': '2 abates',
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
      other: 'Com base em $nString partidas com dados completos de abates.',
      one: 'Com base em $nString partida com dados completos de abates.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Rodadas vencidas';

  @override
  String get profilePerformanceDrillHint =>
      'Toque em uma linha para ver só esse agente, mapa ou modo.';

  @override
  String get profilePerformanceLoadOlder => 'Analisar partidas antigas';

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
          'O ValHub só analisa partidas abertas neste dispositivo. Cada toque adiciona até $nString partidas mais antigas.',
      one:
          'O ValHub só analisa partidas abertas neste dispositivo. Cada toque adiciona até $nString partida mais antiga.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSearchingOlder =>
      'Procurando partidas mais antigas…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Analisando partidas: $doneString/$totalString…';
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
      other: '$nString partidas adicionadas à análise.',
      one: '$nString partida adicionada à análise.',
      zero: 'Nenhuma partida nova para adicionar.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'A Riot não guarda mais partidas antigas.';

  @override
  String get profileEconomyTitle => 'Economia do seu time';

  @override
  String get profileEconomyHint =>
      'Tipo de compra pelo valor total do equipamento do seu time no início da rodada (convenção do vlr.gg para 5 jogadores): Eco abaixo de 5.000, Semi-eco abaixo de 10.000, Semi-buy abaixo de 20.000, Full buy a partir de 20.000 créditos. A primeira rodada de cada metade é Pistol.';

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

    return 'Vencidas $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      'Seu parceiro de VALORANT: loja diária, wishlist, ranque, partidas, várias contas e uma comunidade de jogadores, direto no seu dispositivo.';

  @override
  String get legalBackToTop => 'Voltar ao topo';

  @override
  String get legalConsentAnd => ' e a ';

  @override
  String get legalConsentPrefix => 'Ao continuar, você concorda com os ';

  @override
  String get legalConsentPrivacy => 'Política de Privacidade';

  @override
  String get legalConsentSuffix => ' do ValHub.';

  @override
  String get legalConsentTerms => 'Termos de Uso';

  @override
  String get legalContact => 'Contato';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'CONTATO';

  @override
  String legalEffectiveFrom(String date) {
    return 'Em vigor desde $date';
  }

  @override
  String get legalLegalHeader => 'INFORMAÇÕES LEGAIS';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Todos os direitos reservados.';

  @override
  String get legalThirdPartyLicenses => 'Software de terceiros';

  @override
  String get legalThirdPartyLicensesBody =>
      'Licenças dos softwares de código aberto usados pelo ValHub';

  @override
  String get legalTocTitle => 'ÍNDICE';

  @override
  String legalVersion(String version) {
    return 'Versão $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Este documento está sendo exibido em $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Não foi possível ler o documento legal. Tente de novo ou entre em contato com o suporte.';

  @override
  String get legalTranslationNotice =>
      'Esta tradução é fornecida para sua conveniência. Em caso de divergência, prevalece a versão em vietnamita.';

  @override
  String get settingsUiLanguageTitle => 'Idioma do app';

  @override
  String get settingsLanguageFollowDevice => 'Igual ao dispositivo';

  @override
  String get settingsLanguageSaveFailed =>
      'Não foi possível salvar o idioma. Tente de novo.';

  @override
  String get settingsGeoCountry => 'País';

  @override
  String get settingsGeoSearchCountry => 'Buscar nome ou código do país';

  @override
  String get settingsGeoSupportedOnly => 'Só locais com suporte confirmado';

  @override
  String get settingsGeoUnknown => 'Suporte não confirmado';

  @override
  String get settingsGeoRestricted => 'Restrito';

  @override
  String get settingsGeoSeparate => 'Serviço separado';

  @override
  String get settingsGeoAvailable => 'Com suporte';

  @override
  String get settingsGeoNotApplicable => 'Não se aplica';

  @override
  String get settingsGeoConnection => 'Conexão com a Riot';

  @override
  String get settingsGeoChooseRegion => 'Escolher região';

  @override
  String get settingsGeoAuto => 'Automático pela conta';

  @override
  String get settingsGeoManual => 'Escolher manualmente';

  @override
  String get settingsGeoNoRegion => 'Região da Riot não identificada';

  @override
  String get settingsGeoManualWarning =>
      'Esta opção só muda o servidor ao qual o ValHub se conecta. Ela não transfere a região da sua conta Riot. O ValHub vai testar a conexão antes de salvar.';

  @override
  String get settingsGeoConnectionSaved => 'Conexão salva';

  @override
  String get settingsGeoValidationFailed =>
      'A conta não foi confirmada neste servidor. Escolha a região de novo.';

  @override
  String get settingsGeoHintOnly =>
      'O país serve só para consultas e sugestões. A região de conexão segue sua conta Riot.';

  @override
  String get settingsGeoSave => 'Testar e salvar';

  @override
  String get settingsGeoCancel => 'Cancelar';

  @override
  String get settingsGeoLoading => 'Testando a conexão…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Esta opção é usada para nomes de países, sugestões e preços estimados em VP. O servidor de conexão e o país da conta na Comunidade continuam definidos pela Riot.';

  @override
  String get settingsGeoCountryAutomatic =>
      'Usar o país da conta ou do dispositivo';

  @override
  String get settingsGeoSaveFailed =>
      'Não foi possível salvar sua escolha. Tente de novo.';

  @override
  String get settingsGeoAllRegions => 'Todas as regiões';

  @override
  String get settingsGeoSuggestions => 'Sugestões';

  @override
  String get settingsGeoNoCountries => 'Nenhum país corresponde ao filtro.';

  @override
  String get settingsGeoActiveCountries => 'Com atividade';

  @override
  String get settingsGeoAllCountries => 'Todos os países';

  @override
  String get settingsGeoActivityUnavailable =>
      'Não foi possível carregar a atividade dos países. Você ainda pode escolher em Todos os países.';

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
    return 'Você escolheu $manual, mas a Riot identifica sua conta em $detected. Continuar testando esta conexão?';
  }

  @override
  String get settingsGeoUnverified =>
      'Não foi possível confirmar a conexão porque o servidor ou a rede está com problemas. Salvar esta escolha e tentar de novo depois?';

  @override
  String get settingsGeoContinue => 'Continuar';

  @override
  String settingsGeoMismatch(String region) {
    return 'A conexão manual é diferente da região da Riot: $region. Quer usar a região automática?';
  }

  @override
  String get settingsGeoUseAuto => 'Usar automático';

  @override
  String get settingsGeoKeepManual => 'Manter manual';

  @override
  String get settingsGeoReviewConnection => 'Ver conexão';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Último teste: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Testar de novo';

  @override
  String get settingsPlatformMobile => 'Celular';

  @override
  String get settingsPlatformOther => 'Outra plataforma';

  @override
  String get settingsContentLanguageFollowApp => 'Igual ao idioma do app';

  @override
  String get settingsContentLanguageHint =>
      'Escolha o idioma dos nomes dos itens. Isso não muda o idioma do app nem o servidor da Riot.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Idioma: $language.';
  }

  @override
  String get settingsAboutHeader => 'INFORMAÇÕES';

  @override
  String get settingsAboutRowSubtitle =>
      'Privacidade, termos, direitos autorais e contato';

  @override
  String get settingsAboutTitle => 'Sobre e informações legais';

  @override
  String get settingsAppHeader => 'AVANÇADO';

  @override
  String get settingsAppearanceHeader => 'APARÊNCIA';

  @override
  String settingsBuildNumber(String build) {
    return 'Compilação $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return '$size liberados';
  }

  @override
  String get settingsClearCache => 'Limpar dados temporários';

  @override
  String get settingsClearCacheFailed =>
      'Não foi possível limpar os dados temporários. Tente de novo.';

  @override
  String get settingsClearCacheSubtitle =>
      'Imagens e dados baixados no aparelho, incluindo relatórios de erros registrados';

  @override
  String get settingsExportLog => 'Enviar relatório de erros ao ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Ainda não há nada para enviar. Use o app por um tempo e tente de novo.';

  @override
  String get settingsExportLogSubtitle =>
      'O relatório de erros não contém sua senha nem seus dados de login da Riot.';

  @override
  String get settingsFeedback => 'Enviar sugestões ao ValHub';

  @override
  String get settingsFeedbackSubtitle =>
      'Abrir a página de sugestões do ValHub';

  @override
  String get settingsItemLanguageEn => 'Inglês';

  @override
  String get settingsItemLanguageLabel => 'Nome dos itens';

  @override
  String get settingsItemLanguagePickerTitle => 'Idioma dos nomes dos itens';

  @override
  String get settingsItemLanguageVi => 'Vietnamita';

  @override
  String get settingsLinkOpenFailed =>
      'Não foi possível abrir o link. Tente de novo.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Relatório de erros';
  }

  @override
  String get settingsLogShareFailed =>
      'Não foi possível enviar o relatório de erros. Tente de novo.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Quando o Mercado Noturno abrir';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Lembra você de revelar as ofertas do Mercado Noturno';

  @override
  String get settingsNotifPermissionMissing =>
      'O app ainda não tem permissão para enviar notificações.';

  @override
  String get settingsNotifStoreReset => 'Quando a loja for atualizada';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'Diariamente às $time';
  }

  @override
  String get settingsNotifWishlist => 'Quando uma skin da wishlist aparecer';

  @override
  String get settingsNotifWishlistSubtitle =>
      'Verifica a loja de todas as contas, mesmo com o app fechado';

  @override
  String get settingsNotificationsHeader => 'NOTIFICAÇÕES';

  @override
  String get settingsOptionAutoOpenLiveGame =>
      'Abrir detalhes da partida automaticamente';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Abre o painel da partida atual assim que a partida for encontrada';

  @override
  String get settingsOptionOwnPrice => 'Preço do seu pacote de VP';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Não informado — usa a tabela de preços da região, se houver';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Plataforma';

  @override
  String get settingsOptionShowLiveScore => 'Mostrar placar ao vivo';

  @override
  String get settingsOptionShowPeakRank =>
      'Mostrar ranque mais alto nos detalhes da partida';

  @override
  String get settingsOptionShowPrice => 'Mostrar preço convertido estimado';

  @override
  String get settingsOptionShowPriceInfo =>
      'Como o preço convertido é calculado';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Ao lado do preço em VP, por exemplo $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Ainda não há uma tabela de preços verificada para sua região — insira o preço do seu pacote de VP.';

  @override
  String get settingsOptionsHeader => 'OPÇÕES';

  @override
  String get settingsPhaseComplete => 'Concluída';

  @override
  String get settingsPhaseInProgress => 'Em andamento';

  @override
  String get settingsPhaseScheduled => 'Agendada';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Vale para $account';
  }

  @override
  String get settingsPlatformHint =>
      'Escolha PC, PlayStation ou Xbox conforme onde você joga para ver o histórico de partidas certo.';

  @override
  String get settingsPlatformPickerTitle => 'Escolher plataforma';

  @override
  String get settingsPrimingBody =>
      'Ative as notificações para saber quando a loja for atualizada e quando uma skin da wishlist aparecer.';

  @override
  String get settingsPrimingEnable => 'Ativar notificações';

  @override
  String get settingsPrimingFootnote =>
      'Você pode ativar ou desativar cada tipo de notificação a qualquer momento nas Configurações.';

  @override
  String get settingsPrimingLater => 'Mais tarde';

  @override
  String get settingsPrimingPointNightMarket =>
      'Saiba quando o Mercado Noturno abrir';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Para revelar as ofertas antes que expirem';

  @override
  String get settingsPrimingPointStore =>
      'Aviso quando a loja diária for atualizada';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Aviso depois que a loja da conta for atualizada';

  @override
  String get settingsPrimingPointWishlist =>
      'Alerta quando a skin que você quer aparecer';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Verifica a loja de todas as contas, mesmo com o app fechado';

  @override
  String get settingsPrimingTitle => 'Não perca a skin que você quer';

  @override
  String settingsRemovedAccount(String account) {
    return 'Conta $account removida';
  }

  @override
  String get settingsServerStatus => 'Status dos servidores';

  @override
  String get settingsServerStatusMaintenance => 'Em manutenção';

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
      'Manutenções e problemas do VALORANT por servidor';

  @override
  String get settingsSessionLogTitle => 'Relatório de erros do ValHub';

  @override
  String get settingsSeverityCritical => 'Crítico';

  @override
  String get settingsSeverityInfo => 'Informação';

  @override
  String get settingsSeverityWarning => 'Alerta';

  @override
  String get settingsSignedOutAll => 'Você saiu de todas as contas';

  @override
  String get settingsStatusAllGood => 'Servidores funcionando normalmente';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'Nenhum problema ou manutenção no servidor $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Recolher';

  @override
  String get settingsStatusIssues => 'A Riot está resolvendo um problema';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Este servidor tem $n avisos de problema.',
      one: 'Este servidor tem $n aviso de problema.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'Problema';

  @override
  String get settingsStatusKindMaintenance => 'Manutenção';

  @override
  String get settingsStatusMaintenanceNow => 'Servidores em manutenção';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Talvez você não consiga entrar no jogo, e o ValHub pode não conseguir carregar informações por enquanto.';

  @override
  String settingsStatusMoreUpdates(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ver mais $n atualizações',
      one: 'Ver mais $n atualização',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusScheduled => 'Manutenção em breve';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n manutenções agendadas anunciadas pela Riot.',
      one: '$n manutenção agendada anunciada pela Riot.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusSourceNote =>
      'Fonte: página oficial de status da Riot Games. Horários no fuso do dispositivo.';

  @override
  String settingsStatusStarted(String when) {
    return 'Início: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Atualizado: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'ATUALIZAÇÕES DA RIOT';

  @override
  String get settingsSupportHeader => 'SUPORTE';

  @override
  String settingsSwitchedTo(String account) {
    return 'Você trocou para $account';
  }

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemePickerTitle => 'Escolher tema';

  @override
  String get settingsThemeSystem => 'Igual ao sistema';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Ranque, histórico e partida em andamento';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR de cada partida, ranque dos adversários';

  @override
  String get settingsWelcomeBulletStore =>
      'Loja diária, Mercado Noturno e pacotes';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Veja preços, raridade e a contagem até a renovação';

  @override
  String get settingsWelcomeBulletWishlist => 'Wishlist e notificações';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Aviso quando a skin que você quer chegar à loja';

  @override
  String get settingsWelcomeFootnote =>
      'Você entra pela página oficial da Riot. O ValHub só salva sua senha se você escolher salvar os dados de login.';

  @override
  String get settingsWelcomeKicker => 'PARCEIRO DE VALORANT';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (avaliações: $count) · ',
      'other': '',
    });
    return 'Comunidade: ${_temp0}curtidas: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'Adicionar à wishlist';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'Na loja de: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      daily,
      locale: localeName,
      other: '$daily vezes na loja diária',
      one: '$daily vez na loja diária',
    );
    String _temp1 = intl.Intl.pluralLogic(
      night,
      locale: localeName,
      other: '$night Mercados Noturnos',
      one: '$night Mercado Noturno',
    );
    return 'Na sua loja: $_temp0, $_temp1. Só conta dados deste dispositivo, registrados desde $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'Apagar histórico da loja';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Apagar todos os dias de loja registrados para esta conta neste dispositivo?';

  @override
  String get skinDetailInWishlist => 'Já está na wishlist';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Bloqueado';

  @override
  String get skinDetailMute => 'Desativar som';

  @override
  String get skinDetailNotFound => 'Skin não encontrada.';

  @override
  String get skinDetailOwned => 'Obtida';

  @override
  String get skinDetailPause => 'Pausar';

  @override
  String get skinDetailPlay => 'Reproduzir';

  @override
  String get skinDetailPlayVideo => 'Ver vídeo';

  @override
  String get skinDetailRemoveFromWishlist => 'Remover da wishlist';

  @override
  String get skinDetailTitle => 'Detalhes da skin';

  @override
  String get skinDetailUnmute => 'Ativar som';

  @override
  String get skinDetailUpgrades => 'Melhorias';

  @override
  String get skinDetailVariants => 'Variantes';

  @override
  String get skinDetailVideoError =>
      'Não foi possível reproduzir o vídeo. Verifique sua conexão e tente de novo.';

  @override
  String get socialPresenceInMatch => 'Em partida';

  @override
  String get socialPresenceAgentSelect => 'Na seleção de agentes';

  @override
  String get socialPresenceQueue => 'Na fila';

  @override
  String get socialPresenceLobby => 'No saguão';

  @override
  String get socialPresenceCustom => 'Em jogo personalizado';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Grupo aberto',
      'other': 'Só convidados',
    });
    return '$size/$max jogadores · $_temp0';
  }

  @override
  String get socialAccept => 'Aceitar';

  @override
  String get socialAcceptInGame => 'Aceite este convite no jogo.';

  @override
  String socialActionFailed(String message) {
    return 'Não foi possível concluir a ação. $message';
  }

  @override
  String get socialAutoRefresh => 'Atualização automática';

  @override
  String get socialAway => 'Ausente';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Sair da fila · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Sair da fila';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'O grupo ainda não pode entrar em $queue: $reason';
  }

  @override
  String get socialChangeQueue => 'Trocar modo';

  @override
  String get socialChatUnavailable => 'O chat está offline.';

  @override
  String get socialCloseParty => 'Fechar grupo';

  @override
  String get socialCodeInvalid => 'O código do grupo só tem letras e números.';

  @override
  String get socialConnecting => 'Conectando ao chat…';

  @override
  String get socialCopyCode => 'Copiar';

  @override
  String get socialCurrentQueue => 'Selecionado';

  @override
  String get socialCustomGameLobby =>
      'O grupo está no saguão de Jogo Personalizado.';

  @override
  String get socialDecline => 'Recusar';

  @override
  String get socialDisableCode => 'Desativar código';

  @override
  String get socialEmptyChat => 'Nenhuma mensagem ainda. Diga oi!';

  @override
  String get socialEmptyChatTitle => 'Comece a conversar';

  @override
  String get socialFailedBadge => 'Não enviada';

  @override
  String get socialFilterAll => 'Todos';

  @override
  String get socialFilterOnline => 'Online';

  @override
  String get socialFilterUnread => 'Não lidas';

  @override
  String get socialFriendsPrivacyNote =>
      'A lista de amigos e as mensagens vêm diretamente da Riot. O ValHub não as guarda em nenhum outro lugar.';

  @override
  String socialFriendsSummary(int total, int online) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total amigos',
      one: '$total amigo',
    );
    return '$_temp0 · $online online';
  }

  @override
  String get socialFriendsTitle => 'Amigos e chat';

  @override
  String get socialGameNotRunningBody =>
      'Grupo e fila só funcionam com o VALORANT aberto no seu computador ou console. Abra o jogo e puxe para baixo para atualizar.';

  @override
  String get socialGameNotRunningTitle =>
      'Abra o VALORANT no computador ou console';

  @override
  String get socialGenerateCode => 'Criar código';

  @override
  String get socialIdleQueue => 'Pronto para entrar na fila';

  @override
  String get socialInMatchBanner =>
      'Você está em uma partida. A fila volta a abrir quando a partida terminar.';

  @override
  String get socialInValorant => 'No VALORANT';

  @override
  String get socialInviteByRiotId => 'Convidar por Riot ID';

  @override
  String get socialInviteByRiotIdHint => 'Convide também quem não é seu amigo';

  @override
  String get socialInviteFriends => 'Convidar amigos';

  @override
  String socialInviteFrom(String name) {
    return 'Convite de $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Convidar $name';
  }

  @override
  String get socialInviteNeedsName =>
      'O Riot ID desta pessoa é desconhecido, então não é possível convidar.';

  @override
  String socialInviteSent(String name) {
    return 'Convite enviado para $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Convidado';
  }

  @override
  String get socialInvitesSection => 'Convites';

  @override
  String get socialJoin => 'Entrar';

  @override
  String get socialJoinConfirmBody =>
      'Você vai sair do grupo atual para entrar no grupo com este código.';

  @override
  String get socialJoinConfirmTitle => 'Entrar em outro grupo?';

  @override
  String get socialJoinSection => 'Entrar em outro grupo';

  @override
  String get socialJoinWithCode => 'Digite o código para entrar';

  @override
  String get socialJoined => 'Você entrou no grupo.';

  @override
  String socialLastOnline(String relative) {
    return 'Ativo $relative';
  }

  @override
  String get socialLeader => 'Líder';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Você vai sair do grupo atual e voltar a um grupo só seu.';

  @override
  String get socialLeaveConfirmTitle => 'Sair do grupo?';

  @override
  String get socialLeaveParty => 'Sair do grupo';

  @override
  String socialLevel(int n) {
    return 'Nível $n';
  }

  @override
  String get socialMatchFound => 'Partida encontrada!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Membros ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Digite uma mensagem…';

  @override
  String get socialMoreActions => 'Mais opções';

  @override
  String get socialNoCode =>
      'Crie um código para seus amigos entrarem rápido no grupo.';

  @override
  String get socialNoCodeMember =>
      'O líder pode criar um código para convidar rápido.';

  @override
  String get socialNoFilterResults => 'Nenhum amigo corresponde a este filtro.';

  @override
  String get socialNoFriends =>
      'Sua lista de amigos da Riot está vazia. Adicione amigos no jogo.';

  @override
  String get socialNoFriendsTitle => 'Nenhum amigo ainda';

  @override
  String get socialNoOnlineFriends => 'Nenhum amigo online no VALORANT agora.';

  @override
  String get socialNoSearchResults => 'Nenhum amigo encontrado.';

  @override
  String get socialNoSearchResultsTitle => 'Nada encontrado';

  @override
  String get socialNotReady => 'Não está pronto';

  @override
  String socialOfflineSection(int n) {
    return 'Offline ($n)';
  }

  @override
  String get socialOfflineStatus => 'Offline';

  @override
  String get socialOnlineMobile => 'Online no celular';

  @override
  String socialOnlineSection(int n) {
    return 'Online ($n)';
  }

  @override
  String get socialOnlineStatus => 'Online';

  @override
  String get socialOnlyLeader =>
      'Só o líder pode trocar o modo e entrar na fila.';

  @override
  String get socialOpenParty => 'Abrir grupo';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Código do grupo';

  @override
  String socialPartyCodeValue(String code) {
    return 'Código do grupo: $code';
  }

  @override
  String get socialPartyInvite => 'Convite para o grupo';

  @override
  String socialPartyOf(int size, int max) {
    return 'Grupo $size/$max';
  }

  @override
  String get socialPartyTitle => 'Grupo e fila';

  @override
  String socialPickQueueSubtitle(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'Grupo de $size jogadores',
      one: 'Grupo de $size jogador',
    );
    return '$_temp0';
  }

  @override
  String get socialPickQueueTitle => 'Escolher modo';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Melhor ping até os servidores de partida';

  @override
  String socialPlayingOther(String game) {
    return 'Jogando $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'Jogando ($n)';
  }

  @override
  String get socialQueueLabel => 'Fila';

  @override
  String get socialQueueLocked =>
      'Não é possível trocar o modo durante a partida.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Máximo de $max jogadores',
      one: 'Máximo de $max jogador',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Não foi possível confirmar o status do jogo. Atualize para usar pronto e fila.';

  @override
  String get socialReady => 'Pronto';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Prontos $ready/$total';
  }

  @override
  String get socialReasonAccountLevel =>
      'um membro não tem o nível de conta necessário';

  @override
  String get socialReasonGeneric => 'o grupo não cumpre os requisitos';

  @override
  String socialReasonPartyTooLarge(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '$max jogadores',
      one: '$max jogador',
    );
    return 'o grupo é grande demais (máximo de $_temp0)';
  }

  @override
  String get socialReasonRankDisparity =>
      'a diferença de ranque é grande demais para o Competitivo';

  @override
  String socialReasonRestricted(String time) {
    return 'o grupo está impedido de entrar na fila (faltam $time)';
  }

  @override
  String get socialReconnecting => 'Conexão com o chat perdida. Reconectando…';

  @override
  String get socialRemoteNote =>
      'As alterações só são enviadas à Riot quando você toca. O ValHub não entra na fila nem confirma agentes por você.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name será removido do seu grupo.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Remover do grupo?';

  @override
  String get socialRemoveMember => 'Remover do grupo';

  @override
  String socialRequestFrom(String name) {
    return '$name quer entrar no grupo';
  }

  @override
  String get socialRequestsSection => 'Pedidos para entrar';

  @override
  String get socialRiotIdFieldHint => 'Nome#TAG';

  @override
  String get socialRiotIdInvalid =>
      'O Riot ID tem um nome (3–16 caracteres), o sinal # e uma tag (3–5 letras ou números).';

  @override
  String get socialSearchHint => 'Buscar por Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'Na fila · $elapsed';
  }

  @override
  String get socialSend => 'Enviar';

  @override
  String get socialSendFailed =>
      'Não foi possível enviar a mensagem. Verifique sua conexão e tente de novo.';

  @override
  String get socialSendInvite => 'Enviar convite';

  @override
  String get socialShareCode => 'Compartilhar';

  @override
  String socialShareCodeText(String code) {
    return 'Entre no meu grupo do VALORANT com o código: $code';
  }

  @override
  String get socialShootingRange => 'No The Range';

  @override
  String get socialShowEveryone => 'Ver todos';

  @override
  String get socialStartQueue => 'Entrar na fila';

  @override
  String get socialSuggestionsItem0 => 'Oi!';

  @override
  String get socialSuggestionsItem1 => 'Bora jogar umas?';

  @override
  String get socialSuggestionsItem2 => 'Entra no meu grupo!';

  @override
  String socialUnread(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mensagens não lidas',
      one: '$n mensagem não lida',
    );
    return '$_temp0';
  }

  @override
  String get socialUnready => 'Cancelar pronto';

  @override
  String get socialViewProfile => 'Ver perfil';

  @override
  String get socialWaitingForConnection =>
      'Conectando… Você poderá enviar mensagens quando a conexão for concluída.';

  @override
  String get socialYou => 'Você';

  @override
  String get socialPartyUnavailable =>
      'Não foi possível sincronizar o grupo. Atualize para tentar de novo.';

  @override
  String get storeAccessoryEmpty =>
      'A loja de acessórios está vazia no momento.';

  @override
  String get storeAccessoryEmptyTitle => 'Nenhum acessório ainda';

  @override
  String storeAccessoryFrom(String contract) {
    return 'De: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Renova em $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Renova às $wall';
  }

  @override
  String get storeAddToWishlist => 'Adicionar à wishlist';

  @override
  String get storeBackToBundles => 'Ver pacotes à venda';

  @override
  String get storeBundleBuySeparateLabel => 'Compra avulsa';

  @override
  String get storeBundleDetailTitle => 'Detalhes do pacote';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Expira às $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Restam $t';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n itens',
      one: '$n item',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'Grátis';

  @override
  String get storeBundleItemsTitle => 'Itens do pacote';

  @override
  String get storeBundleNotFound =>
      'Pacote não encontrado. Ele pode ter expirado.';

  @override
  String get storeBundleNotFoundTitle => 'Pacote expirado';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return '$owned/$total itens obtidos';
  }

  @override
  String get storeBundlePriceLabel => 'Preço do pacote';

  @override
  String get storeBundleSavingsLabel => 'Economia';

  @override
  String get storeBundleWholesaleOnly =>
      'Vendido só como pacote completo, sem compra avulsa.';

  @override
  String get storeBundlesEmpty => 'Nenhum pacote à venda no momento.';

  @override
  String get storeBundlesEmptyTitle => 'Nenhum pacote ainda';

  @override
  String get storeDailyEmpty => 'A loja não tem skins hoje.';

  @override
  String get storeDailyEmptyTitle => 'Loja vazia';

  @override
  String storeDailyResetAt(String time) {
    return 'Renova diariamente às $time';
  }

  @override
  String get storeDailyTotalLabel => 'Total';

  @override
  String get storeNightMarketEmpty => 'Não há Mercado Noturno no momento.';

  @override
  String get storeNightMarketEmptyTitle => 'Mercado Noturno fechado';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Termina às $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Termina em $t';
  }

  @override
  String get storeNightMarketNote =>
      'As ofertas do Mercado Noturno são exclusivas da sua conta e não podem ser renovadas.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Economia total de $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Não revelada';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Obtida';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Obtidas: $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Remover da wishlist';

  @override
  String get storeResetNotificationTitle => 'A loja foi atualizada';

  @override
  String storeResetsIn(String t) {
    return 'Renova em $t';
  }

  @override
  String get storeSegmentAccessories => 'Acessórios';

  @override
  String get storeSegmentBundles => 'Pacotes';

  @override
  String get storeSegmentDaily => 'Diária';

  @override
  String get storeSegmentNightMarket => 'Mercado Noturno';

  @override
  String get storeShareButton => 'Compartilhar';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Loja de hoje';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Mercado Noturno';

  @override
  String get storeShareCardPriceNote =>
      'O preço convertido é só uma estimativa pelo pacote de VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Economia de $vp';
  }

  @override
  String get storeShareCardTagline => 'Seu parceiro de VALORANT';

  @override
  String storeShareCardTotal(String vp) {
    return 'Total: $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Até $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Compartilhar a loja de hoje';

  @override
  String get storeShareFailed =>
      'Não foi possível criar a imagem. Tente de novo.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-loja-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-mercado-noturno-$stamp.png';
  }

  @override
  String get storeShareImage => 'Compartilhar imagem';

  @override
  String get storeShareNightMarketTitle => 'Compartilhar Mercado Noturno';

  @override
  String get storeSharePreparing => 'Carregando imagens das skins…';

  @override
  String get storeShareShowPrice => 'Mostrar preço convertido estimado';

  @override
  String get storeShareShowPriceHint =>
      'Convertido pelo pacote de VP mais vantajoso.';

  @override
  String get storeShareShowRiotId => 'Mostrar Riot ID na imagem';

  @override
  String get storeShareShowRiotIdHint =>
      'Desativado por padrão para proteger sua privacidade.';

  @override
  String get storeShareSubjectDaily => 'Minha loja do VALORANT hoje';

  @override
  String get storeShareSubjectNightMarket => 'Meu Mercado Noturno do VALORANT';

  @override
  String get storeShareSubtitle =>
      'Compartilhe uma imagem da loja com seus amigos pelo app que preferir.';

  @override
  String get storeTitle => 'Loja';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Saldo: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '$n na wishlist';
  }

  @override
  String get storeHistoryTitle => 'Histórico da loja';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString dias',
      one: '$daysString dia',
    );
    return 'Registrado neste dispositivo desde $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'Nenhum dia registrado ainda. O ValHub salva sua loja diária sempre que você abre o app, só neste dispositivo.';

  @override
  String get storeHistoryMostOffered => 'Mais frequentes';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString vezes',
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
      other: 'Mercado Noturno · $countString ofertas',
      one: 'Mercado Noturno · $countString oferta',
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
      other: '$daysString dias registrados neste dispositivo',
      one: '$daysString dia registrado neste dispositivo',
      zero: 'Registro iniciado hoje',
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
      'yes': '$skin está na loja de $account — restam $left.',
      'other': '$skin está na loja de $account.',
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
      'discount': '$skin com $percent% de desconto, por $price ($account).',
      'price': '$skin por apenas $price ($account).',
      'other': '$skin está no Mercado Noturno de $account.',
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
      'yes': '$skin está no pacote $bundle ($account).',
      'other': '$skin está em um pacote à venda ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'Na loja de $account: $names e mais $more skins.',
      one: 'Na loja de $account: $names e mais $more skin.',
      zero: 'Na loja de $account: $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', já está na wishlist',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Adicionar skins';

  @override
  String get wishlistAddToWishlist => 'Adicionar à wishlist';

  @override
  String get wishlistAllWeapons => 'Todas as armas';

  @override
  String get wishlistBrowseCatalog => 'Ver todas as skins';

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
      'Não foi possível carregar a lista de skins. Atualize para tentar de novo.';

  @override
  String get wishlistCatalogEmptyTitle => 'Nenhuma skin ainda';

  @override
  String wishlistCatalogInWishlist(String count) {
    return '$count na wishlist';
  }

  @override
  String get wishlistCatalogSubtitle =>
      'Toque em ♡ para adicionar uma skin à wishlist';

  @override
  String get wishlistCatalogTitle => 'Todas as skins';

  @override
  String get wishlistChooseWeapon => 'Escolher arma';

  @override
  String get wishlistClearFilters => 'Limpar filtros';

  @override
  String get wishlistEmpty =>
      'A wishlist está vazia. Toque em ♡ em qualquer skin para adicionar.';

  @override
  String get wishlistEmptyTitle => 'Nenhuma skin ainda';

  @override
  String wishlistEndsIn(String time) {
    return 'Termina em $time';
  }

  @override
  String get wishlistExcludedRewards => 'Sem contar skins de recompensa';

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
    return 'Filtrando: $_temp0 · $value';
  }

  @override
  String get wishlistNoMatch =>
      'Nenhuma skin encontrada. Remova os filtros para ver mais.';

  @override
  String get wishlistNoMatchTitle => 'Nenhuma skin encontrada';

  @override
  String get wishlistNotifBundleTitle => 'Novo pacote com skin da wishlist';

  @override
  String get wishlistNotifDailyTitle => 'Uma skin da wishlist apareceu!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'O Mercado Noturno tem uma skin que você quer!';

  @override
  String get wishlistNotifPermissionMissing =>
      'O app ainda não tem permissão para enviar notificações.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins da wishlist estão à venda!',
      one: '$count skin da wishlist está à venda!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'Notificações da wishlist';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Para esta conta, mesmo com o app fechado';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Wishlist de $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skins da wishlist estão à venda!',
      one: '$count skin da wishlist está à venda!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Toque na linha destacada para ver a oferta.';

  @override
  String get wishlistOpenSettings => 'Abrir configurações';

  @override
  String get wishlistOwned => 'Obtida';

  @override
  String get wishlistRemoveAction => 'Remover da wishlist';

  @override
  String get wishlistRemoveFromWishlist => 'Remover da wishlist';

  @override
  String wishlistRemoved(String name) {
    return '$name removida da wishlist';
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
  String get wishlistSortName => 'Nome';

  @override
  String get wishlistSortPrice => 'Preço';

  @override
  String get wishlistSortRarity => 'Raridade';

  @override
  String get wishlistSortWeapon => 'Arma';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistTotalValue => 'Valor total da wishlist';

  @override
  String get wishlistUndo => 'Desfazer';

  @override
  String get wishlistViewInStore => 'Ver na loja';

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
      'yes': ', na wishlist',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', na wishlist',
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
      'gain': 'ganhou',
      'other': 'perdeu',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins vitórias',
      one: '$wins vitória',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses derrotas',
      one: '$losses derrota',
    );
    return 'Hoje você $_temp0 $rr RR, $_temp1, $_temp2';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins vitórias',
      one: '$wins vitória',
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
      other: ', $unknown partidas sem resultado conhecido',
      one: ', $unknown partida sem resultado conhecido',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody =>
      'Abra Personalizar Início para mostrar de novo.';

  @override
  String get homeAllHiddenTitle => 'Você ocultou todos os cartões';

  @override
  String get homeCardBattlePass => 'Passe de Batalha';

  @override
  String get homeCardBattlePassDesc =>
      'Nível, XP necessário por dia e missões semanais.';

  @override
  String get homeCardCommunity => 'Comunidade';

  @override
  String get homeCardCommunityDesc =>
      'Parceiros do seu ranque e as skins favoritas da comunidade.';

  @override
  String get homeCardFriends => 'Amigos jogando';

  @override
  String get homeCardFriendsDesc => 'Amigos em partida ou na fila.';

  @override
  String homeCardHidden(String name) {
    return '“$name” oculto';
  }

  @override
  String get homeCardLive => 'Partida atual';

  @override
  String get homeCardLiveDesc =>
      'Aparece quando você está na fila, na seleção de agentes ou em partida.';

  @override
  String get homeCardOtherAccounts => 'Outras contas';

  @override
  String get homeCardOtherAccountsDesc =>
      'Status e wishlist das outras contas.';

  @override
  String get homeCardRank => 'Ranque e desempenho';

  @override
  String get homeCardRankDesc =>
      'Ranque, RR de hoje, sequências e partidas para subir.';

  @override
  String get homeCardServerStatus => 'Status dos servidores';

  @override
  String get homeCardServerStatusDesc =>
      'Só aparece quando há manutenção ou problemas.';

  @override
  String get homeCardStore => 'Loja de hoje';

  @override
  String get homeCardStoreDesc => 'Skins diárias, wishlist e Mercado Noturno.';

  @override
  String get homeCustomize => 'Personalizar Início';

  @override
  String get homeCustomizeHint =>
      'Arraste para reordenar. Desative para ocultar um cartão.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Indo para $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Ativar';

  @override
  String get homeFriendsConsentBody =>
      'Para saber quais amigos estão jogando, o ValHub conecta ao chat da Riot da conta em uso sempre que você abre o Início. Seus amigos verão você online. Você pode desativar em Personalizar Início.';

  @override
  String get homeFriendsConsentDecline => 'Não, ocultar cartão';

  @override
  String get homeFriendsConsentTitle => 'Ver quais amigos estão jogando?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n amigos jogando',
      one: '$n amigo jogando',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'Ver todos';

  @override
  String get homeHideCard => 'Ocultar este cartão';

  @override
  String homeLeaderboard(String pos) {
    return 'Posição $pos no ranking';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Restam $time';
  }

  @override
  String homeLfgNeeds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Procura $n jogadores',
      one: 'Procura $n jogador',
    );
    return '$_temp0';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Parceiros do seu ranque';

  @override
  String get homeLiveAllyLabel => 'Aliados';

  @override
  String get homeLiveEnemyLabel => 'Inimigos';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'Na fila, esperando há $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Aliados $ally, inimigos $enemy';
  }

  @override
  String homeLossStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n derrotas',
      one: '$n derrota',
    );
    return 'Sequência de $_temp0 no Competitivo';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n partidas para chegar a $rank',
      one: '≈ $n partida para chegar a $rank',
    );
    return '$_temp0';
  }

  @override
  String homeMoreActions(String name) {
    return 'Opções de $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Entre novamente para atualizar a loja, o ranque e o Passe de Batalha de $riotId. Você ainda pode ver a versão salva no dispositivo.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Restam $time';
  }

  @override
  String get homeNightMarketNew => 'Novo';

  @override
  String get homeNightMarketTitle => 'Mercado Noturno';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ofertas esperando para serem reveladas',
      one: '$n oferta esperando para ser revelada',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'Nenhuma partida competitiva hoje';

  @override
  String get homeOpenLfg => 'Ver todos os anúncios de grupo';

  @override
  String get homeOpenRanking => 'Ver ranking de skins';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Outras contas ($n)';
  }

  @override
  String homeOtherMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n contas',
      one: '+$n conta',
    );
    return '$_temp0';
  }

  @override
  String get homeOtherWishlistHit => 'Tem skin da wishlist';

  @override
  String homePreviousAct(String rank) {
    return 'Ato anterior: $rank';
  }

  @override
  String get homeQuietBody => 'Puxe para baixo para atualizar.';

  @override
  String get homeQuietTitle => 'Nada novo por aqui';

  @override
  String homeRankToNext(int rr) {
    String _temp0 = intl.Intl.pluralLogic(
      rr,
      locale: localeName,
      other: 'Faltam $rr RR para subir',
      one: 'Falta $rr RR para subir',
    );
    return '$_temp0';
  }

  @override
  String get homeResetLayout => 'Restaurar padrão';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Hoje $value';
  }

  @override
  String get homeStatusDetails => 'Detalhes';

  @override
  String homeStatusIncident(String region) {
    return 'Problema nos servidores · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'Em manutenção · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Manutenção em breve · $region';
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
  String get homeStoreRefreshing => 'Atualizando…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Renova em $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Total: $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Carteira: $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins',
      one: '$n skin',
    );
    return 'Carteira: $vp · dá para comprar até $_temp0';
  }

  @override
  String get homeStoreWishlistHit => 'Tem skin da wishlist!';

  @override
  String homeStoreWishlistHits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skins da wishlist à venda',
      one: '$n skin da wishlist à venda',
    );
    return '$_temp0';
  }

  @override
  String get homeTitle => 'Início';

  @override
  String get homeTrendingTitle => 'Skins favoritas no mundo';

  @override
  String homeTrendingVotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n curtidas',
      one: '$n curtida',
    );
    return '$_temp0';
  }

  @override
  String get homeUndo => 'Desfazer';

  @override
  String homeWinStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n vitórias',
      one: '$n vitória',
    );
    return 'Sequência de $_temp0 no Competitivo';
  }

  @override
  String get homeStoreOutdated =>
      'A loja mudou. O ValHub ainda não conseguiu carregar a nova.';

  @override
  String get communityErrorConsent =>
      'Concorde em compartilhar seu Riot ID com a Comunidade para continuar.';

  @override
  String get communityErrorForbidden =>
      'Você ainda não pode fazer isso. Veja as Diretrizes da comunidade ou entre em contato com o ValHub.';

  @override
  String get communityErrorGeneric => 'Algo deu errado. Tente de novo.';

  @override
  String get communityErrorImageTooLarge =>
      'Imagem grande demais (máximo de 2 MB). Escolha outra.';

  @override
  String get communityErrorImageType => 'Escolha uma imagem JPEG, PNG ou WebP.';

  @override
  String get communityErrorInvalid =>
      'O conteúdo não foi aceito. Revise e tente de novo.';

  @override
  String get communityErrorNetwork =>
      'Não foi possível conectar à Comunidade ValHub. Verifique sua conexão e tente de novo.';

  @override
  String get communityErrorNotFound => 'Este conteúdo não existe mais.';

  @override
  String get communityErrorPickImage =>
      'Não foi possível abrir a galeria de fotos. Tente de novo.';

  @override
  String get communityErrorRateLimited =>
      'A Comunidade está recebendo muitas solicitações. Tente de novo em alguns minutos.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'A Comunidade está recebendo muitas solicitações. Tente de novo em $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'A Riot não conseguiu confirmar sua conta. Entre novamente na sua conta Riot e tente de novo.';

  @override
  String get communityErrorRiotUnavailable =>
      'A Riot está com problemas. Tente de novo em alguns minutos.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'A Riot está com problemas. Tente de novo em $duration.';
  }

  @override
  String get communityErrorServer =>
      'A Comunidade ValHub está com problemas. Tente de novo em alguns minutos.';

  @override
  String get communityErrorStorageFull =>
      'O espaço de fotos da Comunidade está cheio. Você ainda pode publicar, mas sem fotos por enquanto. Tente de novo mais tarde.';

  @override
  String get communityErrorTimeout =>
      'A Comunidade ValHub está demorando para responder. Tente de novo.';

  @override
  String get communityErrorTitle => 'Não concluído';

  @override
  String get communityErrorUnauthorized =>
      'A conexão com a Comunidade expirou. Tente de novo.';

  @override
  String get communityErrorImageQuota =>
      'Você usou todo o espaço para imagens. Apague algumas publicações com imagens e tente de novo.';

  @override
  String get smokePlain => 'Teste de geração de código';

  @override
  String smokeGreeting(String name) {
    return 'Olá, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n itens',
      one: '$n item',
    );
    return '$_temp0';
  }
}
