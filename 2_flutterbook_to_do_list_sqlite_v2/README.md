# **Proposta do Projeto — Versão 2**

Agora que a primeira versão da tela de ToDo List já ficou bem redondinha, chegou a hora de dar o próximo passo natural: **incluir persistência local usando SQLite**. A ideia é manter o mesmo espírito do v1 — desenvolvimento guiado por prompts e o mínimo de intervenção manual — mas evoluindo o projeto pra algo mais próximo de um app “de verdade”, que guarda os dados mesmo depois que o usuário fecha a aplicação.

---

# **Objetivo**

Quero integrar o SQLite ao projeto atual, tornando a tela de tarefas totalmente persistente. A meta é:

* Salvar, atualizar, listar e remover tarefas direto no banco.
* Continuar usando a técnica de **vibe coding**, deixando o fluxo o mais automático possível.
* Manter o código limpo, claro e dentro das boas práticas estabelecidas no v1.

---

# **Métricas de Avaliação**

* **Persistência funcional:**
  Todos os dados da ToDo List devem ser armazenados localmente via SQLite e recuperados corretamente ao abrir o app.

* **Qualidade do Código:**
  Seguir a mesma tradição do v1: organização, padrões do Flutter e respeito ao analisador.

* **Integração transparente:**
  A adição do banco não pode quebrar a simplicidade da tela original. Tudo deve continuar funcionando como antes — só que agora com estado real.

* **Baixa intervenção manual:**
  Assim como no v1, quero maximizar o uso de prompts para geração do código, reduzindo retrabalho.

* **Manutenção da fidelidade visual:**
  O design da interface deve permanecer fiel ao FlutterBook, mesmo com a integração de dados reais.

---

# **Resultados**

Em apenas uma iteração a IA conseguiu implementar a persistência dos dados no SQLite. Como eu não especifiquei o método de implementação, ela própria optou por criar um singleton de um helper para fazer a comunicação com o arquivo SQLite — e funcionou muito bem. Essa nova implementação gerou duas issues no analisador de código do Dart, mas em mais duas pequenas iterações a IA conseguiu resolver tudo com sucesso.

<img width="1408" height="198" alt="Captura de Tela 2025-12-03 às 20 26 00" src="https://github.com/user-attachments/assets/73232e41-b8d2-4bbf-a6af-15611d1d6dd5" />

