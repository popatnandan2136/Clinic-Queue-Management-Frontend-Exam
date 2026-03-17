import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../utils/keys.dart';
import '../utils/token.dart';

class AdminController extends GetxController {
  var loading = false.obs;

  var clinicName = "".obs;
  var clinicCode = "".obs;
  var userCount = 0.obs;
  var appointmentCount = 0.obs;

  var users = [].obs;

  Future<Map<String, String>> headers() async{
    final token = await TokenManager.getToken();
    return{
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",};
  }

  @override
  void onInit(){
    fetchClinic();
    fetchUsers();
    super.onInit();}

  void fetchClinic() async{
    try {
      final res = await http.get(
        Uri.parse(ApiKeys.clinicInfo),
        headers: await headers(),);
      if (res.statusCode==200){
        final data=jsonDecode(res.body);
        clinicName.value=data["name"]??"";
        clinicCode.value =data["code"]??"";
        userCount.value=data["userCount"] ?? 0;
        appointmentCount.value=data["appointmentCount"]??0;
      }
      else{
        Get.snackbar("Error", "Failed to load clinic");}
    }
    catch (_){
      Get.snackbar("Error", "Something went wrong");
    }
  }

  void fetchUsers() async{
    loading.value=true;

    try{
      final res=await http.get(
        Uri.parse(ApiKeys.users),
        headers: await headers(),
      );

      if (res.statusCode==200){
        users.value = jsonDecode(res.body);
      }
      else{
        Get.snackbar("Error", "Failed to load users");
      }
    } catch (_)
    {
      Get.snackbar("Error", "Something went wrong");
    }

    loading.value=false;
  }

  void addUser(
    String name,
    String email,
    String password,
    String role,
    String phone,
  )
  async{
    if (name.isEmpty||email.isEmpty||password.isEmpty){
      Get.snackbar("Error", "Fill all required fields");
      return;
    }

    try{
      final res=await http.post(
        Uri.parse(ApiKeys.users),
        headers: await headers(),
        body: jsonEncode({
          "name":name,
          "email":email,
          "password":password,
          "role":role,
          "phone":phone,
        }),
      );

      if (res.statusCode==201){
        Get.snackbar("Success", "User created");
        fetchUsers();
      }
      else{
        final err=jsonDecode(res.body);
        Get.snackbar("Error", err["error"]??"Failed");
      }
    }
    catch (_){
      Get.snackbar("Error", "Something went wrong");
    }
  }
}
