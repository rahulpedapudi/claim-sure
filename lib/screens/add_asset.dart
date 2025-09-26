import 'package:flutter/material.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String _selectedAssetType = 'Fixed Deposit';
  final List<String> _assetTypes = [
    'Fixed Deposit',
    'Insurance Policy',
    'Bond',
    'Mutual Fund',
    'Stock',
    'Provident Fund',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _institutionController.dispose();
    _accountNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveAsset() {
    if (_formKey.currentState!.validate()) {
      final asset = {
        'title': _titleController.text,
        'type': _selectedAssetType,
        'value': double.tryParse(_valueController.text) ?? 0.0,
        'institution': _institutionController.text,
        'accountNumber': _accountNumberController.text,
        'description': _descriptionController.text,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      Navigator.pop(context, asset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Asset'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Add New Asset',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Secure your financial information for your loved ones',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Asset Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Asset Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                    hintText: 'e.g., SBI Fixed Deposit',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter asset title';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Asset Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedAssetType,
                  decoration: const InputDecoration(
                    labelText: 'Asset Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _assetTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedAssetType = newValue;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Asset Value
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Asset Value (₹)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                    hintText: 'Enter amount in rupees',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter asset value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Institution
                TextFormField(
                  controller: _institutionController,
                  decoration: const InputDecoration(
                    labelText: 'Institution/Bank Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                    hintText: 'e.g., State Bank of India',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter institution name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Account Number
                TextFormField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Account/Policy Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    hintText: 'Account or policy reference number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account/policy number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Additional Details (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: 'Any additional information about this asset',
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Save Button
                ElevatedButton(
                  onPressed: _saveAsset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Asset',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All your asset information is encrypted and securely stored.',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
