import 'package:assessment/view/home/tambah/tambah.user.controller.dart';
import 'package:get/get.dart';

class TambahUserBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahUserController>(() => TambahUserController());
  }
}