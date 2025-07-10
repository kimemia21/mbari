import 'package:flutter/material.dart';
import 'package:mbari/auth/Login.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/data/models/ChamasDropDown.dart';
import 'package:mbari/data/services/globalFetch.dart';
import 'package:mbari/routing/Navigator.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNames = TextEditingController();

  late Future<List<Chamasdropdown>> chamas;

  Chamasdropdown? _selectedChama;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<List<Chamasdropdown>> fetchChamas() async {
    final response = await fetchGlobal<Chamasdropdown>(
      getRequests: (endpoint) => comms.getRequests(endpoint: endpoint),
      fromJson: (json) => Chamasdropdown.fromJson(json),
      endpoint: "chamas",
    );
    return response;
  }

  @override
  void initState() {
    super.initState();
    chamas = fetchChamas();
  }

  // Phone/Password Sign Up
  Future<void> _signUpWithPhonePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await comms.postRequest(
        endpoint: "members/register",
        data: {
          "chama_id": _selectedChama!.id,
          'name':_fullNames.text.trim(),
          "phoneNumber": _phoneController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );
      if (response["rsp"]["success"]) {
        setState(() => _isLoading = false);

        await userPrefs.clearUserData();
        await userPrefs.saveCredentials(
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          SmoothNavigator.push(
            context,
            Login(),
            type: TransitionType.slideUp,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["rsp"]["error"]),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }

      // Success case
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Get responsive padding based on screen size
  EdgeInsets _getResponsivePadding() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 360) {
      return const EdgeInsets.all(16.0); // Small phones
    } else if (screenWidth <= 414) {
      return const EdgeInsets.all(20.0); // Medium phones
    } else {
      return const EdgeInsets.all(24.0); // Large phones/tablets
    }
  }

  // Get responsive field height
  double _getFieldHeight() {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight <= 640) {
      return 60.0; // Small screens
    } else if (screenHeight <= 800) {
      return 65.0; // Medium screens
    } else {
      return 70.0; // Large screens
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final fieldHeight = _getFieldHeight();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: _getResponsivePadding(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenSize.height * 0.05),

                  // Header
                  Text(
                    'Create your account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: screenSize.width <= 360 ? 22 : 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: screenSize.width <= 360 ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.04),

                  // Chama Dropdown Field
                  FutureBuilder<List<Chamasdropdown>>(
                    future: chamas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Container(
                            height: fieldHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outline),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Container(
                            height: fieldHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.error),
                            ),
                            child: Center(
                              child: Text(
                                'Failed to load chamas',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontSize: screenSize.width <= 360 ? 12 : 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Container(
                            height: fieldHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outline),
                            ),
                            child: Center(
                              child: Text(
                                'No chamas available',
                                style: TextStyle(
                                  fontSize: screenSize.width <= 360 ? 12 : 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          height: fieldHeight,
                          child: DropdownButtonFormField<Chamasdropdown>(
                            decoration: InputDecoration(
                              labelText: 'Select Chama',
                              labelStyle: TextStyle(
                                fontSize: screenSize.width <= 360 ? 14 : 16,
                              ),
                              prefixIcon: Icon(
                                Icons.group_outlined,
                                color: colorScheme.onSurfaceVariant,
                                size: screenSize.width <= 360 ? 20 : 24,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.error),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: fieldHeight * 0.25,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: screenSize.width <= 360 ? 14 : 16,
                              color: colorScheme.onSurface,
                            ),
                            items: snapshot.data!
                                .map(
                                  (chama) => DropdownMenuItem<Chamasdropdown>(
                                    value: chama,
                                    child: Text(
                                      chama.name,
                                      style: TextStyle(
                                        fontSize: screenSize.width <= 360 ? 14 : 16,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedChama = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a chama';
                              }
                              return null;
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  // Member Name Field
                  Container(
                    height: fieldHeight,
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: TextFormField(
                      controller: _fullNames,
                      style: TextStyle(
                        fontSize: screenSize.width <= 360 ? 14 : 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          fontSize: screenSize.width <= 360 ? 14 : 16,
                        ),
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(
                          fontSize: screenSize.width <= 360 ? 12 : 14,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: colorScheme.onSurfaceVariant,
                          size: screenSize.width <= 360 ? 20 : 24,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: fieldHeight * 0.25,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Phone Number Field
                  Container(
                    height: fieldHeight,
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontSize: screenSize.width <= 360 ? 14 : 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          fontSize: screenSize.width <= 360 ? 14 : 16,
                        ),
                        hintText: 'Enter your phone number',
                        hintStyle: TextStyle(
                          fontSize: screenSize.width <= 360 ? 12 : 14,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: colorScheme.onSurfaceVariant,
                          size: screenSize.width <= 360 ? 20 : 24,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: fieldHeight * 0.25,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^[+]?[\d\s\-\(\)]{10,}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Password Field
                  Container(
                    height: fieldHeight,
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        fontSize: screenSize.width <= 360 ? 14 : 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontSize: screenSize.width <= 360 ? 14 : 16,
                        ),
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          fontSize: screenSize.width <= 360 ? 12 : 14,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: colorScheme.onSurfaceVariant,
                          size: screenSize.width <= 360 ? 20 : 24,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorScheme.onSurfaceVariant,
                            size: screenSize.width <= 360 ? 20 : 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: fieldHeight * 0.25,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Confirm Password Field
                  Container(
                    height: fieldHeight,
                    margin: const EdgeInsets.only(bottom: 32.0),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(
                        fontSize: screenSize.width <= 360 ? 14 : 16,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                          fontSize: screenSize.width <= 360 ? 14 : 16,
                        ),
                        hintText: 'Confirm your password',
                        hintStyle: TextStyle(
                          fontSize: screenSize.width <= 360 ? 12 : 14,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: colorScheme.onSurfaceVariant,
                          size: screenSize.width <= 360 ? 20 : 24,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: colorScheme.onSurfaceVariant,
                            size: screenSize.width <= 360 ? 20 : 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.error),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.error,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: fieldHeight * 0.25,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: screenSize.height <= 640 ? 60 : 65,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUpWithPhonePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        disabledBackgroundColor: colorScheme.onSurface
                            .withOpacity(0.12),
                        disabledForegroundColor: colorScheme.onSurface
                            .withOpacity(0.38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Sign Up',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimary,
                                fontSize: screenSize.width <= 360 ? 16 : 18,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.04),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: screenSize.width <= 360 ? 14 : 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          SmoothNavigator.push(
                            context,
                            Login(),
                            type: TransitionType.slideUp,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: screenSize.width <= 360 ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}