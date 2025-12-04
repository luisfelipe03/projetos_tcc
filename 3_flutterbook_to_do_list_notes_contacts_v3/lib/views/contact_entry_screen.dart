import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/navigation_tabs.dart';

class ContactEntryScreen extends StatefulWidget {
  const ContactEntryScreen({super.key});

  @override
  State<ContactEntryScreen> createState() => _ContactEntryScreenState();
}

class _ContactEntryScreenState extends State<ContactEntryScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_nameController.text.isEmpty) return;

    // TODO: Implementar lógica de salvar contato no banco de dados

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Contact saved',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(bottom: const NavigationTabs(selectedIndex: 1)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: AppTheme.subtitleStyle),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                    ),
                    style: AppTheme.bodyStyle,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.phone,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone', style: AppTheme.bodyStyle),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                        ),
                        style: AppTheme.bodySecondaryStyle,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.email,
                  size: AppSizes.iconSizeLarge,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email', style: AppTheme.bodyStyle),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                        ),
                        style: AppTheme.bodySecondaryStyle,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancel, style: AppTheme.buttonStyle),
            ),
            TextButton(
              onPressed: _saveContact,
              child: Text(AppStrings.save, style: AppTheme.buttonStyle),
            ),
          ],
        ),
      ),
    );
  }
}
