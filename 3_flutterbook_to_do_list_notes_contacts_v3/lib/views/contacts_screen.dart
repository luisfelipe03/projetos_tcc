import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../viewmodels/contacts_viewmodel.dart';
import 'contact_entry_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<ContactsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.contacts.isEmpty) {
            return const Center(child: Text(''));
          }
          return ListView.builder(
            itemCount: viewModel.contacts.length,
            itemBuilder: (context, index) {
              final contact = viewModel.contacts[index];
              return Container(
                color: Colors.grey.shade200,
                margin: const EdgeInsets.only(bottom: 1),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    backgroundImage:
                        contact.avatarPath != null
                            ? FileImage(File(contact.avatarPath!))
                            : null,
                    child:
                        contact.avatarPath == null
                            ? Text(
                              contact.name.isNotEmpty
                                  ? contact.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    contact.phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactEntryScreen()),
          );
        },
        backgroundColor: AppColors.secondary,
        elevation: 4,
        child: const Icon(Icons.add, color: AppColors.background),
      ),
    );
  }
}
