import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/database_helper.dart';

class ContactsViewModel extends ChangeNotifier {
  final List<Contact> _contacts = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  ContactsViewModel() {
    _loadFromDb();
  }

  List<Contact> get contacts => List.unmodifiable(_contacts);

  Future<void> _loadFromDb() async {
    final items = await _dbHelper.getAllContacts();
    _contacts.clear();
    _contacts.addAll(items);
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    await _dbHelper.insertContact(contact);
    _contacts.add(contact);
    notifyListeners();
  }

  Future<void> updateContact(String id, Contact updatedContact) async {
    final index = _contacts.indexWhere((contact) => contact.id == id);
    if (index != -1) {
      await _dbHelper.updateContact(updatedContact);
      _contacts[index] = updatedContact;
      notifyListeners();
    }
  }

  Future<void> deleteContact(String id) async {
    await _dbHelper.deleteContact(id);
    _contacts.removeWhere((contact) => contact.id == id);
    notifyListeners();
  }

  Contact? getContactById(String id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }
}
