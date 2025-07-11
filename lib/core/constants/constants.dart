import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mbari/core/utils/sharedPrefs.dart';
import 'package:mbari/data/models/Member.dart';
import 'package:mbari/data/services/comms.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn.instance;
final Comms comms = Comms();
User? user;
late UserPreferences userPrefs;

final baseUrl = "http://192.168.88.227:3000/api";
 Member member = Member.empty();
