import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'viewmodels/tasks_viewmodel.dart';
import 'views/appointments_screen.dart';
import 'views/contacts_screen.dart';
import 'views/notes_screen.dart';
import 'views/tasks_screen.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/navigation_tabs.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TasksViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterBook',
      theme: AppTheme.lightTheme,
      home: const FlutterBookHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlutterBookHome extends StatefulWidget {
  const FlutterBookHome({super.key});

  @override
  State<FlutterBookHome> createState() => _FlutterBookHomeState();
}

class _FlutterBookHomeState extends State<FlutterBookHome> {
  int _selectedIndex = 3;

  final List<Widget> _pages = const [
    AppointmentsScreen(),
    ContactsScreen(),
    NotesScreen(),
    TasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        bottom: NavigationTabs(
          selectedIndex: _selectedIndex,
          onTabSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
