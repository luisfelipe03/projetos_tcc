import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF)),
        useMaterial3: true,
      ),
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

  final List<Widget> _pages = [
    const AppointmentsScreen(),
    const ContactsScreen(),
    const NotesScreen(),
    const TasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FlutterBook',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF7C4DFF),
          unselectedItemColor: Colors.black54,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 24),
              label: 'Appointm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts, size: 24),
              label: 'Contacts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note, size: 24),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box, size: 24),
              label: 'Tasks',
            ),
          ],
        ),
      ),
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: const Center(child: Text('')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF9575CD),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Appointments'));
  }
}

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Contacts'));
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Notes'));
  }
}
