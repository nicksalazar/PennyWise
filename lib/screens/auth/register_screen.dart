import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.registerTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  l10n.registerTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Hero(
                  tag: 'app_icon',
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      height: 120,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: l10n.registerNameLabel,
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? l10n.registerNameValidationEmpty : null,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: l10n.registerEmailLabel,
                  icon: Icons.email,
                  validator: (value) => !value!.contains('@')
                      ? l10n.registerEmailValidationEmpty
                      : null,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: l10n.registerPasswordLabel,
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? l10n.registerPasswordValidationEmpty
                      : null,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: l10n.registerConfirmPasswordLabel,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => value != _passwordController.text
                      ? l10n.registerConfirmPasswordValidationEmpty
                      : null,
                ),
                SizedBox(height: 16),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      l10n.registerButton,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection('accounts')
            .doc('main')
            .set({
          'balance': 0,
          'name': 'Cuenta Principal',
          'icon': 'account_balance',
          'color': 'blue',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso')),
        );

        context.go('/home');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }
}
