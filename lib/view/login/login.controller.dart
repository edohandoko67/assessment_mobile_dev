import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../data/providers/api.provider.dart';
import '../../routes/routes.dart';
import '../../utils/api.constants.dart';
import '../../utils/storage.dart';
import 'package:dio/dio.dart' as dio;

import 'login.dart';

class LoginController extends GetxController with GetSingleTickerProviderStateMixin {
  final Storage _storage = Storage();
  HttpClient httpClient = HttpClient(baseUrl: ApiConstants.baseUrl);
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  RxBool isObscure = true.obs;
  RxBool isSuccess = true.obs;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideInAnimation;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0.3, 1.2),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
    super.onInit();
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }

  AnimationController get animationController => _animationController;

  Animation<double> get fadeInAnimation => _fadeInAnimation;

  Animation<Offset> get slideInAnimation => _slideInAnimation;

  Future<bool> login(Map<String, dynamic> data) async {
    EasyLoading.show(
      status: 'Mohon tunggu...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      dio.Response response = await httpClient.post(ApiConstants.login, data: data, useFormData: true);
      EasyLoading.dismiss();

      final body = response.data;
      if (body == null || body['accessToken'] == null) {
        Get.snackbar(
          "Gagal",
          "Response tidak valid dari server",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final accessToken = body['accessToken'];
      final refreshToken = body['refreshToken'];

      print("token: $accessToken");

      _storage.login();
      _storage.saveToken(accessToken);
      _storage.saveRefreshToken(refreshToken);
      _storage.saveName(data['username'] ?? '');

      return true;
    } on dio.DioError catch (error) {
      EasyLoading.dismiss();

      Get.snackbar(
        "Login Gagal",
        error.response?.data?['message'] ?? error.message ?? 'Terjadi kesalahan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } catch (e, st) {
      EasyLoading.dismiss();
      print('Error login: $e');
      print(st);
      return false;
    }
  }

  Future<void> performLogin() async {
    isLoading.value = true;
    try {
      if (username.text.isEmpty) {
        Get.snackbar('Perhatian', "Username harus diisi!", backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else if (password.text.isEmpty) {
        Get.snackbar('Perhatian', "Password harus diisi!", backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        isSuccess.value = await login({
          'username' : username.text,
          'password' : password.text,
        });

        if (isSuccess.value) {
          Get.dialog(
            barrierDismissible: false,
            AlertDialog(
              contentPadding: const EdgeInsets.all(20.0),
              title: const AnimatedCheckmark(),
              content: SizedBox(
                height: 80,
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Selamat Datang\n',
                          ),
                          TextSpan(
                            text: _storage.getName(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Divider(color: Colors.black),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                   Get.offAllNamed(Routes.HOME);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DCE89),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Oke',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/img_stop.png",
                height: 60,
              ),
              const SizedBox(height: 12),
              const Text(
                "Login Gagal",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Periksa Username / Password / URL Anda!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("OK"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toogleSecure() {
    isObscure.value = !isObscure.value;
  }

}