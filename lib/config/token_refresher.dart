import 'package:greenwheel_user_app/main.dart';

class TokenRefresher {
  static Future<void> refreshToken() async {
    // Check if the user is already signed in
    try{
      if (auth.currentUser != null) {
      await auth.currentUser!.getIdToken(true).then(
            (value) => {
              sharedPreferences.setString('userToken', value!),
              print(auth.currentUser),
              print(value),
            },
          ).catchError( (error) {
            print(error);
            return error;
          },);
    }
    }catch(e){
      print(e);
    }
  }
}
