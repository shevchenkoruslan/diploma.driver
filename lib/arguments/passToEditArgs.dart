import 'package:driver/services/firebaseAuthUtils.dart';

class PassToEditArgs {
  final AuthFunc auth;
  String userId;
  String name;
  String email;
  

  PassToEditArgs(this.auth, this.userId, this.name, this.email);
}