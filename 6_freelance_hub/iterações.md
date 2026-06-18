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
- Mantenha o `pubspec.yaml` enxuto — a stack alvo (riverpod, go_router, Firebase_flutter) virá em iterações posteriores.
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

## Iteração 4
### Prompt usado:
```plaintext
Como Iteração 4, implemente a tela de **Login & Auth** conforme o protótipo do Stitch. Decisões:

- Traduza tudo pro português (consistência com Onboarding):
  - "Welcome Back" → "Bem-vindo de volta"
  - "Login to your account" → "Entre na sua conta"
  - "Enter your credentials to access your workspace." → "Informe suas credenciais para acessar."
  - "Email Address" → "E-mail" (placeholder: "nome@empresa.com")
  - "Password" → "Senha" (placeholder: "••••••••")
  - "Forgot password?" → "Esqueceu a senha?"
  - "Log In" → "Entrar"
  - "OR CONTINUE WITH" → "OU CONTINUE COM"
  - "Don't have an account? Create an account" → "Não tem conta? Cadastre-se"
  - "PRO PLATFORM" → "PLATAFORMA PRO"
- Mantenha o **primary purple `#3B309E`** do app (não trocar pro blue `#1337EC` do protótipo) — preserva consistência cromática com Splash/Onboarding.
- **Remova o botão LinkedIn** — o README só menciona Google como social sign-in. Botão Google fica full-width sozinho.
- Hero card: gradiente diagonal de `#534AB7` → `#1B154A` com 3 círculos decorativos (alpha baixo), 3 avatares circulares sobrepostos no topo direito (representando os 3 freelancers do protótipo), chip "PLATAFORMA PRO" e caption no rodapé esquerdo. **Sem network image** (asset rotting).
- Form com 2 `TextFormField`:
  - E-mail: validação com regex, ícone mail, autofill `email`.
  - Senha: validação ≥6 chars, ícone lock, autofill `password`, toggle de visibilidade (eye icon).
- Top bar: back arrow + "Bem-vindo de volta" centralizado (compensado por padding-right pra centralizar visualmente apesar do arrow à esquerda).
- "Entrar" e "Continuar com Google" navegam pra HomeView via `pushReplacement` (sem Firebase ainda).
- "Esqueceu a senha?" e "Cadastre-se" exibem SnackBar "em breve".
- Suporte completo light/dark com paleta slate (slate-200/400/500/700/900) + bg dark `#0B1020`.
- Tipografia DM Sans (título + botão) + Inter (resto).
- Logo Google: implemente como `CustomPainter` com os 4 segmentos coloridos clássicos — sem dependência externa.
- Atualizar `OnboardingView` pra navegar pra `LoginView` no fim (em vez de HomeView).
```

### Output recebido:
```markdown
- Criou `lib/views/login_view.dart` (~580 linhas) com:
  - `LoginView` (StatefulWidget) com `GlobalKey<FormState>`, 2 `TextEditingController`, estado `_obscurePassword`.
  - Layout em `SingleChildScrollView` (evita overflow quando teclado aparece) + `SafeArea`.
  - `_TopBar` com `IconButton(arrow_back)` + `Center` com padding-right compensatório para centralizar título mesmo com o botão à esquerda. Usa `Navigator.maybePop` (silencioso se não há rota anterior).
  - `_HeroCard`: `Container` 180px com gradient diagonal + 2 círculos decorativos `Positioned` + 3 avatares circulares com borda branca sobrepostos + chip "PLATAFORMA PRO" + caption. Tudo em Flutter puro, sem assets.
  - `_TextInput`: wrapper do `TextFormField` com `OutlineInputBorder` arredondado (14px), estados `enabled`/`focused`/`error`/`focusedError` configurados, fill color + ícone prefix + suffix opcional.
  - Validação inline: regex de e-mail (`^[\w.+-]+@[\w-]+\.[\w.-]+$`), senha ≥6 chars.
  - `_OrDivider`: 2 linhas com texto centralizado e tracking widest.
  - `_SocialButton`: `OutlinedButton` full-width com ícone customizado + label.
  - `_GoogleIcon` + `_GoogleGPainter`: 4 arcos coloridos (amarelo, verde, azul, vermelho) formando o "G" do Google + retângulo azul horizontal + círculo branco interno.
- Atualizou `lib/views/onboarding_view.dart`: import de `home_view.dart` → `login_view.dart`, navegação `Pular`/`Começar` agora vai para `LoginView`.
- Pequena correção pós-analyze: campo `_primaryDeep` declarado mas não usado removido.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.3s)` (depois de remover `_primaryDeep`).
  - `flutter test` → `All tests passed!` (smoke test da Splash inalterado).
```

### Resultado:
A IA implementou a tela de Login completa em uma única iteração, com fidelidade estrutural ao protótipo e os tradeoffs cromáticos/de conteúdo declarados (purple em vez de blue, sem LinkedIn). Pontos de destaque:

- **CustomPainter do logo do Google** implementado com 4 arcos parciais (cada um cobrindo 90° do círculo) traduzindo o desenho clássico do "G" sem precisar de SVG asset. Resultado: aproximação reconhecível, não pixel-perfect — em produção, seria mais robusto usar `flutter_svg` ou o pacote `google_sign_in_web` que traz o logo oficial.
- **Hero card sem network image**: a foto real do protótipo (URL do Stitch) foi substituída por uma composição estilizada que comunica o mesmo conceito (3 avatares = profissionais conectados + gradient corporate = ambiente premium).
- **Top bar com back arrow funcional sem rota anterior**: `Navigator.maybePop` é silencioso quando o stack está vazio (caso de uso real aqui, já que Onboarding → Login é `pushReplacement`). Isso preserva a fidelidade ao design sem comportamento estranho.
- **Validação inline** seguindo padrão `Form` + `validator` do Flutter, sem dependência de `reactive_forms` ainda — virá quando os formulários ficarem mais complexos (cadastro com role selection, criar projeto).
- **Form submit + Google login navegam ambos para HomeView** via `pushReplacement` — placeholder até a Iteração de integração com Firebase Auth.
- **Único warning de analyze** (campo não usado `_primaryDeep`) foi pego e corrigido sem reentrada de prompt — comportamento esperado de boa qualidade.

Pontos que vão precisar de iteração futura:
- O logo do Google está aproximado, não oficial. Considerar uso de `flutter_svg` + asset oficial ou pacote `font_awesome_flutter` com `Brands.googlePlusG`.
- O hero card poderia ter uma ilustração mais elaborada (formas geométricas, dotted patterns) para se aproximar mais do mockup.
- A tela do **Cadastro (Signup)** precisa ser criada — atualmente o link "Cadastre-se" só mostra SnackBar.

### Erro detectado em runtime (após validação automatizada passar)

Ao executar o app no simulador, a `LoginView` quebrou no build do `_HeroCard`:

```
'package:flutter/src/widgets/container.dart': Failed assertion: line 270 pos 15:
'margin == null || margin.isNonNegative': is not true.

#3  _HeroCard.build.<anonymous closure> (package:freelance_hub/views/login_view.dart:353:24)
```

**Causa raiz:** na composição dos 3 avatares sobrepostos no topo direito da hero card, foi usado `margin: EdgeInsets.only(left: i == 0 ? 0 : -8)` para criar o efeito de overlap. O `Container` do Flutter não aceita margins negativos — o asserção `margin.isNonNegative` falha em runtime.

**Por que as validações automatizadas não pegaram:**
- `flutter analyze` é estática, não simula o build dos widgets — não tem como saber que `-8` violaria a precondição do `Container`.
- `flutter test` passou porque o smoke test atual só monta `FreelanceHubApp` e verifica a Splash; ele nunca atravessa Splash → Onboarding → LoginView no contexto do teste (o `Future.delayed(3s)` da Splash é drenado mas o `pushReplacement` para Onboarding não é exercido como evento de interação).

**Lição:** o gap de cobertura é evidente — sem teste que monte `LoginView` diretamente (ou um teste E2E que percorra o fluxo), bugs de assertion de widget passam despercebidos. Mitigações possíveis em iterações futuras: (a) widget tests por tela (`pumpWidget(MaterialApp(home: LoginView()))`), (b) usar `Transform.translate` ou `Stack`+`Positioned` em vez de margins negativos quando precisar de overlap.

**Status:** a Iteração 4 é commitada com o bug presente (registro honesto do que a IA entregou em uma única passada). A correção será feita na **Iteração 5**.

Próximo passo: **Iteração 5 — correção do crash do `_HeroCard`** (substituir margin negativo por uma técnica válida de overlap), depois seguir para **Cadastro (Signup)** com seleção de papel.

---

## Iteração 5
### Prompt usado:
```plaintext
Como Iteração 5, corrija o crash detectado na Iteração 4:
- `_HeroCard` em `lib/views/login_view.dart:353` quebra com `'margin == null || margin.isNonNegative': is not true` por causa de `Container(margin: EdgeInsets.only(left: -8))`. O efeito desejado é overlap dos 3 avatares — vamos substituir por `Stack` + `Positioned` com `left` calculado.
- Aproveite a iteração pra fechar o gap de cobertura que deixou esse bug passar: adicione testes de smoke (`testWidgets`) para `LoginView` e `OnboardingView` que apenas montam cada uma e verificam textos chave. Esses testes pegam qualquer assertion error de widget no build.
- Mantenha o mesmo visual: 3 círculos (lavanda, verde menta, amarelo) com borda branca de 2px, 36x36px, sobrepostos com 8px de intersecção.
```

### Output recebido:
```markdown
- Refatorou o bloco dos 3 avatares em `lib/views/login_view.dart` (linhas 347-378):
  - Trocou `Row` + `Container(margin: EdgeInsets.only(left: -8))` por `SizedBox(width: 92, height: 36)` envolvendo um `Stack`.
  - Cada avatar agora é um `Positioned(left: 28.0 * i, ...)` dentro do Stack. Cálculo: cada item 36px, sobrepondo 8px com o anterior → próximo item a 28px de distância do anterior. Total: 36 + 28 + 28 = 92px.
  - Ordem de desenho preservada (último item fica visualmente em cima, mantendo o stacking original).
- Atualizou `test/widget_test.dart` com 2 testes novos:
  - `OnboardingView builds without errors`: pumpWidget direto da OnboardingView e verifica "Encontre o talento certo", "Próximo", "Pular", "PT".
  - `LoginView builds without errors`: pumpWidget direto da LoginView e verifica "Bem-vindo de volta", "Entre na sua conta", "PLATAFORMA PRO", "Entrar", "Continuar com Google".
  - Esses 2 testes builda o widget tree inteiro de cada tela — qualquer assertion error em sub-widget (como o margin negativo) é detectado.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.8s)`.
  - `flutter test` → `3 tests, all passed`.
```

### Resultado:
Correção pontual + fortalecimento da cobertura de testes. A IA aplicou a solução correta (`Stack` + `Positioned`) sem precisar de retentativas, e o cálculo de `left = 28.0 * i` foi feito corretamente na primeira passada (36 - 8 de overlap = 28 de step). O `SizedBox` de 92x36 dá ao Stack uma dimensão definida — necessário porque Stack sem dimensão herda dos pais e os pais aqui são `Positioned` (que já tem `right: 24, top: 24` no card pai).

**Cobertura de testes:** os 2 novos testes (`OnboardingView builds without errors`, `LoginView builds without errors`) montam diretamente cada tela com `MaterialApp(home: ...)` sem precisar atravessar o fluxo Splash→Onboarding→Login. Isso é o padrão recomendado pelo Flutter para smoke tests de tela. Custo: ~1s adicional por teste, total `flutter test` ainda em 3s.

**Comprovação experimental do valor dos testes novos:** se os mesmos testes existissem na Iteração 4, o bug do margin negativo teria sido pego antes do commit — o `pumpWidget(MaterialApp(home: LoginView()))` triggera todo o build tree, incluindo o `_HeroCard` que quebrava com a assertion.

Esta iteração entra como **iteração de correção** (vs. iteração de feature) — análoga às iterações de correção do `5_habit_flow` (13 de 36 iterações foram para fix de iterações anteriores, ~36%). Para o `6_freelance_hub`: 1 iteração de correção em 5 iterações totais (20% até aqui), proporção menor — mas ainda cedo no projeto para conclusão sobre o índice global.

Próximo passo: tela de **Cadastro (Signup)** com seleção de papel (Cliente vs Freelancer) — desbloqueia o link "Cadastre-se" do Login.

---

## Iteração 6
### Prompt usado:
```plaintext
Como Iteração 6, implemente a tela de **Cadastro (Signup)** com seleção de papel. Essa tela não existe no Stitch — desenhe consistente com o LoginView (mesma paleta purple/slate, DM Sans + Inter, mesmo estilo de input). Estrutura:

- Top bar: back arrow + "Criar conta" centralizado (mesma estrutura do Login).
- Título "Crie sua conta" + subtítulo "Junte-se ao FreelanceHub em poucos passos."
- **Seleção de papel** (central pro RBAC do app):
  - Crie `lib/models/user_role.dart` com `enum UserRole { client, freelancer }` tipado (com `displayName` e `tagline` como propriedades do enum).
  - 2 cards em row (Expanded + SizedBox(width: 12) + Expanded), 50/50 da largura.
  - Cada card: padding 14, border arredondada 16px, ícone (briefcase pra Cliente, design_services pra Freelancer), título DM Sans 15px bold + tagline Inter 11px 2 linhas.
  - Estado não-selecionado: bg = inputBg, border slate (1px). Selecionado: bg = `#E3DFFF` (light) / `#3B309E` com 18% alpha (dark), border purple `#3B309E` (1.5px), ícone purple, título purple, badge circular purple com checkmark no canto superior direito (animado com `AnimatedOpacity`).
  - `AnimatedContainer` na transição (180ms easeOutCubic).
- Form com 3 fields (Nome / E-mail / Senha) usando o mesmo `_TextInput` style do Login.
- Checkbox de termos com `RichText` que mistura cor neutra + 2 links purple ("Termos de Uso", "Política de Privacidade").
- Validação:
  - Form: nome ≥3 chars, regex de e-mail, senha ≥6 chars.
  - Role: deve estar selecionado (`_showRoleError = true` se não).
  - Termos: deve estar marcado (`_showTermsError = true` se não).
  - Mensagens de erro inline (cor `#BA1A1A`) abaixo dos componentes não-form.
- Botão "Criar conta" purple full-width. No tap: valida tudo, se ok → navega pra HomeView via pushReplacement.
- Footer "Já tem uma conta? Entrar" — tap volta pro Login com `Navigator.maybePop`.
- Atualizar LoginView: o link "Cadastre-se" agora navega pra SignupView com `push` (não pushReplacement — pra permitir voltar).
- Adicionar smoke test pra SignupView que verifica os textos chave.
```

### Output recebido:
```markdown
- Criou `lib/models/user_role.dart` com `enum UserRole` tipado:
  - `client` (displayName "Cliente", tagline "Contrate freelancers e\npublique projetos.").
  - `freelancer` (displayName "Freelancer", tagline "Receba projetos e\ngerencie entregas.").
  - Construtor const com required named params.
- Criou `lib/views/signup_view.dart` (~530 linhas):
  - `SignupView` (StatefulWidget) com `GlobalKey<FormState>`, 3 `TextEditingController`, `UserRole? _selectedRole`, `bool _termsAccepted`, `bool _obscurePassword`, `bool _showRoleError`, `bool _showTermsError`.
  - `_handleSubmit`: faz `form.validate()` + checa role + checa terms; só navega se tudo passar; em caso de erro nos não-form (role/terms), seta flags pra exibir mensagens inline via `setState`.
  - `_TopBar` reutilizando o mesmo padrão do Login.
  - `_RoleCard` (StatelessWidget) com `AnimatedContainer` (180ms easeOutCubic) que anima bg/border na seleção, e badge de check no canto top-right com `AnimatedOpacity`.
  - Form com `_TextInput`, `_FieldLabel`, `_TermsCheckbox` (com RichText) — pequena duplicação de helpers do Login (`_FieldLabel`, `_TextInput`) que ficou aceitável até criar um `core/widgets/` compartilhado.
- Atualizou `lib/views/login_view.dart`:
  - Importou `signup_view.dart`.
  - `_handleSignUp` agora faz `Navigator.push(MaterialPageRoute(builder: (_) => SignupView()))` em vez do SnackBar "em breve".
- Adicionou teste de smoke `SignupView builds with role selector and form` em `test/widget_test.dart` verificando: "Crie sua conta", "Eu sou:", "Cliente", "Freelancer", "Criar conta" (2x).
```

### Resultado:
A IA implementou Signup + enum UserRole em uma única passada estrutural. Decisões tomadas sem retentativa:

- **Enum tipado com propriedades** em vez de `enum` simples + map externo — `displayName` e `tagline` viajam junto com o valor.
- **Cards de papel com `AnimatedContainer`** que animam border, bg e título simultaneamente em 180ms — feedback visual claro pro usuário no toque.
- **Badge de check com `AnimatedOpacity`** em vez de aparecer/sumir abruptamente.
- **Validação de não-form em estado separado** (`_showRoleError`, `_showTermsError`) — Flutter's `Form.validate()` só roda nos `FormField`s; role e terms exigem checagem manual + flags pra exibir erro inline.

**Duas correções pós-validação:**
1. **Warning de analyze:** `_primaryLight` declarado em `_SignupViewState` mas o uso real estava no `_RoleCard` (que já tem seu próprio static const). Removido o do parent.
2. **Test failure:** assertion `find.text('Criar conta'), findsOneWidget` falhou porque o texto aparece 2x (top bar + botão). Mudado pra `findsNWidgets(2)` com comentário explicando.

Ambas detectadas e corrigidas dentro da mesma iteração (sem necessidade de iteração de fix separada). `flutter analyze` finaliza com 0 issues, `flutter test` com 4 passes.

**Pequena duplicação intencional:** `_FieldLabel` e `_TextInput` aparecem tanto em `login_view.dart` quanto em `signup_view.dart`. Para 2 ocorrências ainda não vale criar um módulo compartilhado em `core/widgets/`. Quando aparecer uma terceira tela com inputs (talvez profile edit ou criar projeto), extraio.

**Sobre a navegação:** Login → Signup usa `push` (não `pushReplacement`) — assim o botão "Entrar" no footer do Signup volta naturalmente pro Login via `Navigator.maybePop`. Onboarding → Login é `pushReplacement` (não tem por que voltar pra Onboarding após login).

Próximo passo: **Home/Feed do Cliente ou do Freelancer** — começa a entrar nas telas pós-autenticação. Como temos `UserRole` modelado mas nenhum estado de autenticação ainda, o roteamento condicional por papel virá quando a Iteração de Firebase Auth fizer a integração de verdade. Por enquanto, a `HomeView` precisa virar uma tela real (lista de projetos para Freelancer / dashboard para Cliente).

---

## Iteração 7
### Prompt usado:
```plaintext
Como Iteração 7, transforme a `HomeView` (que está em branco) na **tela principal pós-login do Freelancer**, conforme o protótipo "Project Feed" do Stitch. Como ainda não há estado de autenticação/role, a HomeView por enquanto exibe a visão do Freelancer; o roteamento por papel virá com a integração de Firebase Auth.

Estrutura:
- `HomeView` vira um Scaffold com `BottomNavigationBar` custom (4 tabs):
  - Feed (ativa) — exibe o feed de projetos
  - Meus Trabalhos
  - Mensagens
  - Perfil
  - As 3 tabs não-Feed são placeholders ("Em breve" + ícone de construção).
  - Estilo: tab ativa em purple `#3B309E` com ícone preenchido + label em bold; inativas em slate-400 com ícone outline.
- `FeedView` (arquivo separado) com:
  - Top header: ícone hambúrguer (bubble purple/10), título "Feed de Projetos" (DM Sans 18px bold), bell de notificações com badge vermelho, avatar circular com borda purple.
  - Search bar: outline none, bg purple/5, placeholder "Buscar projetos, habilidades…", ícone search prefix.
  - Filter chips em row scrollável: "Todos os filtros" (ativa por default — purple filled), "Categoria ▼", "Orçamento ▼".
  - Lista de project cards (separadas por 12px de gap):
    - Card pode ter hero image opcional (gradient placeholder, sem network image)
    - Título (DM Sans 16 bold) + bookmark toggle (filled/outline) à direita
    - Skill chips em wrap (bg purple/10 light ou purple/20 dark, text purple, uppercase, letter-spacing)
    - Row footer com 2 colunas: budget (DM Sans 18 bold purple) + tipo ("Preço fixo"/"Por hora"); direita: "X propostas" + "há Y horas/dias"
- Criar `lib/models/project.dart`:
  - Class `Project` com: id, title, skills, minBudget, maxBudget, isHourly, proposalCount, postedAgo, hasHeroImage.
  - Helper `formattedBudget()` — formato BR "R$ X,XXX - R$ Y,YYY" ou "R$ X-Y/h"; quando min == max só mostra um valor.
  - Helper `budgetTypeLabel()` — "Preço fixo" ou "Por hora".
  - Helper `relativePostedLabel()` — "há N horas/dias".
  - `const mockProjects` com 4 projetos hardcoded em português (Redesign de UI, Escalar backend, Tema WordPress, Renovação de identidade).
- Adicionar smoke test para HomeView.
- Sem novas deps.
```

### Output recebido:
```markdown
- Criou `lib/models/project.dart` (~80 linhas):
  - Class `Project` imutável com 9 campos.
  - 3 helpers: `formattedBudget()` (formatação BR manual com pontos como milhares), `budgetTypeLabel()`, `relativePostedLabel()`.
  - `const mockProjects` list com 4 projetos, 1 com `hasHeroImage: true` (o de e-commerce).
- Reescreveu `lib/views/home_view.dart`:
  - Trocou o `Scaffold(body: SizedBox.shrink())` antigo por um Scaffold com:
    - State `_currentTab` (int, default 0).
    - BottomNav custom (não usa `BottomNavigationBar` nativo) com 4 tabs via `_TabSpec` (label + icon + activeIcon).
    - Switch expression sobre `_currentTab`: caso 0 → `FeedView()`, demais → `_PlaceholderTab(label: ...)`.
    - `AnnotatedRegion<SystemUiOverlayStyle>` adaptativo light/dark.
- Criou `lib/views/feed_view.dart` (~440 linhas):
  - `FeedView` (StatefulWidget) com state: `_searchController`, `_activeFilter` (String), `_bookmarked` (Set<String>).
  - Layout em `CustomScrollView` com Slivers (top header → search → filters → lista → padding final).
  - 5 helpers privados: `_TopHeader`, `_IconBubble`, `_SearchBar`, `_FilterChip`, `_ProjectCard`, `_HeroImagePlaceholder`, `_SkillChip`.
  - `_HeroImagePlaceholder`: gradient `#1B154A → #534AB7` com 2 círculos decorativos brancos low-alpha + ícone `dns_outlined` centralizado (substitui a foto real do protótipo).
  - Bookmark é estado list-level via `Set<String>` em `_FeedViewState`; toggle no `_ProjectCard` chama `setState` na lista.
- Adicionou teste de smoke para HomeView verificando: "Feed de Projetos", "Todos os filtros", título do primeiro projeto, e 4 labels de tab.
- Pequena correção pós-analyze: removeu 2 campos não-usados (`_slate200`, `_slate700`) de `_FeedViewState`.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.4s)`.
  - `flutter test` → `5 tests, all passed`.
```

### Resultado:
A IA implementou a Home + Feed completos numa única iteração estrutural. Pontos relevantes:

- **Separação em 3 arquivos** (`home_view.dart` + `feed_view.dart` + `models/project.dart`) em vez de tudo num só — boa decomposição, considerando que `feed_view.dart` já passa de 400 linhas.
- **Bottom nav custom** em vez do `BottomNavigationBar` nativo do Material. Trade-off: mais código pra implementar, mas controle total sobre estilo (cores, ícones outline/filled, label bold no ativo, divisor topo, shadow). Compatível com o look do protótipo.
- **`CustomScrollView` com Slivers** para a feed view, em vez de `ListView` + `Column` aninhados. Performance superior (apenas itens visíveis são built) e permite header, search e chips ficarem no mesmo scroll natural.
- **Bookmark com `Set<String>`** em vez de bool por Project ou Map<String,bool>. Eficiente para checagem/toggle (`O(1)` ambos) e econômico em memória pra poucos bookmarks.
- **Formatação de moeda BR manual** em `Project._formatCurrency`: insere pontos como separador de milhar percorrendo a string da direita para a esquerda. Sem dependência do pacote `intl` (que viria mais tarde junto com i18n). Trade-off: não suporta decimais nem outras moedas — suficiente pro mock atual.
- **`hero image` substituído por gradient + ícone**: solução já estabelecida nas iterações anteriores (Splash, Login) para evitar network images com URLs rotting do Stitch.

**1 correção interna:** 2 cores declaradas (`_slate200`, `_slate700`) que sobraram da fase de cópia de paletas do Login — removidas no mesmo turno do warning, sem iteração de fix separada.

**Considerações sobre estado da app:**
- `_activeFilter` é apenas visual (a lista não é filtrada de verdade ainda).
- `_bookmarked` é estado local — perde quando a tela é recriada. Persistência virá com Firestore.
- A busca não filtra a lista — `_searchController` é capturado mas não aplicado. Virá quando precisar.

**Próximos passos sugeridos:**
- Tela de **Project Detail** (visão do freelancer ao tocar num card): título, descrição completa, cliente, propostas, botão "Enviar proposta".
- Tela de **Send Proposal** (form com valor proposto + mensagem).
- **Client Dashboard** (visão do Cliente, equivalente da Home dele, com projetos próprios + propostas recebidas).

A escolha entre seguir o fluxo do Freelancer (Project Detail → Send Proposal) ou pivotar para o Cliente Dashboard depende da prioridade — implementar primeiro o Freelancer cobre um caminho completo (do feed à proposta enviada) antes de duplicar o roteamento condicional pra Cliente.

---

## Iteração 8
### Prompt usado:
```plaintext
Como Iteração 8, implemente a tela de **Detalhes do Projeto** (visão do Freelancer ao tocar num card do feed). Não existe protótipo no Stitch — desenhe consistente com o sistema visual já estabelecido (purple primary, slate scale, DM Sans + Inter, mesmo padrão de top bar/cards).

Estrutura:
- Top bar: back arrow + "Detalhes do projeto" centralizado + bookmark toggle no canto direito.
- Hero opcional: usa o mesmo gradient placeholder de feed quando `project.hasHeroImage == true`.
- Bloco principal:
  - Título (DM Sans 24 bold, line-height 1.2)
  - Wrap de skill chips (mesmo `_SkillChip` style do feed)
  - Budget em destaque (DM Sans 26 bold purple) + tipo (Preço fixo / Por hora)
  - Metadata: ícone people + "X propostas" • ícone clock + "há Y horas/dias"
- Divider
- Seção "Sobre o projeto" com a description completa do projeto (Inter 14, line-height 1.6, color muted)
- Divider
- Seção "Cliente" com card outlined:
  - Avatar circular purple (Icons.person)
  - Nome (DM Sans 15 bold)
  - Linha "★ X.X · N projetos publicados" (Inter 12)
- Sticky bottom action bar:
  - Container com top border + shadow sutil
  - Botão "Enviar proposta" purple full-width (52px alto, rounded 14, DM Sans 15 bold)
  - Por enquanto: tap mostra SnackBar "Tela de envio de proposta virá na próxima iteração."

Expandir model:
- Adicionar campos ao `Project`: `description` (String, parágrafo longo PT-BR), `clientName` (String), `clientRating` (double), `clientProjectsCount` (int).
- Atualizar os 4 mock projects com descrições realistas e dados de cliente.

Wire navegação:
- O `_ProjectCard.onTap` no FeedView agora faz `Navigator.push(MaterialPageRoute(builder: (_) => ProjectDetailView(project: project)))`.

Smoke test pra ProjectDetailView que verifica: "Detalhes do projeto", título do projeto, "Sobre o projeto", "Cliente", nome do cliente, "Enviar proposta".
```

### Output recebido:
```markdown
- Atualizou `lib/models/project.dart`:
  - Adicionou 4 campos required: `description`, `clientName`, `clientRating`, `clientProjectsCount`.
  - Atualizou os 4 mock projects com descrições realistas em PT-BR (média ~80 palavras cada, com `\n\n` pra separar parágrafos) e dados de cliente plausíveis (nomes brasileiros, ratings entre 4.6-5.0, projects count 7-24).
- Criou `lib/views/project_detail_view.dart` (~430 linhas):
  - `ProjectDetailView` (StatefulWidget) recebe `Project` no construtor.
  - Estado local: `_bookmarked` (não persistido).
  - Layout: Scaffold body = Column(_TopBar, Expanded(SingleChildScrollView(...)), _BottomActionBar).
  - 6 helpers privados: `_TopBar`, `_HeroImage`, `_Section`, `_ClientCard`, `_SkillChip`, `_BottomActionBar`.
  - `_BottomActionBar` é um Container com `SafeArea(top: false)` interno pra respeitar a home indicator do iOS.
  - SnackBar "Tela de envio de proposta virá na próxima iteração." no tap do botão "Enviar proposta".
- Editou `lib/views/feed_view.dart`:
  - Import de `project_detail_view.dart`.
  - `_ProjectCard.onTap` antes vazio (`() {}`), agora navega com `Navigator.push(MaterialPageRoute(builder: (_) => ProjectDetailView(project: project)))`.
- Adicionou smoke test `ProjectDetailView renders project metadata and CTA` que monta a tela com `mockProjects.first` e verifica 6 textos (título da tela, título do projeto, seções, nome do cliente, CTA).
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.8s)` na primeira execução, sem warnings de campos não usados (aprendi com as iterações anteriores).
  - `flutter test` → `6 tests, all passed`.
```

### Resultado:
Iteração limpa, sem retentativas internas. A IA aplicou os aprendizados das iterações anteriores:

- **Sem cores declaradas sobrando**: a paleta foi importada já enxuta (apenas `_primary`, `_slate900`, `_slate500`, `_slate200`, `_slate800`, `_surfaceCream`, `_bgDark`) — todas usadas. Reflete a correção feita na Iteração 7 sendo internalizada como padrão.
- **`_SkillChip` duplicado entre feed_view.dart e project_detail_view.dart** — aceitável por enquanto, mas já são 2 ocorrências; uma terceira tela com skill chips justifica extrair pra `core/widgets/`.
- **`Project` model agora tem 4 campos required novos** — todos os call-sites já existentes foram atualizados no mesmo arquivo (mockProjects), zero risco de compile error em outros lugares.
- **Decisão de layout pro sticky bottom**: `Column(TopBar, Expanded(SingleChildScrollView), BottomActionBar)` em vez de `Scaffold.bottomSheet` ou `Scaffold.persistentFooterButtons`. Garante que o botão sempre fica visível, scroll é confinado ao body, e respeita SafeArea da home indicator.

**Decisões deferidas (não-bloqueantes):**
- Bookmark do detalhe não está sincronizado com o bookmark do card no feed — cada um tem seu próprio estado. Quando Firestore entrar, vão compartilhar a fonte de verdade.
- Botão "Enviar proposta" só mostra SnackBar — a tela real virá na próxima iteração.

**Estado da navegação:**
```
SplashView → OnboardingView → LoginView ⇆ SignupView
                                  ↓
                              HomeView (Scaffold + BottomNav)
                                  ├─ Feed (lista de projetos)
                                  │    ↓ tap em card
                                  │   ProjectDetailView ← (Iteração 8)
                                  │        ↓ tap em "Enviar proposta"
                                  │       (próxima iteração)
                                  ├─ Meus Trabalhos (placeholder)
                                  ├─ Mensagens (placeholder)
                                  └─ Perfil (placeholder)
```

Próximo passo: **Send Proposal** — form com valor proposto + mensagem ao cliente, validação, e ao enviar volta pro Feed com SnackBar de confirmação. Fecha o loop "ver projeto → propor" no lado Freelancer antes de virar pro Cliente Dashboard.

---

## Iteração 9
### Prompt usado:
```plaintext
Como Iteração 9, implemente a tela de **Send Proposal** — fecha o loop do Freelancer (ver projeto → propor). Não existe protótipo no Stitch; desenhe consistente com o sistema visual (purple primary, slate scale, DM Sans + Inter).

Estrutura:
- Top bar: back arrow + "Enviar proposta" centralizado (mesmo padrão do Login/Signup/Detail).
- **Recap card** no topo da rolagem: ícone briefcase purple, label "Propondo para", título do projeto truncado em 1 linha com ellipsis, budget formatado + tipo. Dá contexto visual antes do form.
- Form (Form + GlobalKey + 3 controllers):
  - **Valor da proposta** — input de número com `prefixText: 'R$ '`, suffix `/h` se project.isHourly. Formatter custom `_ThousandsFormatter` que insere pontos como separador de milhar (replicando a lógica de `Project._formatCurrency`). Validador: não vazio, parse positivo.
  - **Prazo estimado** — input numérico com ícone `event_outlined` prefix, suffix "dias". Validador: 1-365.
  - **Mensagem ao cliente** — TextFormField multiline (minLines 6, maxLines 7, maxLength 1000). Counter custom no label header ("N / 1000") com cor verde `#086B53` quando ≥ 30 chars (mínimo válido), cor neutra abaixo disso. Validador: ≥ 30 chars.
- Sticky bottom: botão "Enviar proposta" purple full-width.
- No submit:
  - Form.validate()
  - Se ok: dismiss keyboard via FocusScope.unfocus(), mostra SnackBar verde `#086B53` floating com cantos arredondados ("Proposta enviada com sucesso! Você será notificado se for aceita."), e pop pra ProjectDetailView.
- Wire: o botão "Enviar proposta" do ProjectDetailView agora navega pra SendProposalView (substituindo o SnackBar placeholder).
- Smoke test que verifica títulos, labels do form, recap card.
```

### Output recebido:
```markdown
- Criou `lib/views/send_proposal_view.dart` (~440 linhas):
  - `SendProposalView` (StatefulWidget) com `Project` no construtor + GlobalKey<FormState> + 3 `TextEditingController` + listener no message controller pra atualizar o counter.
  - Layout: Column(_TopBar, Expanded(SingleChildScrollView(Form)), _BottomActionBar). `resizeToAvoidBottomInset: true` permite o teclado empurrar o body sem cobrir o input ativo.
  - `_ProjectRecap`: Container com border + Icon briefcase purple bg + textos hierárquicos (label uppercase, título 1 linha com ellipsis, budget+tipo).
  - `_TextInput` parametrizável: aceita `icon` (prefixIcon Material), `prefixText` (texto antes do conteúdo, ex.: "R$ "), `suffixText` (depois, ex.: "/h" ou "dias"), `inputFormatters`, `maxLines`/`minLines`/`maxLength`. `counterText: ''` desabilita o counter default do Flutter (uso meu próprio no label header).
  - Counter custom no label da mensagem: muda cor verde `#086B53` quando ≥30 chars, neutro abaixo. Reage via `_messageController.addListener` → `setState`.
  - `_ThousandsFormatter` (TextInputFormatter): retira tudo não-dígito, percorre da direita pra esquerda inserindo "." a cada 3 — mesma lógica do `_formatCurrency` do model mas adaptada pra input.
  - Submit: `Form.validate()` + dismiss keyboard + SnackBar verde floating + `Navigator.pop()`.
- Editou `lib/views/project_detail_view.dart`:
  - Import de `send_proposal_view.dart`.
  - O `_BottomActionBar.onSendProposal` antes mostrava SnackBar placeholder, agora navega com `Navigator.push(MaterialPageRoute(builder: (_) => SendProposalView(project: project)))`.
- Adicionou smoke test `SendProposalView builds with form + recap` verificando: "Enviar proposta" 2x (top bar + botão), "Propondo para", título do projeto, "Sua proposta", labels dos 3 fields.
- Pequena correção pós-analyze: `_slate400` declarado mas não usado em `_SendProposalViewState` (o `_TextInput` hint color é resolvido localmente). Removido no mesmo turno.
- Validação:
  - `flutter analyze` → `No issues found!` (após remover `_slate400`).
  - `flutter test` → `7 tests, all passed`.
```

### Resultado:
A IA implementou a tela de envio de proposta completa em uma iteração, com formatação custom de moeda, contador dinâmico de caracteres, e validação tripla. Pontos relevantes:

- **`_ThousandsFormatter` custom** em vez de adicionar `intl` (pacote pesado só pra um caso). É 8 linhas de Dart puro e atende. Quando i18n entrar no projeto, vale substituir pelo `NumberFormat` do `intl`.
- **Counter de caracteres dinâmico** com feedback de cor: verde quando o mínimo é atingido, neutro antes. Pequeno detalhe de UX que sinaliza "você já tem uma mensagem aceitável" sem precisar tentar submeter.
- **Layout com `resizeToAvoidBottomInset: true` + `Expanded(SingleChildScrollView)`** garante que o teclado não cobre os fields. O sticky bottom button continua visível porque está abaixo do Expanded.
- **SnackBar verde com canto arredondado floating** em vez do SnackBar padrão (que é cinza, retangular e na parte inferior). Reforça a noção de sucesso e combina com a paleta.
- **`Form.validate()` + dismiss keyboard antes do pop** evita o flicker do teclado fechando depois da navegação.

**Único warning interno corrigido**: `_slate400` declarado mas não usado — removido no mesmo turno (padrão de auto-correção que estou mantendo desde a Iteração 7).

**Decisão deferida**: a proposta enviada não é persistida em lugar nenhum. Quando Firestore entrar, o submit vai criar um doc em `proposals/{id}` com `clientId`, `freelancerId`, `value`, `message`, `daysEstimate`, `status: pending`. Por enquanto é só visual.

**Loop do Freelancer está fechado:**
```
Feed → Project Detail → Send Proposal → (submit) → volta pro Detail com SnackBar
```

Próximo passo: virar pro lado do **Cliente**. O candidato natural é o **Client Dashboard** (a HomeView do papel Cliente, paralela ao Feed do Freelancer) — vai ter resumo dos próprios projetos publicados + propostas recebidas + métricas básicas. Para isso, vai ser hora de modelar o roteamento condicional por papel: HomeView precisa decidir entre FeedView (Freelancer) e ClientDashboardView (Cliente) baseado em alguma fonte de role. Sem auth ainda, posso adicionar um seletor temporário de papel ou hardcodar pra demo.

---

## Iteração 10
### Prompt usado:
```plaintext
Como Iteração 10, implemente o **Client Dashboard** (HomeView no modo Cliente, paralela ao FeedView). Conforme protótipo do Stitch:

Conteúdo:
- Top header "Painel" + avatar circular purple.
- 3 cards de métricas verticais (full-width): label uppercase pequeno + valor grande em DM Sans bold + ícone circular colorido à direita. Métricas: Projetos ativos (12), Aguardando revisão (4, amarelo), Total de propostas (48, verde).
- CTA "Publicar Novo Projeto" purple full-width (52px, ícone + à esquerda). Tap mostra SnackBar.
- Seção "Projetos ativos" + link "Ver tudo →".
- 2 cards de projeto ativo (hero gradient + badge "MAIS DISCUTIDO" no primeiro, "N propostas" + "Ver projeto →" no rodapé).
- Seção "Aguardando aprovação".
- 2 cards menores: badge "AGUARDANDO REVISÃO" + título + link "Revisar agora →".

Roteamento condicional por papel:
- `HomeView` ganha `initialRole` (default Freelancer); state interno `_role` mutável.
- Tab 0 branchifica: Freelancer → FeedView, Cliente → ClientDashboardView.
- Tabs específicas por papel (Feed/Meus Trabalhos vs. Painel/Projetos; Mensagens/Perfil iguais).
- Login navega com Freelancer hardcoded; Signup passa `_selectedRole`.
- Profile tab tem caixa "MODO DEMO" com botão "Trocar para [outro papel]" — switch via setState, reseta tab pra 0.

Smoke tests:
- ClientDashboardView com viewport ampliado (`Size(800, 2000)`) + Scaffold wrapper.
- HomeView com `initialRole: UserRole.client` mostrando dashboard e tabs corretas.
```

### Output recebido:
```markdown
- Criou `lib/views/client_dashboard_view.dart` (~480 linhas):
  - StatelessWidget porque o conteúdo é mock estático.
  - 3 records privados: `_Metric`, `_ActiveProject`, `_PendingProject` com listas estáticas em PT-BR.
  - `CustomScrollView` com 7 slivers (header, métricas, CTA, section header Ativos, lista Ativos, section header Pendentes, lista Pendentes, padding).
  - 8 helpers privados: `_TopHeader`, `_MetricCard`, `_SectionHeader`, `_ActiveProjectCard`, `_PendingProjectCard`, `_Badge`, `_HeroPlaceholder`.
- Reescreveu `lib/views/home_view.dart` (~250 linhas):
  - `initialRole` no construtor (default Freelancer); `_role` state mutável.
  - 2 listas constantes de `_TabSpec` por papel; getter `_tabs` retorna a correta.
  - `_bodyForCurrentTab()`: tab 0 → FeedView ou ClientDashboardView; tab final (Profile) → `_ProfileTab` com switcher; demais → `_PlaceholderTab`.
  - `_ProfileTab` com caixa "MODO DEMO" + texto explicativo + `OutlinedButton.icon` "Trocar para [outro]".
- Editou `lib/views/login_view.dart`: import de UserRole + navegação com `initialRole: UserRole.freelancer`.
- Editou `lib/views/signup_view.dart`: navegação com `initialRole: _selectedRole!`.
- 2 testes novos:
  - `ClientDashboardView renders metrics + sections`: usa `tester.view.physicalSize = Size(800, 2000)` + `addTearDown(tester.view.reset)` pra cobrir toda a CustomScrollView. Envolvido em `Scaffold(body: ...)` pelo InkWell exigir Material.
  - `HomeView shows ClientDashboard when initialRole is client`: verifica "Publicar Novo Projeto", "Painel" 2x (header + tab label), "Projetos".
- 2 correções internas durante a iteração:
  - "Projetos ativos" 2x: label da métrica + título da seção. Mudou pra `findsNWidgets(2)`.
  - "Aguardando aprovação" caía abaixo do viewport default (800x600). Solução: aumentar viewport pra 800x2000.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.8s)` (zero warnings de primeira).
  - `flutter test` → `9 tests, all passed` (era 7).
```

### Resultado:
A IA implementou Dashboard + roteamento por papel + switcher demo numa única iteração. Pontos relevantes:

- **Tabs específicas por papel** (Feed/Meus Trabalhos vs. Painel/Projetos) refletem que o léxico do Freelancer ≠ Cliente. Inline em vez de abstrair — quando os 2 papéis convergirem mais, refatora.
- **`_role` como state interno + switcher no Profile**: abordagem mais simples. Quando Auth entrar, `initialRole` virá de `currentUser.role` e o switcher some.
- **`FilledButton.icon`** em vez de `FilledButton` + Row custom — Material já oferece e economiza 4 linhas.
- **2 correções internas no teste sem entrar em iteração de fix**: agora viraram padrão. A do viewport é uma armadilha conhecida do flutter_test quando se usa CustomScrollView grande — a partir desta iteração fica registrada como lesson learned aqui.

**Cobertura visual:**
- Modo Cliente: 4 tabs + 3 métricas + CTA + 2 ativos + 2 pendentes.
- Modo Freelancer: inalterado.

**Switcher demo:**
- Profile → "Trocar para Cliente/Freelancer" → setState muda `_role` e reseta `_currentTab = 0`. Bottom nav recarrega com tabs do outro papel.

**Decisões deferidas:**
- "Ver tudo", "Revisar agora", "Publicar Novo Projeto" são placeholders sem navegação ainda.
- A tab "Projetos" do Cliente eventualmente terá lista filtrável dos próprios projetos.

**Estado da navegação:**
```
SplashView → OnboardingView → LoginView ⇆ SignupView
                                  ↓
                              HomeView(initialRole)
                                  ├─ Freelancer:
                                  │    Feed → Project Detail → Send Proposal
                                  └─ Cliente:
                                       Painel (Dashboard) → placeholders
```

Próximo passo: **Criar Projeto** (publicar novo projeto), acessado pelo CTA do dashboard — paralelo do SendProposal mas no lado Cliente. OU iniciar a **integração Firebase** (Auth primeiro), que marca a transição "fase UI" → "fase backend" e destrava várias coisas (auth real, persistência, roteamento real por papel).

---

## Iteração 11
### Prompt usado:
```plaintext
Como Iteração 11, implemente a tela de **Criar Projeto** (CTA do Dashboard "Publicar Novo Projeto" → form de criação). Paralela ao SendProposal mas no lado Cliente.

Estrutura:
- Top bar: back + "Publicar projeto" centralizado.
- Form scrollável com 6 blocos:
  1. **Título** — TextField simples, validação ≥10 chars e ≤100.
  2. **Categoria** — Wrap de chips single-select (Design, Desenvolvimento, Marketing, Conteúdo, Outros). Mostra erro inline se nenhuma selecionada no submit.
  3. **Habilidades** — Wrap de chips multi-select (14 opções: UI/UX, Figma, Branding, Logo Design, Node.js, Python, React, Flutter, AWS, WordPress, PHP, SEO, Copywriting, Social Media). Contador "N selecionada(s)" no header. Mínimo 1.
  4. **Tipo de orçamento** — Segmented control custom (Preço fixo / Por hora). Pílula purple quando selecionada.
  5. **Valor (R$)** — 2 inputs side-by-side (Mínimo, Máximo) com prefix "R$ " e ThousandsFormatter. Validação: ambos > 0, max ≥ min.
  6. **Descrição do projeto** — multiline (6-7 linhas), validação ≥50 chars.
- Sticky bottom: botão "Publicar projeto" purple. No submit válido: SnackBar verde "Projeto publicado! Você receberá propostas em breve." + pop.

Refatoração de oportunidade:
- `_ThousandsFormatter` está em 2 telas (SendProposal e agora Criar Projeto). Extrair pra `lib/core/text_formatters.dart` como `ThousandsFormatter` público. Atualizar SendProposal pra usar o compartilhado.

Wire:
- CTA "Publicar Novo Projeto" no ClientDashboardView agora navega pra CreateProjectView (em vez do SnackBar placeholder).

Smoke test com viewport ampliado.
```

### Output recebido:
```markdown
- Criou `lib/core/text_formatters.dart` com `ThousandsFormatter` público (mesma lógica do helper privado anterior).
- Editou `lib/views/send_proposal_view.dart`:
  - Import do `ThousandsFormatter` compartilhado.
  - Trocou referência de `_ThousandsFormatter()` para `ThousandsFormatter()`.
  - Removeu a definição duplicada no final do arquivo.
- Criou `lib/views/create_project_view.dart` (~540 linhas):
  - StatefulWidget com 4 controllers (título, minBudget, maxBudget, descrição) + 3 estados não-form (`_selectedCategory`, `_selectedSkills` como Set, `_budgetType` enum, flags de erro `_showCategoryError`, `_showSkillsError`).
  - Enum privado `_BudgetType { fixed, hourly }`.
  - Lista constante de 5 categorias e 14 habilidades.
  - `_SelectableChip` (StatelessWidget) reutilizável: aceita `selected`, `onTap`, `compact` (true pra skills, false pra categorias). Quando selected: bg purple/22 dark ou purple/10 light, border purple 1.5px, ícone check à esquerda, label em bold purple.
  - `_BudgetTypeSegmented` (StatelessWidget) custom: Container com padding 4px + Row de 2 segments; segment selected tem bg purple sólido + texto branco.
  - Label do bloco de valor muda dinamicamente: "Faixa de orçamento (R$)" pro fixed, "Valor por hora (R$)" pro hourly.
  - Validação tripla (Form.validate + categoria + habilidades). Erros não-form via flags `_show*Error` + Text vermelho inline.
  - `_validateMaxBudget` cruza com `_minBudgetController.text` pra garantir max ≥ min.
  - Submit: dismiss keyboard + SnackBar verde floating "Projeto publicado! Você receberá propostas em breve." + pop.
- Editou `lib/views/client_dashboard_view.dart`:
  - Import de `create_project_view.dart`.
  - CTA "Publicar Novo Projeto" antes mostrava SnackBar; agora navega com `Navigator.push(MaterialPageRoute(builder: (_) => CreateProjectView()))`.
- Adicionou smoke test `CreateProjectView builds with form + chips + segmented` com viewport `Size(800, 2000)` (form é alto), verificando: "Publicar projeto" 2x, "Conte-nos sobre o projeto", labels dos 6 blocos, "Design" (1ª categoria), "Preço fixo", "Por hora".
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.8s)` (zero warnings de primeira).
  - `flutter test` → `10 tests, all passed` (era 9).
```

### Resultado:
Iteração limpa, sem retentativas. Decisões relevantes:

- **Refator de `ThousandsFormatter` no momento certo**: a 3ª ocorrência iminente justificou extrair pra `core/text_formatters.dart`. SendProposal foi migrado no mesmo turno — sem regressão (smoke test continua passando porque o comportamento é idêntico). Padrão "extrair na 3ª duplicação" virou diretriz prática.
- **`_SelectableChip` parametrizado pelo `compact`** em vez de criar 2 widgets separados (um pra categoria, um pra skills). Mesma estética, só ajusta padding e font-size.
- **`_BudgetTypeSegmented` custom** em vez de usar `SegmentedButton` do Material 3. Razão: o SegmentedButton tem padrão de borda externa contínua e cantos compartilhados que conflitam com o padrão do app (pílula full purple solid). Custom dá mais controle.
- **Label do bloco de valor é dinâmico**: muda baseado em `_budgetType`. Pequeno detalhe que dá feedback ao usuário ("estou pedindo valor por hora ou faixa fixa?").
- **Validação cruzada de max ≥ min**: `_validateMaxBudget` lê o `_minBudgetController.text` no momento da validação. Não é reativa (só dispara em validate, não atualiza em tempo real ao mudar o min) — aceitável; uma versão reativa exigiria listener no min controller que re-valida o max.
- **`_TextInput` ainda duplicado** entre Login, Signup, SendProposal e agora CreateProject. As 4 instâncias têm pequenas variações de capabilities (alguns têm icon, outros prefixText). Extração via parâmetros opcionais é viável mas adiciona complexidade — vou aguardar mais ocorrências antes de consolidar.

**Loop do Cliente fechado:**
```
Dashboard → "Publicar Novo Projeto" → CreateProject form → (submit) → volta pro Dashboard
```

**Estado completo da navegação:**
```
Splash → Onboarding → Login ⇆ Signup
                        ↓
                    HomeView(initialRole)
                        ├─ Freelancer:
                        │   Feed → Detail → Send Proposal
                        └─ Cliente:
                            Dashboard → Create Project
```

**Próximo passo:** virar pra fase de **integração Firebase** — o usuário já criou o projeto `freelance-hub-c53e2` e quer rodar `flutterfire configure`. Marca transição UI → backend. Vai ser a Iteração 12.

---

## Iteração 12
### Prompt usado:
```plaintext
Como Iteração 12, faça a **integração inicial do Firebase** (pure plumbing — só base, sem auth/firestore/storage ainda):

1. Instalar `flutterfire_cli` globalmente.
2. Rodar `flutterfire configure --project=freelance-hub-c53e2 --platforms=android,ios --yes`. Esperado: registrar apps Android+iOS no projeto Firebase `freelance-hub-c53e2`, gerar `lib/firebase_options.dart` com `DefaultFirebaseOptions`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `firebase.json` na raiz, e atualizar `android/app/build.gradle.kts`, `android/settings.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj` pra registrar os plugins/configs nativos.
3. Adicionar `firebase_core: ^3.6.0` ao `pubspec.yaml`.
4. Atualizar `lib/main.dart`:
   - `Future<void> main() async`.
   - `WidgetsFlutterBinding.ensureInitialized()`.
   - `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` antes de `runApp`.
5. Rodar `flutter pub get`.
6. Garantir que `flutter analyze` continua 0 issues e que os 10 testes existentes continuam passando (testes montam widgets via `pumpWidget` direto, não passam pelo `main()`, então o `Firebase.initializeApp` não é disparado em teste — não precisa mockar).

Esta iteração NÃO inclui:
- Firebase Auth (próxima iteração)
- Cloud Firestore (depois)
- Storage / FCM / Functions (depois)
- Login real (continua navegando pra HomeView sem autenticar)
```

### Output recebido:
```markdown
- Instalou `flutterfire_cli 1.3.2` globalmente via `dart pub global activate`. Notou que `$HOME/.pub-cache/bin` não está no PATH e usou `export PATH="$PATH":"$HOME/.pub-cache/bin"` inline pras chamadas subsequentes.
- Confirmou que o Firebase CLI já estava logado (`firebase projects:list` retornou `freelance-hub-c53e2` na lista).
- Rodou `flutterfire configure --project=freelance-hub-c53e2 --platforms=android,ios --yes`:
  - Registrou novo Firebase Android app: `1:769113492542:android:6c80e2652778acdfca956f`
  - Registrou novo Firebase iOS app: `1:769113492542:ios:f831c693d4e92aa7ca956f`
  - Gerou `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `firebase.json` (raiz)
  - Atualizou `android/app/build.gradle.kts` (plugin google-services), `android/settings.gradle.kts` (classpath), `ios/Runner.xcodeproj/project.pbxproj` (registra GoogleService-Info.plist no bundle)
- Editou `pubspec.yaml`: adicionou `firebase_core: ^3.6.0` ao bloco `dependencies`.
- Editou `lib/main.dart`:
  - Adicionou imports de `package:firebase_core/firebase_core.dart` e `'firebase_options.dart'`.
  - Mudou assinatura pra `Future<void> main() async`.
  - Adicionou `WidgetsFlutterBinding.ensureInitialized()` e `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` antes do `runApp`.
- Validação:
  - `flutter pub get` → `Got dependencies!` (firebase_core 3.6.0 instalado + transitive deps).
  - `flutter analyze` → `No issues found! (ran in 1.7s)`.
  - `flutter test` → `10 tests, all passed` (mesmos 10 da iteração 11 — Firebase init não dispara porque tests não chamam `main()`).
```

### Resultado:
Iteração de infra limpa, sem retentativas. Pontos relevantes:

- **PATH não setado** após `pub global activate` é um gotcha conhecido do Dart. A IA detectou pela mensagem de warning do pub e usou `export PATH=...` inline pras chamadas seguintes — sem precisar editar `.zshrc` do usuário (que seria intrusivo). O usuário pode adicionar permanentemente depois se quiser usar `flutterfire` diretamente no terminal.
- **`--yes` + `--platforms` no flutterfire** evitou o modo interativo (que pergunta plataforma por plataforma). Útil pra automação.
- **Tests continuam verdes sem mock do Firebase**: a estratégia atual do `widget_test.dart` é montar widgets isolados via `MaterialApp(home: SomeView())` ou `pumpWidget(FreelanceHubApp())`. Em nenhum caso o `main()` real é chamado, então `Firebase.initializeApp` nunca dispara em ambiente de teste. Quando começar a usar Firebase Auth / Firestore dentro das views, vou precisar de mocks (`firebase_auth_mocks`, `fake_cloud_firestore` ou Riverpod overrides).
- **Arquivos gerados commitados**: `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`, `firebase.json` — todos vão pro repo. Padrão da comunidade Firebase: essas chaves não são "secret" no sentido tradicional (são restritas por package/bundle ID + App Check + Security Rules); a real segurança vem das Rules + RBAC nos backends. Pra um TCC, é OK e segue a recomendação oficial.

**Notas pra próxima iteração:**
- O `flutter run` em iOS vai precisar de `pod install` pelos novos plugins nativos. Hot restart NÃO basta — stop + run completo na primeira vez.
- `pubspec.lock` foi regenerado com várias deps transitivas do firebase_core (`plugin_platform_interface`, `firebase_core_platform_interface`, `firebase_core_web`, etc.).
- O app continua funcionando exatamente como antes — Firebase está inicializado mas nenhuma view o consome ainda.

**Próximo passo:** **Iteração 13 — Firebase Auth**:
- Adicionar `firebase_auth` ao pubspec.
- Substituir o navegação placeholder do Login (que só pulava pra HomeView) por `signInWithEmailAndPassword`.
- Substituir o submit do Signup por `createUserWithEmailAndPassword` + criar doc em `users/{uid}` com o role selecionado (mas Firestore ainda não tá instalado — pode persistir só na memória até a iteração de Firestore, ou já adicionar Firestore junto).
- Decisão deferida: fazer Iteração 13 só de Auth, ou Iteração 13 = Auth + Firestore (pra já ter user role persistido)?

---

## Iteração 13
### Prompt usado:
```plaintext
Como Iteração 13, integre **Firebase Auth + Cloud Firestore juntos** (opção B aprovada — sem auth o role não persiste, não vale a pena fazer separado). Escopo:

1. Adicionar `firebase_auth: ^5.3.1` e `cloud_firestore: ^5.4.4` ao pubspec.
2. Criar `lib/models/app_user.dart` com classe `AppUser` (uid, email, displayName, role).
3. Criar `lib/core/services/auth_service.dart` (singleton estático):
   - `signUp({email, password, displayName, role})` → createUserWithEmailAndPassword + updateDisplayName + criar doc em `users/{uid}` com `{email, displayName, role.name, createdAt: FieldValue.serverTimestamp()}`.
   - `signIn({email, password})` → signInWithEmailAndPassword + buscar doc em `users/{uid}` + retornar `AppUser`.
   - `currentAppUser()` → se `_auth.currentUser != null`, busca doc e retorna `AppUser?`.
   - `signOut()`.
   - `mapAuthError(FirebaseAuthException)` → traduz códigos pro português (invalid-email, wrong-password, email-already-in-use, weak-password, too-many-requests, network-request-failed, etc.).
4. Atualizar LoginView:
   - `_isSubmitting` state flag.
   - `_handleLogin` async: dismiss keyboard + setState(_isSubmitting=true) + try AuthService.signIn / catch FirebaseAuthException → SnackBar vermelho com mapeamento PT.
   - Botão "Entrar": `onPressed: _isSubmitting ? null : _handleLogin`. Mostra CircularProgressIndicator branco no lugar do label quando submetendo. Disabled bg alpha 0.5.
   - "Continuar com Google" agora só mostra SnackBar "em breve" (Google Sign-In vai precisar de outro pacote + setup OAuth).
5. Atualizar SignupView: igual ao Login, com `_isSubmitting` + try AuthService.signUp + error SnackBar. No success usa `pushAndRemoveUntil` (sem possibilidade de voltar pro Signup após criar conta).
6. Atualizar SplashView:
   - `_goToNext` agora async.
   - Se `Firebase.apps.isNotEmpty`: tenta `AuthService.currentAppUser()`; se retorna user válido, pushReplacement pra HomeView(initialRole: user.role).
   - Senão (ou erro): segue pro fluxo de OnboardingView.
   - Guard `Firebase.apps.isNotEmpty` é essencial pra widget tests não quebrarem (tests não chamam main(), Firebase nunca inicializa).
7. Atualizar HomeView _ProfileTab:
   - Remover o switcher demo "Trocar para X" (não tem mais utilidade — agora o user troca de papel deslogando e cadastrando como outro).
   - Tornar `_role` `late final` (não muta mais).
   - Adicionar botão "Sair" vermelho que chama AuthService.signOut + pushAndRemoveUntil pra LoginView.
   - Visual do Profile: avatar grande purple + "Você está como X" + botão Sair.
8. Criar `firestore.rules` no repo com regras pra `users/{uid}`:
   - read: qualquer authenticated (perfil é público dentro do app).
   - create: só pelo próprio uid, role precisa ser 'client' ou 'freelancer'.
   - update: só pelo próprio uid, role não pode mudar após criação.
   - delete: bloqueado.
9. Atualizar `firebase.json` pra referenciar `firestore.rules` (mas NÃO deploy automático — usuário decide quando deployar com `firebase deploy --only firestore:rules`).
```

### Output recebido:
```markdown
- pubspec.yaml: +firebase_auth ^5.3.1, +cloud_firestore ^5.4.4. `flutter pub get` resolveu 20 transitive deps.
- Criou `lib/models/app_user.dart` (~15 linhas): classe imutável com 4 campos.
- Criou `lib/core/services/auth_service.dart` (~110 linhas):
  - Singleton `AuthService.instance`.
  - 4 métodos públicos (signUp, signIn, currentAppUser, signOut) + `mapAuthError` + `_loadUser` privado.
  - `_loadUser` faz `.get()` em `users/{uid}`, parseia `role` via `UserRole.values.firstWhere` com fallback pra freelancer.
- Editou `lib/views/login_view.dart`:
  - Imports: firebase_auth, AuthService.
  - +`bool _isSubmitting`.
  - `_handleLogin` agora `Future<void>` com try/catch/finally. `FirebaseAuthException` → `_showError(mapAuthError(e))`. Outros erros → `'Erro inesperado: $e'`.
  - Botão "Entrar" desabilita durante submit e mostra spinner branco 22x22.
  - `_handleGoogleLogin` antes navegava pra HomeView; agora só mostra SnackBar "Login com Google em breve."
  - `_showError` helper: SnackBar floating vermelho `#BA1A1A` com texto branco.
- Editou `lib/views/signup_view.dart`:
  - Mesmo padrão: +_isSubmitting + async _handleSubmit + spinner + _showError.
  - Após signup bem-sucedido, `pushAndRemoveUntil` pra HomeView (limpa stack — não faz sentido voltar pro Signup).
- Editou `lib/views/splash_view.dart`:
  - +imports de firebase_core, AuthService, HomeView.
  - `_goToNext` virou async. Se `Firebase.apps.isNotEmpty` (não-test environment), tenta AuthService.currentAppUser. Se retorna user válido → pushReplacement pra HomeView com role. Senão → onboarding (caminho default).
- Editou `lib/views/home_view.dart`:
  - Removeu o switcher `onSwitchRole` e o `_ProfileTab` agora só tem `onSignOut`.
  - `_role` virou `late final`.
  - `_handleSignOut`: await AuthService.signOut + pushAndRemoveUntil(LoginView).
  - `_ProfileTab` redesenhado: avatar circular grande purple (Icons.person 44px) + título "Perfil" + "Você está como X" + "Edição de perfil em breve" + botão "Sair" vermelho com ícone logout.
- Criou `firestore.rules` (~25 linhas) com regras pra collection users/.
- Atualizou `firebase.json` adicionando `"firestore": {"rules": "firestore.rules"}` (também reformatou o JSON pra ficar legível).
- Pequena correção pós-analyze: warning de `_role` ser `final` (porque sem switcher não muta mais) — adicionado `final` ao late.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.8s)`.
  - `flutter test` → `10 tests, all passed`.
```

### Resultado:
Iteração grande e bem-sucedida. Pontos relevantes:

- **`AuthService` como singleton estático** (`AuthService.instance`) em vez de injeção via Riverpod/Provider. Decisão pragmática enquanto Riverpod não está instalado. Quando entrar (eventualmente), o singleton vira um `Provider<AuthService>` injetado e os call-sites mudam de `AuthService.instance.signIn` pra `ref.read(authServiceProvider).signIn`. Pouco churn quando chegar a hora.
- **Guard `Firebase.apps.isNotEmpty` no Splash** é o detalhe que mantém os 10 testes existentes passando sem precisar mockar Firebase. Em runtime de teste, `main()` não é chamado → Firebase nunca inicializa → guard pula a tentativa de leitura → vai pro onboarding (mesmo caminho de antes).
- **`mapAuthError` traduz códigos do Firebase pro PT-BR** (8 códigos cobertos + fallback). Erro genérico mostra `e.message ?? e.code` — adiciona ruído mas previne perda de informação útil.
- **SnackBar de erro com estilo dedicado** (vermelho, floating, rounded). Visualmente diferente do SnackBar de sucesso (verde) usado no SendProposal/CreateProject. Padrão consistente: verde pra sucesso, vermelho pra erro.
- **Sign-out vai pra LoginView (não Splash)**: melhor UX. Splash faria check de auth e tentaria buscar user que acabou de deslogar — passaria pelo mesmo guard mas adicionaria um delay de 3s desnecessário.
- **`pushAndRemoveUntil` no signup success**: garante que o stack fica só com HomeView. Sem isso, o usuário poderia apertar back e voltar pro form de signup com a conta já criada — fluxo confuso.
- **`firestore.rules` no repo** mas NÃO deployadas automaticamente. O usuário decide quando rodar `firebase deploy --only firestore:rules`. Razão: deploy é ação remota que afeta state real do projeto Firebase — deve ser explícita. Documento as regras antes mas executo só sob comando.

**Decisões críticas de segurança documentadas nas rules:**
- Leitura pública de `users/` (autenticado): necessária pra exibir nome/avatar do cliente em telas como ProjectDetailView. Documento sensível (senha hash, etc.) fica no Auth, não no Firestore.
- `role` não muda após criação: previne escalação de privilégio (cliente que quer virar freelancer ou vice-versa, ganhando acesso a fluxos que não deveria).
- Delete bloqueado: usuários não auto-deletam. Quando "Excluir conta" entrar, será via Cloud Function que valida + cascade nos outros docs.

**Pontos que precisam de ação manual do usuário antes do app funcionar:**
1. **Habilitar Email/Password Auth no console Firebase** (Firebase Console → Authentication → Sign-in method → Email/Password → Enable). Sem isso, signup retorna `operation-not-allowed`.
2. **Criar database Cloud Firestore no console** (Firebase Console → Firestore Database → Create database → Production mode ou Test mode). Sem isso, todas as operações falham com `failed-precondition`.
3. **Deployar as rules**: `firebase deploy --only firestore:rules` (opcional se já tá em test mode com regras permissivas; obrigatório em production mode).

**Próximo passo:** Iteração 14 — usar o auth real em telas que precisam saber quem é o usuário (ex.: o `clientName` no ProjectDetailView agora poderia vir do Firestore quando os projetos forem persistidos, mas projects ainda são mock). Ou: persistir os **projects no Firestore** — mover o `mockProjects` pra `projects/{id}` em Firestore + alimentar o FeedView via stream. Marca a transição final "mock → real backend".

---

## Iteração 14
### Prompt usado:
```plaintext
Como Iteração 14, persistir **Projects no Firestore** — transição "mock → backend real" pro feed e criação de projetos.

Refactor do model `Project`:
- Adicionar: `ownerId` (String), `status` (enum `ProjectStatus { open, active, delivered, completed, disputed, closed }`), `category` (String), `createdAt` (DateTime).
- Remover: `clientRating`, `clientProjectsCount` (voltam com Reviews depois), `postedAgo` (substituído por `createdAt`).
- Manter: `clientName` denormalizado no doc (escrito no createProject, atualizado se necessário no futuro via trigger).
- `relativePostedLabel({DateTime? now})` agora deriva de `createdAt`, e aceita `now` opcional pra testes determinísticos.
- `mockProjects` vira um getter (`List<Project> get mockProjects`) com `DateTime.now().subtract(...)` — útil pra testes e como fallback offline (no FeedView).

Criar `lib/core/services/projects_service.dart`:
- Singleton `ProjectsService.instance`.
- `streamOpenProjects()` — Stream<List<Project>>, query `where status==open` + `orderBy createdAt desc`.
- `streamMyProjects(ownerId)` — análogo, filtrado por owner.
- `createProject({...})` — Future<String>, add doc com `FieldValue.serverTimestamp()` e retorna id.
- `_fromDoc` privado mapeando Firestore → Project. Conversão de Timestamp → DateTime com fallback `?? DateTime.now()` pra docs com pendingWrites.

Wire:
- `FeedView`: state guarda `late final Stream<List<Project>>`. Inicializa com `Firebase.apps.isNotEmpty ? ProjectsService.instance.streamOpenProjects() : Stream.value(mockProjects)` — guard pra testes que não inicializam Firebase. StreamBuilder envolve o sliver com 4 estados (loading/erro/vazio/dados) via novo widget `_StateMessage`.
- `CreateProjectView`: `_handleSubmit` agora async — busca `AuthService.currentAppUser()`, chama `ProjectsService.createProject(...)`, mostra SnackBar verde no sucesso, vermelho no erro. Loading spinner no botão durante submit (`_isSubmitting`).
- `ProjectDetailView`: `_ClientCard` perde os params `rating`/`projectsCount`; passa a mostrar só nome + placeholder "Avaliações e portfólio em breve.".

Firestore rules pra `projects/{id}`:
- read: qualquer autenticado.
- create: só pelo próprio ownerId, status precisa ser 'open', proposalCount precisa ser 0.
- update: só pelo dono; ownerId, status e proposalCount são imutáveis (Cloud Function vai cuidar dessas mudanças).
- delete: só pelo dono, e só se status='open' e proposalCount=0 (sem propostas pendentes).
```

### Output recebido:
```markdown
- Rewriteu `lib/models/project.dart` (~150 linhas):
  - `enum ProjectStatus { open, active, delivered, completed, disputed, closed }`.
  - `Project` com 14 campos imutáveis + 3 helpers (`formattedBudget`, `budgetTypeLabel`, `relativePostedLabel`).
  - `relativePostedLabel` derivado de `createdAt`, suporta `now` opcional pra testes determinísticos.
  - `mockProjects` agora é getter retornando lista nova a cada chamada (datas relativas a `DateTime.now()`).
  - 4 mocks atualizados pro novo shape (com `ownerId: 'mock-owner-N'`, `category`, `createdAt: now.subtract(...)`, `status: open`).
- Criou `lib/core/services/projects_service.dart` (~85 linhas):
  - Singleton + 3 métodos públicos + `_fromDoc` privado.
  - `streamOpenProjects` faz `where status==open` + `orderBy createdAt desc`.
  - `createProject` retorna o doc id após `add`.
- Editou `lib/views/feed_view.dart`:
  - +import firebase_core e ProjectsService.
  - `_projectsStream` em `initState` com guard `Firebase.apps.isNotEmpty`.
  - StreamBuilder envolvendo o sliver da lista, com 4 estados:
    - loading (CircularProgressIndicator centrado, 40px padding).
    - erro (icone error_outline + título "Não foi possível carregar os projetos" + mensagem do erro).
    - vazio (icon inbox_outlined + "Nenhum projeto disponível" + texto explicativo).
    - dados (SliverList.separated como antes).
  - Novo widget `_StateMessage` reutilizado pra erro/vazio.
- Editou `lib/views/create_project_view.dart`:
  - +imports de AuthService e ProjectsService.
  - +`_isSubmitting` state.
  - `_handleSubmit` agora async: busca currentAppUser, valida sessão, chama createProject com parseamento dos campos numéricos. Try/catch com SnackBar verde/vermelho.
  - `_BottomActionBar` agora aceita `isSubmitting` e troca o label por CircularProgressIndicator quando submetendo. Disabled bg alpha 0.5.
- Editou `lib/views/project_detail_view.dart`:
  - `_ClientCard` removeu `rating` e `projectsCount` params; só nome + "Avaliações e portfólio em breve."
- Editou `firestore.rules`: adicionou bloco `match /projects/{projectId}` com 4 regras conforme spec.
- 2 correções internas:
  - Test `HomeView builds feed + bottom nav` quebrou porque `Stream.value(mockProjects)` emite no próximo microtask, não síncrono. Solução: `await tester.pump()` extra após `pumpWidget` pra deixar o StreamBuilder reconstruir com os dados. Comentado no teste.
  - Lint `prefer_final_fields` no `_role` (já era resolvido na 13 mas surgiu de novo? Não — esse era warning anterior já fixed).
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.9s)`.
  - `flutter test` → `10 tests, all passed`.
```

### Resultado:
Iteração ambiciosa de "mock → real backend" pra projects, executada limpa. Pontos relevantes:

- **Guard `Firebase.apps.isNotEmpty` no FeedView + fallback pra `mockProjects`** segue o padrão estabelecido no Splash (Iteração 13). Benefício duplo: tests funcionam sem mockar Firebase + dev pode rodar o app sem `flutter pub get` completo do Firebase pra avaliar a UI.
- **Stream.value emite assíncrono**: descoberta que custou 1 mini-correção interna (`await tester.pump()` extra). Lição: qualquer StreamBuilder em test exige pump adicional após o primeiro pumpWidget. Documentado no comentário do teste.
- **`createdAt` como DateTime em vez de Timestamp** mantém o model framework-agnostic (não importa cloud_firestore no model). A conversão Timestamp→DateTime acontece no `_fromDoc` do service. Quando o doc acabou de ser criado e o `serverTimestamp()` ainda não preencheu, `data['createdAt']` é null → fallback `?? DateTime.now()` previne crash.
- **Rules cuidadosas pra `projects/`**: ownerId, status e proposalCount são imutáveis via client. Isso fecha vetores de ataque (cliente não pode forjar projeto de outro user, freelancer não pode "fechar" projeto, ninguém pode inflar proposalCount). Quando Cloud Functions entrarem (Iteração de escrow), elas vão escrever esses campos via Admin SDK que ignora rules.
- **Denormalização do `clientName`**: opcional, controverso. Vantagem: 1 read por card no feed em vez de 1+N. Desvantagem: stale data se cliente troca nome. Aceitável pra MVP; sync via trigger quando virar problema real.
- **Decisão de não atualizar Client Dashboard ainda**: as métricas (12/4/48) e listas (Projetos ativos / Aguardando) do dashboard precisam de mais coleções (contracts, proposals agregadas) que ainda não existem. Fica em mock até a iteração de contracts.

**Setup necessário antes de validar:**
1. Firestore Database já criado (Iteração 13).
2. **Deployar firestore.rules**: `firebase deploy --only firestore:rules` (importante! As rules antigas só tinham `users/`; sem deploy, `projects/` cai no default "deny all" ou "allow all" dependendo do test mode).
3. Stop+run no app (não basta hot restart — refactor do model é grande).

**Como testar:**
1. Entra como Cliente. CTA "Publicar Novo Projeto" → preenche form → publicar.
2. Verifica em Firebase Console > Firestore > collection `projects/` — doc novo criado com todos os campos.
3. Desloga, cadastra/entra como Freelancer. O feed agora deve mostrar o projeto recém-criado (em "tempo real" via stream).
4. Cria outro projeto como Cliente em outra sessão — Freelancer vê aparecer instantaneamente no feed (Firestore listeners em ação).

**Próximo passo:** **Iteração 15 — Proposals no Firestore**. SendProposal hoje só mostra SnackBar; deve criar doc em `proposals/{id}` com `projectId`, `freelancerId`, `clientId`, `value`, `daysEstimate`, `message`, `status: pending`, `createdAt`. Também atualizar `proposalCount` do project... mas isso precisaria de Cloud Function (regra impede client de mexer em proposalCount). Decisão: ou (a) só criar o doc da proposal e deixar contador stale até CF, ou (b) já adicionar Cloud Function pra incrementar (introduz `functions/` no projeto).

---

## Iteração 15
### Prompt usado:
```plaintext
Como Iteração 15, persistir **Proposals no Firestore**. Opção (a) escolhida: só criar o doc da proposta, `proposalCount` do project fica stale até Cloud Function (iteração de escrow).

Modelagem:
- `lib/models/proposal.dart`: classe `Proposal` (id, projectId, projectTitle, freelancerId, freelancerName, clientId, value, daysEstimate, isHourly, message, status, createdAt). Enum `ProposalStatus { pending, accepted, rejected, withdrawn }`.
- Doc ID determinístico: `${projectId}_${freelancerId}` — previne duplicatas naturalmente (segunda tentativa do mesmo freelancer no mesmo projeto cai em "update" que as rules negam).

`lib/core/services/proposals_service.dart`:
- `createProposal(...)` com `set()` no doc ID determinístico.
- `streamProposalsForProject(projectId)` — pro Cliente ver propostas recebidas (UI vem depois).
- `streamProposalsByFreelancer(freelancerId)` — pra tab "Meus Trabalhos" (UI vem depois).

Wire SendProposalView:
- `_isSubmitting` state.
- `_handleSubmit` async: busca currentAppUser, chama createProposal com `widget.project.ownerId` como clientId e `widget.project.title` denormalizado.
- Loading spinner no botão.
- Error handling humanizado: `permission-denied` → "Você já enviou proposta para este projeto." (porque a 2ª tentativa cai em update bloqueado).

Firestore rules pra `proposals/{id}`:
- read: só freelancer dono OR cliente do projeto (campos `freelancerId`/`clientId` no doc).
- create: só pelo próprio freelancer, status pending obrigatório.
- update/delete: bloqueado (transições via Cloud Function depois).

Indexes:
- (projectId ASC, createdAt DESC) — pra streamProposalsForProject.
- (freelancerId ASC, createdAt DESC) — pra streamProposalsByFreelancer.

Deploy `firebase deploy --only firestore` (rules + indexes juntos).
```

### Output recebido:
```markdown
- Criou `lib/models/proposal.dart` (~30 linhas): classe imutável + enum.
- Criou `lib/core/services/proposals_service.dart` (~75 linhas): singleton + 3 métodos públicos + `_docId` privado + `_fromDoc` privado.
- Editou `lib/views/send_proposal_view.dart`:
  - +imports de AuthService e ProposalsService.
  - +`_isSubmitting` state.
  - `_handleSubmit` virou async: form.validate + busca currentAppUser + valida sessão + chama createProposal + SnackBar verde no sucesso + pop / SnackBar vermelho no erro.
  - `_humanizeError` detecta `permission-denied` no toString e mostra mensagem específica de duplicata.
  - `_BottomActionBar` agora aceita `isSubmitting` + `onSubmit` nullable; mostra spinner durante submit; disabled bg 0.5.
- Editou `firestore.rules`: bloco `match /proposals/{proposalId}` com 4 regras (read condicional, create restrito, update/delete false).
- Editou `firestore.indexes.json`: +2 índices compostos.
- `firebase deploy --only firestore` rodou: rules released + indexes deployed em ~5s.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.9s)`.
  - `flutter test` → `10 tests, all passed`.
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **Doc ID determinístico `${projectId}_${freelancerId}`** é o detalhe arquitetural mais importante desta iteração. Resolve o problema de duplicatas SEM precisar de Cloud Function ou validação client-side complexa (que pode ser burlada). Tradeoff: a UX da segunda tentativa é "erro genérico de permissão" em vez de validação inline ("você já propôs aqui"); mitigado pelo `_humanizeError`.
- **Denormalização agressiva**: `projectTitle` e `freelancerName` ficam no doc da proposta. Razão: as views futuras (Propostas Recebidas pro cliente, Meus Trabalhos pro freelancer) vão listar muitas propostas e ler title/name 1 vez por linha. Sem denormalização seria 1 doc proposta + 1 doc project + 1 doc user = 3 reads por linha. Com denormalização, 1 read. O custo é stale data se project/user mudarem — aceitável pro MVP.
- **`proposalCount` fica stale**: decisão consciente. O badge "X propostas" no feed e no detalhe vai estar errado pra projetos novos com propostas recebidas. Será corrigido na **Iteração de Cloud Functions** (próxima grande virada arquitetural) quando entrar o trigger `onCreate` em `proposals/` que increment `projects/{projectId}.proposalCount` via `FieldValue.increment(1)`.
- **Rules com `read` condicional sobre `resource.data`**: padrão usual de Firebase rules. Cliente lê proposals do seu projeto, freelancer lê as próprias. Sem leak entre freelancers, sem leak pra clientes que não são donos.
- **Indexes deployados junto** evita o erro "query requires an index" que apareceu na Iteração 14. Lesson learned aplicada.

**Cobertura visual continua a mesma** — nenhuma view nova nesta iteração; apenas o submit do SendProposal virou real. As próximas iterações vão expor essas propostas em UIs (Meus Trabalhos pro Freelancer, Propostas Recebidas pro Cliente).

**Fluxo testável agora:**
1. Cliente publica projeto (já funcionava na Iteração 14).
2. Freelancer abre o feed, tap em card, "Enviar proposta", preenche valor + prazo + mensagem, submete → **proposta criada em Firestore**.
3. Verifica no Firebase Console > Firestore > `proposals/` — doc com ID `{projectId}_{freelancerId}` deve aparecer.
4. Tentar enviar proposta de novo no mesmo projeto → SnackBar vermelho "Você já enviou proposta para este projeto."

**Próximo passo:** **Iteração 16** tem 2 candidatos naturais:
- **A — "Propostas Recebidas"** (UI do Cliente que lista propostas pros próprios projetos, com botão aceitar/rejeitar). Mas aceitar é o ponto de entrada pro contrato + escrow, que precisa de Cloud Function. Então essa iteração só lista (sem ações reais).
- **B — "Meus Trabalhos"** (UI do Freelancer que lista propostas enviadas, status atual de cada uma). Mais simples, sem dependência de Cloud Function.
- **C — Cloud Functions setup** (entra `functions/` no projeto, escreve trigger pra incrementar proposalCount + função callable `acceptProposal` pra criar contrato/transferir escrow). Maior, marca transição "transações reais".

Recomendação: B primeiro (UI freelancer fecha mais um loop visível), depois C (server-side é foundational e destrava A).

---

## Iteração 16
### Prompt usado:
```plaintext
Iteração 16 — "Meus Trabalhos" (opção B).

Tela acessada pela tab Freelancer (índice 1 do bottom nav) — hoje é _PlaceholderTab "Em breve". Substituir por uma view real que lista as propostas que o freelancer logado enviou, com status atual de cada uma.

Implementação:
- `lib/views/my_proposals_view.dart`:
  - StatefulWidget. initState busca `AuthService.instance.currentAppUser()` e usa o uid pra inicializar `ProposalsService.instance.streamProposalsByFreelancer(uid)`.
  - Guard `Firebase.apps.isEmpty` → stream vazia (mantém pattern do FeedView pra testes que não rodam main()).
  - Header simples: título "Meus Trabalhos" + descrição curta.
  - StreamBuilder com 4 estados: loading (CircularProgressIndicator), error (`_ErrorState`), empty (`_EmptyState`), data (lista de `_ProposalCard`).
  - `_ProposalCard`: projectTitle, badge de status colorido (Aguardando/Aceita/Recusada/Retirada), valor formatado, prazo em dias, data relativa.
  - Sem dependência nova — usa só `firebase_core`, `google_fonts`, e os models/services existentes.
- `lib/views/home_view.dart`: adiciona import + branch `if (_currentTab == 1 && _role == UserRole.freelancer) return const MyProposalsView();` antes do fallback de placeholder.
- Smoke test em `test/widget_test.dart` cobrindo empty state (Firebase.apps vazio → stream `[]` → renderiza `Nenhuma proposta ainda`).

Validar com `flutter analyze` + `flutter test`. Stage tudo pro commit.
```

### Output recebido:
```markdown
- Criou `lib/views/my_proposals_view.dart` (~330 linhas): MyProposalsView + _Header + _EmptyState + _ErrorState + _ProposalCard + _MetaItem + _StatusBadge.
- Editou `lib/views/home_view.dart`: +1 import e +1 branch no `_bodyForCurrentTab` (3 linhas adicionais).
- Editou `test/widget_test.dart`: +1 import + smoke test de empty state.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.8s)`.
  - `flutter test` → 11 passed (10 antes + 1 novo).
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **Stream inicializada após `await currentAppUser()`**: como o uid só está disponível assincronamente, a view começa com `_stream = null` (renderiza spinner), e o `setState` no callback do `_initStream` planta a stream real. Pattern simples, sem precisar de `FutureBuilder<Stream<...>>` aninhado.
- **Reuso de `streamProposalsByFreelancer`**: o método já existia desde a Iteração 15. Esta iteração apenas consumiu. Refletiu uma decisão acertada lá: criar os 2 streams (porProjeto/porFreelancer) já que dependem do mesmo índice composto.
- **Badge de status com paleta dedicada**: 4 status × 2 cores cada (background + foreground). Mantive todas as cores inline em `_specFor` em vez de criar tema, porque é a primeira (e por enquanto única) view que precisa delas. Se a tela do Cliente "Propostas Recebidas" reusar, extraio pra `core/`.
- **Formatadores duplicados (`_formatValue`, `_formatDays`, `_relativeDate`)**: convivem com versões parecidas em `Project.formattedBudget` e `Project.relativePostedLabel`. Não unifiquei porque Proposal não estende Project nem compartilha campos — extrair um `core/formatters.dart` agora seria abstração prematura. Quando a 3ª view duplicar, eu refatoro.
- **Guard `Firebase.apps.isEmpty` no initState**: igual ao FeedView. Sem isso, o teste rodaria `AuthService.currentAppUser()`, que chama `FirebaseAuth.instance.currentUser`, que crasha em PlatformException no test environment.

**Cobertura visual:**
- Tab "Meus Trabalhos" (Freelancer) agora tem conteúdo real.
- Tab "Painel" (Cliente) ainda é placeholder — virará a próxima view real (Iteração A) ou ficará pra depois de Cloud Functions.
- Mensagens (ambos) e Painel (Cliente, índice 1) continuam placeholders.

**Fluxo testável agora:**
1. Login como Freelancer sem propostas → tab "Meus Trabalhos" mostra empty state ("Nenhuma proposta ainda").
2. Envia proposta em um projeto via SendProposal (Iteração 15).
3. Volta pra tab "Meus Trabalhos" → o card da proposta aparece com badge "Aguardando" (status pending), valor, prazo, data relativa.
4. Stream é em tempo real: se o status mudar no Firestore (manualmente no Console, por enquanto), o badge atualiza sem precisar reabrir a tela.

**Próximo passo:** **Iteração 17** tem 2 candidatos:
- **A — "Propostas Recebidas"** (UI Cliente, agora simétrica ao Meus Trabalhos). Lista propostas dos projetos que o Cliente publicou, agrupadas por projeto. Aceitar/rejeitar continuam pendentes de Cloud Function — botões aparecem mas mostram SnackBar "Em breve".
- **C — Cloud Functions setup** (entra `functions/` no projeto, abre caminho pra incrementar `proposalCount`, mudar status de proposta, depois escrow). Marca a transição "primeira lógica server-side".

Recomendação: A agora (fecha o triângulo Cliente-publica → Freelancer-propõe → Cliente-vê) e depois C (destrava aceitar de verdade).

---

## Iteração 17
### Prompt usado:
```plaintext
Iteração 17 — "Propostas Recebidas" (opção A).

Substituir o placeholder da tab "Projetos" do Cliente (índice 1 do bottom nav) por uma view real que lista as propostas recebidas pelo Cliente nos projetos que ele publicou. Diferente do "Meus Trabalhos" do Freelancer, aqui as propostas devem ser **agrupadas por projeto** — Cliente raciocina em termos de projetos, não propostas isoladas.

Implementação:
- Add `streamProposalsByClient(clientId)` em `lib/core/services/proposals_service.dart`: query `where('clientId', isEqualTo: clientId).orderBy('createdAt', descending: true)`.
- Add índice composto (`clientId` ASC, `createdAt` DESC) em `firestore.indexes.json`. Deploy com `firebase deploy --only firestore`.
- Rules de read em `proposals/{id}` JÁ cobrem o Cliente (`resource.data.clientId == request.auth.uid`), nada a mudar.
- `lib/views/received_proposals_view.dart`:
  - StatefulWidget com o mesmo pattern do MyProposalsView (initState busca currentAppUser → seta stream; guard `Firebase.apps.isEmpty`).
  - Header "Projetos" + descrição.
  - 4 estados (loading/error/empty/data).
  - Agrupa propostas por `projectId` em memória (`_groupByProject` helper): ordena grupos pela proposta mais recente.
  - Cada grupo: header `<projectTitle>` + badge `N propostas`; abaixo, lista de `_ProposalCard`.
  - `_ProposalCard`: avatar com iniciais do freelancer (CircleAvatar fake — só cor primária + texto), nome, status badge, valor, prazo, mensagem (preview de 3 linhas), data relativa, botões "Rejeitar" (outlined vermelho) + "Aceitar" (filled roxo) — só pra status `pending`.
  - `onAccept`/`onReject` mostram SnackBar roxo "Aceitar/Rejeitar proposta chegará junto com Cloud Functions (próxima iteração)."
- HomeView: branch `if (_currentTab == 1 && _role == UserRole.client) return const ReceivedProposalsView();` antes do placeholder.
- Smoke test em `widget_test.dart` cobrindo empty state.

Validar `flutter analyze` + `flutter test`. Stage tudo.
```

### Output recebido:
```markdown
- Editou `lib/core/services/proposals_service.dart`: +1 método `streamProposalsByClient`.
- Editou `firestore.indexes.json`: +1 índice composto.
- Deploy firestore com sucesso (rules unchanged, 1 índice novo).
- Criou `lib/views/received_proposals_view.dart` (~470 linhas): ReceivedProposalsView + _Header + _StateMessage + _ProjectGroup + _ProposalCard + _MetaItem + _StatusBadge.
- Editou `lib/views/home_view.dart`: +1 import + +1 branch.
- Editou `test/widget_test.dart`: +1 import + smoke test de empty state.
- Validação:
  - `flutter analyze` → `No issues found! (ran in 1.9s)`.
  - `flutter test` → 12 passed (11 antes + 1 novo).
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **Agrupamento client-side por `projectId`**: a query retorna lista flat ordenada por `createdAt desc`; `_groupByProject` faz LinkedHashMap em memória e ordena os grupos pela proposta mais recente de cada um. Alternativa seria 1 query por projeto (mais reads, mais streams), ou subcoleção `projects/{id}/proposals/{id}` (refactor maior). A escolha atual é a mais barata em reads e a mais simples em código.
- **Botões "Aceitar"/"Rejeitar" stub'ados**: aparecem só em propostas `pending` e mostram SnackBar "Em breve". A escolha aqui é estabelecer a UI **antes** da Cloud Function, pra que a próxima iteração (C) seja só "trocar o callback do botão" — não precisar redesenhar layout. Padrão "UI primeiro, lógica depois" usado conscientemente.
- **`streamProposalsByClient` vs filtrar `streamProposalsForProject` 1-a-1**: optar pela query única + agrupar é justificado por (1) Firestore cobra por document read, então 1 query que retorna 30 docs custa o mesmo que 3 queries de 10; (2) listeners têm overhead de manutenção — 1 listener é mais barato que N; (3) a paginação futura (`limit` + `startAfter`) funciona melhor com query única.
- **Duplicação de helpers de formatação** (`_formatValue`, `_relativeDate`, `_StatusBadge`) com MyProposalsView. Conscientemente não extraí ainda. A duplicação é localmente óbvia, e cada view tem nuances próprias (label "enviada"/"recebida" do `_relativeDate`). Quando a terceira view precisar disso ou os designs convergirem 100%, extraio pra `core/proposal_formatters.dart`.
- **Avatar com iniciais**: solução compacta sem rede (sem `network_image` rot — lembrete da Iteração 1). `_initials` extrai 1-2 letras do nome; fallback "?" pra nome vazio. Estilo coerente com o resto do app.
- **Sem refactor do `ClientDashboardView`**: a tela "Painel" do Cliente continua mock estático com métricas hardcoded ("12 projetos ativos", "48 propostas"). Idealmente esses números viriam de queries reais (count de projects + count de proposals do clientId). Deixei intencional pra essa iteração — escopo seria muito maior. Quando vier o Cloud Function de `proposalCount` (Iteração C), aproveito pra renumerar as métricas reais.

**Cobertura visual:**
- Cliente: Painel (placeholder mock), **Projetos (novo, real)**, Mensagens (placeholder), Perfil (real).
- Freelancer: Feed (real), Meus Trabalhos (real), Mensagens (placeholder), Perfil (real).
- 6/8 tabs com conteúdo real. Mensagens vai precisar de outra collection + outra arquitetura (chat em tempo real); fica reservado pra iteração depois de Cloud Functions.

**Fluxo testável agora:**
1. Login como Cliente sem projetos → tab "Projetos" → empty state.
2. Publica projeto, desloga, entra como Freelancer.
3. Freelancer envia proposta nesse projeto (Iteração 15) e vê em "Meus Trabalhos" (Iteração 16).
4. Volta pra conta Cliente → tab "Projetos" → grupo do projeto aparece com a proposta, mostrando nome do freelancer, valor, prazo, mensagem completa, badge "Aguardando", botões "Aceitar"/"Rejeitar".
5. Tap em qualquer botão → SnackBar roxo "chegará junto com Cloud Functions".
6. Cliente abre 2 projetos diferentes, recebe propostas em ambos → tab "Projetos" mostra 2 grupos separados, cada um com seu título e propostas.

**Próximo passo:** **Iteração 18 — Cloud Functions setup (C)**. Marca a transição "primeira lógica server-side":
- `firebase init functions` introduz `functions/` no projeto (TypeScript ou JS; provavelmente TS).
- Primeira função: trigger `onCreate` em `proposals/{id}` que incrementa `proposals_count` no `projects/{projectId}` via `FieldValue.increment(1)`. Resolve a divergência da Iteração 14/15 onde `proposalCount` ficou stale.
- Segunda função: callable `acceptProposal({proposalId})` que (1) muda status da proposta pra `accepted`; (2) rejeita as outras propostas do mesmo projeto (`rejected`); (3) muda status do projeto pra `active`; (4) cria doc em `contracts/{id}` com referência cruzada. Tudo em transaction. Wire no botão "Aceitar" da Iteração 17.
- Terceira função: callable `rejectProposal({proposalId})` simples — muda status. Wire no botão "Rejeitar".
- Rules atualizadas pra permitir `proposalCount` ser escrito SÓ pelo service account (Cloud Function roda com privilégios elevados — mas o cliente continua bloqueado).
- Quando rolar, abre caminho pra escrow (`payment_intent` + Stripe ou similar) que seria a próxima.

---

## Iteração 18
### Prompt usado:
```plaintext
Iteração 18 — Cloud Functions setup (parte 1 do C, dividida em 2).

Decisão: dividir o setup de Cloud Functions em DUAS iterações em vez de uma só.
- Esta (18): infraestrutura + 1 trigger simples. Milestone visual = `proposalCount` no card do feed para de ficar stale.
- Próxima (19): callables `acceptProposal`/`rejectProposal` + wire nos botões da ReceivedProposalsView + collection `contracts/`.

Implementação (Iteração 18):
- Criar `functions/` (TypeScript) na raiz do projeto.
- `functions/package.json`: engines node 22; deps `firebase-admin` ^12.7, `firebase-functions` ^6.1; devDep `typescript` ^5.6.
- `functions/tsconfig.json`: strict, target es2020, outDir lib, module commonjs.
- `functions/.gitignore`: node_modules, lib, *.log, .env, .firebase.
- `functions/src/index.ts`: 1 trigger `onProposalCreated` (v2) em `proposals/{proposalId}` que atualiza `projects/{projectId}.proposalCount` via `FieldValue.increment(1)`. Validação defensiva: snapshot vazio → warn e return; projectId ausente → error e return. Try/catch envolvendo o update pra não derrubar a function se project foi deletado.
- `firebase.json`: adicionar bloco "functions" apontando pra `functions/`, runtime nodejs22, predeploy `npm run build`.
- `cd functions && npm install` (242 packages, warns de uuid deprecation são do firebase-tools — ignoráveis).
- `npm run build` → `lib/index.js` gerado.
- `firebase deploy --only functions`.
- Setar cleanup policy: `firebase functions:artifacts:setpolicy --location us-central1 --days 7` (apaga imagens Docker antigas — sem isso, Artifact Registry acumula cobrança).

Rules: NÃO precisam mudar. O Admin SDK (usado pelas Functions) bypassa rules totalmente — então `projects` continua com `request.resource.data.proposalCount == resource.data.proposalCount` bloqueando o cliente, mas a CF escreve livremente.

Validar `flutter analyze` + `flutter test` (intactos — sem código Dart tocado). Stage tudo, exceto `functions/node_modules/` e `functions/lib/` (gitignored).
```

### Output recebido:
```markdown
- Criou diretório `functions/` com 4 arquivos versionados (package.json, tsconfig.json, .gitignore, src/index.ts).
- Editou `firebase.json`: +bloco "functions" (runtime nodejs22, predeploy npm run build).
- `npm install` rodou ok (242 packages).
- `npm run build` rodou ok (tsc silencioso = sucesso).
- Primeiro `firebase deploy --only functions` falhou com "Permission denied while using the Eventarc Service Agent" — esperado em primeiro deploy v2 (APIs Eventarc, Cloud Build, Cloud Run, Artifact Registry sendo habilitadas pela 1ª vez e o Service Agent ainda propagando IAM).
- Aguardou ~90s. Re-deploy → `Successful create operation` pra `onProposalCreated(us-central1)`.
- Setou cleanup policy (7 dias) pra Artifact Registry.
- `flutter analyze` → No issues. `flutter test` → 12 passed.
```

### Resultado:
Iteração com 1 retry esperado (Service Agent propagation), sem alteração de código entre tentativas. Pontos relevantes:

- **Functions v2 vs v1**: usei v2 (`firebase-functions/v2`). v2 roda em Cloud Run nos bastidores (Cloud Functions 2nd Gen é só uma camada de abstração sobre Cloud Run). Vantagens: cold starts menores, concurrency configurável, region binding flexível. Tradeoff: setup inicial requer mais APIs habilitadas — 7 no total (cloudfunctions, cloudbuild, artifactregistry, eventarc, pubsub, run, storage). Por isso o primeiro deploy demora.
- **`setGlobalOptions({region: "us-central1"})`**: explicitar região na chamada do `setGlobalOptions` em vez de spalhar pelo trigger. `us-central1` é o default e mais barato. `southamerica-east1` (São Paulo) daria latência menor pro Brasil, mas custo 30-40% maior e cold starts piores. Pra TCC, `us-central1` está bom.
- **Trigger v2 vs v1 syntax**: v2 usa `onDocumentCreated('path', handler)`. Handler recebe `event` com `.data` (DocumentSnapshot) e `.params` (path params). Diferente de v1 que era `functions.firestore.document('path').onCreate((snap, ctx) => {...})`.
- **`FieldValue.increment(1)` vs `get + update`**: increment é **atômico no servidor** — se 2 propostas forem criadas em paralelo pro mesmo projeto, ambos triggers rodam, ambos chamam `increment(1)`, e o contador vai pra +2 sem race condition. Get+set perderia 1 dos 2.
- **Não retentei deploy automaticamente em loop**: o erro de Eventarc é raro (só 1ª deploy v2 de um projeto), então uma espera + retry manual é melhor que código retry sofisticado.
- **`.gitignore` em `functions/`**: `node_modules` (não versiona deps), `lib` (build artifact — gerado a partir de src). Sem isso, commit ficaria com 240+ arquivos JS desnecessários.
- **Não tem teste pra Function**: Functions v2 tem `firebase-functions-test`, mas pra 1 trigger trivial (apenas chama increment), não vale o setup. Será adicionado quando tiver callables com lógica de negócio (Iteração 19).
- **`proposalCount` retroativo**: o trigger só dispara em **NOVAS** propostas a partir de agora. Propostas que já existem no Firestore (ex: `eF5gO47WRWwmuNaU5PY5_...`) NÃO foram contadas — o card do projeto vai mostrar `0 propostas` se a única proposta foi criada antes desta iteração. Pra resetar, pode-se:
  1. Apagar todos os docs de `proposals/` no Console e refazer.
  2. Ou: executar um script one-shot (admin SDK local) que conta propostas por projectId e seta proposalCount. Fica pra "Iteração extra de migração" se precisar.

**Cobertura visual:**
- Sem nova tela. Mas o card do projeto (Feed e ClientDashboard) que tem `proposalCount` agora reflete realidade pra propostas criadas a partir desta iteração.

**Fluxo testável agora:**
1. Como Cliente, publica projeto novo (proposalCount começa em 0).
2. Como Freelancer, envia proposta nesse projeto.
3. Volta no Feed/ClientDashboard (a stream do `projects` é live) — após ~1-3s (latência do trigger), `proposalCount` no card vira `1`.
4. Cria 2ª proposta com outro freelancer → vira `2`.
5. Logs da function: `firebase functions:log` (espera ver `proposalCount incrementado`).

**Próximo passo (Iteração 19):** callables `acceptProposal` e `rejectProposal` em `functions/src/index.ts`:
- `acceptProposal({proposalId})`: validar caller == clientId; transaction: status da proposta → `accepted`, status do projeto → `active`, outras propostas pending do mesmo projeto → `rejected`, criar `contracts/{contractId}`.
- `rejectProposal({proposalId})`: validar caller == clientId; status da proposta → `rejected`.
- Adicionar dep `cloud_functions` ao `pubspec.yaml`.
- Wire nos botões da ReceivedProposalsView (substituir SnackBars stub por chamadas reais com loading state).
- Rules pra `contracts/{id}`: read se for parte; create/update/delete: false (só CF).

---

## Iteração 19
### Prompt usado:
```plaintext
Iteração 19 — callables acceptProposal/rejectProposal + wire UI + collection contracts/.

Server-side (functions/src/index.ts):
- `acceptProposal({proposalId})` callable v2:
  - Valida auth (HttpsError unauthenticated).
  - Valida proposalId string não-vazia (invalid-argument).
  - Transaction:
    - Lê proposta → not-found / permission-denied (caller != clientId) / failed-precondition (status != pending).
    - Lê projeto → not-found.
    - Lê outras propostas pending do mesmo projectId.
    - Update proposta → status accepted.
    - Update outras propostas → status rejected.
    - Update projeto → status active.
    - Set contracts/{auto-id} com projeto/cliente/freelancer/valor/dias/isHourly/acceptedProposalId/status active/createdAt.
  - Retorna {contractId}.
- `rejectProposal({proposalId})` callable v2:
  - Mesma validação (auth + caller + status pending).
  - Update simples → status rejected.

Rules (firestore.rules):
- Bloco match /contracts/{contractId}: read condicional (clientId OR freelancerId match request.auth.uid); create/update/delete false (só Cloud Function, que usa Admin SDK).

Cliente (Flutter):
- pubspec: + cloud_functions ^5.1.3. flutter pub get.
- proposals_service.dart: + métodos acceptProposal/rejectProposal que invocam as callables via FirebaseFunctions.instance.httpsCallable.
- received_proposals_view.dart:
  - State _processingId pra rastrear qual proposta está em transação.
  - _handleAccept/_handleReject async com try/catch + finally.
  - Botões disabled enquanto outra proposta processa (`actionsDisabled`); spinner inline quando ela mesma processa (`isProcessing`).
  - _humanizeError com switch case nos códigos da FirebaseFunctionsException (unauthenticated, permission-denied, failed-precondition, not-found, default).
  - SnackBar verde no sucesso, vermelho no erro.

Deploy: functions (build + deploy) e firestore (só rules). Valida analyze + test.
```

### Output recebido:
```markdown
- Editou `functions/src/index.ts` (+150 linhas): acceptProposal + rejectProposal callables.
- Build TS limpo. Deploy: rejectProposal e acceptProposal criadas; onProposalCreated atualizada (update incidental, sem mudança real).
- Editou `firestore.rules`: +bloco match /contracts/{contractId}. Deploy de rules.
- Editou `pubspec.yaml`: +`cloud_functions: ^5.1.3`. `flutter pub get` ok (warns de outdated em deps transitivas, nada novo).
- Editou `lib/core/services/proposals_service.dart`: +import cloud_functions, +campo _functions, +2 métodos públicos.
- Editou `lib/views/received_proposals_view.dart`:
  - +import cloud_functions.
  - +State _processingId; removeu helper _showComingSoon antigo.
  - +_handleAccept, _handleReject async.
  - +_humanizeError, +_showSnack.
  - _ProjectGroup + _ProposalCard ganharam parâmetros processingId/isProcessing/actionsDisabled. Botões disabled + spinner inline.
- Validação: flutter analyze 0 issues. flutter test 12 passed (intacto — o smoke test atual cobre só empty state).
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **Transaction com query interna**: `tx.get(query)` em `acceptProposal` lê todas as propostas pending do projeto numa snapshot consistente. Sem isso, race entre "lê outras pending" e "atualiza" poderia perder uma proposta nova. Custo: a query precisa estar resolvida ANTES de qualquer `tx.update`, regra do Firestore.
- **Outras propostas → rejected, não withdrawn**: `withdrawn` semanticamente é "freelancer desistiu"; `rejected` é "cliente passou". Quando o cliente aceita uma, as outras viraram inviáveis por culpa do cliente, não do freelancer — `rejected` está correto.
- **HttpsError com codes específicos**: `unauthenticated`, `permission-denied`, `failed-precondition`, `not-found`. O Flutter SDK propaga via `FirebaseFunctionsException.code`, e o `_humanizeError` traduz cada um pra PT-BR. Sem isso, o usuário veria stack traces crus.
- **`_processingId` em vez de bool simples**: o estado de loading é "qual proposta?" não "tem loading rolando?". Isso permite distinguir 3 estados visuais por proposta: idle, **eu** estou processando (spinner inline), **outra** está processando (disabled em cinza). Bool simples agruparia esses 2 últimos.
- **`Cloud Functions us-central1` + Flutter sem config**: o SDK do Flutter pega a região default (us-central1) automaticamente. Se mudássemos pra `southamerica-east1`, precisaria `FirebaseFunctions.instanceFor(region: 'southamerica-east1')`. Fica como nota pra futuro.
- **Sem modelo Contract.dart**: optei por NÃO criar o model Dart de `Contract` agora porque não há UI consumindo essa collection ainda. Quando vier a tela "Meus contratos", crio o model junto. Evita arquivo morto.
- **`disabledBackgroundColor`** explicitado no FilledButton "Aceitar": sem isso, o botão fica quase invisível em disabled (mesma cor com opacity baixa). Setei `_primary.withValues(alpha: 0.5)` pra continuar reconhecível.
- **Erro de transaction NÃO faz rollback de cobranças**: callables v2 são facturas por execução, mesmo que dêem rollback. Implicação: tentar `acceptProposal` várias vezes com input inválido custa por chamada. Mitigação: validar client-side antes (já fazemos — botão só aparece pra `pending`).

**Cobertura visual:**
- Botões "Aceitar"/"Rejeitar" na ReceivedProposalsView agora são **reais**.
- Sucesso muda 4 coisas simultaneamente em ~1-3s (transaction commit + stream propagate): status da proposta aceita vira `accepted` (badge verde em ambas views), outras pending viram `rejected` (badge vermelho), projeto sai do feed do Freelancer (filtro `status == open`), e um doc novo aparece em `contracts/` no Console.

**Fluxo testável agora:**
1. Cenário básico: Cliente publica projeto, 2 freelancers mandam propostas, Cliente aceita uma → confere que a aceita virou verde "Aceita" em "Meus Trabalhos" do freelancer vencedor, a outra virou vermelha "Recusada" em "Meus Trabalhos" do outro freelancer, e o projeto sumiu do feed público.
2. Firestore Console > `contracts/` → doc novo com auto-id e referência cruzada.
3. Cliente tenta aceitar uma proposta já aceita de outra sessão → SnackBar vermelho "Proposta não está mais pendente."
4. Cliente desconectado tenta aceitar → SnackBar vermelho "Sessão expirada."

**Próximo passo (Iteração 20):** **Meus Contratos** — primeira UI que consome `contracts/`. Pode ser tab nova ou aproveitar o placeholder "Painel" do Cliente. Implementação:
- `lib/models/contract.dart`: enum ContractStatus { active, delivered, completed, disputed }; model imutável.
- `lib/core/services/contracts_service.dart`: streamContractsByClient(uid), streamContractsByFreelancer(uid).
- Índices compostos: clientId+createdAt, freelancerId+createdAt.
- Tela `MyContractsView` (renomear "Painel" pro Cliente? Ou adicionar coluna nova?). Lista contratos com card: projectTitle, valor, prazo, status badge, contraparte (nome do cliente OU freelancer, dependendo do role logado), data.
- Talvez aproveitar pra renumerar as métricas do ClientDashboardView com counts reais (`Number of contracts.active`, etc).

---

## Iteração 20
### Prompt usado:
```plaintext
Iteração 20 — Meus Contratos.

Primeira UI que consome `contracts/`. Decisão arquitetural sobre onde colocar a entrada:
- Cliente e Freelancer ambos têm contratos (de pontos de vista opostos do mesmo doc). Em vez de uma tab dedicada (já tem 4) ou refactor de Painel/Feed/etc, expor a tela via botão na tab Perfil — visível pros dois roles, sem mudança em UI existente.

Implementação:
- `lib/models/contract.dart`: enum ContractStatus { active, delivered, completed, disputed }; classe imutável com todos os campos do doc no Firestore.
- `lib/core/services/contracts_service.dart`: singleton com 2 streams (streamContractsByClient + streamContractsByFreelancer) ordenadas por createdAt desc.
- `firestore.indexes.json`: +2 índices compostos (clientId+createdAt, freelancerId+createdAt). Deploy.
- `lib/views/my_contracts_view.dart`:
  - StatefulWidget. initState busca currentAppUser → seta _role + escolhe stream conforme role.
  - Scaffold com TopBar (botão voltar + título "Meus contratos") em vez de header sliver — não está num tab, é tela navegada.
  - StreamBuilder com 4 estados (loading/error/empty/data).
  - Card de contrato: projectTitle, status badge colorido (Em andamento/Entregue/Concluído/Em disputa), valor formatado, prazo, **contraparte** (label muda conforme viewer — Cliente vê "Freelancer: Nome X", Freelancer vê "Cliente: ..." placeholder porque não temos clientName denormalizado ainda), data relativa "iniciado há X".
- `lib/views/home_view.dart`: +import + +botão FilledButton "Meus contratos" antes do "Sair" no `_ProfileTab`, abre MyContractsView via push.
- Smoke test cobrindo empty state.

Validar analyze + test. Stage tudo.
```

### Output recebido:
```markdown
- Criou `lib/models/contract.dart` (~30 linhas).
- Criou `lib/core/services/contracts_service.dart` (~55 linhas, mesmo pattern do ProposalsService).
- Editou `firestore.indexes.json`: +2 índices contracts. Deploy ok.
- Criou `lib/views/my_contracts_view.dart` (~440 linhas): tela completa com TopBar próprio, status badge dedicado, contraparte adaptativa.
- Editou `lib/views/home_view.dart`: +import + +botão "Meus contratos" no Perfil tab.
- Editou `test/widget_test.dart`: +import + smoke test empty state.
- Validação: flutter analyze 0 issues. flutter test 13 passed (12 antes + 1 novo).
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **Tela navegada vs tab**: optei por push em vez de adicionar 5ª tab (ou substituir uma existente). Mantém o bottom nav simples e a tela ainda tem um "voltar" claro. Contratos não são consultados com a mesma frequência de Feed/Trabalhos/Projetos — não precisam de tab.
- **`_role` decide o stream**: detecta o role do user logado e usa `streamContractsByClient` ou `streamContractsByFreelancer`. Adaptação 100% client-side; o doc é o mesmo no Firestore, a diferença é só na query.
- **Contraparte adaptativa**: o label "Freelancer:" / "Cliente:" + o nome mudam conforme o role do viewer. Atualmente só `freelancerName` está denormalizado no doc — o `clientName` precisaria ser também. Por ora, o Freelancer vê "Cliente: Cliente" (placeholder genérico). Quando aceitar proposta evoluir pra denormalizar `clientName` também, o card fica correto bilateral.
- **Status badges com paleta diferente**: contratos usam roxo claro pra `active` (em andamento — neutro, esperançoso), âmbar pra `delivered` (entrega aguardando aprovação), verde pra `completed`, vermelho pra `disputed`. Diferente das propostas (pending/accepted/rejected/withdrawn) — semanticamente os 4 estados não correspondem 1:1. Mantive paleta separada por clareza.
- **`SystemUiOverlayStyle` no Scaffold da tela navegada**: replica o setup das outras telas (SendProposal, etc) — sem isso, em iOS a status bar fica off-tone quando entra na tela.
- **Não há "ações" no card de contrato**: o card é read-only nesta iteração. Botões de "Marcar entregue" (Freelancer) e "Aprovar entrega" (Cliente) virão na Iteração 21 (workflow de entrega) — vai precisar de + 2 callables.
- **Estrutura de dado robusta o suficiente pra disputas**: deixei `ContractStatus.disputed` no enum mesmo sem UI consumindo agora, porque mudar enum depois é refactor — deixar planejado é praticamente grátis.
- **Sem CTA pra abrir o projeto associado**: o card mostra `projectTitle` mas não navega pro `ProjectDetailView`. Por enquanto não vale a pena — a tela de detalhe foi feita pra projetos abertos no feed, status "Em andamento" exigiria uma vista diferente. Em vez de empilhar lógica de exibição condicional, defiro pra futuro.

**Cobertura visual:**
- Tab "Perfil" (ambos roles) agora tem 2 botões: "Meus contratos" (roxo primário) e "Sair" (outlined vermelho).
- Nova tela `MyContractsView` acessível via push.
- 9/10 telas reais (sobra Mensagens nos 2 roles — vai exigir collection nova + arquitetura de chat).

**Fluxo testável agora:**
1. Cenário completo: Cliente publica, Freelancer propõe, Cliente aceita → contrato é criado em `contracts/`.
2. Como Cliente: Perfil → "Meus contratos" → card aparece com nome do Freelancer + badge "Em andamento" + valor + prazo.
3. Como Freelancer (mesmo contrato): Perfil → "Meus contratos" → card aparece com "Cliente: Cliente" (placeholder) + mesmo restante. Stream live: se outro contrato for criado, aparece sem reload.
4. Empty state pros 2 roles antes de qualquer contrato existir.

**Próximo passo (Iteração 21):** workflow de **entrega** — primeira mudança de status pós-aceite.
- 2 callables novas: `markContractDelivered({contractId})` (só freelancer, status active → delivered) e `acceptContractDelivery({contractId})` (só cliente, status delivered → completed).
- Botões "Marcar entregue" (Freelancer) e "Aprovar entrega" / "Solicitar revisão" (Cliente) no card do contrato — só visíveis no status apropriado.
- Eventualmente, `disputed` precisaria de um fluxo separado (input de motivo, etc).
- Denormalizar `clientName` no Contract doc (mudança no `acceptProposal` lá no functions/index.ts) pra o card do Freelancer mostrar o nome do Cliente em vez de placeholder.

---

## Iteração 21
### Prompt usado:
```plaintext
Iteração 21 — workflow de entrega + denormalização de clientName.

Server-side (functions/src/index.ts):
- `acceptProposal`: dentro da transaction, ler `projectSnap.data().clientName` e gravar `clientName` no doc do contract criado. Resolve o placeholder "Cliente: Cliente" da Iteração 20.
- `markContractDelivered({contractId})` callable v2:
  - Validações: auth, contractId string não-vazia, contrato existe, caller == freelancerId, status atual == active.
  - Update simples: status → delivered.
- `acceptContractDelivery({contractId})` callable v2:
  - Validações: auth, contractId, contrato existe, caller == clientId, status atual == delivered.
  - Transaction: contract → completed, project → completed.

Rules: NÃO precisam mudar. Admin SDK bypassa update: false.

Cliente (Flutter):
- `lib/models/contract.dart`: +campo `clientName` (final String).
- `lib/core/services/contracts_service.dart`: +import cloud_functions, +campo _functions, +parse de clientName no _fromDoc, +métodos markDelivered/acceptDelivery (invocam callables).
- `lib/views/my_contracts_view.dart`:
  - +State _processingId (loading per-contract).
  - +_handleMarkDelivered, _handleAcceptDelivery, _humanizeError, _showSnack.
  - _ContractCard ganha 4 params: isProcessing, actionsDisabled, onMarkDelivered, onAcceptDelivery.
  - Trocar placeholder "Cliente" pelo `contract.clientName` real (fallback "Cliente" só se vazio — útil pra contratos antigos sem clientName).
  - Botões contextuais SÓ visíveis na intersecção status+role:
    - active + freelancer → FilledButton roxo "Marcar como entregue".
    - delivered + client → FilledButton verde "Aprovar entrega".
  - Spinner inline durante a chamada, disabled em outros cards enquanto processa.

Validar analyze + test. Stage tudo.

**Migração**: contratos antigos não têm clientName. O ?? '' no _fromDoc + fallback no display "rawCounterpartyName.isEmpty ? counterpartyLabel : rawCounterpartyName" mantém retrocompatibilidade — antigos seguem mostrando "Cliente", novos mostram o nome real.
```

### Output recebido:
```markdown
- Editou `functions/src/index.ts`:
  - acceptProposal: +leitura de clientName do project + grava no contract.
  - +markContractDelivered (44 linhas).
  - +acceptContractDelivery (51 linhas, com transaction).
- Build TS limpo. Deploy: markContractDelivered + acceptContractDelivery criadas; acceptProposal, rejectProposal, onProposalCreated atualizadas.
- Editou `lib/models/contract.dart`: +clientName required final String.
- Editou `lib/core/services/contracts_service.dart`: +cloud_functions, +_functions, +markDelivered/acceptDelivery, +clientName no _fromDoc.
- Editou `lib/views/my_contracts_view.dart`:
  - +import cloud_functions.
  - +_processingId, +2 handlers, +_humanizeError, +_showSnack.
  - _ContractCard recebe processingId/disabled/2 callbacks.
  - Counterparty name agora usa contract.clientName real (com fallback).
  - +2 botões contextuais (Marcar entregue / Aprovar entrega).
- Validação: flutter analyze 0 issues. flutter test 13 passed.
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **Update do acceptProposal foi cirúrgico**: 1 leitura adicional (`projectSnap.data().clientName`) + 1 campo a mais no `tx.set`. Continua dentro da mesma transaction (atomicidade garantida).
- **Botões contextuais por status + role**: a UI mostra apenas a ação que faz sentido pra quem está olhando, no momento certo do workflow. Combinações:
  - `active` + Cliente → nada (só lê — espera entrega).
  - `active` + Freelancer → "Marcar como entregue".
  - `delivered` + Freelancer → nada (só lê — espera aprovação).
  - `delivered` + Cliente → "Aprovar entrega".
  - `completed`, `disputed` → nada (terminal por ora).
- **Estado terminal `completed`**: a transação no `acceptContractDelivery` também muda o status do `project` pra `completed` — fechando o ciclo completo: `open → active → completed`. Já tinha esse status no enum desde a Iteração 14, mas era só decorativo. Agora é real.
- **Cores semânticas**: "Marcar entregue" é roxo (primário/positivo neutro), "Aprovar entrega" é verde (#086B53 — sucesso). Diferenças visuais transmitem "sim, isso é final" vs "isso só avança a etapa".
- **Migração de dados sem script**: contratos criados na Iteração 20 não têm `clientName`. O `?? ''` no parser + ternary no display permite que continuem funcionando — só vão mostrar o placeholder antigo até serem substituídos por contratos novos. Sem necessidade de script de backfill pra MVP.
- **Project lifecycle agora completo** (do ponto de vista de status): open (criação) → active (proposta aceita) → completed (entrega aprovada). O `delivered`/`disputed` no enum de Project não é usado mais — o ciclo de "entrega" agora vive no Contract, não no Project. **Devo limpar isso?** Não nesta iteração — mexer no enum implica refactor de filtros do feed e seria distração. Deixo nota pra futuro: enum Project deve ser reduzido pra `open | active | completed | closed`.
- **`acceptContractDelivery` retorna `{ok: true}` em vez de algo mais rico**: poderia retornar o contract atualizado pra a UI consumir, mas o stream já vai re-emitir em ~500ms via Firestore listener. Manter resposta pequena.

**Cobertura visual:**
- Card de contrato (Freelancer) agora mostra o nome real do Cliente (não mais "Cliente: Cliente").
- Botões "Marcar como entregue" (Freelancer/active) e "Aprovar entrega" (Cliente/delivered) — workflow completo de entrega.
- Estado terminal `completed` (badge verde) destaca contratos finalizados.

**Fluxo testável agora:**
1. Cenário fim-a-fim: Cliente publica → Freelancer propõe → Cliente aceita (contrato criado em status active com clientName real).
2. Freelancer abre "Meus contratos" → vê badge "Em andamento" + botão "Marcar como entregue".
3. Freelancer clica → spinner ~1-2s → SnackBar verde "Entrega registrada. Aguardando aprovação do cliente." → badge vira "Entregue" (âmbar).
4. Em paralelo (sessão Cliente): card atualiza pra status "Entregue" + botão "Aprovar entrega" aparece.
5. Cliente clica → spinner ~1-2s → SnackBar verde "Entrega aprovada! Contrato concluído." → badge vira "Concluído" (verde).
6. (Bônus) Firestore Console > `projects/{id}.status` agora é `completed`.

**Próximo passo (Iteração 22):** decisões abertas:
- **A — Mensagens** (chat freelancer ↔ cliente): collection `messages`, Streams paginados, sender/receiver, MaterialDateLabel agrupando. Destrava as 2 tabs "Mensagens" que ainda são placeholder. Maior iteração até agora (UI + arquitetura nova).
- **B — Native integration #1 (Câmera)**: enviar foto de perfil OU adicionar anexos no fluxo de entrega (Freelancer envia foto do trabalho ao marcar como entregue). Começa a abordar o requisito do TCC "recursos nativos" (camera, files, biometric, geolocation).
- **C — Disputas**: cliente solicita revisão em vez de aprovar; freelancer responde; ciclo de comunicação. Precisa de chat antes (A) ou input de texto inline.
- **D — Histórico de status no contract**: subcollection `contracts/{id}/events/` registrando cada mudança de status com timestamp e ator. Útil pra auditoria e timeline visual, mas não destrava nada visível agora.

Recomendação: **B — Câmera primeiro** (avança um requisito explícito do TCC e é uma iteração "redonda" de 1 recurso nativo) e depois **A — Mensagens** (maior, mas necessária pro fluxo realista).

---

## Iteração 22
### Prompt usado:
```plaintext
Iteração 22 — Câmera (recurso nativo #1).

Decisão de integração: anexar foto da entrega ao fluxo "Marcar como entregue" (em vez de foto de perfil) — mais coeso com workflow existente da Iteração 21, dá valor concreto pro Cliente (vê o resultado), e estabelece pattern de upload de mídia que vai ser reusado depois.

Server-side:
- Habilitar Firebase Storage (manual no Console — 1 clique).
- `storage.rules`: write se auth + size < 5MB + contentType image/*; read se auth (limitação MVP — sem custom claims, Storage rules não lêem Firestore).
- `firebase.json`: +bloco storage.
- `markContractDelivered` callable v2 atualizado:
  - Aceita `photoUrls?: string[]` opcional (até 10, cada uma deve ser https).
  - Valida shape (array, types, count, prefixo).
  - Grava `deliveryPhotoUrls` e `deliveredAt` no doc.
- Deploy functions + storage.

Cliente (Flutter):
- pubspec: +firebase_storage ^12.3.4, +image_picker ^1.1.2.
- iOS Info.plist: NSCameraUsageDescription + NSPhotoLibraryUsageDescription (sem isso, image_picker crasha com PlatformException ao primeiro uso).
- model contract.dart: +deliveryPhotoUrls List<String> required.
- contracts_service.dart: markDelivered aceita named param photoUrls.
- storage_service.dart NOVO: uploadDeliveryPhoto(contractId, file) → path `delivery_photos/{contractId}/{ts}_{rand}.{ext}`, contentType inferido, retorna download URL.
- my_contracts_view.dart:
  - _handleMarkDelivered agora abre BottomSheet (_DeliveryComposerSheet) primeiro:
    - Botões "Câmera" e "Galeria" (max 5 fotos).
    - Preview com thumbnail removível.
    - "Confirmar entrega" (com count ou "sem fotos").
  - Pop com lista → upload sequencial → callable com URLs.
  - SnackBar de sucesso menciona quantidade.
  - Card renderiza Row scrollable de thumbnails 72x72 quando deliveryPhotoUrls não-vazio. Loading/error placeholders.
  - Tap em thumbnail → _PhotoFullscreenView com InteractiveViewer (zoom 1x-4x).

Validar analyze + test. Stage tudo.
```

### Output recebido:
```markdown
- pubspec.yaml: +2 deps. pub get ok.
- iOS Info.plist: +NSCameraUsageDescription e NSPhotoLibraryUsageDescription.
- storage.rules NOVO + firebase.json +bloco storage.
- functions/src/index.ts: markContractDelivered aceita photoUrls com validação shape, grava deliveryPhotoUrls e deliveredAt. Build TS limpo.
- lib/models/contract.dart: +deliveryPhotoUrls.
- lib/core/services/contracts_service.dart: markDelivered named photoUrls; _fromDoc parse defensivo.
- lib/core/services/storage_service.dart NOVO (~55 linhas).
- lib/views/my_contracts_view.dart:
  - +dart:io, +image_picker, +storage_service imports.
  - _handleMarkDelivered virou async com sheet + upload sequencial + callable.
  - +_DeliveryComposerSheet StatefulWidget (~190 linhas).
  - +_ThumbWithRemove (~35 linhas).
  - +_PhotoFullscreenView (~30 linhas).
  - _ContractCard: +Row scrollable de thumbnails 72x72 com loadingBuilder/errorBuilder, tap abre fullscreen.
- Deploy: markContractDelivered update + storage rules released.
- Validação: flutter analyze 0 issues. flutter test 13 passed.
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **Por que entrega-com-foto em vez de foto-de-perfil**: foto de perfil seria um upload trivial mas não integraria com nenhum workflow já implementado. Entrega-com-foto fecha um loop real (Freelancer entrega → Cliente vê o resultado → aprova com evidência) e usa o pattern de "upload + URL grava em doc via callable" que vai ser reaproveitado em chat/anexos depois.
- **Upload no cliente, validação no server**: storage_service faz o upload e devolve URL; o callable só recebe a string. Vantagem: rede mais barata (a CF não precisa receber binário grande), Storage cobra pelo upload direto, e o pattern é padrão Firebase. Tradeoff: validação de "essa URL realmente é do meu storage" cai parcial — o callable valida prefixo https mas não confirma origem. Pra MVP, ok; pra produção, validaria via Cloud Function de download URL signed.
- **Upload sequencial vs concorrente**: o for await sobe uma foto por vez. Mais simples, e com 5 fotos no máximo a diferença em ux é ~2-3s. Quando crescer pra >10 fotos, paralelizar com Future.wait.
- **Path determinístico com timestamp + tag**: `{ms}_{rand6hex}.{ext}` evita colisões mesmo se 2 uploads acontecerem no mesmo millisecond. Substituiria por UUID em produção, mas sem dep extra.
- **`image_picker` configs**: `imageQuality: 85` + `maxWidth: 1920` cortam significativamente o tamanho da foto sem perda visual perceptível em mobile. Sem isso, fotos de iPhone modernas têm 3-5MB e atingem o ceiling de 5MB do rules.
- **Rules de Storage soltas no read**: aceito como limitação consciente. Storage rules não conseguem ler Firestore — pra restringir só às partes do contrato, precisaria de custom claims ou Cloud Function gerando signed URL. MVP-aceitável porque os paths usam IDs auto-gerados não-listáveis.
- **Sem Android testado**: o usuário usa iPhone. Adicionei permissões iOS no Info.plist. No Android, `image_picker` >= 1.x já não precisa de READ_EXTERNAL_STORAGE explícita (usa photo picker do SDK). Câmera nativa precisaria CAMERA — adicionar quando o usuário testar em Android.
- **`deliveredAt: serverTimestamp()` extra**: aproveitei pra registrar timestamp da transição. Hoje não tem UI consumindo, mas vai dar pra mostrar "Entregue em DD/MM" em iterações futuras sem migração.
- **Fullscreen viewer com InteractiveViewer**: built-in do Flutter, sem dep extra (`photo_view` seria mais rico mas pesado pra MVP).

**Cobertura visual:**
- Bottom sheet de composição da entrega — primeira UI nova com câmera/galeria nativas.
- Card de contrato com Row scrollable de thumbnails (visível pros dois lados).
- Tela fullscreen com zoom.
- Esses elementos materializam o requisito do TCC "integração com recursos nativos" pela primeira vez no projeto.

**Fluxo testável agora:**
1. Cenário fim-a-fim a partir do Cliente publica → Freelancer propõe → Cliente aceita (contrato criado).
2. Freelancer: Perfil → Meus contratos → "Marcar como entregue" → bottom sheet abre.
3. Tap "Câmera" (iOS pede permissão na 1ª vez) → tira foto → volta pro sheet com thumbnail. Pode adicionar mais via "Galeria" (até 5).
4. "Confirmar entrega (N)" → spinner ~3-8s (upload + callable) → SnackBar "Entrega registrada com N fotos. Aguardando aprovação." → badge vira "Entregue" + Row de thumbnails aparece no card.
5. Cliente (sessão paralela): card já mostra os thumbnails. Tap em qualquer um → fullscreen com pinch-to-zoom.
6. Cliente clica "Aprovar entrega" → contrato vira "Concluído".

**Próximo passo (Iteração 23):** decisões abertas:
- **A — Mensagens** (chat freelancer ↔ cliente): collection `messages`, modelagem 1-N por contract. Destrava as 2 tabs "Mensagens". Iteração grande — pode quebrar em 23a (modelo + envio) + 23b (lista + tempo real + grupos por dia).
- **B — Biometria/Auth nativo**: face_id/touch_id pro login (LocalAuthentication). Recurso nativo #2, mais isolado.
- **C — Geolocalização**: filtrar projetos por proximidade ou enviar localização no chat. Recurso nativo #3, mas precisa de filtro real no feed pra fazer sentido.
- **D — Notificações push**: FCM quando proposta é aceita, contrato entregue, etc. Reforça o tempo real.

Recomendação: **B — Biometria** como recurso nativo #2 (rápido, isolado, fortalece auth) e depois **A — Mensagens** (a maior pendência funcional).

---

## Iteração 23
### Prompt usado:
```plaintext
Iteração 23 — Notificações Push (Android-only, com TODO documentado pra iOS APNs).

Decisão de escopo: usuário priorizou notificações pra fechar o core (sobre biometria/recursos extras). Push REAL via FCM + Cloud Function — diferente do `flutter_local_notifications` do habit_flow, que era agendamento local. Aqui são eventos remotos que precisam chegar mesmo com app fechado.

Trade-off de plataforma: iOS push real precisa de APNs (Apple Developer Account, $99/ano). Como o usuário não tem, focamos Android. O código foi escrito pra falhar silenciosamente em iOS — getAPNSToken() retorna null → initialize() retorna early sem registrar nada. Quando o APNs for configurado, deve "só funcionar" sem mudanças.

Cliente (Flutter):
- pubspec: +firebase_messaging ^15.1.3.
- main.dart: +rootMessengerKey GlobalKey<ScaffoldMessengerState>; +scaffoldMessengerKey no MaterialApp.
- lib/core/services/notifications_service.dart NOVO (~150 linhas):
  - Singleton. initialize(uid, messengerKey):
    - Guard iOS (getAPNSToken == null → return).
    - requestPermission().
    - getToken() + arrayUnion em users/{uid}.fcmTokens.
    - onTokenRefresh → re-arrayUnion.
    - onMessage (foreground) → SnackBar via messengerKey.
  - dispose(uid): arrayRemove do token atual, cancela listeners.
  - top-level _backgroundMessageHandler annotated @pragma('vm:entry-point') — vazio porque SO já mostra notification automaticamente.
- home_view.dart: initState chama _initPushNotifications (com guard Firebase.apps.isEmpty pra testes). _handleSignOut chama dispose antes do AuthService.signOut.

Server (functions/src/index.ts):
- +import getMessaging from firebase-admin.
- +sendPushToUser(uid, notification, data) helper:
  - Lê users/{uid}.fcmTokens.
  - Promise.all em todos os tokens com try/catch individual.
  - Erros `messaging/registration-token-not-registered` e `messaging/invalid-registration-token` → arrayRemove.
  - android: { priority: "high" } pra entregar imediatamente.
- onProposalCreated: depois do increment, sendPushToUser(clientId, "Nova proposta recebida", body) com data {type: proposalCreated, projectId, proposalId}.
- NOVO trigger onProposalStatusChanged (onDocumentUpdated proposals/{id}):
  - diff de status; só age em pending → accepted/rejected.
  - sendPushToUser(freelancerId) com title "Proposta aceita!" ou "Proposta recusada".
- NOVO trigger onContractStatusChanged (onDocumentUpdated contracts/{id}):
  - active → delivered: push pro cliente "Entrega recebida".
  - delivered → completed: push pro freelancer "Contrato concluído!".

Validar analyze + test. Stage tudo.
```

### Output recebido:
```markdown
- pubspec.yaml: +firebase_messaging.
- main.dart: rootMessengerKey + scaffoldMessengerKey wired.
- lib/core/services/notifications_service.dart NOVO.
- lib/views/home_view.dart: +import Firebase + NotificationsService + rootMessengerKey, +initState, +_initPushNotifications (com guard Firebase.apps.isEmpty), +dispose call no signOut.
- functions/src/index.ts: +import getMessaging, +sendPushToUser helper (~50 linhas), push em onProposalCreated (clientId), 2 triggers novos onDocumentUpdated.
- Build TS limpo. Deploy: 2 funções novas criadas (onProposalStatusChanged + onContractStatusChanged), 5 atualizadas.
- Validação inicial: 2 testes de HomeView quebraram porque initState tentava ler Firebase. Corrigido com guard Firebase.apps.isEmpty (pattern já usado em FeedView/MyProposalsView).
- Re-validação: flutter analyze 0 issues. flutter test 13 passed.
```

### Resultado:
Iteração coesa, sem retentativas além do guard de teste. Pontos relevantes:

- **Local notifications vs Push notifications (diferença explicada pro usuário)**: o habit_flow usava `flutter_local_notifications` (agendamento local, sem servidor, sem APNs, funciona iOS+Android grátis). Pro Freelance Hub, os eventos relevantes nascem no servidor (proposta nova, contrato entregue), então **só push real resolve**. Push real em iOS sempre passa por APNs (limitação da Apple, não do Firebase). $99/ano da Apple Developer Account é trava de plataforma — qualquer alternativa (OneSignal, AWS SNS, etc) cai no mesmo lugar.
- **Strategy "Android-funciona-iOS-cala"**: o `initialize()` detecta iOS sem APNs no `getAPNSToken()` (retorna null) e retorna early. Sem crashes, sem logs barulhentos. Quando o APNs for configurado, o mesmo código funciona — não precisa refactor.
- **Tokens em array (não single)**: `fcmTokens` é array pra suportar multi-device. Mesmo user logado em 2 celulares recebe push nos dois. Cleanup via `dispose()` no signOut + arrayRemove automático no servidor quando token vira inválido.
- **Triggers onDocumentUpdated em vez de embutir no callable**: poderia ter colocado o `sendPushToUser` direto nas callables `acceptProposal`/`rejectProposal`/`markContractDelivered`/`acceptContractDelivery`. Triggers são mais robustos — qualquer mudança de status (mesmo manual no Console pra debug) dispara push. Tradeoff: 2 invocações por evento em vez de 1 (custo Cloud Functions desprezível em escala TCC).
- **`android: { priority: "high" }` no send**: sem isso, FCM pode atrasar o push até alguns minutos pra economizar bateria. High priority é entrega imediata. Padrão pra notificações de UX, não pra background sync.
- **Top-level background handler vazio + `@pragma('vm:entry-point')`**: o plugin firebase_messaging precisa de uma referência top-level pra inicializar isolate em background. Vazio é correto porque o payload tem `notification`: o sistema operacional desenha a notificação sem precisar de código Dart rodando. Se a gente quisesse processar `data` em background (ex: pre-fetch antes do user clicar), aí o handler teria conteúdo.
- **Foreground SnackBar via `rootMessengerKey`**: a `GlobalKey<ScaffoldMessengerState>` está no `MaterialApp` em `main.dart`. Qualquer service pode mostrar SnackBar sem precisar de BuildContext. Pattern bom pra notificações vindo de fora do widget tree.
- **`_initPushNotifications` com guard `Firebase.apps.isEmpty`**: replica o pattern usado em FeedView/MyProposalsView/etc — em ambiente de teste, pula sem crashar.
- **Sem deep linking ao tocar notificação**: payload tem `data: {type, ids}` mas o app ainda não consome. Iteração futura conectaria `getInitialMessage()` + `onMessageOpenedApp` pra navegar pra tela relevante.

**Cobertura visual:**
- SnackBar in-app roxo com título + corpo quando push chega em foreground.
- Notificação nativa do sistema (Android) quando app em background/fechado.

**Fluxo testável agora (Android):**
1. Como Cliente logado → Console → users/{seuUid} → confere campo `fcmTokens` (array).
2. Em **outra sessão**, como Freelancer, envia uma proposta no projeto.
3. Cliente recebe push "Nova proposta recebida — Jose Silva enviou para [projeto]" — banner do sistema se app fechado, SnackBar in-app se aberto.
4. Cliente aceita → Freelancer recebe "Proposta aceita!".
5. Freelancer marca como entregue (com ou sem fotos) → Cliente recebe "Entrega recebida".
6. Cliente aprova → Freelancer recebe "Contrato concluído!".

**iOS:** todos os passos funcionam visualmente igual, exceto que NENHUM push chega no device. Logs mostram "iOS sem APNs configurado". Pra ativar, precisa criar APNs Authentication Key no Apple Developer Portal → upload no Firebase Console → testar em device físico (simulator não recebe APNs real até Xcode 14+ com .apns files).

**Próximo passo (Iteração 24):** voltar pro **core**. Candidatos:
- **A — Painel Cliente real** (`ClientDashboardView` sai do mock): contar projects, proposals e contracts do Cliente logado e mostrar métricas reais. Substituir "12 projetos ativos / 48 propostas" hardcoded por aggregates ao vivo.
- **B — Workflow de revisão** ("Solicitar revisão" no botão Cliente): hoje só tem "Aprovar entrega". Cliente recebeu entrega ruim, precisa devolver pro Freelancer corrigir. Novo status `revision_requested` no Contract + nova callable. Sem disputa formal ainda.
- **C — Detalhe do contrato** (tela nova quando tap no card de MyContractsView): timeline de eventos, fotos em grid, ações contextuais. Hoje o card mostra tudo achatado.

Recomendação: **A** (rápido, fecha um placeholder visível) **→ B** (destrava o ciclo realista de freelance — nem sempre entrega é aprovada de primeira) **→ C**.

---

## Iteração 24
### Prompt usado:
```plaintext
Iteração 24 — Painel Cliente real (opção A do plano).

Substituir o mock hardcoded ("12 / 4 / 48", 2 projetos fake na seção ativa, 2 na seção pendente) por aggregates ao vivo das collections Firestore do cliente logado.

Implementação:
- streamMyProjects(ownerId) já existe no ProjectsService desde a Iteração 14 — não preciso adicionar nada server-side. Usa índice composto (ownerId, createdAt) que também já existe.
- Refactor `lib/views/client_dashboard_view.dart` de StatelessWidget pra StatefulWidget:
  - 3 StreamSubscription privadas (projects, contracts, proposals).
  - initState chama `_initStreams`: guard Firebase.apps.isEmpty (pra testes), busca currentAppUser, assina os 3 streams. Cada listener chama setState armazenando a lista.
  - dispose cancela as 3 subs.
- Métricas computadas das listas:
  - "Projetos ativos" = count(projects where status in [open, active]) — semanticamente "em movimento", exclui completed/closed.
  - "Aguardando revisão" = count(contracts where status=delivered) — entregas aguardando aprovação do cliente.
  - "Total de propostas" = count(proposals) — histórico bruto.
- Listas (top 3 cada):
  - Seção "Projetos ativos" → mostra os 3 mais recentes em [open, active]. Card tap abre ProjectDetailView. Badge dinâmico: "EM ANDAMENTO" se status=active, "MAIS DISCUTIDO" se proposalCount>=5.
  - Seção "Aguardando aprovação" → mostra os 3 contracts delivered. Card tap abre MyContractsView.
- Empty states inline:
  - "Nenhum projeto em movimento ainda. Publique um pra começar a receber propostas."
  - "Nada pra revisar agora."
- Test ajustado: o assert `find.text('48')` (do mock) removido; agora valida labels textuais e os 2 empty states.

Validar analyze + test. Stage.
```

### Output recebido:
```markdown
- streamMyProjects já existia — pulou o passo de adicionar service method.
- Reescreveu `lib/views/client_dashboard_view.dart` (~640 → ~620 linhas, refactor + dados reais).
- Atualizou `test/widget_test.dart` pra refletir empty states.
- Validação: flutter analyze 0 issues. flutter test 13 passed.
```

### Resultado:
Iteração coesa, sem retentativas além do test update esperado. Pontos relevantes:

- **3 subs paralelas em vez de 1 stream combinado**: cada coleção tem seu próprio listener Firestore. Sem rxdart/CombineLatest. O custo é que o build pode rodar até 3x quando o user entra pela 1ª vez (cada stream emite separado), mas isso é imperceptível e o código fica mais simples de entender.
- **"Projetos ativos" inclui status=open**: discussão semântica que merece nota. "Ativo" pra um cliente típico significa "tô esperando rolar" (open com propostas chegando) OU "tá rolando" (active com freelancer entregando). Excluir open daria a métrica errada quando o cliente publicou e não aceitou ainda. Excluo completed/closed que são estados terminais.
- **Top 3 cards por seção**: limite arbitrário razoável. Sem paginação por enquanto. "Ver tudo" da seção continua com `onTap: () {}` — quando criar a tela Projetos do Cliente (vista completa) eu wiro.
- **Badge dinâmico no _ActiveProjectCard**: "EM ANDAMENTO" (status=active) vs "MAIS DISCUTIDO" (>=5 propostas). Heurística simples mas dá personalidade visual diferente. Pode evoluir pra "MAIS RECENTE" ou outros.
- **Tap em "Aguardando aprovação" abre MyContractsView**: leva o usuário pra tela onde tem o botão "Aprovar entrega" real (Iteração 21). Reuso natural — sem inventar nova tela.
- **`_SectionEmpty` inline**: containers cinza claros com ícone + texto. Diferente dos empty states fullscreen das outras views (MyProposalsView, etc) porque cabem inline numa página com várias seções. Padrão diferente justificado pelo contexto.
- **Sem skeleton/shimmer durante load**: quando o user abre o app pela 1ª vez, as 3 listas começam vazias (= mostra "0" e empty states) e depois preenchem em ~500ms. Skeleton seria nice-to-have mas adiciona complexidade pra ganho marginal — métricas mudando 0→N é aceitável visualmente.

**Cobertura visual:**
- Painel Cliente agora 100% real. As 3 métricas refletem dados do Firestore. Cards listam projects/contracts próprios.
- Push notification (Iteração 23) + Painel real (Iteração 24) trabalham juntas: quando uma proposta nova chega, o contador "Total de propostas" sobe AO VIVO sem reload (stream propaga em ~500ms).

**Fluxo testável agora:**
1. Como Cliente novo (sem nada) → Painel mostra 0/0/0 + 2 empty states ("Nenhum projeto em movimento..." e "Nada pra revisar agora.").
2. Publica 1 projeto → métrica "Projetos ativos" vira 1 em ~500ms + card aparece na seção.
3. Em outra sessão (Freelancer) → envia proposta → contador "Total de propostas" do Cliente sobe pra 1.
4. Cliente aceita proposta → status do project vira active → badge no card vira "EM ANDAMENTO".
5. Freelancer marca como entregue → métrica "Aguardando revisão" vira 1 + card aparece na seção "Aguardando aprovação".
6. Cliente tap no card "Aguardando revisão" → abre MyContractsView com o botão "Aprovar entrega" verde.
7. Aprova → contract vira completed → projeto sai da lista de ativos → métricas atualizam.

**Próximo passo (Iteração 25):** **B — Workflow de revisão** (botão "Solicitar revisão"). Hoje cliente só tem "Aprovar entrega"; cenário realista precisa devolver pro Freelancer corrigir.
- Novo status no Contract enum: `revisionRequested` (Dart) / `revision_requested` (Firestore).
- Callable `requestContractRevision({contractId, reason})`: status delivered → revision_requested. Cliente only.
- Callable `resubmitContractDelivery({contractId, photoUrls})`: status revision_requested → delivered. Freelancer only. Reusa lógica de upload.
- Trigger `onContractStatusChanged` já existe, vai precisar mais 2 branches no diff (delivered→revision_requested, revision_requested→delivered) com push pros 2 lados.
- UI MyContractsView: novo botão "Solicitar revisão" (Cliente) ao lado de "Aprovar entrega" quando status=delivered. Dialog/sheet pra capturar motivo. Badge "Em revisão" pro novo status. Quando freelancer vê revisionRequested, mostra botão "Reenviar entrega" (reabre o composer da Iteração 22).
- Visualização do motivo da revisão pro Freelancer.

---

## Iteração 25
### Prompt usado:
```plaintext
Iteração 25 — Workflow de revisão (opção B).

Cliente hoje só tem "Aprovar entrega" no contrato delivered. Adicionar o caminho "Solicitar revisão" + reenvio pelo freelancer, completando o ciclo realista.

Server (functions/src/index.ts):
- `requestContractRevision({contractId, reason})` callable v2:
  - Valida auth, contractId, reason (string trimmed, 10..500 chars).
  - Lê contract → not-found / permission-denied (caller != clientId) / failed-precondition (status != delivered).
  - Update: status → revision_requested, revisionReason, revisionRequestedAt timestamp, revisionCount += 1.
  - Não mexe no projeto — o projeto continua "active" durante revisão.
- `resubmitContractDelivery({contractId, photoUrls})` callable v2:
  - Mesma validação de markContractDelivered (auth, contractId, photoUrls shape).
  - Lê contract → not-found / permission-denied (caller != freelancerId) / failed-precondition (status != revision_requested).
  - Update: status → delivered, deliveryPhotoUrls (SUBSTITUI as anteriores), deliveredAt updated.
- Trigger `onContractStatusChanged` extends:
  - delivered → revision_requested: push pro freelancer "Revisão solicitada — {reason truncado a 80 chars}".
  - revision_requested → delivered: push pro cliente "Entrega reenviada — Toque para revisar".

Client (Flutter):
- model contract.dart: +ContractStatus.revisionRequested no enum. +revisionReason String, +revisionCount int.
- contracts_service.dart:
  - _fromDoc parse novos campos.
  - _parseStatus mapeia 'revision_requested' (snake) → ContractStatus.revisionRequested (camel).
  - +requestRevision(contractId, reason) e +resubmitDelivery(contractId, photoUrls).
- my_contracts_view.dart:
  - +_handleRequestRevision e +_handleResubmitDelivery (compartilha lógica de upload via _handleDelivery(isResubmit)).
  - +_RevisionReasonSheet bottom sheet com TextField (10..500 chars), botão laranja "Enviar solicitação" + Cancelar.
  - _DeliveryComposerSheet aceita isResubmit pra mudar título/labels ("Reenviar entrega" em vez de "Confirmar entrega").
  - Badge spec pra revisionRequested: laranja-âmbar "Revisão pedida".
  - Caixa "Revisão solicitada" mostrando revisionReason pro freelancer (e como histórico se revisionCount > 0).
  - Cliente vendo delivered agora vê 2 botões lado a lado: "Solicitar revisão" (outline laranja) + "Aprovar" (filled verde).
  - Freelancer vendo revisionRequested vê botão "Reenviar entrega" (filled roxo, ícone upload).

Validar analyze + test. Stage.
```

### Output recebido:
```markdown
- functions/src/index.ts: +requestContractRevision (~70 linhas), +resubmitContractDelivery (~80 linhas), +2 branches no onContractStatusChanged. Build TS limpo. Deploy: 2 funções novas criadas, 7 atualizadas.
- lib/models/contract.dart: +revisionRequested no enum, +revisionReason + revisionCount required.
- lib/core/services/contracts_service.dart: +2 métodos, +_parseStatus helper (snake↔camel), parse defensivo dos 2 campos novos.
- lib/views/my_contracts_view.dart:
  - +_handleRequestRevision, refactor _handleMarkDelivered/_handleResubmitDelivery em _handleDelivery(isResubmit).
  - _ContractCard ganha 2 callbacks (onRequestRevision, onResubmitDelivery) + 4 novos flags computed (showRequestRevision, showResubmitDelivery, showRevisionReason).
  - +badge spec revisionRequested (laranja).
  - +caixa revisionReason com ícone replay (visível pro freelancer/quando count > 0).
  - +Row de 2 botões pro Cliente em delivered (Solicitar revisão outline laranja + Aprovar filled verde).
  - +Botão "Reenviar entrega" pro Freelancer em revision_requested.
  - +_RevisionReasonSheet com TextField + counter + botão dinâmico ("Faltam X caracteres" / "Enviar solicitação").
  - _DeliveryComposerSheet aceita isResubmit (muda título de "Confirmar entrega" pra "Reenviar entrega" + label do botão final).
- Validação: flutter analyze 0 issues. flutter test 13 passed (testes existentes intactos — UI nova não tem assertion).
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **Status `revision_requested` snake_case no Firestore**: o enum Dart usa camelCase (`revisionRequested`), mas Firebase gravar/ler usa `revision_requested` (consistência com `proposalCount`, etc — snake é convenção no docs). Adicionei `_parseStatus` helper porque `.name` do enum não bate. Tradeoff: 1 enum entre N precisa de mapping especial. Vale a pena pra manter Firestore consistente com seu próprio padrão.
- **Substituir vs acumular fotos no reenvio**: decisão de UX — a entrega reenviada é uma "nova versão", as fotos antigas viram irrelevantes. Cliente que quiser comparar tem que pedir antes. Acumular ficaria confuso visualmente (10+ fotos misturando versões). `revisionCount` no doc registra que houve N revisões — auditoria sem precisar ver as fotos antigas.
- **`revisionCount` em vez de só boolean `wasRevised`**: prepara pro futuro mostrar "Última revisão solicitada (2ª)" se acontecer ciclo. Realista pra freelance — 1-2 ajustes é comum.
- **Botão "Solicitar revisão" outline laranja, "Aprovar" filled verde**: hierarquia visual clara — verde é o caminho "feliz" (filled = primário), laranja é o caminho de fricção (outline = secundário). Cliente é nudgeado pra aprovar, mas tem a saída visível.
- **`_RevisionReasonSheet` separado de `_DeliveryComposerSheet`**: poderia ter tentado generalizar, mas semanticamente são fluxos diferentes (escolher fotos vs escrever texto). Manter 2 sheets simples é mais legível que 1 polimórfico.
- **`revisionReason` visível pro freelancer mesmo após reenvio**: contrato volta a `delivered` mas a caixa de motivo continua aparecendo (a condição é `revisionCount > 0`). Útil pra ele lembrar o que foi pedido enquanto espera 2ª aprovação. Cliente também vê — fica claro o histórico.
- **Trigger `onContractStatusChanged` agora tem 4 branches**: active→delivered, delivered→completed, delivered→revision_requested, revision_requested→delivered. Está ficando longo — provavelmente vai precisar refactor pra switch puro quando vier "delivered → disputed". Por ora ifs são OK.
- **Sem mudança no `project.status` durante revisão**: o projeto continua `active`. Quando aprovar finalmente, vira `completed`. Bom — durante a revisão é só ruído mover o status do projeto.

**Cobertura visual:**
- Workflow circular agora: entrega → revisão → reenvio → revisão → reenvio → ... → aprovação. Realista.
- Push em 6 pontos totais (4 antigos + 2 novos): cobre todos os eventos que mudam o estado entre as partes.

**Fluxo testável agora:**
1. Cliente publica → Freelancer propõe → Cliente aceita (contrato active).
2. Freelancer "Marcar como entregue" → contrato delivered + push pro Cliente.
3. Cliente abre Meus contratos → 2 botões: "Solicitar revisão" (laranja) + "Aprovar" (verde).
4. Tap "Solicitar revisão" → bottom sheet com TextField. Escreve "A paleta tá fora do brief…". Botão vira "Enviar solicitação" quando passa de 10 chars.
5. Confirma → contrato vira "Revisão pedida" (badge laranja). Cliente vê na tela "aguardando reenvio". Push pro Freelancer chega.
6. Freelancer vê o card com caixa "Revisão solicitada" + texto do motivo. Tap "Reenviar entrega" abre composer com título "Reenviar entrega". Anexa novas fotos.
7. Confirma → contrato volta a "Entregue". Cliente vê push "Entrega reenviada — Toque para revisar". Caixa de motivo continua visível (histórico).
8. Cliente aprova → contrato "Concluído". Projeto → completed. Fim.

**Hotfix da Iteração 25 (mesmo commit ou commit separado):** durante validação, o usuário viu o erro `failed-precondition` mostrado como "Contrato não está no status esperado." num cenário onde a UI do Freelancer ficou stale (badge "Em andamento" + botão "Marcar como entregue" mesmo com o status real sendo `revision_requested` no Firestore). Causa raiz: hot reload no app não recarregou o método estático novo `_parseStatus` que mapeia `revision_requested` (snake) → `ContractStatus.revisionRequested` (camel). O fallback `orElse: () => ContractStatus.active` chutou pra active, fazendo a UI mostrar o botão errado.

Fix aplicado (sem deploy server-side):
- `_humanizeError` em `my_contracts_view.dart` agora retorna "O estado do contrato mudou. Puxe pra baixo pra atualizar e tente novamente." — instrução acionável.
- RefreshIndicator wrappa a tela MyContractsView. Pull-to-refresh chama `_refresh()` que limpa `_loadError` e re-executa `_initStream` — cria nova subscription do Firestore que re-emite o estado real.
- `physics: AlwaysScrollableScrollPhysics()` em todos os ListViews (incluindo empty/error states) pra que o gesture funcione mesmo sem conteúdo.

Lição arquitetural: hot reload em singleton com método estático pode manter versão antiga em memória. Pra desenvolvimento da próxima vez: stop+run sempre que enum/parser mudar. Pra produção: pull-to-refresh agora cobre o caso de cache divergente.

**Próximo passo (Iteração 26):** voltar ao core. Candidatos:
- **A — Detalhe do contrato** (tela nova quando tap no card de MyContractsView): timeline de eventos (criado / entregue em X / revisão em Y / aprovado), fotos em grid maior, ações contextuais.
- **B — Edição de perfil** (Profile tab hoje é placeholder "Edição em breve"): trocar displayName + foto de perfil. Reusa storage + image_picker.
- **C — Mensagens** (chat freelancer ↔ cliente): collection messages, streams paginados. Maior, fecha o último placeholder de tab. Já mencionado várias vezes — provavelmente o "mais valioso" funcionalmente.

Recomendação: **B — Edição de perfil** (foco rápido + recupera o "Foto de perfil" que era a alternativa de câmera na Iteração 22) ou direto **C** se quiser fechar a tab Mensagens de uma vez.

---

## Iteração 26
### Prompt usado:
```plaintext
Iteração 26 — Mensagens (chat freelancer ↔ cliente).

Fecha o último placeholder de tab. Modelagem:
- threads/{tid}/messages/{mid} subcollection.
- threadId determinístico = uids ordenados ({uidA}_{uidB} com uidA<uidB) — uma única thread por par de pessoas, qualquer order de quem inicia cai no mesmo doc.
- thread doc denormaliza: participantIds, participantNames {uid: name}, lastMessageText, lastMessageSenderId, lastMessageAt, createdAt.

Server (functions/src/index.ts):
- `sendMessage({receiverId, text})` callable v2:
  - Valida auth, receiverId != senderUid e string, text 1..2000 chars (trim).
  - threadId = uids ordenados.
  - Promise.all([users/sender, users/receiver]) pra ler displayName (denormalizar). Receiver não existe → not-found.
  - Transaction: lê thread, se não existe cria com participantIds+participantNames+lastMessage*+createdAt; senão update lastMessage*. Sempre cria message na sub com senderId+text+createdAt serverTimestamp.
  - Push pro receiver: title = nome do sender, body = text truncado a 100 chars.

Rules:
- threads/{tid} + threads/{tid}/messages/{mid}: read se uid in participantIds. Subcollection valida via get(threads/$tid).data.participantIds. Create/update/delete: false (server-only via callable).

Índice:
- threads(participantIds array-contains, lastMessageAt desc).

Cliente (Flutter):
- models/chat_thread.dart + chat_message.dart (imutáveis + helpers otherUid/otherName).
- core/services/messages_service.dart:
  - threadIdFor(a, b) helper estático.
  - streamThreadsByUser(uid), streamMessages(threadId).
  - sendMessage(receiverId, text) chama callable.
- views/messages_view.dart NOVO: tab Mensagens (substitui placeholder). Lista de _ThreadCard com avatar de iniciais, nome, preview ("Você: ..." se foi você o último), tempo relativo (agora/Nmin/Nh/Nd/Nsem). Empty state.
- views/chat_view.dart NOVO: AppBar com avatar+nome+back, lista reversed de bubbles, input bar fixo embaixo com TextField multiline + botão circular send (roxo quando hasText, disabled cinza quando vazio, spinner enquanto envia).
- views/home_view.dart: +import MessagesView, +branch _currentTab==2 (tab Mensagens em ambos os roles, índice 2).
- views/my_contracts_view.dart: linha do counterparty agora tem botão "Mensagem" no canto direito que abre ChatView com otherUid/otherName.

Validar analyze + test. Stage.
```

### Output recebido:
```markdown
- Criou models chat_thread.dart + chat_message.dart.
- Criou messages_service.dart com threadIdFor + 2 streams + sendMessage.
- Editou firestore.rules: +bloco threads + subcollection messages. Deploy de rules.
- Editou firestore.indexes.json: +índice array-contains. Deploy.
- Editou functions/src/index.ts: +sendMessage callable (~110 linhas) com leitura paralela dos users + transaction com upsert da thread + push pro receiver. Deploy.
- Criou messages_view.dart (~340 linhas) com _Header + 4 estados + _ThreadCard com avatar de iniciais + preview "Você: ...".
- Criou chat_view.dart (~430 linhas) com _TopBar avatar+nome, lista reverse de _MessageBubble (roxo direita pra "minhas", branco/slate esquerda pras outras, hora HH:MM no rodapé), _InputBar multiline com botão send circular.
- Editou home_view.dart: +import MessagesView, +branch tab=2 → MessagesView.
- Editou my_contracts_view.dart: +import ChatView, +_openChat(Contract) no State, +counterpartyUid, +InkWell "Mensagem" no Row do counterparty (ícone chat + texto roxo), +param onOpenChat em _ContractCard.
- Validação: flutter analyze 0 issues. flutter test 13 passed.
```

### Resultado:
Iteração coesa, sem retentativas. Pontos relevantes:

- **threadId determinístico via uids ordenados**: maior decisão. Vantagens: 0 lookup pra descobrir se thread existe (sempre é o doc `{min}_{max}`), idempotente (qualquer parte que envie cai no mesmo doc), não exige collection de "índice reverso". Tradeoff: uma única thread por par, sem possibilidade de "chat por projeto" ou "chat por contrato". Pra MVP é correto — UX típica de freelance é uma conversa contínua com o mesmo cliente independente de quantos projetos rolaram.
- **`participantNames` map denormalizado**: a tab Mensagens lista N threads. Sem denormalizar nome, cada card precisaria de 1 read em `users/{otherUid}` (N reads). Com denormalização, 0 reads extras. Tradeoff: se o user trocar `displayName`, threads antigas continuam mostrando o nome antigo. Aceitável — quando vier edição de perfil, posso adicionar trigger pra propagar.
- **Promise.all dos 2 user reads fora da transaction**: transactions Firestore exigem leitura antes de escrita e só permitem certos patterns. Os displayNames são essencialmente imutáveis na prática (mudam raramente). Lê fora da tx, usa o snapshot dentro. Risco de race: zero prático.
- **`reverse: true` no ListView de mensagens**: Firestore retorna msgs `orderBy createdAt desc` — a mais nova primeiro. ListView reverse renderiza isso de baixo pra cima = mensagem mais nova fica na parte de baixo. Sem precisar scroll programático.
- **Sem scroll-to-bottom programático ao enviar**: o ListView reverse + Firestore stream emitindo a nova msg fazem o trabalho. O Stream emite, o build reconstrói, a nova msg aparece no índice 0 (que renderiza no fundo). Smooth.
- **Botão "Mensagem" no MyContractsView e não em outros lugares ainda**: ponto de entrada principal — depois do contrato é quando mais precisa conversar (alinhar entrega, tirar dúvida). Pode-se adicionar no card de proposta no futuro pro Cliente conversar antes de aceitar.
- **Push de chat reutiliza `sendPushToUser`**: a mesma infra de notificação de proposals/contracts roda aqui — title = nome do sender, body = preview do texto (truncado a 100 chars). Data tem `type: chat_message` + `threadId` pra deep link futuro.
- **Não tem read receipts / typing / online**: pular intencional. Read receipts exigem armazenar `lastReadAt` por user na thread, comparações, badges. Pra MVP fica fora. Typing indicator é ainda mais complexo (Firestore presence é tricky, geralmente requer Realtime Database).
- **Bubble com border radius assimétrico**: cantos arredondados padrão `(16,16,16,4)` ou `(16,16,4,16)` dependendo do lado. Detalhe pequeno, faz parecer chat de verdade em vez de retângulos.

**Cobertura visual:**
- Última tab placeholder eliminada. App agora 100% navegável sem nenhum "Em breve".
- 2 telas novas (lista + chat) + integração em 2 views existentes (home + contracts).
- Push notification de chat completa o conjunto de 5 push types: proposalCreated, proposal_accepted/rejected, contract_delivered/redelivered/revision_requested/completed, chat_message.

**Fluxo testável agora (Android pra ver push de verdade):**
1. Cliente publica → Freelancer propõe → Cliente aceita. Ambos vêem o contrato em "Meus contratos".
2. Cliente abre "Meus contratos" → tap "Mensagem" no card → ChatView abre com nome do Freelancer no topo. Empty state "Comece a conversa".
3. Digita "Quando você pretende começar?" → tap send → bolha roxa aparece à direita.
4. Freelancer recebe push "Luis Felipe: Quando você pretende começar?" (Android nativo, iOS SnackBar in-app se app aberto).
5. Freelancer abre tab "Mensagens" → card do Cliente com preview da msg + tempo "agora".
6. Tap → ChatView mostra bolha à esquerda (branca/slate). Responde "Amanhã cedo." → bolha roxa à direita.
7. Cliente recebe push, abre, vê a resposta. Lista threads mostra preview "Amanhã cedo." atualizada.
8. (Bônus) Outro cenário: dois Clientes diferentes mandam mensagem pro mesmo Freelancer → tab Mensagens lista 2 threads diferentes, ordenadas por lastMessageAt desc.

**Próximo passo (Iteração 27):** core completion + polish. Candidatos:
- **A — Detalhe do contrato** (tela nova): timeline de status + ações + galeria. Aprofunda a UX existente em vez de adicionar novo loop.
- **B — Edição de perfil** (tab Perfil): trocar displayName + foto de perfil + trigger que propaga nome novo pra threads e contratos (denormalização viva).
- **C — Filtros e busca no Feed**: hoje feed é flat. Adicionar filtros por categoria/orçamento ativos + busca textual.
- **D — Deep link em push notifications**: tocar a notificação abre a tela relevante (chat → ChatView, contrato → MyContractsView, etc).

Recomendação: **B** (libera o "Foto de perfil" prometido + denormaliza nomes nas threads existentes) **→ D** (notificação que abre tela é UX padrão esperada).

---

### Hotfix 26.1 — permission-denied ao abrir chat (thread inexistente)

**Sintoma reportado:** ao tap "Mensagem" no card de contrato com par que **nunca trocou mensagem**, ChatView abre e mostra `Erro: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.` no lugar do empty state.

**Causa raiz:** a regra de leitura de `threads/{tid}/messages` fazia `get(/databases/.../threads/$(threadId)).data.participantIds`. Quando a thread ainda **não existia** (nenhuma mensagem trocada), o `get()` retornava null e a expressão falhava → denied. A `streamMessages` é aberta no `initState` do ChatView, antes da primeira `sendMessage`, então o stream emitia erro de cara.

**Fix:** trocar a regra para validar pelo próprio `threadId`, que é `{uidMenor}_{uidMaior}` — UIDs do Firebase Auth não contêm `_`, então `threadId.split('_')` retorna exatamente 2 partes. Não depende mais de existência do doc.

```
match /messages/{messageId} {
  allow read: if request.auth != null
              && (request.auth.uid == threadId.split('_')[0]
                  || request.auth.uid == threadId.split('_')[1]);
  allow create: if false;  // sendMessage callable
  allow update: if false;
  allow delete: if false;
}
```

**Side-effect:** a leitura passou a ser ligeiramente **mais barata** (sem o `get()` extra que custa 1 read por avaliação de rule).

**Deploy:** `firebase deploy --only firestore:rules` ✔

**Validação:** par novo → tap "Mensagem" → ChatView abre no empty state "Comece a conversa" sem erro. Primeira mensagem é enviada normalmente (callable continua sendo o único caminho de escrita).

---

## Iteração 27
### Prompt usado:
```plaintext
Iteração 27 — Deep link em push notifications (opção D).

Hoje a notificação chega (Android nativo / iOS in-app SnackBar) mas o tap nela só abre o app na última tela aberta. Falta UX: tocar a notif tem que abrir a tela relevante.

Mapeamento desejado por `data.type`:
- `proposalCreated`               → ReceivedProposalsView (cliente)
- `proposal_accepted` / `rejected`→ MyProposalsView (freelancer)
- `contract_delivered`            → MyContractsView (cliente)
- `contract_redelivered`          → MyContractsView (cliente)
- `contract_completed`            → MyContractsView (freelancer)
- `contract_revision_requested`   → MyContractsView (freelancer)
- `chat_message`                  → ChatView(otherUid, otherName)

Cobrir 2 cenários:
1. App em background → tap notif do sistema → app vem pra foreground na tela certa.
2. App terminated (cold start) → tap notif → app abre e navega pra tela certa.

Foreground (app aberto) já mostra SnackBar; não navega (manter como está, fica intrusivo).
```

### Output:
- `lib/main.dart`: adicionado `rootNavigatorKey = GlobalKey<NavigatorState>()` e plugado em `MaterialApp.navigatorKey`. Paralelo ao `rootMessengerKey` que já existia. Permite navegação a partir de qualquer lugar (ex: handler que roda em isolate diferente do widget tree).
- `lib/core/services/notifications_service.dart`:
  - `initialize` ganhou parâmetro opcional `GlobalKey<NavigatorState>? navigatorKey`.
  - Novo `StreamSubscription<RemoteMessage>? _tapSub` registrado em `FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap)` — cobre o cenário "app em background → tap notif → foreground".
  - `await _messaging.getInitialMessage()` chamado em sequência — cobre cold start. O dispatch é envelopado em `WidgetsBinding.instance.addPostFrameCallback` pra garantir que o Navigator está montado no momento do push (a `initialize` é chamada do `HomeView.initState`, mas o `Navigator` só está pronto após o primeiro frame).
  - Novo método privado `_handleNotificationTap(RemoteMessage msg)`: lê `msg.data['type']` e usa `_navigatorKey.currentState.push(...)` pra empilhar a tela. Switch case cobre os 8 tipos. Default = no-op (push sem `type` ou tipo desconhecido — silencioso, não quebra).
  - `dispose` agora também cancela `_tapSub` e limpa `_navigatorKey`. Idempotência mantida.
- `lib/views/home_view.dart`: `_initPushNotifications` passa `navigatorKey: rootNavigatorKey` pro `initialize`. Único call-site, então 1 linha de mudança.
- `functions/src/index.ts`: data payload do `sendMessage` callable agora inclui `senderName`. Sem ele, ao tocar push de chat no cold start, ChatView abriria com o nome vazio. Já estava no `title` da notificação, mas data fields ficam separados de `notification`, então melhor explicitar. Deploy só dessa função.

### Resultado:
**Cobertura de UX completa pra push notifications.** Os 7 tipos de push (proposalCreated, proposal_accepted/rejected, contract_delivered/redelivered/revision_requested/completed, chat_message) agora abrem a tela certa quando tocados. Foreground continua mostrando SnackBar (não navega — comportamento esperado).

**Arquitetura:**
- Navegação por **push de rota** (não troca de tab). Justificativa: navegar pra tabs internas do `HomeView` exigiria comunicação com estado interno daquele widget (mudar `_currentTab`); empurrar uma rota nova por cima é o padrão Material e funciona em qualquer estado do app. O usuário pode voltar com o back-button.
- **Cold start defensivo:** o `addPostFrameCallback` evita race com o Navigator não estar montado. Sem ele, em devices lentos a navegação no cold start falharia silenciosamente.
- **chat_message é o único tipo que precisa de parâmetro do payload** (senderId + senderName). Os outros são telas estáticas, então não precisam de contexto adicional — a tela carrega tudo do Firestore pelo uid do user atual.
- **Tolerante a payload faltando:** se `data.type` vier null/unknown, o handler retorna sem ação. Se chat_message vier sem senderId, no-op.

**Validações:**
- `flutter analyze` → 0 issues
- `flutter test` → 13 passed
- `firebase deploy --only functions:sendMessage` → "Successful update operation" ✔

**Fluxo testável agora (Android — push real):**
1. Cliente publica → Freelancer (em outro device, app em background ou fechado) propõe.
2. Notificação "Nova proposta recebida" chega no device do Cliente → tap → app abre direto em **Propostas Recebidas** com a proposta nova no topo.
3. Cliente aceita → Freelancer recebe push "Proposta aceita" → tap → app abre direto em **Meus Trabalhos** com a proposta em "Aceita".
4. Freelancer marca entregue → Cliente recebe push "Entrega recebida" → tap → app abre direto em **Meus contratos** no card pronto pra aprovar.
5. Cliente toca "Mensagem" → manda msg → fecha app inteiro → Freelancer recebe push "Luis Felipe: ..." → tap → app abre direto na **ChatView com o Cliente**, mostrando a msg.
6. App em foreground continua mostrando SnackBar roxo (não navega — comportamento esperado).

**Próximo passo (Iteração 28):** candidatos restantes do menu:
- **A — Detalhe do contrato** (timeline + galeria + ações em tela própria, libera mais real estate pro UX)
- **B — Edição de perfil** (displayName + foto + trigger de propagação nas threads e contratos existentes)
- **C — Filtros + busca no Feed** (hoje o feed é flat; tem chip "Categoria" mas é só visual em alguns mocks)

Recomendação: **B** (compromisso "Edição de perfil em breve" do tab Perfil + exercita propagação de denormalização — caso clássico de manutenção em sistema com dados duplicados).

---

### Hotfix 27.1 — SnackBar tocável em foreground

**Sintoma reportado:** push de chat tocada no iOS (sem APNs configurado) ou Android com app aberto não navegava pra ChatView — o SnackBar in-app só mostrava texto e desaparecia.

**Causa raiz:** o handler de tap (`onMessageOpenedApp` + `getInitialMessage`) cobre os cenários background/cold start, mas **foreground** só dispara `onMessage` — que monta o SnackBar sem ação. iOS sem APNs nem dispara o handler de tap (decisão Iteração 23), então o SnackBar era o único caminho.

**Fix:** SnackBar ganhou `SnackBarAction("Abrir")` que reusa o mesmo `_handleNotificationTap(msg)`. Visível quando `data.type` está presente (qualquer notificação do app, hoje todas têm). Duration aumentada pra 6s pra dar tempo de tocar.

**Cobertura final por cenário:**
| App state | Plataforma | Deep link |
|---|---|---|
| Foreground | Android | SnackBar com "Abrir" ✔ |
| Foreground | iOS | SnackBar com "Abrir" ✔ |
| Background | Android | Tap notif do sistema ✔ |
| Background | iOS (sem APNs) | Push não chega — N/A |
| Cold start | Android | Tap notif → app + nav ✔ |
| Cold start | iOS (sem APNs) | Push não chega — N/A |

---

## Iteração 28
### Prompt usado:
```plaintext
Iteração 28 — Edição de perfil (opção B).

Tab Perfil hoje mostra placeholder "Edição de perfil em breve." Construir o fluxo completo:
1. Tela EditProfileView: trocar displayName (com validação) + escolher foto via image_picker (galeria).
2. Upload da foto para Firebase Storage em path profile_photos/{uid}/avatar.{ext}, retorna download URL.
3. Atualizar doc users/{uid} com displayName/photoUrl.
4. Cloud Function trigger onUserUpdated detecta mudança de displayName e propaga as denormalizações:
   - threads.participantNames[{uid}] em todas as threads em que user participa
   - contracts.clientName / freelancerName em todos os contratos do user
   - proposals.freelancerName nas propostas do user
   photoUrl NÃO é denormalizado em nenhum lugar (foto é lida via single read direto do doc).
5. Mostrar foto no tab Perfil (avatar grande) + no _TopBar da ChatView (avatar do interlocutor).
6. Rules: users update SÓ no próprio uid, SÓ campos displayName/photoUrl/fcmTokens (role/email imutáveis).
7. Storage rules: profile_photos/{uid} write SÓ próprio uid, read pra qualquer authed.
```

### Output:
**Modelo + serviços:**
- `lib/models/app_user.dart`: campo `photoUrl: String?` adicionado. `null` quando user nunca subiu foto, mostrado nos avatars como fallback de iniciais.
- `lib/core/services/auth_service.dart`:
  - `_loadUser` lê `photoUrl` (normaliza string vazia pra null).
  - Novo método `updateProfile({uid, displayName?, photoUrl?})` que faz Firestore.update apenas com os campos não-null. Centraliza a única forma do client mexer no perfil.
- `lib/core/services/storage_service.dart`: novo método `uploadProfilePhoto({uid, file})`. Path fixo `profile_photos/{uid}/avatar{ext}` — sobrescreve a foto anterior automaticamente. Sem timestamp porque a URL gerada inclui um access token de versão do Storage que muda a cada upload (invalida cache de Image.network).

**Nova tela:**
- `lib/views/edit_profile_view.dart` (~430 linhas): Form com avatar tocável no topo, TextField pra nome (validação 2-60 chars), campos read-only de e-mail e tipo de conta, botão "Salvar alterações" no rodapé. Suporta dark mode. Cores reutilizadas das outras telas (primary purple, surface cream, error red, success green). Fluxo:
  1. `initState` carrega user atual via AuthService → pre-popula nome + photoUrl.
  2. Tap no avatar → `image_picker.gallery` com `maxWidth: 1024, imageQuality: 85` (já comprime no client, evita upload de 5MB+).
  3. Tap "Salvar" → upload foto (se trocou) → AuthService.updateProfile com apenas o que mudou → SnackBar verde + `Navigator.pop(true)`.
  4. Edge case: clicar Salvar sem mudar nada → SnackBar vermelho "Nada para salvar."

**Cloud Function — trigger de propagação:**
- `functions/src/index.ts`: novo trigger `onUserUpdated` (`onDocumentUpdated("users/{uid}")`):
  - Detecta mudança de `displayName` (skip se só photoUrl ou fcmTokens mudou — early return).
  - Roda 3 funções de propagação em paralelo via `Promise.all`:
    - `propagateInThreads`: query `where('participantIds', 'array-contains', uid)` → batch update `participantNames.{uid}` (path nested no Map).
    - `propagateInContracts`: 2 queries separadas (`clientId == uid`, `freelancerId == uid`) → batch update do campo correspondente.
    - `propagateInProposals`: query `freelancerId == uid` → batch update `freelancerName`.
  - Helper `commitInBatches`: divide em lotes de 400 docs (limite firestore = 500 por batch). 99% dos users vão ter <400 docs de cada tipo; o resto fica seguro.
  - Logs estruturados em cada propagação pra debugging futuro.

**Rules:**
- `firestore.rules` (users/{uid} update): adicionada validação `request.resource.data.diff(resource.data).affectedKeys().hasOnly(['displayName', 'photoUrl', 'fcmTokens'])`. Justifica fcmTokens na lista porque NotificationsService faz arrayUnion/arrayRemove nesse campo — sem isso, push notifications quebrariam.
- `storage.rules`: novo bloco `profile_photos/{uid}/{fileName}` com `allow write: if request.auth.uid == uid && size < 5MB && contentType matches 'image/.*'`. Read aberto pra qualquer authed (avatar visível em qualquer lista de pessoas).

**UI:**
- `lib/views/home_view.dart`:
  - `_ProfileTab` convertido em StatefulWidget. Carrega user no `initState` via AuthService. Mostra avatar grande (componente `_ProfileAvatar` novo: `Image.network` com `errorBuilder` → fallback de iniciais). Nome + email + role.
  - Botão "Editar perfil" filled primary, push EditProfileView. Quando volta com `true`, re-carrega user (refresh do avatar + nome).
  - Botão "Meus contratos" virou outlined (era filled) — hierarquia visual: ação primária é Editar.
- `lib/views/chat_view.dart`:
  - `_ChatViewState` ganhou `_otherPhotoUrl: String?` + método `_loadOtherPhoto()` que faz `users/{otherUid}.get()` 1x quando a chat abre.
  - `_TopBar` aceita `photoUrl?` e mostra `Image.network` com `errorBuilder` → fallback de iniciais (mesma lógica do `_ProfileAvatar`).
  - Decisão arquitetural: **só ChatView lê a foto, não MessagesView**. Listas (Mensagens, MyContractsView, etc) continuam com iniciais — economiza N reads em tela que lista N items.

### Resultado:
**Loop completo:** editar nome → ver propagar nos cards de contrato/proposta/thread dos outros usuários em real-time (StreamBuilder pega o update do Firestore). photoUrl mostrada onde adiciona valor (Perfil + ChatView), iniciais onde não compensa o custo (listas).

**Validações:**
- `flutter analyze` → 0 issues
- `flutter test` → 13 passed (sem testes novos — os existentes seguram a UI; testar trigger no emulador exige Firestore emulator que ainda não está configurado)
- `tsc` (functions) → compila limpo
- `firebase deploy --only firestore:rules,storage,functions:onUserUpdated` → Successful create operation ✔

**Fluxo testável agora (cliente + freelancer, qualquer device):**
1. Cliente e Freelancer estão com contrato ativo e thread aberta. Abrir Mensagens em ambos: thread mostra o nome antigo do outro.
2. Freelancer → tab Perfil → "Editar perfil" → muda nome de "Gabriel Santos" pra "Gabriel S." → escolhe foto da galeria → Salvar.
3. SnackBar verde "Perfil atualizado!" + volta pro tab Perfil → avatar com foto + nome novo.
4. Cliente (sem fazer nada) → tab Mensagens **atualiza sozinha** com o nome novo (StreamBuilder pega o snapshot novo). Threads, propostas e contratos com o Freelancer mostram "Gabriel S."
5. Cliente abre o chat → AppBar mostra "Gabriel S." + a foto carregada (1 read no doc user).
6. Re-uploadar foto: nome igual → trigger não dispara propagação (early return); doc atualiza só photoUrl. Confirmar no log: trigger não rodou propagation.

**Custos:**
- Edit profile = 1 storage upload + 1 firestore update + trigger.
- Trigger por mudança de nome: ~1 query + N batch updates por coleção (threads, contracts, proposals). Para um user com 5 threads + 3 contracts + 10 proposals = ~18 writes. Aceitável.
- ChatView abrir = 1 read extra do doc user (mas amortizado: usuário fica no chat tempo suficiente pra fazer várias outras reads).

**Próximo passo (Iteração 29):** restantes do menu:
- **A — Detalhe do contrato**: timeline + galeria + ações em tela própria. Adiciona profundidade na UX existente.
- **C — Filtros + busca no Feed**: feed flat hoje. Adiciona descoberta.

Recomendação: **A** (fecha o loop de contrato com tela rica, libera real estate pra ações + histórico). Filtros viriam depois quando o catálogo crescer.

---

## Iteração 29
### Prompt usado:
```plaintext
Iteração 29 — Detalhe do contrato (opção A).

Hoje a UX inteira de contrato vive no card de MyContractsView: meta + status + fotos thumbnail + 3 variantes de botão + caixinha laranja com motivo de revisão. Tudo amontoado num card de 16px de padding. Construir tela própria pra contrato:

1. Tela nova ContractDetailView(contractId) que observa UM contrato em tempo real (single-doc snapshot).
2. Layout vertical de cards: header (título + status badge grande), contraparte (avatar + nome + Mensagem), linha do tempo (marcos verticais), razão da revisão se houver, galeria 3-col.
3. Bottom bar fixa com ações contextuais por status × role.
4. Refatorar MyContractsView: card simplifica (sem ações inline, sem fotos thumb, sem caixa de revisão), tap inteiro vai pra ContractDetailView.
5. Extrair widgets reusáveis (badge, sheets, fullscreen) pra lib/widgets/contract_widgets.dart.
6. Atualizar NotificationsService: push de contract_* (4 tipos) abre ContractDetailView(data.contractId) em vez de lista.
```

### Output:
**Service:**
- `contracts_service.dart`:
  - Novo `streamContract(contractId): Stream<Contract?>` — observa UM doc. Emite `null` se sumir.
  - `_fromDoc` agora delega pra `_fromMap(id, data)` que aceita também `DocumentSnapshot.data()`. Reuso sem duplicar parsing.

**Widgets compartilhados (novo arquivo):**
- `lib/widgets/contract_widgets.dart` (~530 linhas): exports públicos — `ContractStatusBadge` (com flag `large` pra detail), `ContractPhotoFullscreenView`, `DeliveryComposerSheet`, `RevisionReasonSheet`, helpers `formatContractValue`, `relativeContractDate`. Movidos de `my_contracts_view.dart`.

**Tela nova:**
- `lib/views/contract_detail_view.dart` (~830 linhas): StreamBuilder<Contract?> assina o single-doc. Composição de cards desacoplados (`_HeaderCard`, `_CounterpartyCard`, `_TimelineCard`, `_RevisionReasonCard`, `_GalleryCard`). Ações ficam num Container com SafeArea colado no rodapé — não scroll-flutua com o conteúdo.
- **Timeline visual:** lista de 3-4 marcos (Iniciado / Entrega enviada / [Revisão se houver] / Concluído). Cada marco = círculo com ícone + traço vertical até o próximo. Cor: roxo se ativo, cinza se pendente, laranja no marco de revisão, verde no marco final concluído. Subtitle traduz o subestado.
- **Foto da contraparte:** carregada lazy via `WidgetsBinding.addPostFrameCallback` no primeiro build (1 read em `users/{counterpartyUid}`). Sem foto → iniciais.
- **Galeria em grid 3-col** (vs lista horizontal antiga). Tap → `ContractPhotoFullscreenView`.

**Refatoração:**
- `my_contracts_view.dart` reescrito (1473 → 395 linhas):
  - Card simples: título + badge, valor / prazo / "N anexos" como chips, contraparte + chevron, data relativa. **Sem botões, sem fotos, sem caixa de revisão.**
  - InkWell envolve o card → tap dispara `ContractDetailView(contractId)`.
  - Apaga todos os handlers de ação, `_humanizeError`, `_processingId` — migraram pro detail.
  - Imports limpos: `cloud_functions`, `image_picker`, `dart:io`, `chat_view` removidos.

**Notifications:**
- `notifications_service.dart`: case dos 4 tipos `contract_*` agora lê `msg.data['contractId']` e abre `ContractDetailView(contractId: ...)`. Fallback pra `MyContractsView` se vier sem id (defensivo).

### Resultado:
**UX:** loop completo do contrato em tela própria, com timeline narrativa em vez de amontoado de botões. MyContractsView volta a ser uma lista limpa de cards navegáveis. Push de contrato leva direto ao card no detail, em 1 tap.

**Arquitetura:**
- **Stream single-doc** = update em tempo real do detail. Mudou o status no server? A tela se reorganiza sozinha (botões certos aparecem/somem, timeline avança, badge muda) sem refresh.
- **Helpers públicos** em `widgets/` permitem reuso futuro (ex: card resumido em ClientDashboard).
- **Carga da foto desacoplada do stream**: stream observa só o contrato; foto vem por fetch separado (1 read). A foto raramente muda durante a vida do contrato; quando muda, próxima abertura pega.
- **Ações no rodapé fixo**, não no scroll: quando o contrato é longo (várias fotos + revisão + timeline), o botão de ação primária continua visível. Padrão Material para detail views ricos.

**Validações:**
- `flutter analyze` → 0 issues
- `flutter test` → 13 passed (testes existentes do MyContractsView seguram o empty state)

**Fluxo testável agora:**
1. Cliente aceita proposta → contrato active aparece em "Meus contratos" no Freelancer.
2. Tap no card → ContractDetailView abre. Header com título + badge "Em andamento". Contraparte mostra Cliente com foto/iniciais. Timeline: ✓ Contrato iniciado / ○ Entrega enviada / ○ Concluído. Bottom bar: "Marcar como entregue".
3. Freelancer marca entregue (3 fotos). UI em tempo real: badge → "Entregue", marco "Entrega enviada" → roxo. Card "Anexos da entrega" grid 3-col. Bottom bar some.
4. Cliente recebe push "Entrega recebida" → tap → abre direto no detail com galeria + bottom bar "Solicitar revisão | Aprovar entrega".
5. Cliente solicita revisão com motivo. UI: marco "Revisão solicitada (1ª)" entra entre Entrega e Concluído (laranja). Card laranja com motivo aparece. Bottom bar some.
6. Freelancer recebe push → tap → vê timeline com revisão + card com motivo. Bottom bar "Reenviar entrega". Reenvia com novas fotos.
7. Cliente vê galeria atualizada, marco "Revisão" vira "Reenviada pelo freelancer", bottom bar volta com Aprovar/Solicitar revisão.
8. Cliente aprova → badge "Concluído", último marco verde, bottom bar some. Read-only daí em diante.

**Próximo passo (Iteração 30):** sobrou só **C — Filtros + busca no Feed** do menu original. Outras direções possíveis:
- Avaliações mútuas pós-conclusão (rating 1-5 + comentário; mostra média no perfil)
- Notificações in-app persistidas (badge na sineta + lista de notifs)
- Disputa de contrato (estado `disputed` existe no enum mas sem fluxo)

Recomendação: **C — Filtros** primeiro (entrega valor imediato pro freelancer descobrir trabalhos), depois **avaliações** (fecha o ciclo do contrato com confiança social — essencial pra marketplace).

---

## Iteração 30
### Prompt usado:
```plaintext
Iteração 30 — Filtros + busca no Feed (opção C).

Feed hoje tem search bar que não filtra nada e 3 chips placeholder ("Todos os filtros", "Categoria", "Orçamento") que só trocam um estado mock. Habilitar descoberta:

1. Busca textual em tempo real (case-insensitive) em title, description, skills, category, clientName.
2. Filtros multi-select por categoria (mesmas do CreateProjectView).
3. Filtros por faixa de orçamento (faixas predefinidas, multi-select).
4. Filtro por tipo: todos / preço fixo / por hora.
5. Bottom sheet "Filtros" com tudo (Limpar + Aplicar).
6. Chips de filtros ativos na linha de filtros, removíveis individualmente.
7. Empty state pra "0 resultados após filtros".

Tudo client-side (filter em memória da lista carregada do stream). Feed flat com até dezenas de projetos = filter local é OK. Server-side ficaria pra quando o catálogo crescer.
```

### Output:
**Modelo (`lib/models/project.dart`):**
- `const projectCategories` (movida de `create_project_view.dart`): 'Design', 'Desenvolvimento', 'Marketing', 'Conteúdo', 'Outros'. Fonte canônica única.
- `enum BudgetRange` com 5 faixas predefinidas (Até R$500 / R$500-2k / R$2k-5k / R$5k-20k / R$20k+). Cada variante carrega label, min, max (max=infinity pra última).
- `enum BudgetTypeFilter { any, fixed, hourly }`.
- `class ProjectFilters` imutável: searchQuery, categories Set, budgetRanges Set, budgetType. Getters `isEmpty`, `activeCount`. Métodos `copyWith`, `removeCategory`, `removeBudgetRange`, `clearAll`.
- Método `Project.matchesFilters(filters): bool` — AND entre dimensões, OR dentro de cada Set. Busca casa por substring em `[title, description, category, clientName, ...skills].join(' ')` lowercased. Orçamento usa intersecção de intervalos.

**Bottom sheet (novo):**
- `lib/widgets/feed_filters_sheet.dart` (~340 linhas): `FeedFiltersSheet(initial: filters)` retorna `ProjectFilters` via `Navigator.pop`. Seções: Categoria (chips multi-select), Orçamento (chips das 5 faixas), Tipo (segmented "Todos / Preço fixo / Por hora"). Botão Limpar no header + Aplicar no rodapé. Estado local interno; `_apply` chama `widget.initial.copyWith(...)` — preserva a searchQuery (controlada pela SearchBar do FeedView).

**FeedView refatorado:**
- Estado `_activeFilter` mock removido. Novo `_filters: ProjectFilters`.
- SearchController listener propaga texto pro `_filters.searchQuery` em real time. Filter aplicado antes de renderizar.
- Suffix X na SearchBar quando tem texto.
- Chips do header substituídos por `_buildFilterChips`:
  - `_FiltersButton(activeCount, onTap: _openFiltersSheet)` — badge com contagem se `activeCount > 0`.
  - Para cada categoria/range/tipo ativo, um `_ActiveChip(label, onRemove)` removível inline.
- Empty state com `Icons.search_off` quando `allProjects.isNotEmpty` mas filter retornou vazio.

**Dedupe:**
- `create_project_view.dart` agora usa `static const _categories = projectCategories` (import de `models/project.dart`).

**Teste:**
- `widget_test.dart`: assertion `find.text('Todos os filtros')` → `find.text('Filtros')` (label do `_FiltersButton`).

### Resultado:
**Descoberta real no Feed.** Busca textual viva cobrindo 5 campos. Filtros estruturados via bottom sheet ergonômico. Chips ativos visíveis e removíveis sem reabrir o sheet. Busca + filtros compõem (AND).

**Arquitetura:**
- **Client-side por escolha consciente:** Firestore não suporta full-text nativo; pra MVP em catálogo pequeno, filter em memória é mais simples e flexível (qualquer combinação sem índices novos). Migração server-side é só trocar `streamOpenProjects()` por query parametrizada quando escalar — `ProjectFilters` já é o contrato.
- **Imutabilidade do `ProjectFilters`:** mudança vira `copyWith`. Sem aliasing acidental em Sets (uso de `{...set}` antes de mutar).
- **`projectCategories` único source of truth:** mudou a lista? Feed filter + CreateProject form pegam de uma vez.

**Validações:**
- `flutter analyze` → 0 issues
- `flutter test` → 13 passed

**Fluxo testável agora:**
1. Freelancer abre o Feed → vê todos os projetos abertos. Chip "Filtros" sem badge.
2. Digita "ui" na SearchBar → cards somem exceto os que casam. X aparece pra limpar.
3. Tap em "Filtros" → bottom sheet. Marca "Design" + "Por hora". Aplica.
4. Volta pro Feed. Chip "Filtros" mostra badge "2". Dois `_ActiveChip` aparecem ("Design", "Por hora") removíveis. Lista filtrada.
5. Tap no X de "Por hora" → chip some, badge vira "1", lista re-aplica filter ao vivo.
6. Combina com search — restringe ainda mais. Se vazio: empty state "Nenhum projeto encontrado".
7. Reabre o sheet → estado preservado. "Limpar" no header zera os filtros (searchQuery continua, é do FeedView).

**Próximo passo (Iteração 31):** opções restantes:
- **Avaliações mútuas pós-conclusão**: rating 1-5 + comentário ao concluir contrato; média no Perfil. Fecha o ciclo social.
- **Notificações in-app persistidas**: badge na sineta + lista de notifs (hoje só push + SnackBar foreground).
- **Disputa de contrato**: estado `disputed` no enum mas sem fluxo.
- **Convidar freelancer pra projeto**: inverso da proposta (cliente convida).

Recomendação: **Avaliações** (fecha o loop, gera confiança social, libera componente `_RatingStars` reusável).

---
