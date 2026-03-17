import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../utils/keys.dart';
import '../utils/token.dart';

class ReceptionistController extends GetxController {
  var loading=false.obs;
  var queue=[].obs;
  var selectedDate=''.obs;

  Future<Map<String,String>> headers() async{
    final token=await TokenManager.getToken();
    return{
      'Content-Type':'application/json',
      'Authorization':'Bearer $token',
    };
  }

  void setDate(String value){
    selectedDate.value=value;
  }

  void fetchQueue() async{
    if(selectedDate.isEmpty){
      Get.snackbar('Error','Select date first');
      return;
    }

    loading.value=true;

    try{
      final uri=Uri.parse(ApiKeys.queue)
          .replace(queryParameters:{'date':selectedDate.value});

      final res=await http.get(uri,headers:await headers());

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

  void updateStatus(int id,String status) async{
    try{
      final apiStatus=status=='in_progress'?'in-progress':status;

      final res=await http.patch(
        Uri.parse(ApiKeys.updateQueue(id)),
        headers:await headers(),
        body:jsonEncode({'status':apiStatus}),
      );

      if(res.statusCode==200){
        fetchQueue();
      }else{
        Get.snackbar('Error','Failed to update status');
      }
    }catch(_){
      Get.snackbar('Error','Something went wrong');
    }
  }

  Map<String,dynamic>? currentEntry(){
    if(queue.isEmpty)return null;

    final inProgress=queue.firstWhereOrNull(
      (e)=>e['status']=='in_progress',
    );
    if(inProgress!=null)return inProgress;

    final waiting=queue.firstWhereOrNull(
      (e)=>e['status']=='waiting',
    );
    return waiting;
  }
} 