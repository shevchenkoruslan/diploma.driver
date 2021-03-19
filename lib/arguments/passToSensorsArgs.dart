import 'package:driver/services/firebaseAuthUtils.dart';

class PassToSensorsArgs {
  final AuthFunc auth;
  String userId;   

  PassToSensorsArgs(this.auth, this.userId);
}