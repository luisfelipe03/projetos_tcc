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
