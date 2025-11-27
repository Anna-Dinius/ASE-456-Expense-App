// ProfileEditingScreen: allow editing of name, phone, and image URL.
// Keeps fields minimal so it's easy to follow and extend later.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p5_expense/service/auth_service.dart';
import 'package:p5_expense/service/user_service.dart';

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({super.key});

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

  /// Prompts the user for their password until correct or cancelled.
  /// Returns true if reauthentication succeeded.
  Future<bool> _reauthenticateUser(BuildContext context) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return false;

    final email = user.email!;
    final passwordController = TextEditingController();
    String? errorText;

    while (true) {
      final result = await showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text("Confirm Password"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Enter your password",
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 13.5),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(null),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext)
                        .pop(passwordController.text),
                    child: const Text("Confirm"),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result == null) return false; // user canceled

      try {
        final credential = fb_auth.EmailAuthProvider.credential(
          email: email,
          password: result,
        );
        await user.reauthenticateWithCredential(credential);
        return true; // ✅ success
      } on fb_auth.FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          // Wrong password: show inline error, clear field
          errorText = "Incorrect password. Please try again.";
          passwordController.clear(); // 🔥 Clears the field automatically
          await Future.delayed(const Duration(milliseconds: 100));
          continue; // reopen dialog with error
        } else {
          errorText = "Error: ${e.message}";
          passwordController.clear();
          await Future.delayed(const Duration(milliseconds: 100));
          continue;
        }
      }
    }
  }

  Future<void> _deleteConfirmation() async {
    final parentContext = context;

    final success = await _reauthenticateUser(parentContext);
    if (!success) return; // cancelled or failed

    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
            "Are you sure you want to delete your account? "
            "This is permanent and your account will be non-recoverable.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _delete();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete() async {
    final fb_auth.User? user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      await UserService.deleteUser(user.uid);

      if (mounted) {
        // Simply pop back to the very first screen in the stack
        // This ensures we don't have any leftover screens or state
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (optional)',
                      ),
                    ),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Profile Image URL (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _deleteConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Delete Account"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
