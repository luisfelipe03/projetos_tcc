## Iteração 1
### Promt usado:
```plaintext
Quero que você aja como meu par de programação. Estou na v3 do clone do FlutterBook e agora vamos começar o módulo de Notas. Adicione o botão de cadastro na home de notas igual ao botão(FAB) em tasks
```
### Output recebido:
```markdown
Vou analisar o código atual para entender como o FAB está implementado em tasks e replicar para notes. 

Read [](file:///Users/luis/Desktop/projetos_tcc/3_flutterbook_to_do_list_notes_contacts_v3/lib/views/tasks_screen.dart)

Read [](file:///Users/luis/Desktop/projetos_tcc/3_flutterbook_to_do_list_notes_contacts_v3/lib/views/notes_screen.dart)

Agora vou verificar se existe alguma tela de criação de nota: 

Searched for files matching `**/*note*.dart`, 1 match

Vou criar a tela de entrada de notas (similar ao `TaskEntryScreen`) e adicionar o FAB na `NotesScreen`: 

Created [](file:///Users/luis/Desktop/projetos_tcc/3_flutterbook_to_do_list_notes_contacts_v3/lib/views/note_entry_screen.dart)

Using "Replace String in File"

Pronto! Adicionei o botão FAB (Floating Action Button) na tela de notas, igual ao que está em tasks. 

As mudanças incluem:

1. **Criado `note_entry_screen.dart`**: Tela de cadastro de notas com campos para título, conteúdo e cor (similar ao TaskEntryScreen)

2. **Atualizado notes_screen.dart**: 
   - Adicionado `Scaffold` com `backgroundColor`
   - Adicionado `floatingActionButton` com ícone de adicionar (+)
   - O FAB navega para a tela de cadastro de notas
   - Mesmo estilo visual do FAB de tasks (cor secundária, elevação 4, ícone branco)

Agora ao clicar no FAB na tela de notas, o usuário será levado para a tela de cadastro de notas.

Made changes.
```

### Resultado:
Nessa iteração, foi adicionado um botão de cadastro (Floating Action Button - FAB) na tela de notas, similar ao que já existia na tela de tarefas. Além disso, por conta própria a IA criou uma nova tela de entrada de notas (`note_entry_screen.dart`) para permitir o cadastro de novas notas, mas obviamente essa tela ainda não possui funcionalidade completa, e nem está igual à tela do FlutterBook original. Na próxima iteração, vou solicitar que reformule a tela de cadastro de notas para que fique mais parecida com a do FlutterBook.

## Iteração 2
### Promt usado:
```plaintext
A tela de cadastro de notas que você criou está muito simples. Por favor, reformule a tela de cadastro de notas para que fique mais parecida com a do FlutterBook original. A tela deve ter um campo para o título da nota, um campo para o conteúdo da nota, e uma paleta de cores para escolher a cor da nota. Além disso, adicione um botão de salvar que salva a nota e retorna para a tela de notas. Use o screnshot em anexo como referência.
```
