import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../utils/keys.dart';
import '../utils/token.dart';

class PatientController extends GetxController {
  var tabIndex=0.obs;
  var loading=false.obs;
  var appointments=[].obs;
  var selected={}.obs;
  var prescriptions=[].obs;
  var reports=[].obs;
  var prescriptionLoading=false.obs;
  var reportLoading=false.obs;

  Future<Map<String,String>> headers() async{
    final token=await TokenManager.getToken();
    return{
      "Content-Type":"application/json",
      "Authorization":"Bearer $token",
    };
  }

  void fetchAppointments() async{
    loading.value=true;

    try{
      final res=await http.get(
        Uri.parse(ApiKeys.myAppointments),
        headers:await headers(),
      );

      if(res.statusCode==200){
        appointments.value=jsonDecode(res.body);
      }else{
        Get.snackbar("Error","Failed to load appointments");
      }
    }catch(_){
      Get.snackbar("Error","Something went wrong");
    }

    loading.value=false;
  }

  void getDetails(int id) async{
    loading.value=true;

    try{
      final res=await http.get(
        Uri.parse(ApiKeys.appointmentById(id)),
        headers:await headers(),
      );

      if(res.statusCode==200){
        selected.value=jsonDecode(res.body);
      }else{
        Get.snackbar("Error","Failed to load details");
      }
    }catch(_){
      Get.snackbar("Error","Something went wrong");
    }

    loading.value=false;
  }

  void fetchPrescriptions() async{
    prescriptionLoading.value=true;

    try{
      final res=await http.get(
        Uri.parse(ApiKeys.myPrescriptions),
        headers:await headers(),
      );

      if(res.statusCode==200){
        prescriptions.value=jsonDecode(res.body);
      }else{
        Get.snackbar('Error','Failed to load prescriptions');
      }
    }catch(_){
      Get.snackbar('Error','Something went wrong');
    }

    prescriptionLoading.value=false;
  }

  void fetchReports() async{
    reportLoading.value=true;

    try{
      final res=await http.get(
        Uri.parse(ApiKeys.myReports),
        headers:await headers(),
      );

      if(res.statusCode==200){
        reports.value=jsonDecode(res.body);
      }else{
        Get.snackbar('Error','Failed to load reports');
      }
    }catch(_){
      Get.snackbar('Error','Something went wrong');
    }

    reportLoading.value=false;
  }

  Future<bool> book(String date,String slot) async{
    try{
      final res=await http.post(
        Uri.parse(ApiKeys.appointments),
        headers:await headers(),
        body:jsonEncode({
          "appointmentDate":date,
          "timeSlot":slot
        }),
      );

      if(res.statusCode==201){
        Get.snackbar("Success","Appointment booked");
        fetchAppointments();
        return true;
      }else{
        Get.snackbar("Error","Failed");
        return false;
      }
    }catch(_){
      Get.snackbar("Error","Something went wrong");
      return false;
    }
  }
}