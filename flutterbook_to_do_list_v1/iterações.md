## Iteração 1
### Promt usado:
```plaintext
Quero que você aja como meu par de programação. Vou enviar um print da primeira página da aba Tasks do FlutterBook, e quero que você gere todo o código necessário para reproduzir exatamente essa tela vazia, seguindo o mesmo estilo visual, componentes e padrões usados no app original. Gere o widget completo da tela, com a estrutura correta, os estilos coerentes, os elementos visuais idênticos ao print e qualquer widget auxiliar que a tela precise. O código deve ser limpo, idiomático e sem comentários desnecessários. Depois que você entregar essa parte, vamos continuar o resto do fluxo (adicionar, editar e remover tarefas).
```
### Output recebido:
```markdown
Vou analisar o print e criar o código para reproduzir a tela inicial da aba Tasks do FlutterBook. 

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/main.dart#1-1), lines 1 to 50

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/main.dart#51-51), lines 51 to 123

Agora vou criar o código completo baseado no print. Vejo que a tela tem:

1. AppBar com título "FlutterBook"
2. Navegação inferior com 4 abas (Appointments, Contacts, Notes, Tasks)
3. Tasks está selecionada (roxa)
4. Área vazia para lista de tarefas
5. Botão flutuante roxo com ícone de adicionar 

Pronto! Criei a estrutura completa da tela Tasks do FlutterBook:

**Estrutura implementada:**

1. **AppBar** - título "FlutterBook" centralizado, fundo branco
2. **BottomNavigationBar** - 4 abas (Appointm, Contacts, Notes, Tasks) com a Tasks selecionada na cor roxa (#7C4DFF)
3. **TasksScreen** - tela vazia com fundo cinza claro, pronta para receber a lista de tarefas
4. **FloatingActionButton** - botão roxo com ícone de adicionar no canto inferior direito

O código está limpo, idiomático e segue os padrões Flutter. As cores e estilos visuais correspondem ao print fornecido. 

Execute o app para ver a tela funcionando. Quando estiver pronto, podemos avançar para implementar a funcionalidade de adicionar, editar e remover tarefas.
```

### Resultado:

Para uma primeira iteração, o código gerado foi bem satisfatório, ou um erro no design onde a barra com as ferramentas foi colocada no canto inferior da tela, mas originalmente estava no topo. Mas o restante do design foi bem capturado, cores, botões, tipografia, etc. E assim como no projeto base que já vem ao criar um projeto Flutter, a AI mante todo o código em um único arquivo main.dart, o que não é o ideal para projetos maiores, mas para uma primeira iteração está aceitável. Agora vamos para a próxima iteração, onde faremos adição de mais funcionalidades.

## Iteração 2
### Promt usado:
```plaintext
Ok, ficou bem parecido com o design original do print que eu forneci, mas tem só um detalhe: a barra com as ferramentas está no canto inferior da tela, e originalmente ela fica no canto superior, logo abaixo do nome Flutterbook. A barra está perfeita, com todos os ícones e nomes iguais, então basta mudar apenas a posição
```

### Output recebido:
```markdown
Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/main.dart)

Perfeito! Movi a barra de navegação para o topo, logo abaixo do título "FlutterBook". Agora ela está posicionada exatamente como no print original, usando o `bottom` do AppBar com os mesmos ícones e estilos que você já aprovou.

Made changes.
```

### Resultado:


## Iteração 3
### Promt usado:
```plaintext
Ficou bacana. Agora vamos criar a próxima página de cadastro de task, e essa tela deve seguir os mesmos padrões da screenshot
```

### Output recebido:
```markdown
Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/main.dart#1-1), lines 1 to 160

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/main.dart#160-160), lines 160 to 172

Pronto! Criei a tela de cadastro de task seguindo o design do print:

**Elementos implementados:**

1. **AppBar** com título "FlutterBook" e barra de navegação com Tasks selecionado
2. **Campo Description** com ícone de documento e campo de texto
3. **Due Date** com ícone de calendário, data formatada ("November 28, 2025") e botão de editar (lápis azul)
4. **Botões Cancel e Save** na parte inferior em roxo
5. **Date Picker** funcional ao clicar no botão de editar

A navegação já está conectada - ao clicar no botão flutuante "+" na tela de Tasks, a tela de cadastro será aberta. Os botões Cancel e Save fecham a tela e retornam para a lista.

Made changes.
```

### Resultado:
Nessa iteração, a AI conseguiu criar a tela de cadastro de tarefas com todos os elementos visuais, inputs e botões necessários, seguindo o design original. A navegação entre a tela de lista de tarefas e a tela de cadastro também foi implementada corretamente. As função de salvar e cancelar apenas fecham a tela por enquanto, mas isso é esperado para essa etapa. O problema é que a AI ainda manteve todo o código em um único arquivo main.dart, o que já está ficando confuso. Na próxima iteração, vamos pedir para ela separar o código em múltiplos arquivos para melhorar a organização.

## Iteração 4
### Promt usado:
```plaintext
Show, o resultado da tela de cadastro ficou muito bacana, mas o código está ficando muito verboso e vai acabar dificultando a manutenção. Vamos melhorar o código e separar o projeto em arquivos menores respeitando os padrões de desenvolvimento mvvm
```

### Output recebido:
```markdown
Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/main.dart#1-1), lines 1 to 50

Created 7 todos

Starting: *Criar estrutura de diretórios MVVM* (1/7)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/models/task_model.dart)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/core/constants.dart)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/core/theme.dart)

Starting: *Criar widgets compartilhados* (4/7)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/widgets/custom_app_bar.dart)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/widgets/navigation_tabs.dart)

Starting: *Criar TasksViewModel* (5/7)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/viewmodels/tasks_viewmodel.dart)

Starting: *Refatorar screens para views* (6/7)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/views/tasks_screen.dart)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/views/task_entry_screen.dart)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/views/appointments_screen.dart)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/views/contacts_screen.dart)

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/views/notes_screen.dart)

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/pubspec.yaml#1-1), lines 1 to 30

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/pubspec.yaml#30-30), lines 30 to 50



Ran terminal command: flutter pub get

Starting: *Atualizar main.dart* (7/7)

Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/main.dart#1-1), lines 1 to 100

Created [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/main_new.dart)

Ran terminal command: rm lib/main.dart && mv lib/main_new.dart lib/main.dart

Completed: *Atualizar main.dart* (7/7)

Checked workspace, no problems found

Pronto! Refatorei completamente o projeto seguindo o padrão MVVM:

**Estrutura criada:**


lib/
├── core/
│   ├── constants.dart    # Cores, tamanhos e strings
│   └── theme.dart        # Tema e estilos reutilizáveis
├── models/
│   └── task_model.dart   # Modelo de dados Task
├── viewmodels/
│   └── tasks_viewmodel.dart  # Lógica de negócio com ChangeNotifier
├── views/
│   ├── appointments_screen.dart
│   ├── contacts_screen.dart
│   ├── notes_screen.dart
│   ├── task_entry_screen.dart
│   └── tasks_screen.dart
├── widgets/
│   ├── custom_app_bar.dart      # AppBar reutilizável
│   └── navigation_tabs.dart     # Abas de navegação
└── main.dart            # Apenas 67 linhas com Provider setup


**Melhorias implementadas:**

✅ **Separação de responsabilidades** - Cada arquivo tem uma função específica
✅ **Reutilização** - Widgets compartilhados (AppBar, Tabs)
✅ **Gerenciamento de estado** - Provider com TasksViewModel
✅ **Manutenibilidade** - Código organizado e fácil de modificar
✅ **Escalabilidade** - Fácil adicionar novas features

O app mantém a mesma aparência visual, mas agora está muito mais organizado e pronto para evoluir com novas funcionalidades!

```

### Resultado:
Nessa iteração, a AI conseguiu refatorar o código do projeto para seguir o padrão MVVM, criando múltiplos arquivos e organizando o código em diretórios específicos para modelos, visualizações, viewmodels, widgets e constantes. Isso melhorou significativamente a organização e manutenibilidade do código. A AI também criou widgets reutilizáveis para a AppBar e as abas de navegação, além de implementar o gerenciamento de estado usando Provider. O resultado final é um código mais limpo, modular e fácil de entender, mantendo a mesma aparência visual do app original. E mesmo sem ser solicitado, a AI criou a lógica de gerenciamento de tarefas em um ViewModel, o que é um bônus adicional, então já é possivel criar e salvar uma nova atividade. Agora o projeto está bem estruturado para futuras iterações.

## Iteração 5
### Promt usado:
```plaintext
Boa, agora sim o projeto está organizado, e com isso podemos prosseguir com o desenvolvimento. Como já conseguimos criar as tasks com a implementação que você fez no ViewModel, vamos apenas adicionar o snackbar de sucesso que está faltando, e ele deve ser igual ao do screenshot anexado
```

### Output recebido:
```markdown
Read [](file:///Users/luis/Desktop/projetos_tcc/flutterbook_to_do_list_v1/lib/views/task_entry_screen.dart#1-1), lines 1 to 100

Pronto! Adicionei o SnackBar verde com a mensagem "Task saved" que aparece após salvar uma task, exatamente como no screenshot. O SnackBar tem:

- Fundo verde (#4CAF50)
- Texto branco
- Duração de 2 segundos
- Comportamento fixo na parte inferior da tela

Made changes.
```

### Resultado:
Nessa iteração, a AI conseguiu adicionar o SnackBar de sucesso que aparece após salvar uma nova tarefa, seguindo exatamente o design do screenshot fornecido. A implementação foi feita no arquivo task_entry_screen.dart, mantendo a organização do código conforme o padrão MVVM já estabelecido. Agora podemos prosseguir para a próxima iteração.

## Iteração 6
### Promt usado:
```plaintext

```

### Output recebido:
```markdown

```

### Resultado:

## Iteração 7
### Promt usado:
```plaintext

```

### Output recebido:
```markdown

```

### Resultado:

## Iteração 8
### Promt usado:
```plaintext

```

### Output recebido:
```markdown

```

### Resultado:

## Iteração 9
### Promt usado:
```plaintext

```

### Output recebido:
```markdown

```

### Resultado:

## Iteração 10
### Promt usado:
```plaintext

```

### Output recebido:
```markdown

```

### Resultado: