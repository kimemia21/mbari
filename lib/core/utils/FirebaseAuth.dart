// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:mbari/core/constants/constants.dart';
// import 'package:mbari/core/utils/sharedPrefs.dart';



// class AuthService {
//   // UserPreferences instance

  


//   // Get current user
//   User? get currentUser => auth.currentUser;
  
//   // Auth state stream
//   Stream<User?> get authStateChanges => auth.authStateChanges();

//   // Register with email and password
//   Future<Map<String, dynamic>> registerWithEmailAndPassword(
//     String email,
//     String password, {
//     bool rememberMe = true,
//   }) async {
//     try {
//       UserCredential result = await auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       // Save credentials to local storage if registration is successful
//       if (result.user != null) {
//         await userPrefs.saveCredentials(
//           username: email,
//           password: password,
//           rememberMe: rememberMe,
//         );
//       }
      
//       return {
//         "success": true,
//         "data": result.user,
//         "message": "Account created successfully"
//       };
//     } on FirebaseAuthException catch (e) {
//       return {
//         "success": false,
//         "error": _handleAuthException(e),
//         "errorCode": e.code
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "An unexpected error occurred: $e",
//         "errorCode": "unknown"
//       };
//     }
//   }

//   // Sign in with email and password
//   Future<Map<String, dynamic>> signInWithEmailAndPassword(
//     String email,
//     String password, {
//     bool rememberMe = false,
//   }) async {
//     try {
//       UserCredential result = await auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       // Save credentials to local storage if sign in is successful
//       if (result.user != null) {
//         await userPrefs.saveCredentials(
//           username: email,
//           password: password,
//           rememberMe: rememberMe,
//         );
//       }
      
//       return {
//         "success": true,
//         "data": result.user,
//         "message": "Signed in successfully"
//       };
//     } on FirebaseAuthException catch (e) {
//       return {
//         "success": false,
//         "error": _handleAuthException(e),
//         "errorCode": e.code
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "An unexpected error occurred: $e",
//         "errorCode": "unknown"
//       };
//     }
//   }

//   // Auto sign in using stored credentials
//   Future<Map<String, dynamic>> autoSignIn() async {
//     try {
//       // Check if user should auto login
//       if (!userPrefs.shouldAutoLogin()) {
//         return {
//           "success": false,
//           "error": "Auto login not available",
//           "errorCode": "auto_login_unavailable"
//         };
//       }

//       // Check if session is expired
//       if (userPrefs.isSessionExpired()) {
//         await userPrefs.clearUserData();
//         return {
//           "success": false,
//           "error": "Session expired. Please log in again.",
//           "errorCode": "session_expired"
//         };
//       }

//       // Get stored credentials
//       String? email = userPrefs.getUsername();
//       String? password = userPrefs.getPassword();

//       if (email == null || password == null) {
//         return {
//           "success": false,
//           "error": "No stored credentials found",
//           "errorCode": "no_credentials"
//         };
//       }

//       // Attempt to sign in with stored credentials
//       return await signInWithEmailAndPassword(email, password, rememberMe: true);
      
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "Auto sign in failed: $e",
//         "errorCode": "auto_signin_error"
//       };
//     }
//   }

//   // Sign out
//   Future<Map<String, dynamic>> signOut({bool clearStoredData = true}) async {
//     try {
//       await auth.signOut();
      
//       // Clear stored user data if requested
//       if (clearStoredData) {
//         await userPrefs.clearUserData();
//       } else {
//         // Only update login status but keep credentials for next auto-login
//         await userPrefs.setLoginStatus(false);
//       }
      
//       return {
//         "success": true,
//         "message": "Signed out successfully"
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "Error signing out: $e",
//         "errorCode": "sign_out_error"
//       };
//     }
//   }

//   // Send password reset email
//   Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
//     try {
//       await auth.sendPasswordResetEmail(email: email);
//       return {
//         "success": true,
//         "message": "Password reset email sent successfully"
//       };
//     } on FirebaseAuthException catch (e) {
//       return {
//         "success": false,
//         "error": _handleAuthException(e),
//         "errorCode": e.code
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "An unexpected error occurred: $e",
//         "errorCode": "unknown"
//       };
//     }
//   }

//   // Send email verification
//   Future<Map<String, dynamic>> sendEmailVerification() async {
//     try {
//       if (currentUser == null) {
//         return {
//           "success": false,
//           "error": "No user is currently signed in",
//           "errorCode": "no_user"
//         };
//       }
      
//       await currentUser!.sendEmailVerification();
//       return {
//         "success": true,
//         "message": "Verification email sent successfully"
//       };
//     } on FirebaseAuthException catch (e) {
//       return {
//         "success": false,
//         "error": _handleAuthException(e),
//         "errorCode": e.code
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "Error sending verification email: $e",
//         "errorCode": "verification_error"
//       };
//     }
//   }

//   // Reload user to get updated info
//   Future<Map<String, dynamic>> reloadUser() async {
//     try {
//       if (currentUser == null) {
//         return {
//           "success": false,
//           "error": "No user is currently signed in",
//           "errorCode": "no_user"
//         };
//       }
      
//       await currentUser!.reload();
//       return {
//         "success": true,
//         "data": auth.currentUser,
//         "message": "User data reloaded successfully"
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "Error reloading user: $e",
//         "errorCode": "reload_error"
//       };
//     }
//   }

//   // Delete user account
//   Future<Map<String, dynamic>> deleteUser() async {
//     try {
//       if (currentUser == null) {
//         return {
//           "success": false,
//           "error": "No user is currently signed in",
//           "errorCode": "no_user"
//         };
//       }
      
//       await currentUser!.delete();
      
//       // Clear stored user data after deleting account
//       await userPrefs.clearUserData();
      
//       return {
//         "success": true,
//         "message": "User account deleted successfully"
//       };
//     } on FirebaseAuthException catch (e) {
//       return {
//         "success": false,
//         "error": _handleAuthException(e),
//         "errorCode": e.code
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "Error deleting user: $e",
//         "errorCode": "delete_error"
//       };
//     }
//   }

//   // Update user email
//   Future<Map<String, dynamic>> updateUserEmail(String newEmail) async {
//     try {
//       if (currentUser == null) {
//         return {
//           "success": false,
//           "error": "No user is currently signed in",
//           "errorCode": "no_user"
//         };
//       }
      
//       await currentUser!.updateEmail(newEmail);
      
//       // Update stored email if user has remember me enabled
//       if (userPrefs.isRememberMeEnabled()) {
//         String? storedPassword = userPrefs.getPassword();
//         if (storedPassword != null) {
//           await userPrefs.saveCredentials(
//             username: newEmail,
//             password: storedPassword,
//             rememberMe: true,
//           );
//         }
//       }
      
//       return {
//         "success": true,
//         "message": "Email updated successfully"
//       };
//     } on FirebaseAuthException catch (e) {
//       return {
//         "success": false,
//         "error": _handleAuthException(e),
//         "errorCode": e.code
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "Error updating email: $e",
//         "errorCode": "update_error"
//       };
//     }
//   }

//   // Update user password
//   Future<Map<String, dynamic>> updateUserPassword(String newPassword) async {
//     try {
//       if (currentUser == null) {
//         return {
//           "success": false,
//           "error": "No user is currently signed in",
//           "errorCode": "no_user"
//         };
//       }
      
//       await currentUser!.updatePassword(newPassword);
      
//       // Update stored password if user has remember me enabled
//       if (userPrefs.isRememberMeEnabled()) {
//         String? storedEmail = userPrefs.getUsername();
//         if (storedEmail != null) {
//           await userPrefs.saveCredentials(
//             username: storedEmail,
//             password: newPassword,
//             rememberMe: true,
//           );
//         }
//       }
      
//       return {
//         "success": true,
//         "message": "Password updated successfully"
//       };
//     } on FirebaseAuthException catch (e) {
//       return {
//         "success": false,
//         "error": _handleAuthException(e),
//         "errorCode": e.code
//       };
//     } catch (e) {
//       return {
//         "success": false,
//         "error": "Error updating password: $e",
//         "errorCode": "update_error"
//       };
//     }
//   }

//   // Get stored user credentials
//   Map<String, dynamic> getStoredCredentials() {
//     return userPrefs.getUserCredentials();
//   }

//   // Check if user has valid stored credentials
//   bool hasValidStoredCredentials() {
//     return userPrefs.validateStoredCredentials() && 
//            !userPrefs.isSessionExpired();
//   }

//   // Get last login time formatted
//   String getLastLoginTime() {
//     return userPrefs.getFormattedLastLoginTime();
//   }

//   // Clear only stored password (for security)
//   Future<bool> clearStoredPassword() async {
//     return await userPrefs.clearPassword();
//   }

//   // Toggle remember me for current user
//   Future<bool> toggleRememberMe(bool rememberMe) async {
//     if (!rememberMe) {
//       // If disabling remember me, clear stored password
//       await userPrefs.clearPassword();
//     } else {
//       // If enabling remember me, we need current credentials
//       String? email = userPrefs.getUsername();
//       if (email != null && currentUser != null) {
//         // Note: We can't get the current password from Firebase
//         // User needs to provide it again or we store it during login
//         return false; // Return false to indicate password is needed
//       }
//     }
//     return true;
//   }

//   // Handle Firebase Auth exceptions
//   String _handleAuthException(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'weak-password':
//         return 'The password provided is too weak.';
//       case 'email-already-in-use':
//         return 'The account already exists for that email.';
//       case 'user-not-found':
//         return 'No user found for that email.';
//       case 'wrong-password':
//         return 'Wrong password provided for that user.';
//       case 'invalid-email':
//         return 'The email address is not valid.';
//       case 'user-disabled':
//         return 'This user account has been disabled.';
//       case 'too-many-requests':
//         return 'Too many requests. Try again later.';
//       case 'operation-not-allowed':
//         return 'Email/password accounts are not enabled.';
//       case 'requires-recent-login':
//         return 'This operation requires recent authentication. Please log in again.';
//       case 'invalid-credential':
//         return 'The credential is invalid or has expired.';
//       case 'credential-already-in-use':
//         return 'This credential is already associated with a different user account.';
//       default:
//         return 'An error occurred: ${e.message}';
//     }
//   }
// }