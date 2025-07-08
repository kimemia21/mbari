import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mbari/auth/Login.dart';
import 'package:mbari/core/utils/FirebaseAuth.dart';
import 'package:mbari/routing/Navigator.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Uncomment for Apple Sign In

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // // Email/Password Sign Up
  Future<void> _signUpWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create an instance of AuthService
      final authService = AuthService();

      // Call the correct method for registration
      final result = await authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result["success"] == true) {
         setState(() => _isLoading = true);
        // Success case
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result["message"] ?? 'Account created successfully!',
              ),
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

          // Navigate to next page or home
          // Navigator.pushReplacementNamed(context, '/home');
          // or
          // Navigator.pushReplacementNamed(context, '/verify-email');
        }
      } else {
         setState(() => _isLoading = true);
        // Error case
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result["error"] ?? "Sign up failed"),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
       setState(() => _isLoading = true);
      // Handle unexpected errors
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




  // Google Sign In
  // Future<void> _signInWithGoogle() async {
  //   setState(() => _isLoading = true);

  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       setState(() => _isLoading = false);
  //       return;
  //     }

  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     await _auth.signInWithCredential(credential);

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('Successfully signed in with Google!'),
  //           backgroundColor: Theme.of(context).colorScheme.primary,
  //         ),
  //       );
  //       // Navigate to next page
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Google sign in failed: ${e.toString()}'),
  //           backgroundColor: Theme.of(context).colorScheme.error,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  // Apple Sign In (uncomment and configure when needed)
  /*
  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      await _auth.signInWithCredential(oauthCredential);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed in with Apple!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        // Navigate to next page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple sign in failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  */

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

                  // Header
                  Text(
                    'Create your account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
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

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colorScheme.onSurfaceVariant,
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
                  const SizedBox(height: 32),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : 
                       _signUpWithEmailPassword,
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
                                'Sign Up',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),

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

                  // Social Sign In Buttons
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: _isLoading ? null : _signInWithGoogle,
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 16),
                  //           side: BorderSide(color: colorScheme.outline),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //         ),
                  //         icon: Image.asset(
                  //           'assets/images/google_logo.png', // Add this asset
                  //           height: 24,
                  //           width: 24,
                  //         ),
                  //         label: Text(
                  //           'Google',
                  //           style: theme.textTheme.labelLarge?.copyWith(
                  //             color: colorScheme.onSurface,
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: _isLoading ? null : () {
                  //           // Uncomment and implement Apple Sign In
                  //           // _signInWithApple();
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(
                  //               content: Text('Apple Sign In not configured yet'),
                  //             ),
                  //           );
                  //         },
                  //         style: OutlinedButton.styleFrom(
                  //           padding: const EdgeInsets.symmetric(vertical: 16),
                  //           side: BorderSide(color: colorScheme.outline),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //         ),
                  //         icon: Icon(
                  //           Icons.apple,
                  //           color: colorScheme.onSurface,
                  //           size: 24,
                  //         ),
                  //         label: Text(
                  //           'Apple',
                  //           style: theme.textTheme.labelLarge?.copyWith(
                  //             color: colorScheme.onSurface,
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 32),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
