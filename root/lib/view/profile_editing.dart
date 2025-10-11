// ProfileEditingScreen: allow editing of name, phone, and image URL.
// Keeps fields minimal so it's easy to follow and extend later.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p5_expense/service/auth_service.dart';
import 'package:p5_expense/service/user_service.dart';

class ProfileEditingScreen extends StatefulWidget {
  @override
  State<ProfileEditingScreen> createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final fb_auth.User? user = AuthService.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    // Load current profile values to prefill the form
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = (data['name'] ?? '').toString();
      _phoneController.text = (data['phoneNumber'] ?? '').toString();
      _imageUrlController.text = (data['profileImageUrl'] ?? '').toString();
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final fb_auth.User? user = AuthService.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    try {
      // Persist edited fields to Firestore
      await UserService.updateUser(user.uid, {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'profileImageUrl': _imageUrlController.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final fb_auth.User? user = AuthService.currentUser;
    if (user == null) return;
    setState(() => _loading = true);

    try {
      await UserService.deleteUser(user.uid);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Full Name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration:
                          InputDecoration(labelText: 'Phone Number (optional)'),
                    ),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                          labelText: 'Profile Image URL (optional)'),
                    ),
                    // Save Button
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _save, child: Text('Save')),
                    // Delete Button
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _delete,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        child: Text("Delete")),
                  ],
                ),
              ),
            ),
    );
  }
}
