import 'package:assessment/view/home/home.controller.dart';
import 'package:assessment/view/home/tambah/tambah.user.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/routes.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    TambahUserController tambahUserController = Get.put(TambahUserController());
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Tambah'),
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(Routes.ADD);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.dataUser();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Daftar User',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      itemCount: controller.userList.length,
                      itemBuilder: (context, index) {
                        final item = controller.userList[index];
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: Text(
                                      item.title ?? "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.body ?? "",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 15,
                              right: 5,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await Get.dialog<bool>(
                                    AlertDialog(
                                      title: const Text("Hapus Data"),
                                      content: const Text("Apakah kamu yakin ingin menghapus data ini?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Get.back(result: false),
                                          child: const Text("Batal"),
                                        ),
                                        TextButton(
                                          onPressed: () => Get.back(result: true),
                                          child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    controller.deleteDataUser(item.id!);
                                  }
                                },
                              ),
                            ),
                            Positioned(
                              top: 15,
                              right: 35,
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () async {
                                  Get.toNamed(Routes.UPDATE, arguments: item);
                                  tambahUserController.updateTitleController.text = item.title ?? '';
                                  tambahUserController.updateIsiController.text = item.body ?? '';
                                  tambahUserController.updatedUserIdController.text = (item.id ?? 0).toString();
                                  tambahUserController.userId.value = item.id ?? 0;
                                  tambahUserController.updateSavedTitle.value = item.title ?? '';
                                  tambahUserController.updateSavedIsi.value = item.body ?? '';
                                  tambahUserController.updateSavedUserId.value = (item.id ?? 0).toString();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
