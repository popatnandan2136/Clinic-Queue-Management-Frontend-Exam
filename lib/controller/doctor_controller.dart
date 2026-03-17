import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../utils/keys.dart';
import '../utils/token.dart';

class DoctorController extends GetxController {
  var loading=false.obs;
  var queue=[].obs;
  var selectedAppointmentId=0.obs;

  Future<Map<String,String>> headers() async{
    final token=await TokenManager.getToken();
    return{
      'Content-Type':'application/json',
      'Authorization':'Bearer $token',
    };
  }

  @override
  void onInit(){
    fetchQueue();
    super.onInit();
  }

  void fetchQueue() async{
    loading.value=true;
    try{
      final res=await http.get(
        Uri.parse(ApiKeys.doctorQueue),
        headers:await headers(),
      );

      if(res.statusCode==200){
        queue.value=jsonDecode(res.body);
      }else{
        Get.snackbar('Error','Failed to load queue');
      }
    }catch(_){
      Get.snackbar('Error','Something went wrong');
    }
    loading.value=false;
  }

  Future<bool> addPrescription(
      int appointmentId,
      List<Map<String,String>> medicines,
      String notes,
      ) async{
    if(appointmentId<=0||medicines.isEmpty){
      Get.snackbar('Error','Fill appointment and medicines');
      return false;
    }

    for(final m in medicines){
      final name=(m['name']??'').trim();
      final dosage=(m['dosage']??'').trim();
      final duration=(m['duration']??'').trim();

      if(name.isEmpty||dosage.isEmpty||duration.isEmpty){
        Get.snackbar('Error','Fill name, dosage and duration for all medicines');
        return false;
      }
    }

    try{
      final res=await http.post(
        Uri.parse(ApiKeys.addPrescription(appointmentId)),
        headers:await headers(),
        body:jsonEncode({'medicines':medicines,'notes':notes}),
      );

      if(res.statusCode==201){
        Get.snackbar('Success','Prescription saved');
        return true;
      }else{
        try{
          final body=jsonDecode(res.body);
          final msg=body['error']?.toString();
          Get.snackbar('Error',msg??'Failed to save prescription');
        }catch(_){
          Get.snackbar('Error','Failed to save prescription');
        }
        return false;
      }
    }catch(_){
      Get.snackbar('Error','Something went wrong');
      return false;
    }
  }

  Future<bool> addReport(
      int appointmentId,
      String diagnosis,
      String testRecommended,
      String remarks,
      ) async{
    if(appointmentId<=0||diagnosis.isEmpty){
      Get.snackbar('Error','Fill required fields');
      return false;
    }

    try{
      final res=await http.post(
        Uri.parse(ApiKeys.addReport(appointmentId)),
        headers:await headers(),
        body:jsonEncode({
          'diagnosis':diagnosis,
          'testRecommended':testRecommended,
          'remarks':remarks,
        }),
      );

      if(res.statusCode==201){
        Get.snackbar('Success','Report saved');
        return true;
      }else{
        Get.snackbar('Error','Failed to save report');
        return false;
      }
    }catch(_){
      Get.snackbar('Error','Something went wrong');
      return false;
    }
  }
}