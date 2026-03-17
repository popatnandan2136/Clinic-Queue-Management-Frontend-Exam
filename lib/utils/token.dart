import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _tokenKey="token";
  static const _roleKey="role";
  static const _clinicNameKey="clinic_name";
  static const _clinicCodeKey="clinic_code";

  static Future<void> save(
      String token,
      String role,{
        String? clinicName,
        String? clinicCode,
      }) async{
    final prefs=await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey,token);
    await prefs.setString(_roleKey,role);

    if(clinicName!=null){
      await prefs.setString(_clinicNameKey,clinicName);
    }
    if(clinicCode!=null){
      await prefs.setString(_clinicCodeKey,clinicCode);
    }
  }

  static Future<String?> getToken() async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRole() async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String?> getClinicName() async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getString(_clinicNameKey);
  }

  static Future<String?> getClinicCode() async{
    final prefs=await SharedPreferences.getInstance();
    return prefs.getString(_clinicCodeKey);
  }

  static Future<void> clear() async{
    final prefs=await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> logout() async{
    await clear();
  }
}