import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mbari/auth/Signup.dart';
import 'package:mbari/core/constants/constants.dart';
import 'package:mbari/core/utils/FirebaseAuth.dart';
import 'package:mbari/core/utils/sharedPrefs.dart';
import 'package:mbari/features/Homepage/Homepage.dart';
import 'package:mbari/routing/Navigator.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  // UserPreferences instance
  UserPreferences? _userPreferences;

  @override
  void dispose() {
    _emailController.dispose();
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
        String? email = _userPreferences!.getUsername();
        String? password = _userPreferences!.getPassword();

        if (email != null && password != null) {
          // Attempt auto-login
          final authService = AuthService();
          final result = await authService.signInWithEmailAndPassword(
            email,
            password,
          );

          if (result["success"] == true) {
              setState(() => _isLoading = false);
            user = result["data"];
            if (mounted) {
              SmoothNavigator.push(
                context,
                ChamaHomePage(),
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
      String? storedEmail = _userPreferences!.getUsername();
      String? storedPassword = _userPreferences!.getPassword();
      bool rememberMe = _userPreferences!.isRememberMeEnabled();
      
      if (storedEmail != null) {
        _emailController.text = storedEmail;
      } else {
        // Keep your default email for testing
        _emailController.text = "bobbymbogo71@gmail.com";
      }
      
      if (storedPassword != null && rememberMe) {
        _passwordController.text = storedPassword;
      } else {
        // Keep your default password for testing
        _passwordController.text = "1234567";
      }
      
      setState(() {
        _rememberMe = rememberMe;
      });
    } else {
      // Fallback to default values
      _emailController.text = "bobbymbogo71@gmail.com";
      _passwordController.text = "1234567";
    }
  }

  Future<void> _signInWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      final result = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result["success"] == true) {
        user = result["data"];
        
        // Save credentials if remember me is enabled
        if (_userPreferences != null) {
          await _userPreferences!.saveCredentials(
            username: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            rememberMe: _rememberMe,
          );
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result["message"] ?? 'Signed in successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          SmoothNavigator.push(
            context,
            ChamaHomePage(),
            type: TransitionType.slideUp,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result["error"] ?? "Sign in failed"),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email address first'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      final authService = AuthService();
      final result = await authService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? 
              (result["success"] ? "Password reset email sent!" : result["error"])),
            backgroundColor: result["success"] 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
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
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
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
                      onPressed: _isLoading ? null : _signInWithEmailPassword,
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
                  if (_userPreferences != null && _userPreferences!.getLastLoginTime() != null)
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