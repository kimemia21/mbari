import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mbari/core/utils/sharedPrefs.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn.instance;
User? user;
late UserPreferences userPrefs;
