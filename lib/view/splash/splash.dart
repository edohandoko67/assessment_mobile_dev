import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../routes/routes.dart';
import '../login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  GetStorage box = GetStorage();
  Duration splashDuration = const Duration(seconds: 2);
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: splashDuration,
    )..addListener(() {
      setState(() {});
    });

    controller.repeat();
    controller.forward().whenComplete(() async {
      box.writeIfNull("isLoggedIn", false);

      final token = box.read("accessToken");
      final refreshToken = box.read("refreshToken");
      final isLoggedIn = box.read("isLoggedIn") ?? false;

      bool isTokenValid = false;

      if (token != null && token.toString().isNotEmpty) {
        if (refreshToken != null && refreshToken.toString().isNotEmpty) {
          final refreshed = await _refreshAccessToken(refreshToken);
          if (refreshed) {
            isTokenValid = true;
          } else {
            box.remove("accessToken");
            box.remove("refreshToken");
            box.write("isLoggedIn", false);
          }
        } else {
          isTokenValid = true;
        }
      }

      if (isLoggedIn && isTokenValid) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAll(() => const LoginPage());
      }
    });
  }

  Future<bool> _refreshAccessToken(String refreshToken) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com/'));
      final response = await dio.post('auth/refresh', data: {
        "refreshToken": refreshToken,
      });

      final newAccessToken = response.data["accessToken"];
      final newRefreshToken = response.data["refreshToken"];

      if (newAccessToken != null && newRefreshToken != null) {
        box.write("token", newAccessToken);
        box.write("refreshToken", newRefreshToken);
        box.write("isLoggedIn", true);
        print("Token berhasil diperbarui otomatis di splash");
        return true;
      }
    } catch (e) {
      print("Gagal refresh token: $e");
    }

    return false;
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  final spinkit = SpinKitWave(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven
              ? Colors.blueAccent
              : Colors.black,
          shape: BoxShape.rectangle,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    SizedBox(
                        width: 30,
                        child: Image.asset('assets/images/tantram.png',)),
                    const SizedBox(width: 5,),
                    const Text('|', style: TextStyle(fontSize: 15),),
                    const SizedBox(width: 5,),
                    const Text(
                      'Assessment Mobile Dev',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFF954828)),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 130,
              ),
              Center(
                child: Image.asset(
                  'assets/images/tantram.png',
                  width: 150,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              spinkit
            ],
          ),
        ),
      ),
    );
  }

}