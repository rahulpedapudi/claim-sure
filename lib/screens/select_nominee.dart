import 'package:flutter/material.dart';

class SelectNomineeScreen extends StatefulWidget {
  const SelectNomineeScreen({super.key});

  @override
  State<SelectNomineeScreen> createState() => _SelectNomineeScreenState();
}

class _SelectNomineeScreenState extends State<SelectNomineeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomineeUsernameController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void dispose() {
    _nomineeUsernameController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Nominee'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomineeUsernameController,
                decoration: const InputDecoration(
                  labelText: 'Nominee Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the nominee\'s username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your relationship with the nominee';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final Map<String, String> nomineeData = {
                      'username': _nomineeUsernameController.text.trim(),
                      'relationship': _relationshipController.text.trim(),
                    };

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nominee registered successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pop(context, nomineeData);
                  }
                },
                child: const Text('Register Nominee'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
