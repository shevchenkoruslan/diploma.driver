import 'package:driver/services/firebaseAuthUtils.dart';

class PassToTripAnalysArgs {
  final AuthFunc auth;
  final String userId;
  int weaving, swerving, fastUTurn, suddenBraking;

  PassToTripAnalysArgs(this.auth, this.userId, this.weaving, this.swerving, this.fastUTurn, this.suddenBraking);
}