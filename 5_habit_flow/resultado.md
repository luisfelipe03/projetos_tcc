# Resultado — Habit Flow (Projeto de Média Complexidade)

## Ferramenta de IA utilizada

**GitHub Copilot (Chat Agent Mode)** integrado ao Visual Studio Code, utilizando o modelo Claude 3.5 Sonnet como base para geração de código e assistência no desenvolvimento.

---

## Resumo geral

O desenvolvimento do Habit Flow foi concluído em **36 iterações** (prompts), partindo de um projeto Flutter em branco até um aplicativo funcional com autenticação, persistência de dados, notificações, gráficos de progresso, internacionalização e suporte a temas claro/escuro. A IA atuou como desenvolvedora principal, recebendo instruções em linguagem natural e protótipos visuais como referência.

---

## Funcionalidades implementadas

| Funcionalidade prevista | Status | Observações |
|---|---|---|
| Cadastro, edição e remoção de hábitos | Implementado | CRUD completo com Firestore |
| Notificações de lembrete | Implementado | Diárias, semanais e mensais com `flutter_local_notifications` |
| Gráficos de progresso | Implementado | Gráficos de barras e métricas com `fl_chart` (7, 30 e 90 dias) |
| Login social com Google | Implementado | Firebase Auth + Google Sign-In |
| Login social com Apple | Não implementado | Removido na iteração 12 por limitações de configuração |
| Persistência com Cloud Firestore | Implementado | Modelos serializáveis com `toMap`/`fromMap` |
| Registro diário com suporte a fotos | Não implementado | Funcionalidade não foi priorizada durante o desenvolvimento |
| Tema claro e escuro | Implementado | Alternância automática e manual |
| Internacionalização (i18n) | Implementado | Inglês e Português com `flutter_localizations` |

**7 de 9 funcionalidades previstas foram implementadas**, resultando em uma taxa de cobertura de aproximadamente **78%**. As duas funcionalidades não implementadas (login Apple e suporte a fotos) não comprometeram a experiência central do aplicativo.

---

## Avaliação pelas métricas definidas

### Funcionalidade

A aplicação permite adicionar, visualizar, editar e remover hábitos de forma funcional. O fluxo completo — desde o onboarding, passando pelo login, criação de hábitos, marcação diária, até a visualização de estatísticas — funciona de ponta a ponta. A IA conseguiu implementar lógica de negócio como cálculo de streaks, filtro por dia da semana, taxa de conclusão por período e categorização de hábitos sem intervenção manual significativa.

### Qualidade do código

O código segue o padrão **MVVM** (Model-View-ViewModel) com separação clara de responsabilidades. A IA utilizou `Provider` para gerenciamento de estado, criou modelos tipados com enums e métodos de serialização, e aplicou tratamento de erros com `try-catch` e verificações de `mounted` para operações assíncronas. Nas iterações finais, o código apresentava conformidade com o `flutter analyze`, sem warnings ou erros. Porém, nas iterações iniciais (especialmente a iteração 3), houve **corrupção de código** causada por substituições mal executadas pela IA, exigindo recriação manual de arquivos.

### Fidelidade ao design

A IA conseguiu reproduzir a maior parte dos elementos visuais dos protótipos, incluindo gradientes, badges flutuantes, bottom sheets animados e cards de hábitos. No entanto, **a fidelidade não foi exata na primeira tentativa** — foram necessárias múltiplas iterações para ajustar cores, espaçamentos e posicionamento de elementos. O caso mais expressivo foi o posicionamento da imagem na tela de login, que demandou **5 iterações consecutivas** (6 a 10) para ser resolvido, evidenciando uma dificuldade da IA em resolver problemas de layout espacial/visual sem feedback interativo.

### Esforço de refatoração

Das 36 iterações, **13 (36%) foram dedicadas a corrigir problemas de iterações anteriores** (retrabalho). As correções mais comuns envolveram:

- Ajustes de layout e overflow (10 ocorrências)
- Correção de lógica de dados (6 ocorrências)
- Qualidade de código e warnings (5 ocorrências)
- Problemas de integração (3 ocorrências)

O esforço de refatoração manual foi **baixo a moderado**. A maioria dos problemas foi resolvida pela própria IA ao receber feedback descritivo. As intervenções manuais se limitaram a: apagar arquivos corrompidos, configurar credenciais do Firebase/Google Sign-In e criar índices compostos no Firestore.

---

## Análise do número de iterações

As **36 iterações** representam um volume **razoável** considerando o escopo do projeto:

- **Iterações de construção (23):** implementação de funcionalidades novas — telas, autenticação, notificações, gráficos, i18n, modelos de dados.
- **Iterações de correção (13):** ajustes de bugs, layout, lógica e polish visual.

Para efeito de comparação, o aplicativo final contém aproximadamente **10-12 telas/views**, **5 ViewModels**, **8 modelos de dados**, **1 serviço de notificação**, **4 arquivos de tradução** e integração com 3 serviços Firebase. Construir esse escopo em 36 prompts — sem escrever código manualmente — é um resultado expressivo.

A média de **1,6 iteração por funcionalidade principal** sugere que a IA consegue entregar features completas com pouca necessidade de retrabalho quando a especificação é clara e acompanhada de protótipos visuais.

---

## Padrões de comportamento da IA observados

### Pontos fortes

1. **Implementação de features bem especificadas em uma única iteração** — Autenticação Firebase (iteração 11), tela de estatísticas (iteração 28) e tela de configurações (iteração 29) foram implementadas corretamente na primeira tentativa.

2. **Evolução da qualidade ao longo do projeto** — As iterações iniciais apresentaram mais problemas (overflow, corrupção de código). A partir da iteração 15, a qualidade das entregas melhorou significativamente.

3. **Proatividade** — A IA frequentemente sugeria próximos passos, criava documentação auxiliar e antecipava necessidades como `flutter pub get` e `flutter gen-l10n`.

4. **Recuperação de erros** — Quando informada de um bug, a IA geralmente resolvia em 1 iteração adicional.

### Pontos fracos

1. **Dificuldade com problemas visuais/espaciais** — O caso da imagem na tela de login (5 iterações para resolver) demonstra que a IA tem dificuldade em depurar problemas de layout sem visualizar o resultado.

2. **Qualidade inconsistente na primeira tentativa** — Overflows não antecipados, deprecated warnings ignorados e lógica de completion incorreta na primeira implementação.

3. **Corrupção de código por edições agressivas** — Na iteração 3, múltiplas substituições no mesmo arquivo resultaram em código duplicado e malformado.

4. **Especificações incompletas geram entregas incompletas** — A internacionalização (iteração 30) ficou parcial na primeira tentativa, exigindo uma iteração adicional para cobrir todas as telas.

---

## Nível de conhecimento técnico necessário

Para reproduzir este resultado utilizando IA como ferramenta de desenvolvimento, o usuário precisaria de:

**Conhecimento mínimo obrigatório:**
- Entendimento básico de **Flutter e Dart** (estrutura de projeto, widgets, navegação)
- Familiaridade com o conceito de **arquitetura MVVM** ou similar
- Capacidade de **configurar o ambiente** (Flutter SDK, Firebase Console, credenciais OAuth)
- Habilidade de **ler e interpretar mensagens de erro** para descrever problemas à IA
- Noção de **versionamento com Git** para gerenciar o histórico de alterações

**Conhecimento desejável:**
- Experiência com **Firebase** (Authentication, Firestore, índices compostos)
- Familiaridade com **gerenciamento de estado** (Provider, ChangeNotifier)
- Capacidade de avaliar **qualidade de código** e identificar padrões ruins
- Conhecimento de **design responsivo** para identificar problemas de layout

**Não seria necessário:**
- Dominar a sintaxe de Dart em profundidade
- Conhecer de cor as APIs do Flutter
- Saber implementar animações, gráficos ou notificações manualmente

Em resumo, um desenvolvedor com **nível intermediário** em Flutter conseguiria conduzir este projeto com IA de forma eficiente. Um iniciante conseguiria avançar, mas teria mais dificuldade em identificar e descrever problemas para a IA corrigir — o que potencialmente aumentaria o número de iterações. Um desenvolvedor sem nenhum conhecimento de programação teria dificuldades significativas na configuração do ambiente e na interpretação de erros.

---

## Conclusão

O desenvolvimento do Habit Flow demonstrou que a IA é uma ferramenta **viável e produtiva** para construir aplicativos Flutter de média complexidade. Em 36 iterações, foi possível construir um aplicativo completo com autenticação, persistência, notificações, gráficos, temas e internacionalização — sem escrever código manualmente.

Os principais gargalos foram problemas visuais/espaciais (que a IA tem dificuldade em resolver sem feedback visual) e a necessidade de configurações manuais em serviços externos (Firebase, Google Sign-In). A taxa de sucesso de **89% na primeira tentativa** e a necessidade de apenas **36% de retrabalho** indicam que, com prompts bem elaborados e protótipos de referência, a IA consegue entregar resultados consistentes.

O número de iterações foi **razoável para o escopo entregue**, e o esforço humano se concentrou principalmente em: descrever requisitos, fornecer protótipos, identificar bugs visuais e configurar serviços externos — tarefas que exigem julgamento e contexto, mas não escrita de código.
