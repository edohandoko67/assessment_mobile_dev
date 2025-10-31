import 'package:assessment/routes/routes.dart';
import 'package:assessment/view/home/home.dart';
import 'package:assessment/view/home/tambah/tambah.user.binding.dart';
import 'package:assessment/view/home/tambah/tambah.user.dart';
import 'package:assessment/view/home/tambah/update.data.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../view/home/home.binding.dart';
import '../view/login/login.binding.dart';
import '../view/login/login.dart';
import '../view/splash/splash.dart';

List<GetPage> Pages = [
  GetPage(
    name: Routes.INITIAL,
    page: () => const SplashScreen(),
    binding: HomeBinding(),
    transition: Transition.fade,
    transitionDuration: const Duration(milliseconds: 500)
  ),
  GetPage(
    name: Routes.LOGIN,
    page: () => const LoginPage(),
    binding: LoginBinding(),
    transition: Transition.fade,
    transitionDuration: const Duration(milliseconds: 500)
  ),
  GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500)
  ),
  GetPage(
      name: Routes.ADD,
      page: () => const TambahUserPage(),
      binding: TambahUserBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500)
  ),
  GetPage(
      name: Routes.UPDATE,
      page: () => const UpdateData(),
      binding: TambahUserBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500)
  ),
];