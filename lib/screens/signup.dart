import 'package:claim_sure/screens/login.dart';
import 'package:claim_sure/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  @override
  void dispose() {
    _fullNameController.dispose();
    // _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Creates a new user account using the API service
  ///
  /// This method validates the form, calls the API to create a user account,
  /// and handles the response appropriately.
  ///
  /// **Process:**
  /// 1. Validates all form fields
  /// 2. Checks terms agreement
  /// 3. Shows loading indicator
  /// 4. Calls API service to create user
  /// 5. Navigates to user details on success
  /// 6. Shows error message on failure
  Future<void> _createUserAccount() async {
    // Validate form and terms agreement
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showErrorMessage(
        'Please agree to the Terms of Service and Privacy Policy',
      );
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Extract username from full name (use first name or full name)
      final String username = _fullNameController.text;
      // Call API service to create user
      final Map<String, dynamic> result = await ApiService.createUser(
        username: username,
        phoneNo: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      // Success: Navigate to login screen for authentication, then personal details
      if (result['success'] == true) {
        _showSuccessMessage(
          result['message'] ?? 'Account created successfully!',
        );

        // Navigate to user details screen after a brief delay
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(redirectToDetails: true),
            ),
          );
        }
      } else {
        _showErrorMessage('Failed to create account. Please try again.');
      }
    } catch (e) {
      // Handle errors
      String errorMessage = 'Failed to create account. ';

      if (e.toString().contains('Network Error')) {
        errorMessage += 'Please check your internet connection.';
      } else if (e.toString().contains('Server Error')) {
        errorMessage += 'Server is currently unavailable.';
      } else {
        errorMessage += 'Please try again later.';
      }

      _showErrorMessage(errorMessage);
      print('❌ Signup Error: $e'); // For debugging
    } finally {
      // Hide loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows a success message to the user
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an error message to the user
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your secure locker',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your ClaimSure account to protect and share your assets with confidence.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Let’s get the essentials',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'These details help us secure and personalize your experience.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _fullNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              hintText: 'First and last name',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (value.trim().split(' ').length < 2) {
                                return 'Please include both first and last name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // TextFormField(
                          //   controller: _emailController,
                          //   keyboardType: TextInputType.emailAddress,
                          //   decoration: const InputDecoration(
                          //     labelText: 'Email address',
                          //     hintText: 'you@email.com',
                          //     prefixIcon: Icon(Icons.mail_outline_rounded),
                          //   ),
                          //   validator: (value) {
                          //     if (value == null || value.trim().isEmpty) {
                          //       return 'Please enter your email address';
                          //     }
                          //     const emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                          //     if (!RegExp(emailRegex).hasMatch(value.trim())) {
                          //       return 'Please enter a valid email address';
                          //     }
                          //     return null;
                          //   },
                          // ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Create password',
                              hintText: 'At least 8 characters',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please create a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(
                                r'^(?=.*[A-Za-z])(?=.*\d)',
                              ).hasMatch(value)) {
                                return 'Include at least one letter and one number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              hintText: 'For two-factor authentication',
                              prefixIcon: Icon(Icons.phone_iphone_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length != 10) {
                                return 'Phone number must be 10 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.verified_user_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your data is encrypted at rest and in transit. We use bank-grade security and never share details without consent.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _agreeToTerms = !_agreeToTerms;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: RichText(
                                      text: TextSpan(
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          const TextSpan(
                                            text:
                                                'I have read and agree to the ',
                                          ),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                          const TextSpan(text: '.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _createUserAccount,
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Creating account...'),
                                    ],
                                  )
                                : const Text('Create my secure account'),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: theme.textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Sign in'),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
