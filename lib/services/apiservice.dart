import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/keys.dart';

class ApiService {
  static Future<Map<String,dynamic>?> login(
      String email,
      String password,
      ) async{
    try{
      final res=await http.post(
        Uri.parse(ApiKeys.login),
        headers:{"Content-Type":"application/json"},
        body:jsonEncode({
          "email":email,
          "password":password,
        }),
      );

      if(res.statusCode==200){
        return jsonDecode(res.body);
      }
      return null;
    }catch(_){
      return null;
    }
  }
}