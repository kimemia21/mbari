import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbari/ADMIN/AdminDashboard.dart';
import 'package:mbari/auth/Signup.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/utils/Alerts.dart';
import 'package:mbari/core/utils/sharedPrefs.dart';
import 'package:mbari/data/models/User.dart';
import 'package:mbari/features/Homepage/Homepage.dart';
import 'package:mbari/routing/Navigator.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // UserPreferences instance
  UserPreferences? _userPreferences;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeUserPreferences();
  }

  Future<void> _initializeUserPreferences() async {
    _userPreferences = await UserPreferences.getInstance();

    // Try auto-login first
    await _tryAutoLogin();

    // Load stored credentials if available
    _loadStoredCredentials();
  }

  Future<void> _tryAutoLogin() async {
    if (_userPreferences?.shouldAutoLogin() == true) {
      setState(() => _isLoading = true);

      try {
        // Check if session is expired
        if (_userPreferences!.isSessionExpired()) {
          await _userPreferences!.clearUserData();
          setState(() => _isLoading = false);
          return;
        }

        // Get stored credentials
        String? phoneNumber = _userPreferences!.getPhoneNumber();
        String? password = _userPreferences!.getPassword();

        if (phoneNumber != null && password != null) {
          // Attempt auto-login
          // final authService = AuthService();
          final result = await comms.postRequest(
            endpoint: "members/login",
            data: {"phoneNumber": phoneNumber, "password": password},
          );

          // authService.signInWithphoneNumberAndPassword(phoneNumber, password);

          if (result["rsp"]["success"] == true) {
            setState(() => _isLoading = false);
            comms.setAuthToken(result["rsp"]["token"]);
            user = User.fromJson(result["rsp"]["member"]);

            // user = result["data"];
            if (mounted) {
              SmoothNavigator.push(
                context,
                user.role == Role.member
                    ? ChamaHomePage()
                    : user.role == Role.admin
                    ? AdminDashboard()
                    : ChamaHomePage(),
                type: TransitionType.slideUp,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
              );
              return;
            }
          } else {
            // Auto-login failed, clear stored data
            await _userPreferences!.clearUserData();
            setState(() => _isLoading = false);
          }
        }
      } catch (e) {
        // Auto-login failed, clear stored data
        await _userPreferences!.clearUserData();
        setState(() => _isLoading = false);
      }

      setState(() => _isLoading = false);
    }
  }

  void _loadStoredCredentials() {
    if (_userPreferences != null) {
      String? storedphoneNumber = _userPreferences!.getPhoneNumber();
      String? storedPassword = _userPreferences!.getPassword();
      bool rememberMe = _userPreferences!.isRememberMeEnabled();

      if (storedphoneNumber != null) {
        _phoneNumberController.text = storedphoneNumber;
      }
      if (storedPassword != null && rememberMe) {
        _passwordController.text = storedPassword;
      }
      setState(() {
        _rememberMe = rememberMe;
      });
    }
  }

  Future<void> _signInWithphoneNumberPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await comms.postRequest(
        endpoint: "members/login",
        data: {
          "phoneNumber": _phoneNumberController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      print("=========$result");

      if (result["rsp"]["success"] == true) {
        comms.setAuthToken(result["rsp"]["token"]);
        user = User.fromJson(result["rsp"]["member"]);
        // user = result["data"];

        // Save credentials if remember me is enabled
        if (_userPreferences != null) {
          await _userPreferences!.saveCredentials(
            phoneNumber: _phoneNumberController.text.trim(),
            password: _passwordController.text.trim(),
            rememberMe: true,
          );
        }


        if (mounted) {


          showalert(
          success: true,
          context: context,
          title: "Success",
          subtitle: result["rsp"]["message"],
        );
      

          SmoothNavigator.push(
            context,
            user.role == Role.member
                ? ChamaHomePage()
                : user.role == Role.admin
                ? AdminDashboard()
                : ChamaHomePage(),
            type: TransitionType.slideUp,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }
      } else {
        if (mounted) {
         
          showalert(
          success: false,
          context: context,
          title: "Failed",
          subtitle: result["rsp"]["error"],
        );
      
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
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

  Future<void> _handleForgotPassword() async {
    // if (_phoneNumberController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Please enter your phoneNumber address first'),
    //       backgroundColor: Theme.of(context).colorScheme.error,
    //     ),
    //   );
    //   return;
    // }

    // try {
    //   final authService = AuthService();
    //   final result = await authService.sendPasswordResetphoneNumber(
    //     _phoneNumberController.text.trim(),
    //   );

    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           result["message"] ??
    //               (result["success"]
    //                   ? "Password reset phoneNumber sent!"
    //                   : result["error"]),
    //         ),
    //         backgroundColor:
    //             result["success"]
    //                 ? Theme.of(context).colorScheme.primary
    //                 : Theme.of(context).colorScheme.error,
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error: ${e.toString()}'),
    //         backgroundColor: Theme.of(context).colorScheme.error,
    //       ),
    //     );
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    "assets/images/logofour.png",
                    height: 200,
                    width: 200,
                  ),

                  // Header
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your existing account',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // phoneNumber Field
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'phoneNumber',
                      hintText: 'Enter your phoneNumber',
                      prefixIcon: Icon(
                        Icons.phone_android,
                        color: colorScheme.onSurfaceVariant,
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      // Kenyan phone number: starts with 07, 01, or +2547, +2541, and is 10 or 13 digits
                      final kenyanPattern = RegExp(
                        r'^(?:\+254|254|0)(7|1)\d{8}$',
                      );
                      if (!kenyanPattern.hasMatch(value)) {
                        return 'Please enter a valid Kenyan phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colorScheme.onSurfaceVariant,
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
                  const SizedBox(height: 16),

                  // Remember Me Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: colorScheme.primary,
                      ),
                      Text(
                        'Remember me',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _handleForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : _signInWithphoneNumberPassword,
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
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Sign In',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Show last login time if available
                  if (_userPreferences != null &&
                      _userPreferences!.getLastLoginTime() != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Last login: ${_userPreferences!.getFormattedLastLoginTime()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Social Sign In Buttons (commented out to match original)
                  // ... (keep your original social sign in buttons here)
                  const SizedBox(height: 8),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          SmoothNavigator.push(
                            context,
                            SignUpPage(),
                            type: TransitionType.slideUp,
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
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
