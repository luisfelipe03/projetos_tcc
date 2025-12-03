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

# **Resultados esperados**

A expectativa é que, ao final da v2, o projeto tenha persistente na base de dados.
