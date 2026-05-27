# Sistema de Notificações - Habit Flow

## 📱 Implementação Completa

O sistema de notificações foi implementado usando `flutter_local_notifications` e suporta diferentes tipos de lembretes para hábitos.

## 🔧 Componentes Criados

### 1. **Modelos de Dados**

#### `DayOfWeek` (lib/models/day_of_week.dart)
Enum representando os dias da semana:
- `monday`, `tuesday`, `wednesday`, `thursday`, `friday`, `saturday`, `sunday`
- Métodos: `displayName`, `shortName`, `weekdayNumber`, `fromString()`, `fromWeekdayNumber()`

#### `ReminderRepeat` (lib/models/reminder_repeat.dart)
Enum para frequência de repetição:
- `none` - Sem repetição
- `daily` - Diariamente
- `weekly` - Semanalmente
- `monthly` - Mensalmente

#### `HabitReminder` (lib/models/habit_reminder.dart)
Modelo completo de lembrete:
```dart
HabitReminder({
  required TimeOfDay time,           // Horário do lembrete
  required ReminderRepeat repeat,    // Frequência
  List<DayOfWeek>? daysOfWeek,      // Dias (apenas para weekly)
})
```

**Validações:**
- `daysOfWeek` é obrigatório quando `repeat == weekly`
- `daysOfWeek` deve estar vazio para outros tipos de repetição

### 2. **Modelo Habit Atualizado**

O modelo `Habit` foi atualizado para usar `HabitReminder?` ao invés de `DateTime?`:

```dart
class Habit {
  final String id;
  final String title;
  final HabitFrequency frequency;
  final HabitCategory category;
  final HabitReminder? reminder;  // ✅ Novo campo
  final HabitColor habitColor;
  final DateTime createdAt;
  final bool isCompleted;
}
```

### 3. **NotificationService**

Serviço completo de gerenciamento de notificações (lib/services/notification_service.dart).

#### Funcionalidades:

##### **Inicialização**
```dart
final notificationService = NotificationService();
await notificationService.initialize();
await notificationService.requestPermissions();
```

##### **Agendar Notificação para Hábito**
```dart
await notificationService.scheduleHabitReminder(habit);
```

O serviço detecta automaticamente o tipo de repetição e agenda corretamente:

- **None**: Notificação única no próximo horário disponível
- **Daily**: Notificação diária no horário especificado
- **Weekly**: Múltiplas notificações, uma para cada dia da semana selecionado
- **Monthly**: Notificação mensal no mesmo dia do mês

##### **Cancelar Notificações**
```dart
// Cancela notificações de um hábito específico
await notificationService.cancelHabitReminder(habitId);

// Cancela todas as notificações
await notificationService.cancelAllNotifications();
```

##### **Ver Notificações Pendentes**
```dart
final pending = await notificationService.getPendingNotifications();
```

## 📋 Exemplo de Uso Completo

```dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/habit.dart';
import 'models/habit_reminder.dart';
import 'models/reminder_repeat.dart';
import 'models/day_of_week.dart';
import 'services/notification_service.dart';

// 1. Criar um hábito com lembrete diário
final dailyHabit = Habit(
  id: Uuid().v4(),
  title: 'Meditar 10 minutos',
  frequency: HabitFrequency.daily,
  category: HabitCategory.health,
  habitColor: HabitColor.purple,
  createdAt: DateTime.now(),
  reminder: HabitReminder(
    time: TimeOfDay(hour: 7, minute: 0),
    repeat: ReminderRepeat.daily,
  ),
);

// 2. Criar um hábito com lembrete semanal (Seg, Qua, Sex)
final weeklyHabit = Habit(
  id: Uuid().v4(),
  title: 'Academia',
  frequency: HabitFrequency.weekly,
  category: HabitCategory.health,
  habitColor: HabitColor.green,
  createdAt: DateTime.now(),
  reminder: HabitReminder(
    time: TimeOfDay(hour: 18, minute: 30),
    repeat: ReminderRepeat.weekly,
    daysOfWeek: [
      DayOfWeek.monday,
      DayOfWeek.wednesday,
      DayOfWeek.friday,
    ],
  ),
);

// 3. Agendar notificações
final notificationService = NotificationService();
await notificationService.scheduleHabitReminder(dailyHabit);
await notificationService.scheduleHabitReminder(weeklyHabit);

// 4. Salvar no Firestore
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('habits')
    .doc(dailyHabit.id)
    .set(dailyHabit.toMap());
```

## ⚙️ Configuração de Plataforma

### Android (android/app/src/main/AndroidManifest.xml)

Adicione as permissões necessárias:

```xml
<manifest>
    <!-- Permissões de notificação -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    
    <application>
        <!-- Receiver para notificações -->
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
        
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
            android:exported="false" />
    </application>
</manifest>
```

### iOS (ios/Runner/AppDelegate.swift)

Adicione o código para suportar notificações:

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 🔔 Características do Sistema

### ✅ Recursos Implementados

1. **Notificações em Background**: Funcionam mesmo com o app fechado
2. **Múltiplas Frequências**: Suporte para none, daily, weekly, monthly
3. **Dias Específicos**: Para lembretes semanais, escolha os dias da semana
4. **Horários Precisos**: Notificações no horário exato configurado
5. **Persistência**: Lembretes sobrevivem a reinicializações do dispositivo
6. **Cancelamento Individual**: Cancele lembretes de hábitos específicos
7. **Compatibilidade Firestore**: Modelos totalmente compatíveis com Firestore

### 🎯 Comportamento das Notificações

- **None**: Uma única notificação no próximo horário disponível
- **Daily**: Notificação diária recorrente no horário especificado
- **Weekly**: Uma notificação para cada dia da semana selecionado
- **Monthly**: Notificação mensal no mesmo dia do mês

### 📱 Permissões

O serviço solicita automaticamente as permissões necessárias:
- iOS: Alert, Badge, Sound
- Android: Notificações (Android 13+)

## 🚀 Próximos Passos

1. Criar ViewModel para gerenciar hábitos e notificações
2. Implementar UI para criar/editar lembretes
3. Adicionar navegação quando usuário tocar na notificação
4. Implementar sons customizados para diferentes categorias
5. Adicionar estatísticas de lembretes

## 📦 Dependências Adicionadas

```yaml
dependencies:
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.4
  cloud_firestore: ^5.5.0
```
