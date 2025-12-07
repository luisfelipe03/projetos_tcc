import 'package:flutter/material.dart';
import '../core/constants.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: const Center(child: Text('')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to appointment entry screen
        },
        backgroundColor: AppColors.secondary,
        elevation: 4,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}
