import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
  File? _avatarImage;
  DateTime? _selectedBirthday;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _avatarImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Take a picture',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                title: const Text(
                  'Select From Gallery',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(1995, 12, 3),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar section
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Row(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child:
                          _avatarImage != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(
                                  _avatarImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Center(
                                child: Text(
                                  'No avatar image for this contact',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.accent,
                          size: AppSizes.iconSize,
                        ),
                        onPressed: _showImageSourceDialog,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name field
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
                        hintText: 'Name',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      style: AppTheme.bodyStyle,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 32),

              // Phone field
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
                    child: TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Phone',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      style: AppTheme.bodyStyle,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 32),

              // Email field
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
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      style: AppTheme.bodyStyle,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 32),

              // Birthday field
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: AppSizes.iconSizeLarge,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Birthday', style: AppTheme.bodyStyle),
                        if (_selectedBirthday != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(_selectedBirthday),
                            style: AppTheme.bodySecondaryStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: AppColors.accent,
                      size: AppSizes.iconSize,
                    ),
                    onPressed: _selectBirthday,
                  ),
                ],
              ),
            ],
          ),
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
