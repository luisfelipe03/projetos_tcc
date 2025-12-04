# **Proposta do Projeto — Versão 3**

Depois de fechar a tela de ToDo List e garantir a persistência via SQLite, cheguei enfim num ponto bem sólido da estrutura do app. Agora a ideia é dar mais um passo e implementar mais duas telas importantes do FlutterBook: **Notas** e **Contatos**.

Aqui o nível sobe um pouco, porque essas entidades têm mais complexidade.

* **Notas** exige título, corpo e um seletor de cores para personalizar cada item.
* **Contatos** envolve nome, telefone, data de nascimento e, pra completar, um seletor de imagem — permitindo escolher da galeria ou tirar foto na hora.

Essa integração extra traz mais desafios, mas faz parte da evolução natural do projeto, sempre mantendo o foco em geração de código com prompts e intervenção mínima.

---

# **Notas — Screenshot da aplicação original**

<img width="350" alt="Notas vazia" src="https://github.com/user-attachments/assets/78017b92-c684-4fb3-9ace-d1554c534014" />
<br>
<img width="350" alt="Cadastro de notas campos vazio" src="https://github.com/user-attachments/assets/77e6d94d-c9e4-41c3-a41b-7d82cbc32b68" />
<br>
<img width="350" alt="cadastro de notas campos preenchidos" src="https://github.com/user-attachments/assets/3a5b9819-bb91-4a88-8fa1-fab8281e8f45" />
<br>
<img width="350" alt="listagem de notas e snackbar de sucesso" src="https://github.com/user-attachments/assets/9cf233cb-77c7-46ed-8172-be9c469c2366" />
<br>
<img width="350" alt="botão de apagar notas" src="https://github.com/user-attachments/assets/291ad165-cb0f-4d09-b472-651922f80fcb" />
<br>
<img width="350" alt="snackbar de confirmação de excluição" src="https://github.com/user-attachments/assets/809002f3-b226-48d9-a4f1-e90547e9c5ad" />

---

# **Contatos — Screenshot da aplicação original**

<img width="350" alt="Contatos vazio" src="https://github.com/user-attachments/assets/4689f65f-e027-427b-90f1-832a86d18181" />
<br>
<img width="350" alt="cadastro de contatos" src="https://github.com/user-attachments/assets/06fc2f9e-e1e1-45cb-b674-96537955b085" />
<br>
<img width="350" alt="Escolha de selecionar foto ou capturar par foto do contatos" src="https://github.com/user-attachments/assets/3051aff2-10df-46f5-b2cf-ca29a76fa8dd" />
<br>
<img width="350" alt="foto selecionada" src="https://github.com/user-attachments/assets/d002c4b0-5667-4da6-bd61-069039883ccd" />
<br>
<img width="350" alt="seletor de data" src="https://github.com/user-attachments/assets/43de00ee-f633-48ef-9dab-6baf597e8835" />
<br>
<img width="350" alt="listagem de contatos e snackbar de sucesso" src="https://github.com/user-attachments/assets/2c409368-97bf-4cbd-a9c6-7985f3ec5ee7" />
<br>
<img width="350" alt="botão de exclusão" src="https://github.com/user-attachments/assets/f457049e-993b-4959-bdf1-025fda900089" />
<br>
<img width="350" alt="snackbar de exclusão" src="https://github.com/user-attachments/assets/468c2de0-7a65-4068-83a4-3e227d42010f" />

---

# **Objetivo**

Nessa etapa, o foco é expandir a estrutura já construída e manter o mesmo espírito da v1 e v2:
usar **vibe coding** pra gerar o máximo de código possível automaticamente, sem abrir mão da clareza, do padrão e daquela organização tradicional que evita dor de cabeça mais pra frente.

Os objetivos principais são:

* Implementar totalmente as funcionalidades de **Notas** e **Contatos**.
* Integrar ambas ao SQLite, mantendo o padrão já usado na ToDo List.
* Respeitar fielmente o design do FlutterBook.
* Reduzir ao máximo qualquer intervenção manual, confiando no fluxo guiado por prompts.

---

# **Métricas de Avaliação**

* **Persistência completa:**
  Notas e contatos precisam estar 100% integrados ao SQLite: criar, listar, editar e remover sem falhas.

* **Qualidade do código:**
  Manter o mesmo cuidado das versões anteriores — coeso, organizado, seguindo padrões clássicos do Flutter.

* **Fidelidade visual:**
  A interface deve seguir o FlutterBook literalmente, sem “interpretação artística”.

* **Baixa intervenção manual:**
  Quanto menos eu mexer no código gerado, melhor. A ideia é continuar validando a eficiência do vibe coding.

* **Integrações funcionando de ponta a ponta:**
  Seletor de cor, seleção/captura de imagem, picker de data… tudo precisa estar fluindo sem gambiarras.

---

# **Resultados**

