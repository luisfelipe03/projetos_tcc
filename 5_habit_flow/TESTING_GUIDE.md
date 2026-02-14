# 🚀 Guia Rápido - Testando a Criação de Hábitos

## ⚙️ Configuração Inicial

### 1. Instale as dependências
```bash
flutter pub get
```

### 2. Execute o app
```bash
flutter run
```

## 📱 Fluxo de Teste

### 1. Login/Cadastro
- Abra o app
- Faça login ou crie uma conta
- Você será redirecionado para a tela Home

### 2. Criar Primeiro Hábito
1. **Toque no botão "+" (FAB)** no canto inferior direito
2. **Preencha o formulário:**
   - Nome: "Morning Meditation"
   - Frequência: Daily
   - Categoria: Health
   - Lembrete: 07:00 AM (ativo)
   - Cor: Purple
3. **Toque em "Save Habit"**
4. **Verifique:**
   - SnackBar verde de sucesso
   - Volta para home automaticamente
   - Hábito aparece na lista

### 3. Criar Hábito Semanal
1. **Toque no FAB novamente**
2. **Preencha:**
   - Nome: "Gym Workout"
   - Frequência: Weekly
   - Categoria: Health
   - Lembrete: 06:00 PM (ativo)
   - **Selecione dias:** Segunda, Quarta, Sexta
   - Cor: Red
3. **Salve e verifique**

### 4. Testar Reset
1. **Preencha alguns campos**
2. **Toque em "Reset"** no canto superior direito
3. **Verifique:** Todos os campos voltam ao padrão

### 5. Testar Validação
1. **Deixe o nome vazio**
2. **Tente salvar**
3. **Verifique:** Mensagem de erro aparece

### 6. Testar Conclusão
1. **Na home, toque no checkbox** de um hábito
2. **Verifique:** Estado muda imediatamente

## 🔍 Verificações no Firebase

### Firestore Console
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Vá em Firestore Database
3. Navegue: `users/{seu-user-id}/habits`
4. **Verifique:**
   - Cada hábito tem um documento com ID único
   - Campos: title, frequency, category, etc.
   - reminder está preenchido corretamente

### Estrutura Esperada:
```json
{
  "id": "uuid-aqui",
  "title": "Morning Meditation",
  "frequency": "daily",
  "category": "health",
  "habitColor": "purple",
  "createdAt": "timestamp",
  "isCompleted": false,
  "reminder": {
    "hour": 7,
    "minute": 0,
    "repeat": "daily",
    "daysOfWeek": []
  }
}
```

## 🔔 Testar Notificações

### Android
1. **Após criar hábito com lembrete**
2. **Aguarde ou ajuste horário do dispositivo**
3. **Feche o app completamente**
4. **Aguarde notificação aparecer**

### iOS
1. **No primeiro uso, conceda permissão**
2. **Criar hábito com lembrete próximo**
3. **Verificar notificação**

### Verificar Notificações Pendentes
No código, adicione temporariamente:
```dart
final pending = await NotificationService().getPendingNotifications();
print('Pending notifications: ${pending.length}');
```

## 🎨 Testar Temas

### Alternar entre Light e Dark
No arquivo [main.dart](lib/main.dart):
```dart
// Mudar de:
themeMode: ThemeMode.light,

// Para:
themeMode: ThemeMode.dark,
```

**Verifique:**
- Cores mudam (verde → roxo)
- Backgrounds escuros
- Contraste adequado

## 🧪 Casos de Teste

### ✅ Casos de Sucesso
- [x] Criar hábito diário
- [x] Criar hábito semanal com múltiplos dias
- [x] Criar sem lembrete (toggle off)
- [x] Selecionar diferentes categorias
- [x] Selecionar diferentes cores
- [x] Marcar hábito como completo
- [x] Desmarcar hábito completo

### ❌ Casos de Erro
- [x] Salvar com nome vazio → Validação impede
- [x] Weekly sem dias selecionados → SnackBar vermelho
- [x] Criar sem estar logado → Erro tratado

### 🔄 Edge Cases
- [x] Criar muitos hábitos (scroll na lista)
- [x] Nomes muito longos
- [x] Alternar frequência enquanto preenche
- [x] Fechar e reabrir app (persistência)
- [x] Internet offline → Firestore cache

## 📊 Resultados Esperados

### Home View - Estado Vazio
```
┌─────────────────────────┐
│   💜 Habit Flow    ⎆    │
├─────────────────────────┤
│                         │
│      📅                 │
│                         │
│   No habits yet         │
│  Tap the + button to    │
│  create your first      │
│  habit                  │
│                         │
│                    [+]  │
└─────────────────────────┘
```

### Home View - Com Hábitos
```
┌─────────────────────────┐
│   💜 Habit Flow    ⎆    │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ 💜 Morning Yoga  ☐  │ │
│ │ Daily • Health      │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ 🔴 Gym Workout   ☐  │ │
│ │ Weekly • Health     │ │
│ └─────────────────────┘ │
│                    [+]  │
└─────────────────────────┘
```

### Create Habit View
```
┌─────────────────────────┐
│ Cancel  New Habit Reset │
├─────────────────────────┤
│ HABIT NAME              │
│ ┌─────────────────────┐ │
│ │ Morning Yoga      ✏️ │ │
│ └─────────────────────┘ │
│                         │
│ FREQUENCY               │
│ ┌──────────┬──────────┐ │
│ │  📅 Daily │ 📊 Weekly│ │
│ └──────────┴──────────┘ │
│                         │
│ CATEGORY                │
│ ❤️ Health 🎓 Study ...  │
│                         │
│ REMINDER                │
│ ┌─────────────────────┐ │
│ │ 🔔 07:00 AM    🟢  │ │
│ └─────────────────────┘ │
│                         │
│ HABIT COLOR             │
│ 🔴 🔵 🟢 🟣 🟠          │
│                         │
│ ┌─────────────────────┐ │
│ │    💾 Save Habit    │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

## 🐛 Problemas Comuns

### "Target of URI doesn't exist: 'package:uuid/uuid.dart'"
**Solução:** Execute `flutter pub get`

### Notificações não aparecem
**Android:**
- Verifique permissões no app
- Settings → Apps → Habit Flow → Notifications

**iOS:**
- Settings → Habit Flow → Notifications → Allow

### Hábitos não aparecem após criar
**Solução:** 
- Verifique conexão internet
- Verifique console de erros
- Confirme usuário está logado

### Erro ao salvar no Firestore
**Solução:**
- Verifique regras do Firestore
- Confirme Firebase inicializado
- Verifique console Firebase

## 📈 Métricas de Sucesso

Após os testes, você deve ter:
- ✅ Pelo menos 3 hábitos criados
- ✅ 1 hábito daily e 1 weekly
- ✅ Dados no Firestore
- ✅ Notificações agendadas
- ✅ Interface responsiva
- ✅ Temas funcionando
- ✅ Validações ativas

---

**Pronto para testar! 🎉**
