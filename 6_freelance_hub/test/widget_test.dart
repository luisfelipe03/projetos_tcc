import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:freelance_hub/main.dart';
import 'package:freelance_hub/models/project.dart';
import 'package:freelance_hub/models/user_role.dart';
import 'package:freelance_hub/views/client_dashboard_view.dart';
import 'package:freelance_hub/views/create_project_view.dart';
import 'package:freelance_hub/views/home_view.dart';
import 'package:freelance_hub/views/login_view.dart';
import 'package:freelance_hub/views/my_contracts_view.dart';
import 'package:freelance_hub/views/my_proposals_view.dart';
import 'package:freelance_hub/views/onboarding_view.dart';
import 'package:freelance_hub/views/project_detail_view.dart';
import 'package:freelance_hub/views/received_proposals_view.dart';
import 'package:freelance_hub/views/send_proposal_view.dart';
import 'package:freelance_hub/views/signup_view.dart';

void main() {
  testWidgets('App starts on SplashView with brand', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FreelanceHubApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('FreelanceHub'), findsOneWidget);
    expect(find.text('Conecte. Crie. Cresça.'), findsOneWidget);
    expect(find.text('V1.0.0'), findsOneWidget);

    // Drena timers pendentes para evitar pumpAndSettle infinito por causa do
    // AnimationController em repeat + Future.delayed de 3s na SplashView.
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('OnboardingView builds without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: OnboardingView()),
    );

    expect(find.text('Encontre o talento certo'), findsOneWidget);
    expect(find.text('Próximo'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);
    expect(find.text('PT'), findsOneWidget);
  });

  testWidgets('LoginView builds without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginView()),
    );

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entre na sua conta'), findsOneWidget);
    expect(find.text('PLATAFORMA PRO'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
  });

  testWidgets('SignupView builds with role selector and form', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignupView()),
    );

    expect(find.text('Crie sua conta'), findsOneWidget);
    expect(find.text('Eu sou:'), findsOneWidget);
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Freelancer'), findsOneWidget);
    // "Criar conta" aparece 2x: no top bar (título) e no botão primário.
    expect(find.text('Criar conta'), findsNWidgets(2));
  });

  testWidgets('HomeView builds feed + bottom nav', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeView()),
    );
    // Stream.value(mockProjects) emite no próximo microtask; precisa de um
    // pump extra pro StreamBuilder rebuildar com os dados.
    await tester.pump();

    expect(find.text('Feed de Projetos'), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
    expect(find.text('Redesign de UI de app mobile'), findsOneWidget);
    // Tabs do bottom nav.
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Meus Trabalhos'), findsOneWidget);
    expect(find.text('Mensagens'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('ProjectDetailView renders project metadata and CTA', (
    tester,
  ) async {
    final project = mockProjects.first;
    await tester.pumpWidget(
      MaterialApp(home: ProjectDetailView(project: project)),
    );

    expect(find.text('Detalhes do projeto'), findsOneWidget);
    expect(find.text(project.title), findsOneWidget);
    expect(find.text('Sobre o projeto'), findsOneWidget);
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text(project.clientName), findsOneWidget);
    // "Enviar proposta" aparece 2x: na sticky CTA + na recap da próxima tela
    // não — esta tela é só Detail. 1 ocorrência aqui.
    expect(find.text('Enviar proposta'), findsOneWidget);
  });

  testWidgets('ClientDashboardView renders metrics + sections', (
    tester,
  ) async {
    // Viewport maior pra renderizar todas as seções da CustomScrollView numa
    // tela só (default 800x600 corta o final da lista).
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // ClientDashboardView é embedada no Scaffold do HomeView; o InkWell
    // interno exige Material ancestor, então o teste precisa envolver em
    // Scaffold (HomeView fornece esse Scaffold em tempo real).
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ClientDashboardView()),
      ),
    );

    expect(find.text('Painel'), findsOneWidget);
    // "Projetos ativos" aparece 2x: label da métrica + título da seção.
    expect(find.text('Projetos ativos'), findsNWidgets(2));
    expect(find.text('Aguardando revisão'), findsOneWidget);
    expect(find.text('Aguardando aprovação'), findsOneWidget);
    expect(find.text('Publicar Novo Projeto'), findsOneWidget);
    expect(find.text('Total de propostas'), findsOneWidget);
    // Em ambiente de teste (Firebase.apps.isEmpty), métricas mostram 0 e
    // as seções caem em empty state.
    expect(find.text('Nenhum projeto em movimento ainda.\n'
        'Publique um pra começar a receber propostas.'), findsOneWidget);
    expect(find.text('Nada pra revisar agora.'), findsOneWidget);
  });

  testWidgets('HomeView shows ClientDashboard when initialRole is client', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeView(initialRole: UserRole.client),
      ),
    );

    expect(find.text('Publicar Novo Projeto'), findsOneWidget);
    // Tab "Painel" aparece 2x: título do header da dashboard + label da tab no
    // bottom nav (modo Cliente).
    expect(find.text('Painel'), findsNWidgets(2));
    expect(find.text('Projetos'), findsOneWidget);
  });

  testWidgets('CreateProjectView builds with form + chips + segmented', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: CreateProjectView()),
    );

    // "Publicar projeto" aparece 2x: top bar + botão sticky.
    expect(find.text('Publicar projeto'), findsNWidgets(2));
    expect(find.text('Conte-nos sobre o projeto'), findsOneWidget);
    expect(find.text('Título do projeto'), findsOneWidget);
    expect(find.text('Categoria'), findsOneWidget);
    expect(find.text('Habilidades'), findsOneWidget);
    expect(find.text('Tipo de orçamento'), findsOneWidget);
    expect(find.text('Preço fixo'), findsOneWidget);
    expect(find.text('Por hora'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
  });

  testWidgets('MyProposalsView shows empty state when no proposals', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MyProposalsView())),
    );
    // Stream.value([]) emite no próximo microtask; precisa de pump extra.
    await tester.pump();

    expect(find.text('Meus Trabalhos'), findsOneWidget);
    expect(find.text('Nenhuma proposta ainda'), findsOneWidget);
    expect(
      find.text('Vá ao Feed, abra um projeto e envie sua primeira proposta.'),
      findsOneWidget,
    );
  });

  testWidgets('MyContractsView shows empty state when no contracts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MyContractsView()),
    );
    await tester.pump();

    expect(find.text('Meus contratos'), findsOneWidget);
    expect(find.text('Nenhum contrato ainda'), findsOneWidget);
  });

  testWidgets('ReceivedProposalsView shows empty state when no proposals', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ReceivedProposalsView())),
    );
    await tester.pump();

    // "Projetos" aparece 1x (header da tela; bottom nav está em outro teste).
    expect(find.text('Projetos'), findsOneWidget);
    expect(find.text('Nenhuma proposta recebida'), findsOneWidget);
  });

  testWidgets('SendProposalView builds with form + recap', (tester) async {
    final project = mockProjects.first;
    await tester.pumpWidget(
      MaterialApp(home: SendProposalView(project: project)),
    );

    // "Enviar proposta" aparece 2x: top bar (título) + botão sticky.
    expect(find.text('Enviar proposta'), findsNWidgets(2));
    expect(find.text('Propondo para'), findsOneWidget);
    expect(find.text(project.title), findsOneWidget);
    expect(find.text('Sua proposta'), findsOneWidget);
    expect(find.text('Valor da proposta'), findsOneWidget);
    expect(find.text('Prazo estimado'), findsOneWidget);
    expect(find.text('Mensagem ao cliente'), findsOneWidget);
  });
}
