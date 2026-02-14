# Tela de Criação de Hábitos - Implementação Completa

## 📱 Arquivos Criados

### 1. HabitViewModel (`lib/viewmodels/habit_viewmodel.dart`)
ViewModel completo para gerenciar hábitos com as seguintes funcionalidades:

#### Métodos Principais:
- **`createHabit()`** - Cria um novo hábito
  - Valida dados do formulário
  - Gera ID único com UUID
  - Salva no Firestore
  - Agenda notificação automaticamente
  - Atualiza lista local

- **`updateHabit()`** - Atualiza um hábito existente
  - Cancela notificações antigas
  - Agenda novas notificações
  - Atualiza no Firestore

- **`deleteHabit()`** - Remove um hábito
  - Remove do Firestore
  - Cancela notificações

- **`toggleHabitCompletion()`** - Marca/desmarca conclusão

- **`loadHabits()`** - Carrega todos os hábitos do usuário

#### Integração:
- ✅ Firebase Firestore para persistência
- ✅ NotificationService para lembretes
- ✅ Firebase Auth para autenticação do usuário
- ✅ ChangeNotifier para state management

### 2. CreateHabitView (`lib/views/habits/create_habit_view.dart`)
Tela completa de criação de hábitos seguindo o design fornecido.

#### Componentes da Interface:

**App Bar:**
- Cancel (cinza) - volta para tela anterior
- Título "New Habit" centralizado
- Reset (verde claro/roxo) - limpa formulário

**Campos do Formulário:**

1. **HABIT NAME**
   - TextField com ícone de edição
   - Validação de campo obrigatório
   - Placeholder: "Morning Yoga"

2. **FREQUENCY**
   - Toggle entre Daily e Weekly
   - Ícones personalizados
   - Ajusta automaticamente o reminder repeat

3. **CATEGORY**
   - 5 categorias com ícones:
     - Health (vermelho, ícone coração)
     - Study (azul, ícone escola)
     - Finance (verde, ícone dinheiro)
     - Personal (roxo, ícone pessoa)
     - Social (laranja, ícone pessoas)
   - Cards horizontais scrolláveis
   - Borda destacada ao selecionar

4. **REMINDER**
   - Card com ícone de sino laranja
   - Horário selecionável (07:00 AM padrão)
   - Toggle switch para ativar/desativar
   - Time picker nativo do Flutter
   - Cores adaptáveis ao tema

5. **Dias da Semana (apenas para Weekly)**
   - Aparece condicionalmente quando frequency = weekly
   - 7 botões circulares (M T W T F S S)
   - Seleção múltipla obrigatória
   - Validação: pelo menos 1 dia deve ser selecionado

6. **HABIT COLOR**
   - 5 cores disponíveis (Red, Blue, Green, Purple, Orange)
   - Círculos grandes (60x60)
   - Checkmark branco ao selecionar
   - Box shadow na cor selecionada

**Botão Save Habit:**
- Gradiente verde (light) / roxo (dark)
- Ícone de save + texto
- Loading spinner durante salvamento
- Box shadow colorido

#### Validações Implementadas:
- ✅ Título obrigatório
- ✅ Pelo menos 1 dia da semana para weekly reminders
- ✅ Feedback visual de erros
- ✅ SnackBar de sucesso/erro

#### Estados e Comportamentos:
- Sincroniza frequency com reminder repeat
- Mostra/esconde seletor de dias conforme necessário
- Mantém estado durante edição
- Função reset limpa todos os campos

### 3. Atualizações em Arquivos Existentes

#### `main.dart`
```dart
// Adicionado MultiProvider para gerenciar múltiplos ViewModels
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel()),
    ChangeNotifierProvider(create: (_) => HabitViewModel()), // ✨ Novo
  ],
  // ...
)
```

#### `home_view.dart`
Transformada de StatelessWidget para StatefulWidget com:

- **initState()** - Carrega hábitos ao abrir a tela
- **Lista de hábitos** - Mostra cards com:
  - Avatar circular com cor do hábito
  - Ícone da categoria
  - Título e informações (frequência, categoria)
  - Checkbox para marcar conclusão
- **Estado vazio** - Mensagem "No habits yet" com ícone
- **FloatingActionButton** 
  - Ícone de "+"
  - Verde (light) / Roxo (dark)
  - Navega para CreateHabitView
  - Recarrega lista ao voltar

#### `pubspec.yaml`
```yaml
dependencies:
  uuid: ^4.5.1  # ✨ Adicionado para gerar IDs únicos
```

## 🎯 Fluxo Completo de Criação de Hábito

1. **Usuário clica no FAB (+)** na home
2. **Navega para CreateHabitView**
3. **Preenche o formulário:**
   - Digita nome do hábito
   - Seleciona frequência (Daily/Weekly)
   - Escolhe categoria com ícone
   - Configura lembrete (horário + repetição)
   - Se Weekly: seleciona dias da semana
   - Escolhe cor do hábito
4. **Clica em "Save Habit"**
5. **HabitViewModel:**
   - Valida dados
   - Cria objeto Habit com UUID
   - Salva no Firestore (`users/{userId}/habits/{habitId}`)
   - Agenda notificação via NotificationService
   - Adiciona à lista local
6. **Usuário vê SnackBar de sucesso**
7. **Navega de volta para home**
8. **Home recarrega e mostra o novo hábito**

## 🗄️ Estrutura no Firestore

```
users/
  └── {userId}/
       └── habits/
            └── {habitId}
                 ├── id: string
                 ├── title: string
                 ├── frequency: string ("daily" | "weekly" | "monthly")
                 ├── category: string ("health" | "study" | ...)
                 ├── habitColor: string ("red" | "blue" | ...)
                 ├── createdAt: timestamp
                 ├── isCompleted: boolean
                 └── reminder: map (opcional)
                      ├── hour: int
                      ├── minute: int
                      ├── repeat: string
                      └── daysOfWeek: array (apenas weekly)
```

## 🔔 Integração com Notificações

Quando um hábito é criado com reminder ativo:

1. **HabitViewModel.createHabit()** chama:
   ```dart
   await notificationService.scheduleHabitReminder(habit);
   ```

2. **NotificationService detecta o tipo de repetição:**
   - **ReminderRepeat.none** → Notificação única
   - **ReminderRepeat.daily** → Notificação diária
   - **ReminderRepeat.weekly** → Uma notificação por dia selecionado
   - **ReminderRepeat.monthly** → Notificação mensal

3. **Notificações persistem** mesmo com app fechado

4. **Ao atualizar/deletar:**
   - Cancela notificações antigas automaticamente
   - Reagenda se necessário

## 🎨 Temas e Cores

### Tema Claro:
- Fundo: `#F8F9FA`
- Cards: Branco
- Gradiente botão: Verde (`#10B981` → `#059669`)
- Accent: Verde `#10B981`

### Tema Escuro:
- Fundo: `#0F0D15`
- Cards: `#1A1625`
- Gradiente botão: Roxo (`#A855F7` → `#9333EA`)
- Accent: Roxo `#A855F7`

### Cores dos Hábitos:
- Red: `#EF4444`
- Blue: `#3B82F6`
- Green: `#10B981`
- Purple: `#8B5CF6`
- Orange: `#F97316`

### Cores das Categorias:
- Health: Vermelho + ícone de coração
- Study: Azul + ícone de escola
- Finance: Verde + ícone de dinheiro
- Personal: Roxo + ícone de pessoa
- Social: Laranja + ícone de pessoas

## 📝 Próximos Passos Sugeridos

1. **Tela de Edição de Hábito**
   - Reutilizar CreateHabitView com modo "edit"
   - Pré-preencher campos com dados existentes

2. **Tela de Detalhes do Hábito**
   - Histórico de conclusões
   - Estatísticas
   - Streak counter

3. **Dashboard**
   - Visão geral dos hábitos
   - Progresso semanal/mensal
   - Gráficos

4. **Filtros e Ordenação**
   - Por categoria
   - Por frequência
   - Por status (completo/incompleto)

## ⚠️ Ação Necessária

**Execute o comando abaixo para instalar a dependência uuid:**
```bash
flutter pub get
```

Após isso, a aplicação estará totalmente funcional! ✨
