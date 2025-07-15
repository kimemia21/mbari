
import 'package:mbari/core/utils/sharedPrefs.dart';
import 'package:mbari/data/models/User.dart';
import 'package:mbari/data/services/comms.dart';

final Comms comms = Comms();

late UserPreferences userPrefs;

final baseUrl = "http://192.168.88.227:3000/api";
User user = User.empty();

enum Role { admin, member }

Role? userRole;

Role StringToRole(String role) {
  switch (role) {
    case "member":
      return Role.member;
    case "admin":
      return Role.admin;

    default:
      return Role.member;
  }
}



String RoleToString(Role role) {
  switch (role) {
    case Role.member:
      return "member";
    case Role.admin:
      return "admin";

    default:
      return "member";
  }
}


