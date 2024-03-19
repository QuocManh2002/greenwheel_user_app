import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:greenwheel_user_app/view_models/plan_viewmodels/temp_plan.dart';

const secretKey = "mcghmxzqflniwfazobgkcztpfcpwfskt";

class TokenGenerator {
  static String generateToken(Object encoded, String type) {
    JWT jwt;

    if (type == "plan") {
      if (encoded is TempPlan) {
        jwt = JWT(
          // Payload for plan
          {
            'isFromHost':encoded.isFromHost,
            'planId': encoded.planId,
            'isEnableToJoin': encoded.isEnableToJoin,
          },
        );
      } else {
        // Handle the case where encoded is not a TempPlan
        return "Invalid input for 'plan' type";
      }
    } else if (type == "traveler") {
      jwt = JWT(
        // Payload for traveler
        {
          'travelerId': encoded,
        },
      );
    } else {
      // Handle other types if needed
      return "Invalid type";
    }

    // Sign it (default with HS256 algorithm)
    final token = jwt.sign(SecretKey(secretKey));
    return token;
  }
}
