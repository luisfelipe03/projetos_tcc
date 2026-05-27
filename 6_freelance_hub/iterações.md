# Registro de Iterações

> Log de cada interação com a IA durante o desenvolvimento do **Freelance Hub**.
> Cada entrada registra: prompt enviado, output recebido (resumo do que a IA fez) e o resultado/avaliação.
> Padrão herdado do projeto `5_habit_flow`.

---

## Iteração 1
### Prompt usado:
```plaintext
Vamos começar o desenvolvimento do Freelance Hub seguindo o mesmo padrão dos projetos anteriores do TCC (README como spec, iterações.md como log).
Como Iteração 1, faça a limpeza do projeto Flutter inicial:
- Remova o template do contador padrão do `flutter create`.
- Configure a estrutura MVVM básica (pastas `models/`, `views/`, `viewmodels/`).
- Crie uma `HomeView` em branco como ponto de entrada.
- Mantenha o `pubspec.yaml` enxuto — a stack alvo (riverpod, go_router, supabase_flutter) virá em iterações posteriores.
- Corrija também os erros de compilação atuais no `main.dart` (chamadas de `ColorScheme.fromSeed` e `MainAxisAlignment.center` estão sem o prefixo de tipo).
- Já configure o `MaterialApp` com `theme` e `darkTheme` usando `ThemeMode.system`, antecipando o requisito de Light/Dark Mode do README.
- Ajuste o `widget_test.dart` para refletir a nova estrutura.
```

### Output recebido:
```markdown
- Reescreveu `lib/main.dart`:
  - Renomeou o root widget para `FreelanceHubApp`.
  - Configurou `theme` claro e `darkTheme` escuro via `ColorScheme.fromSeed`, com `seedColor` `#3B309E`.
  - `themeMode: ThemeMode.system` — segue o sistema operacional.
  - `useMaterial3: true` em ambos os temas.
  - `debugShowCheckedModeBanner: false`.
  - `home: const HomeView()`.
- Criou `lib/views/home_view.dart` com `Scaffold` vazio (`SizedBox.shrink()`) — pronto para receber o protótipo da próxima iteração.
- Criou as pastas `lib/models/` e `lib/viewmodels/` com `.gitkeep`.
- Atualizou `test/widget_test.dart` para validar apenas que o app inicia em uma tela em branco (`MaterialApp` + `Scaffold` presentes), removendo o teste do contador.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.2s)`.
  - `flutter test` → `All tests passed!`.
```

### Resultado:
A IA executou a limpeza sem dificuldades. O template do contador foi totalmente removido, a estrutura MVVM foi criada na mesma forma do projeto `5_habit_flow` (3 pastas: `models/`, `views/`, `viewmodels/`), e o tema já foi pré-configurado com a cor primary `#3B309E` — antecipando o requisito de Light/Dark Mode do README. O `pubspec.yaml` foi mantido enxuto: nenhum pacote externo foi instalado nesta iteração, refletindo a abordagem incremental adotada no `5_habit_flow`.

Os erros de compilação que existiam no `main.dart` original (`colorScheme: .fromSeed(...)` e `mainAxisAlignment: .center` sem o prefixo do tipo) foram corrigidos por reescrita completa do arquivo, então não foi necessário identificá-los individualmente. Análise estática e testes passam.

Próximo passo: começar pela primeira tela do app — o **Splash**.

---

## Iteração 2
### Prompt usado:
```plaintext
Como Iteração 2, implemente a tela de Splash conforme o protótipo do Google Stitch (variantes Light e Dark). A tela deve conter:
- Background com cor sólida: `#534AB7` no modo claro e `#26215C` no modo escuro.
- Logo personalizada centralizada (64x64): duas figuras estilizadas (cabeça circular + corpo) sobrepostas em branco com opacidades 1.0/0.9/0.7. Use `CustomPainter` para fidelidade ao SVG do protótipo.
- Wordmark "FreelanceHub" em DM Sans bold 28px, branco, abaixo da logo.
- Tagline "Conecte. Crie. Cresça." em Inter 14px, branco com opacidade 0.7.
- Footer com "V1.0.0" em Inter 11px (uppercase, tracking-widest, opacidade 0.3), barra de loading animada (120x2px) e indicador home iOS-style (128x4px).
- Após 3 segundos, navegar para HomeView com `pushReplacement`.
- Use o pacote `google_fonts` para tipografia (Inter como base do textTheme, DM Sans para o wordmark).
- Garanta que o teste de widget continue passando.
```

### Output recebido:
```markdown
- Adicionou `google_fonts: ^6.2.1` ao `pubspec.yaml` (resolveu para 6.3.3).
- Criou `lib/views/splash_view.dart`:
  - `SplashView` é `StatefulWidget` com `SingleTickerProviderStateMixin`.
  - `AnimationController` de 1.8s em `repeat()` controla a barra de loading.
  - `Future.delayed(const Duration(seconds: 3), _goToNext)` agenda a navegação para `HomeView` com `Navigator.pushReplacement`.
  - Detecta tema do contexto (`Theme.of(context).brightness`) e escolhe entre `_bgLight` (#534AB7) e `_bgDark` (#26215C).
  - `AnnotatedRegion<SystemUiOverlayStyle>` para deixar status bar/navigation bar combinando com o fundo (ícones claros).
  - Layout em `Stack`: bloco centralizado (logo + wordmark + tagline) + footer com versão + barra animada + indicador home.
  - `_BrandLogoPainter` (CustomPainter) desenha 4 elementos da logo (2 círculos + 2 paths cúbicos com `cubicTo`), traduzindo o SVG do protótipo.
  - `_LoadingBar` usa `AnimatedBuilder` + `FractionallySizedBox(widthFactor: controller.value)` para encher de 0 → 100% em loop, sobre fundo branco/20%.
  - Tipografia via `GoogleFonts.dmSans` (wordmark) e `GoogleFonts.inter` (tagline, versão).
- Atualizou `lib/main.dart`:
  - `home: const SplashView()` (era `const HomeView()`).
  - `textTheme` injetado nos dois temas via `GoogleFonts.interTextTheme(...)`.
- Atualizou `test/widget_test.dart`:
  - Renomeou o teste para `App starts on SplashView with brand`.
  - Verifica presença de `FreelanceHub`, `Conecte. Crie. Cresça.` e `V1.0.0`.
  - `tester.pump(const Duration(seconds: 4))` no fim para drenar o timer do `Future.delayed` + o `AnimationController.repeat()` pendentes.
- Validação:
  - `flutter pub get` → `Got dependencies!`.
  - `flutter analyze` → `No issues found! (ran in 1.7s)`.
  - `flutter test` → `All tests passed!`.
```

### Resultado:
A IA implementou a tela de Splash com fidelidade ao protótipo em uma única iteração. Os pontos de complexidade resolvidos sem retrabalho: (a) tradução do SVG da logo para um `CustomPainter` com 4 sub-elementos e opacidades diferentes; (b) animação de barra de loading com `AnimationController` + `FractionallySizedBox` ao invés de `LinearProgressIndicator` indeterminado, mantendo o estilo do protótipo (enche-da-esquerda-pra-direita); (c) injeção de fonte custom (DM Sans, Inter) via `google_fonts` no `textTheme` do tema; (d) configuração de `SystemUiOverlayStyle` para a status bar combinar com o background colorido.

Detecção do tema foi feita via `Theme.of(context).brightness`, que respeita o `ThemeMode.system` configurado no `MaterialApp`. Não foi necessário expor um `ThemeNotifier` ainda (virá quando a tela de seleção manual de tema for implementada).

A navegação após o splash usa `Navigator.pushReplacement` puro (sem `go_router` ainda) — está prevista a migração para `go_router` nas iterações futuras quando o número de rotas começar a crescer.

O `widget_test.dart` precisou de um `pump(Duration(seconds: 4))` no final para drenar o `Future.delayed` da navegação + o `AnimationController.repeat()` — sem isso, o teste falharia com "pending timers" ou similar.

Próximo passo: implementar a sequência de **Onboarding** (3 telas) que vem depois do Splash, conforme protótipos.

---

## Iteração 3
### Prompt usado:
```plaintext
Como Iteração 3, implemente a sequência de **Onboarding** com 3 telas conforme os protótipos do Google Stitch. Estrutura:

- `PageView` horizontal com 3 páginas que compartilham layout: top bar (pill de idioma "PT" + botão "Pular") + hero illustration (5/8 da altura) + título + descrição (3/8 da altura) + indicadores de página + botão primário no rodapé.
- Cada página tem hero ilustrativo próprio:
  1. **OB1 — "Encontre o talento certo"**: dois cards de avatar empilhados ("Publique seu projeto e receba propostas de freelancers qualificados em minutos.")
  2. **OB2 — "Trabalhe com segurança"**: ícone shield centralizado com círculos concêntricos + 3 chips flutuantes (ESCROW, CONTRATO, AVALIAÇÃO). ("Pagamento em escrow protege clientes e freelancers em cada projeto.")
  3. **OB3 — "Construa sua reputação"**: card de perfil verificado com avatar, pill "VERIFICADO", 5 estrelas e barra de progresso de 98%. ("Avaliações reais e portfólio verificado ajudam você a se destacar no mercado.")
- Indicador de página: 3 dots, ativo é uma pill alongada (24x8) na cor primary (`#3B309E` light / `#534AB7` dark), inativo é dot (8x8) com 20% de opacidade do on-surface.
- Botão primário: "Próximo →" nas páginas 1-2, "Começar" (sem seta) na página 3. Em "Pular" ou "Começar" → navega pra `HomeView` com `pushReplacement`.
- Animação: `AnimatedContainer` nos dots, `pageController.nextPage` com `Curves.easeOutCubic`.
- Cores: Light = surface `#FBF9F2` + on-surface `#1B1C18` + primary `#3B309E`. Dark = bg `#1A1A18` + on-bg branco + primary-container `#534AB7`.
- Tipografia: DM Sans 28px bold para títulos e botão, Inter 15px para descrição, Inter 12px bold para a pill PT.
- Status bar com `SystemUiOverlayStyle` alinhado ao tema (ícones escuros em light, claros em dark).
- Atualizar `SplashView` para navegar para `OnboardingView` no fim dos 3 segundos (ao invés de `HomeView`).
```

### Output recebido:
```markdown
- Criou `lib/views/onboarding_view.dart` (~530 linhas) com:
  - `OnboardingView` (StatefulWidget) com `PageController` + estado `_currentPage`.
  - Lista privada `_pages` com 3 entradas tipadas (`_OnboardingPageData`: hero widget + título + descrição).
  - Botão primário muda label dinamicamente (`Próximo` com seta vs `Começar` sem seta na última página).
  - Top bar com pill de idioma estilizada (Icon + "PT") e botão "Pular".
  - `_PageIndicator` com `AnimatedContainer` (largura anima 8↔24 em 280ms easeOutCubic).
  - Detecção de tema via `Theme.of(context).brightness` para alternar paleta.
  - `AnnotatedRegion<SystemUiOverlayStyle>` com brightness apropriado para cada tema.
- 3 hero illustrations implementados como `StatelessWidget` privados, totalmente em Flutter (sem assets externos):
  - `_HeroTalent`: dois `_AvatarCard` com `CircleAvatar` simulado por `Container` decorado + barras de "texto" placeholder.
  - `_HeroSecurity`: 3 círculos concêntricos (border verde) + círculo central preenchido com ícone `Icons.verified_user` + 3 `_Chip` em posicionamento absoluto.
  - `_HeroReputation`: card com avatar, pill verde "VERIFICADO" com `Icons.verified`, 5 estrelas amarelas, label "Taxa de conclusão" + `LinearProgressIndicator(value: 0.98)`.
- Editou `lib/views/splash_view.dart`: trocou `import 'home_view.dart'` por `'onboarding_view.dart'` e atualizou o `MaterialPageRoute` para `OnboardingView`.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.8s)`.
  - `flutter test` → `All tests passed!` (teste de smoke da Splash continua passando porque só verifica MaterialApp + textos da Splash, não toca em Onboarding).
```

### Resultado:
A IA implementou as 3 telas de onboarding com estrutura compartilhada e hero illustrations distintos em uma única iteração. Decisões tomadas pela IA sem intervenção manual:

- **Composição via PageView + helpers privados**, mantendo o arquivo todo em `onboarding_view.dart` (não distribuído em vários arquivos) para reduzir overhead de navegação entre arquivos durante esta fase inicial.
- **Hero illustrations 100% renderizados em Flutter** (sem dependência de imagens externas/assets), traduzindo a composição visual do protótipo para `Container`/`Stack`/`Positioned`/`Icon`. Tradeoff: perde-se a foto realista do freelancer no card, mas evita assets externos e mantém o tamanho do app enxuto.
- **Indicadores animados** com `AnimatedContainer` na largura (8→24 px), mais elegante que dots de tamanho fixo + cor.
- **Botão muda dinamicamente** baseado em `_isLastPage` — única condicional na UI, evita 3 botões redundantes nas data classes.

Pontos onde fidelidade ao protótipo foi reduzida vs. perfeita:
- Os avatares no `_HeroTalent` são ícones genéricos `Icons.person`; o protótipo usa fotos reais de pessoas (URLs do Stitch).
- As barras de "texto" nos cards são placeholders coloridos; o protótipo tem texto real.
- Posicionamento absoluto dos chips no `_HeroSecurity` foi calibrado por eyeballing — pode precisar de ajuste fino.

Como esses pontos são cosméticos e a estrutura visual está fiel, vão para uma iteração de polish se necessário após o usuário rodar e revisar.

A integração com Splash foi um one-liner (troca de import + classe na rota). Próximo passo: implementar o **Login & Auth** ou a **Language Sheet** (bottom sheet de seleção de idioma) acessada pelo toque na pill "PT" — o que o usuário priorizar.

---
