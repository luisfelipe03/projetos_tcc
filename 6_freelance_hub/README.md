# **Proposta do Projeto**

Desenvolver um aplicativo Flutter de alta complexidade que funcione como uma **plataforma de marketplace para freelancers**, permitindo que clientes publiquem projetos, freelancers enviem propostas, e ambos gerenciem contratos com sistema de escrow simulado, chat em tempo real e avaliações mútuas.

O foco do projeto está na **implementação completa do aplicativo**, incluindo front-end com protótipos de alta fidelidade, lógica de negócio crítica via Cloud Functions e persistência com Firebase Firestore.

---

# **Objetivo**

Avaliar até que ponto o modelo de IA consegue projetar, implementar e organizar um aplicativo Flutter de alta complexidade, envolvendo múltiplos papéis de usuário (cliente e freelancer), ciclo de vida de contratos com máquina de estados, transações financeiras simuladas e comunicação em tempo real — com backend via Firebase.

### Funcionalidades previstas

* Cadastro e autenticação com Firebase Auth (e-mail/senha)
* Dois papéis de usuário: **Cliente** e **Freelancer**, com navegação e permissões distintas (RBAC)
* Publicação de projetos pelo cliente
* Envio e gerenciamento de propostas pelo freelancer
* Sistema de **escrow simulado** — valor bloqueado ao aceitar proposta, liberado ao aprovar entrega
* Ciclo de vida do contrato: `active → delivered → revisionRequested ↔ delivered → completed`
* **Chat em tempo real** entre cliente e freelancer
* Upload de arquivos de entrega via Firebase Storage
* Sistema de **avaliações mútuas** (reviews) após conclusão do contrato
* Carteira digital (wallet) com saldo disponível, escrow e histórico de transações
* **Push notifications** com deep link para a tela relevante
* Edição de perfil (nome + foto) com propagação automática nas denormalizações
* Busca e filtros de projetos por categoria, orçamento e tipo
* Suporte a **tema claro e escuro** (segue o sistema operacional)

---

# **Arquitetura e Stack Técnica**

### Stack utilizada

* **Gerenciamento de estado:** `StatefulWidget` + `StreamBuilder` (reatividade ponta-a-ponta via streams do Firestore)
* **Navegação:** `Navigator` imperativo
* **Backend:** Firebase (Firestore) + Firebase Auth + Firebase Storage + Cloud Functions + Firebase Cloud Messaging
* **Formulários:** `Form` + `TextFormField` nativos do Flutter
* **Chat:** subcollection `threads/{tid}/messages/{mid}` no Firestore com snapshots em tempo real

### Modelo de dados (Firestore)

Collections principais: `users`, `wallets`, `projects`, `proposals`, `contracts`, `threads` (com subcollection `messages`), `reviews` e `transactions`.

* O campo `status` dos contratos só pode ser alterado via **Cloud Functions** — as Security Rules bloqueiam escrita direta pelo cliente.
* `wallets` é separada de `users` para isolar dados financeiros das rules de leitura pública dos perfis.
* `messages` ficam em subcollection da thread, com leitura validada pelo `threadId` ordenado dos uids dos participantes.

### Cloud Functions

Toda lógica crítica roda em Firebase Cloud Functions (Node.js/TypeScript):

**Callables:**
* `acceptProposal` — cria o contrato, valida saldo do cliente e bloqueia o valor no escrow
* `rejectProposal` — marca proposta como rejeitada
* `markContractDelivered` / `resubmitContractDelivery` — atualiza status e fotos da entrega
* `acceptContractDelivery` — libera o escrow para o freelancer e fecha o projeto
* `requestContractRevision` — volta o contrato para `revisionRequested`
* `sendMessage` — cria/atualiza thread, posta mensagem e dispara push
* `submitReview` — registra avaliação imutável e agrega rating no perfil
* `simulateDeposit` — credita saldo na carteira (modo demonstração)

**Triggers:**
* `onProposalCreated` — incrementa `proposalCount` e notifica o cliente
* `onProposalStatusChanged` / `onContractStatusChanged` — disparam push notifications nos eventos chave
* `onUserCreated` — inicializa a carteira do usuário com saldo zero
* `onUserUpdated` — propaga `displayName` novo em threads, contratos e propostas (denormalização viva)

---

# **Métricas de Avaliação**

* **Funcionalidade**
  A aplicação deve permitir o fluxo completo: publicar projeto → receber propostas → aceitar proposta → gerenciar contrato → aprovar entrega → avaliar — de forma clara e funcional para ambos os papéis (cliente e freelancer).

* **Qualidade do Código**
  O código deve ser organizado, seguir as boas práticas do Flutter e estar em conformidade com o analisador oficial da linguagem.

* **Fidelidade ao Design**
  A interface deve respeitar o visual definido nos protótipos de alta fidelidade disponíveis em:
  [Protótipo - Onboarding e Splash](https://stitch.withgoogle.com/projects/15234981211885077258)
  [Protótipo - Telas principais](https://stitch.withgoogle.com/projects/538885861064600932)

* **Esforço de Refatoração**
  O código gerado deve exigir o mínimo possível de ajustes manuais para atender aos critérios de funcionalidade, qualidade e fidelidade ao design.
  Quantidade de prompts até o app funcionar.

---

# **Protótipo**

> Os protótipos abaixo foram gerados pela ferramenta de IA **Google Stitch**.
> O resultado final pode sofrer pequenas alterações durante a implementação, servindo os protótipos apenas como **referência visual e inspiração**.

### Splash

<img width="300" alt="Splash - Dark" src="https://lh3.googleusercontent.com/aida/ADBb0uj5KCykYI0L4eu8DlfVD6wR00SNh7JLcc-16-M4fYTiFYKUvyguG6wDFU_HFitFRZHNDsEWMnA52Vb5xTaEEfG7mPyqhmPkZuo4rP8yL6SBQ6NqFw8bEUZ_tSlPNSzLpL6N609_igy-BorXyrp_RDsoAqF7eTdc_uc6AVG3o81nDrLWbHDaZ2Y3HhazaLaP_7G6F1mQgNcUfZ-UvqzpmeHW7clPp_8Udw3U0Om2mRFPzzCr5VU1HBZnDmw8" />
<img width="300" alt="Splash - Light" src="https://lh3.googleusercontent.com/aida/ADBb0uhDvoHNScPys65x5E4PX0MpqfLG9UzA0eOOhu10ciat0caANeoSOyHIsGzBeos_6rxYCEkFrcfU0fJoM7YR1ao0EcHyYq4P63sreN9g1x6ZLpJh_KOpLPLC6DuahHW44CVXJEpVtGd3z27TnbB6Ohkn2tNdG4mKkmomgIa5GDUWTfT7TYW-srIAi1y7i4OaP6NBLbN02KD6KFx05mrxvu137rNh3fG4kL8eLAdBRQtScJa4YAiwpn_xLJeP" />

---

### Onboarding 1

<img width="300" alt="Onboarding 1 - Dark" src="https://lh3.googleusercontent.com/aida/ADBb0ugVAsd1L39JrZKfdJ3ACZiRlm0u7bRlUi6t8IXrK0fp2QHZBUe0t2TJqvKrUdWwplG6CCVX328COqpWTOImwV0GjCIEHNiIgwkDiqpkBJN-1zPSQOBCjA38hb3eO11M3C1NM948hPFntve9la1TVx7TXvt8swnB1Qrs1ZOoR1F_4_XIxt2nflA1qVYYBENQt0uSlovpA27LrsB9lMa2_mLUMFppOEOtUzFAYqLR1q5uJchEVU-VGGQxyY0" />
<img width="300" alt="Onboarding 1 - Light" src="https://lh3.googleusercontent.com/aida/ADBb0uh94PeVYicrsxIf-3O1fwjjmn7a9-hig7EdDjcr-qAqzvUXNMNLR95m4kjQ52cybkgEWLO5y-E7njVKkg7DteAywoghuxxSLyPBjo2uPlB7JH0PHA3_7Glb3TRK1zLDxXfekSPh4aCbRM1WS_Qm-fJDHSCmrm65SRpy56glLr3By_ddZrrzWdbfxR1GC846joD3YPq36AUx9iXwTDpnf-OnBLHaII3AuUqNFYrDRsHgCefX9CAfwlUtrrtX" />

---

### Onboarding 2

<img width="300" alt="Onboarding 2 - Dark" src="https://lh3.googleusercontent.com/aida/ADBb0uj_UQu42xmyS0H0g_PlFeN2hTMc8Kp15NibjlQ0NbzdL1PSHbc5JxRV8gePaIZ760rYyyd_RWODKpKM8AJXvVu5BsNKgQ46udKJ6CDczoH6cYq20s73vcJxE7EuB3V4kxoHPTxk8v3jpl5N2MVcnbPU75gSa7GZj0m3aQVm7G-RntI0zXginRPamH2CU5szcAc8waovfn5ybF8009rX7WxXByr4JwqUsop_H7zUZEb9yDiyO_fvVhyJSDco" />
<img width="300" alt="Onboarding 2 - Light" src="https://lh3.googleusercontent.com/aida/ADBb0ui_FCriSRDQDXwTr7nfpIsfng51QUF0aG8CFTxIsPzxmdpKaRhawmbwMvx-ZsjmNZUsQMnMqvPjdejfFuEezeLwbkuTr8ahXOZUlwLVAFz7edSG6jpnyiUkmkGfn4yd3ivBH3sM06isWmfJBENSIWqUZab79TdCFq1o_0YCt1Ty3AeEBe24VV_0enTqwx2HV63H3stpzDMgYVVCRMQ820UeIx8sri3MWhR7d92J3SsCcKHuc5snTjV6sSQ" />

---

### Onboarding 3

<img width="300" alt="Onboarding 3 - Dark" src="https://lh3.googleusercontent.com/aida/ADBb0ugX7jEfLx76FPs4vejScifGRb7LLnl7rEvKIO2G0W0fiX5SaxPlS4TtEi7taEqqI-kVMyALFB-UIDL8fqmcep8wq8h00ymXiEzO37tVVy5zXaldpr58EkYecLsEtWv8UvolDudLKapL-vkYNfUMCtCbqW-Ql4OlwOxrm_EZhDCZdet_DDmzr2A6hiNIM_wUI71AJ_k8hcjCFtWWtJdL-bgBWXjIWkK1TbZZFyc5kfLQTGrd62VJLg_0jNob" />
<img width="300" alt="Onboarding 3 - Light" src="https://lh3.googleusercontent.com/aida/ADBb0ujG1CYet8eXFk9mYSpnxwYL8y6ALs7TQH2v1oKc799NS0x39m9mBLPLDX0RUnQKhpHbh-JxUePIeMKfP66wPkIuC4jeNGVut8jsfGy01XisEn-_TIlI22uvxJ2HvkIbUPNK-Dyh4EL1VPiENOrwRPFilEc5V4eGYMyBrPJkwuQdrr6rpfIwT3wSGBYr86mnYdwTbs65pCVXMQN1dl3RzxPjnkNrN7VziRByAHd5VuQgqJtFkBhpAjoKRsdU" />

---

### Seleção de idioma

<img width="300" alt="Language Sheet - Dark" src="https://lh3.googleusercontent.com/aida/ADBb0ujwhgCJEdiVaWo8lVW2HSkB-4pClrJom9JbsQYK-HTbWNUxvehK-LX6xYikS-zCGHLEFttSOXLIrvJZupSi71zjg-FLBf64T_EXqIjyNowLm7adY-s-X5CV4lcAIbGN_j1P5QBh3n6uFzpOPfiRqU1cc-IXgCG6zF_WuLDMimhFF-QAWfkKKCL8yjZwaZxK1o_oI7D4aDJR9sqkUfLtf_G6xPLOWkanCNVhduqgeqdbCHT67Tonl7q2txqb" />
<img width="300" alt="Language Sheet - Light" src="https://lh3.googleusercontent.com/aida/ADBb0ugj6cvQNv97ovXnF3PViR71LRSEmgJB_BvU-FpGyE_EYHvccrCY8uAlFyszjmp6DFRrBE-ocyJZNbPNmHPHo3GfWQM24PwDsar_ktX-yJdg2N76f0VHkL8PfYzZkkUuRzL-bx3x4Y84aAyqM1cAIdSBr2Lln1RC9FsXCRsyC62g7XzrMGbKC0_OKRyLiUjQEvBTJ1Yn6srw3j3MQdOTgWD3GTnNmmRTQmlqHfXM6UX0YcNN6cK86m4NcVJN" />

---

### Login e Autenticação

<img width="300" alt="Login & Auth" src="https://lh3.googleusercontent.com/aida/ADBb0uiXE96BDEvC9u-iZpuw7kswjudXg5NTo4p3NCrTuWlSb8SWlzeCD6Y-eU30m5Xtay8hNCThBM_cxW5BqnexxDRaCegwgNlEQi_sZp2NP2DFIwqRNeROgk_2L3DZ8GhBbdNvHpDAt-_utTdbxB4qVOwn9F5q4PoO_LhIY0-afWmK2mdiiAn8T0uZdk22xT5WtlyOjJb77Ih4yajyMBi06qajADlhejZoHmUmrjDjZ5X_nAG5CyTz6lFYYA" />

---

### Feed de projetos

<img width="300" alt="Project Feed" src="https://lh3.googleusercontent.com/aida/ADBb0ugsOdElAoeMUFOibVLFo0ptYHmY6oWyhF7ygTVd6ZjOCb8YJdBiQuWHUb541877rCcH8mKtrQQp0v97MlmTUPNU4GlQAi5FGkE2UM9ib5aiixbp5DNu25wBPZlWncz8GSyx6veo0dJrwLkKkriu_kVaDPyNXQjDfk9yloruTHwSV10RVv9r2duuVC_oUVt4wgtEuWyQGivxOegplKAm2pYAe9BGh8llaHkJSKt1KHUtfDaVdMmll1qLRQ" />

---

### Dashboard do cliente

<img width="300" alt="Client Dashboard" src="https://lh3.googleusercontent.com/aida/ADBb0uhppL5ULM5orqRXEMLXtioWGXD_VrnzEzcMhPyqeWEgkT4AjnAWbZIs0r0RTi6SHmJtQLIQPGO8zgfUMq8df6xu7TOSUhuEhV9Ku_fqIT8tzz217GoQ4EyoYzj5lzQmj6U94QIsybgkTDFyFhBc_-84O9BLZniM1HI7I7c8TGzQ7CIEJBrIX2hMMGI4YjBElevBogAtc-buLrH0NuiLVDQLXH9zPbDcyyqyK7hqpj3M-s-DVb6XMO96sg" />

---

### Contrato ativo e Chat

<img width="300" alt="Active Contract & Chat" src="https://lh3.googleusercontent.com/aida/ADBb0uj65RincSgzGfhq3V5dK4PCg0w0Q_Q3HXjZQ4WGgCZGt2ucFeoC4kgHreQYdENvV8ZEMSQscxp9hQ2PzVwwaz73-yhboNBJIkxFNxjtTsab4BUlvfTCIpNeK5JVIfW8wkakL8ymQhKB-_L7-d2lsEu9qL4geAk0mU_uIk1ahuu6Cm3vNMr-qoxI_wc-IOlNtCW3HBUuWDez3w2gjcaIq_gUbtnPkMqHdy61Etj_EA6QYu185M7QPTbvyw" />
