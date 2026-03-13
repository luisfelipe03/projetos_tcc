// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Habit Flow';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonOk => 'OK';

  @override
  String get commonReset => 'Redefinir';

  @override
  String get commonToday => 'Hoje';

  @override
  String get navHome => 'Início';

  @override
  String get navStats => 'Estatísticas';

  @override
  String get navSettings => 'Configurações';

  @override
  String get onboardingBadgeStudy => 'Estudo';

  @override
  String get onboardingBadgeHealth => 'Saúde';

  @override
  String get onboardingTitleStart => 'Domine sua\n';

  @override
  String get onboardingTitleAccent => 'rotina.';

  @override
  String get onboardingDescription =>
      'Crie hábitos duradouros e acompanhe seu progresso com uma plataforma vibrante pensada para estudantes.';

  @override
  String get onboardingGetStarted => 'Começar';

  @override
  String get onboardingExistingAccount => 'Já tenho uma conta';

  @override
  String get onboardingFooterStudents =>
      'JUNTE-SE A MAIS DE 10 MIL ESTUDANTES HOJE';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authWelcomeSubtitle => 'Vamos continuar sua jornada de hábitos';

  @override
  String get authCreateSubtitle => 'Comece hoje a construir seus hábitos';

  @override
  String get authForgotPassword => 'Esqueceu a senha?';

  @override
  String get authForgotPasswordSoon =>
      'A recuperação de senha estará disponível em breve.';

  @override
  String get authOrContinueWith => 'Ou continue com';

  @override
  String get authTabLogin => 'Entrar';

  @override
  String get authTabSignUp => 'Cadastrar';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authEmailHint => 'aluno@exemplo.com';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authLoginButton => 'Entrar';

  @override
  String get authSignUpButton => 'Cadastrar';

  @override
  String get authGoogleButton => 'Google';

  @override
  String get authTermsPrefix => 'Ao continuar, você concorda com nossos ';

  @override
  String get authTermsService => 'Termos de Serviço';

  @override
  String get authTermsAnd => ' e ';

  @override
  String get authTermsPrivacy => 'Política de Privacidade';

  @override
  String get authTermsSuffix => '.';

  @override
  String get authAccountCreatedSuccess => 'Conta criada com sucesso!';

  @override
  String get authWelcomeBackSuccess => 'Bem-vindo de volta!';

  @override
  String get authGoogleSuccess => 'Login com Google realizado com sucesso!';

  @override
  String get authErrorEmailRequired => 'O e-mail é obrigatório';

  @override
  String get authErrorInvalidEmail => 'Digite um e-mail válido';

  @override
  String get authErrorPasswordRequired => 'A senha é obrigatória';

  @override
  String get authErrorPasswordMinLength =>
      'A senha deve ter pelo menos 6 caracteres';

  @override
  String get authErrorWeakPassword => 'A senha é muito fraca';

  @override
  String get authErrorEmailAlreadyInUse =>
      'Já existe uma conta para este e-mail';

  @override
  String get authErrorOperationNotAllowed =>
      'Este método de login não está habilitado';

  @override
  String get authErrorUserNotFound =>
      'Nenhum usuário encontrado para este e-mail';

  @override
  String get authErrorUserNotFoundCredential =>
      'Nenhum usuário encontrado com esta credencial';

  @override
  String get authErrorWrongPassword => 'Senha incorreta';

  @override
  String get authErrorUserDisabled => 'Esta conta de usuário foi desativada';

  @override
  String get authErrorInvalidCredential => 'E-mail ou senha inválidos';

  @override
  String get authErrorAccountExistsDifferentCredential =>
      'Já existe uma conta com este e-mail usando outra credencial de login';

  @override
  String get authErrorGoogleCredentialMalformed =>
      'A credencial do Google está inválida ou expirou';

  @override
  String get authErrorGoogleDisabled =>
      'O login com Google não está habilitado';

  @override
  String get authErrorUnexpected =>
      'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get homeUserFallback => 'Usuário';

  @override
  String homeGreeting(Object name) {
    return 'Olá, $name';
  }

  @override
  String get homeEmptyTitle => 'Ainda não há hábitos';

  @override
  String get homeEmptySubtitle =>
      'Toque no botão + para criar seu primeiro hábito';

  @override
  String get homeEditHabit => 'Editar hábito';

  @override
  String get homeDeleteHabit => 'Excluir hábito';

  @override
  String get homeHabitDeleted => 'Hábito excluído';

  @override
  String get homeDeleteHabitTitle => 'Excluir hábito';

  @override
  String get homeDeleteHabitMessage =>
      'Tem certeza de que deseja excluir este hábito?';

  @override
  String get dailyProgressTitle => 'Progresso diário';

  @override
  String dailyProgressSummary(int completed, int total) {
    return '$completed de $total hábitos concluídos';
  }

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get statsRangeLast7Days => 'Últimos 7 dias';

  @override
  String get statsRangeLast30Days => 'Últimos 30 dias';

  @override
  String get statsRangeLast90Days => 'Últimos 90 dias';

  @override
  String get statsCompletion => 'Conclusão';

  @override
  String get statsBestStreak => 'Melhor sequência';

  @override
  String get statsCheckIns => 'Check-ins';

  @override
  String statsVsPreviousPeriod(Object delta) {
    return '$delta% vs período anterior';
  }

  @override
  String statsDaysInRow(int days) {
    return '$days dias seguidos';
  }

  @override
  String statsHabitsTracked(int count) {
    return '$count hábitos acompanhados';
  }

  @override
  String get statsCategoryBreakdown => 'Desempenho por categoria';

  @override
  String get statsWeeklyAvg => 'Média semanal';

  @override
  String get statsNoCategoryData => 'Sem dados de categoria neste período';

  @override
  String get statsTopPerforming => 'Melhores hábitos';

  @override
  String get statsViewAll => 'Ver tudo';

  @override
  String get statsTopPerformingEmpty =>
      'Conclua seu primeiro hábito para ver insights de desempenho.';

  @override
  String get statsEmptyTitle => 'Ainda não há hábitos';

  @override
  String get statsEmptySubtitle =>
      'Crie hábitos para desbloquear estatísticas e gráficos de tendência.';

  @override
  String get statsErrorTitle => 'Não foi possível carregar as estatísticas';

  @override
  String get statsErrorSubtitle => 'Puxe para baixo para tentar novamente.';

  @override
  String get statsTryAgain => 'Tentar novamente';

  @override
  String statsCategoryStreak(Object category, int days) {
    return '$category • sequência de $days dias';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAccount => 'CONTA';

  @override
  String get settingsProfile => 'Perfil';

  @override
  String get settingsProfileSubtitle => 'Gerencie seus dados pessoais';

  @override
  String get settingsProfileSoon => 'Tela de perfil em breve';

  @override
  String get settingsPreferences => 'PREFERÊNCIAS';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotificationsDescription =>
      'Ative notificações para receber lembretes dos seus hábitos.';

  @override
  String get settingsEnableNotifications => 'Ativar notificações';

  @override
  String get settingsDarkMode => 'Modo escuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSupport => 'SUPORTE';

  @override
  String get settingsDevelopment => 'DESENVOLVIMENTO';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsAboutContent => 'Habit Flow\nVersão 2.4.0';

  @override
  String get settingsHelpSupport => 'Ajuda e suporte';

  @override
  String get settingsHelpSoon => 'Central de ajuda em breve';

  @override
  String get settingsSeedDatabase => 'Popular dados de teste';

  @override
  String get settingsSeedDatabaseSubtitle =>
      'Cria hábitos falsos e histórico de conclusões';

  @override
  String get settingsSeederInProgress => 'Criando dados falsos...';

  @override
  String settingsSeederSuccess(int habits, int completions) {
    return '$habits hábitos e $completions conclusões criados';
  }

  @override
  String get settingsSeederFailed => 'Não foi possível criar dados falsos';

  @override
  String get settingsChooseLanguage => 'Escolha o idioma';

  @override
  String get settingsLogOut => 'Sair';

  @override
  String get settingsLogoutConfirm =>
      'Tem certeza de que deseja sair da conta?';

  @override
  String get habitFormTitleCreate => 'Novo hábito';

  @override
  String get habitFormTitleEdit => 'Editar hábito';

  @override
  String get habitFormSectionName => 'NOME DO HÁBITO';

  @override
  String get habitFormSectionFrequency => 'FREQUÊNCIA';

  @override
  String get habitFormSectionCategory => 'CATEGORIA';

  @override
  String get habitFormSectionReminder => 'LEMBRETE';

  @override
  String get habitFormSectionColor => 'COR DO HÁBITO';

  @override
  String get habitFormNameHint => 'Yoga matinal';

  @override
  String get habitFormNameRequired => 'Digite um nome para o hábito';

  @override
  String get habitFormRepeatOn => 'Repetir em';

  @override
  String get habitFormWeeklyDaysPrompt =>
      'Em quais dias este hábito deve ser feito?';

  @override
  String get habitFormSaveAction => 'Salvar hábito';

  @override
  String get habitFormUpdateAction => 'Atualizar hábito';

  @override
  String get habitFormCreatedSuccess => 'Hábito criado com sucesso!';

  @override
  String get habitFormUpdatedSuccess => 'Hábito atualizado com sucesso!';

  @override
  String get habitFormWeeklyReminderDaysError =>
      'Selecione pelo menos um dia para lembretes semanais';

  @override
  String get habitFormCreateFailed => 'Não foi possível criar o hábito';

  @override
  String get habitFormUpdateFailed => 'Não foi possível atualizar o hábito';

  @override
  String get habitErrorUnauthenticated =>
      'Você precisa entrar na conta para gerenciar hábitos';

  @override
  String get habitErrorNotFound => 'Hábito não encontrado';

  @override
  String get habitDetailsTitle => 'DETALHES DO HÁBITO';

  @override
  String get habitDetailsCurrentStreak => 'SEQUÊNCIA ATUAL';

  @override
  String habitDetailsStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get habitDetailsThisWeek => 'Esta semana';

  @override
  String get habitDetailsMonthlyOverview => 'Visão mensal';

  @override
  String get habitDetailsCompletionRate => 'Taxa de conclusão';

  @override
  String get habitDetailsTotalDays => 'TOTAL DE DIAS';

  @override
  String get languageOptionEnglish => 'Inglês';

  @override
  String get languageOptionPortuguese => 'Português';

  @override
  String get categoryHealth => 'Saúde';

  @override
  String get categoryPersonal => 'Pessoal';

  @override
  String get categoryStudy => 'Estudo';

  @override
  String get categorySocial => 'Social';

  @override
  String get categoryFinance => 'Finanças';

  @override
  String get frequencyDaily => 'Diário';

  @override
  String get frequencyWeekly => 'Semanal';

  @override
  String get frequencyMonthly => 'Mensal';

  @override
  String get dayMonday => 'Segunda-feira';

  @override
  String get dayTuesday => 'Terça-feira';

  @override
  String get dayWednesday => 'Quarta-feira';

  @override
  String get dayThursday => 'Quinta-feira';

  @override
  String get dayFriday => 'Sexta-feira';

  @override
  String get daySaturday => 'Sábado';

  @override
  String get daySunday => 'Domingo';

  @override
  String get dayShortMonday => 'Seg';

  @override
  String get dayShortTuesday => 'Ter';

  @override
  String get dayShortWednesday => 'Qua';

  @override
  String get dayShortThursday => 'Qui';

  @override
  String get dayShortFriday => 'Sex';

  @override
  String get dayShortSaturday => 'Sáb';

  @override
  String get dayShortSunday => 'Dom';
}
