import 'package:assessment/data/services/auth.services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';


class TambahUserController extends GetxController {
  AuthService _service = AuthService();
  TextEditingController titleController = TextEditingController();
  TextEditingController isiController = TextEditingController();
  TextEditingController userIdController = TextEditingController();

  TextEditingController updateTitleController = TextEditingController();
  TextEditingController updateIsiController = TextEditingController();
  TextEditingController updatedUserIdController = TextEditingController();

  var savedTitle = ''.obs;
  var savedIsi = ''.obs;
  var savedUserId = ''.obs;

  var updateSavedTitle = ''.obs;
  var updateSavedIsi = ''.obs;
  var updateSavedUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void validateForm() {
    if (titleController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Harap isi title",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else if (userIdController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Harap isi userId",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      createUser();
    }
  }

  Future<void> createUser() async {
    try {
      final data = {
        "title": titleController.text,
        "body": isiController.text,
        "userId": userIdController.text,
      };

      bool result = await _service.createData(data);
      if (result) {
        savedTitle.value = titleController.text;
        savedIsi.value = isiController.text;
        savedUserId.value = userIdController.text;

        Get.snackbar(
          'Berhasil!',
          'Data ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      print('error: $e');
      print('stack: $stackTrace');
    }
  }

  RxInt userId = 0.obs;
  Future<void> updateUser(int id) async {
    try {
      final data = {
        "title": updateTitleController.text,
        "body": updateIsiController.text,
        "userId": updatedUserIdController.text,
      };

      bool result = await _service.updateData(id, data);
      if (result) {
        updateSavedTitle.value = updateTitleController.text;
        updateSavedIsi.value = updateIsiController.text;
        updateSavedUserId.value = updatedUserIdController.text;

        Get.snackbar(
          'Berhasil!',
          'Data diubah',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      print('error: $e');
      print('stack: $stackTrace');
    }
  }

  void clearText() {
    titleController.text = '';
    isiController.text = '';
    userIdController.text = '';
    savedTitle.value = '';
  }

}