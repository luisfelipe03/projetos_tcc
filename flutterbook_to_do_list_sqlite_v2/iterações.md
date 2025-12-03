## Iteração 1
### Promt usado:
```plaintext
Quero que você atue como meu par de programação. Estou desenvolvendo um clone do FlutterBook, que é dividido em quatro partes. A parte de Tasks eu já finalizei, e agora quero implementar a persistência dos dados usando SQLite. Me ajude a criar essa implementação.
```
### Output recebido:
```markdown
Vou criar um plano de tarefas (TODOs) para a implementação SQLite e marcá-lo como em progresso, em seguida lerei os arquivos mais relevantes para adaptar o modelo e o viewmodel.

Created 6 todos

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_sqlite_v2/lib/models/task_model.dart)

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_sqlite_v2/lib/viewmodels/tasks_viewmodel.dart)

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_sqlite_v2/lib/views/tasks_screen.dart)

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_sqlite_v2/lib/views/task_entry_screen.dart)

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_sqlite_v2/pubspec.yaml)

Próximo: vou abrir main.dart para ver como o `TasksViewModel` é provido e assim inicializar corretamente o DB no arranque.

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_sqlite_v2/lib/main.dart)

Vou aplicar as alterações: 1) atualizar pubspec.yaml, 2) adicionar `lib/services/database_helper.dart`, 3) atualizar task_model.dart, 4) atualizar tasks_viewmodel.dart, 5) ajustar task_entry_screen.dart. Vou aplicar tudo de uma vez.

Using "Apply Patch"

Using "Apply Patch"

Agora vou atualizar o modelo `Task`, o `TasksViewModel` e ajustar `TaskEntryScreen` para usar operações assíncronas com o DB. Em seguida aplico as modificações.

Using "Apply Patch"

Using "Apply Patch"

Using "Apply Patch"


Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_sqlite_v2/lib/models/task_model.dart)

Using "Apply Patch"

Vou checar por erros de compilação/linters nos arquivos alterados.

Checked workspace, no problems found

Trabalho feito — implementei persistência SQLite para Tasks e atualizei o ViewModel/telas para usar o banco. Próximos passos: rodar `flutter pub get` e testar no emulador/dispositivo.

Resumo das alterações
- **Adicionado**: database_helper.dart — singleton SQLite (CRUD para `Task`).
- **Atualizado**: task_model.dart — adicionados `toMap()` e `factory Task.fromMap(...)`.
- **Atualizado**: tasks_viewmodel.dart — carrega tarefas do DB no arranque e persiste add/update/delete.
- **Atualizado**: task_entry_screen.dart — agora aguarda a gravação no DB antes de fechar e mostrar o Snackbar.
- **Atualizado**: pubspec.yaml — dependências `sqflite` e `path` adicionadas.

O que eu alterei (arquivos)
- pubspec.yaml
- database_helper.dart (novo)
- task_model.dart
- tasks_viewmodel.dart
- task_entry_screen.dart

Comandos para rodar localmente

cd /Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_sqlite_v2
flutter pub get
flutter run


Teste rápido sugerido
- Abra a aba Tasks, adicione uma tarefa, feche o app (ou reinicie a tela) e confirme que a tarefa persiste.
- Teste marcar/desmarcar (update) e deletar (delete) via slide — mudanças devem persistir.

Observações e próximos passos recomendados
- A implementação atual persiste só as Tasks. Se quiser, estendo para Notes, Contacts e Appointments (posso:
  - criar tabelas separadas e models com `toMap/fromMap`,
  - adicionar métodos no `DatabaseHelper` ou criar DAOs separados).
- Se preferir, substituo o singleton por repositório/abstração para facilitar testes e mock.
- Depois de testar, quero commitar as mudanças (se desejar faço o commit e uma mensagem de commit).

Quer que eu:
- 1) também implemente persistência para Notes/Contacts/Appointments agora, ou
- 2) abra um PR/commit com essas mudanças, ou
- 3) rode mais ajustes (ex.: ordenar, adicionar índices, busca)?

Made changes.
```

### Resultado:
Em apenas 1 iteração, implementamos a persistência de dados usando SQLite. A AI criou um helper de banco de dados dentro `lib/services/database_helper.dart`, atualizou o modelo de tarefas e o viewmodel, e ajustou a tela de entrada de tarefas para usar operações assíncronas com o banco. Também adicionou as dependências necessárias no `pubspec.yaml`. Como não foi especificado o uso de um repositório ou DAO, a implementação foi feita de forma direta com o singleton do helper. Mas a AI deixou claro que poderia ser adaptada para usar repositórios ou DAOs se necessário.
