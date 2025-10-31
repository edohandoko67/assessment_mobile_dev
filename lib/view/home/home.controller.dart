import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../data/model/user.dart';
import '../../data/services/auth.services.dart';

class HomeController extends GetxController {
  AuthService _service = AuthService();

  @override
  void onInit() {
    super.onInit();
    dataUser();
  }

  RxList<User> userList = <User>[].obs;
  Future<void> dataUser() async {
    try {
      userList.value = await _service.listUser();
    } catch (e, stackTrace) {
      print('error: $e');
      print('stack: $stackTrace');
    }
  }

  Future<void> deleteDataUser(int id) async {
    final success = await _service.deleteData(id);
    if (success) {
      userList.removeWhere((user) => user.id == id);
      EasyLoading.showSuccess('Data berhasil dihapus');
    } else {
      EasyLoading.showError('Gagal menghapus data');
    }
  }


}