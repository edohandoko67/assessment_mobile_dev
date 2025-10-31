import 'dart:convert';

import 'package:assessment/data/model/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dio/dio.dart' as dio;
import '../../utils/api.constants.dart';
import '../providers/api.provider.dart';

class AuthService {
  HttpClient httpClient = HttpClient(baseUrl: ApiConstants.baseUrl);

  Future<List<User>> listUser() async {
    EasyLoading.show(
      status: 'Sedang memuat data...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final dio.Response response = await httpClient.get(ApiConstants.list);
      EasyLoading.dismiss();

      print('Raw Response: ${response.data}');

      if (response.statusCode != 200) {
        EasyLoading.showError('Server mengembalikan status ${response.statusCode}');
        return [];
      }

      final body = response.data;
      if (body is List) {
        return body.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
      }

      if (body is Map<String, dynamic>) {
        if (body['posts'] is List) {
          return (body['posts'] as List)
              .map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        if (body['response']?['data'] is List) {
          return (body['response']['data'] as List)
              .map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      EasyLoading.showError('Data tidak valid dari server');
      return [];

    } on dio.DioError catch (e) {
      EasyLoading.dismiss();
      print('Response Data: ${e.response?.data}');
      print('Response Status: ${e.response?.statusCode}');
      EasyLoading.showError('Gagal terhubung ke Server. Coba lagi!');
      return [];
    } catch (e, st) {
      EasyLoading.dismiss();
      print('Error parsing data: $e');
      print(st);
      EasyLoading.showError('Terjadi kesalahan internal');
      return [];
    }
  }

  void printLong(Object? text) {
    final pattern = RegExp('.{1,800}');
    for (final match in pattern.allMatches(text.toString())) {
      print(match.group(0));
    }
  }

  void printPrettyJson(dynamic json) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyString = encoder.convert(json);
    printLong(prettyString);
  }

  Future<bool> createData(Map<String, dynamic> data) async {
    EasyLoading.show(
      status: 'Sedang memproses...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final dio.Response response = await httpClient.post(
        ApiConstants.addData,
        data: data,
        options: dio.Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      EasyLoading.dismiss();

      final body = response.data;

      print('==== Response Data START ====');
      printPrettyJson(body);
      print('==== Response Data END ====');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body['id'] != null) {
          await Future.delayed(const Duration(milliseconds: 500));
          EasyLoading.showSuccess('Data berhasil ditambahkan!');
          return true;
        } else {
          EasyLoading.showError('Respons tidak valid dari server.');
          return false;
        }
      } else {
        EasyLoading.showError('Gagal menambahkan data. Coba lagi.');
        return false;
      }
    } on dio.DioError catch (e, stackTrace) {
      print('==== Dio Exception START ====');
      printLong(e.response?.data ?? e.message);
      print('==== Dio Exception END ====');
      print('StackTrace: $stackTrace');

      final statusCode = e.response?.statusCode;

      if (statusCode == 400 || statusCode == 500) {
        final errorData = e.response?.data;

        if (errorData != null &&
            errorData.toString().contains('Duplicate entry')) {
          EasyLoading.showError('Data sudah ada. Silakan coba lagi.');
        } else {
          EasyLoading.showError(
            errorData?['message'] ?? 'Terjadi kesalahan memproses data',
          );
        }
      } else {
        EasyLoading.showError('Tidak dapat terhubung ke server.');
      }

      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> updateData(int id, Map<String, dynamic> data) async {
    EasyLoading.show(
      status: 'Sedang memperbarui data...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final response = await httpClient.put(
        '${ApiConstants.updateData}/$id',
        data: data,
        options: dio.Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final body = response.data;

      print('==== Response Data START ====');
      printPrettyJson(body);
      print('==== Response Data END ====');

      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess('Data berhasil diperbarui!');
        return true;
      } else {
        EasyLoading.showError(
          body['message'] ?? 'Gagal memperbarui data. Coba lagi.',
        );
        return false;
      }
    } on dio.DioError catch (e, stackTrace) {
      print('==== Dio Exception START ====');
      printLong(e.response?.data ?? e.message);
      print('==== Dio Exception END ====');
      print('StackTrace: $stackTrace');

      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;

      if (statusCode == 400 || statusCode == 500) {
        if (errorData != null &&
            errorData.toString().contains('Duplicate entry')) {
          EasyLoading.showError('Data sudah ada. Silakan coba lagi.');
        } else {
          EasyLoading.showError(
            errorData?['message'] ?? 'Terjadi kesalahan memproses data',
          );
        }
      } else {
        EasyLoading.showError('Tidak dapat terhubung ke server.');
      }

      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> deleteData(int id) async {
    EasyLoading.show(
      status: 'Menghapus data...',
      maskType: EasyLoadingMaskType.black,
    );

    try {
      final response = await httpClient.delete(
        '${ApiConstants.deleteData}/$id',
      );

      EasyLoading.dismiss();

      final body = response.data;
      print('==== DELETE Response START ====');
      printPrettyJson(body);
      print('==== DELETE Response END ====');

      if (body['isDeleted'] == true) {
        EasyLoading.showSuccess('Data berhasil dihapus');
        return true;
      } else {
        EasyLoading.showError('Gagal menghapus data');
        return false;
      }

    } on dio.DioError catch (e) {
      EasyLoading.dismiss();
      print('==== Dio Error START ====');
      printLong(e.response?.data ?? e.message);
      print('==== Dio Error END ====');
      EasyLoading.showError('Terjadi kesalahan saat menghapus data');
      return false;
    } catch (e, st) {
      EasyLoading.dismiss();
      print('Error: $e');
      print(st);
      EasyLoading.showError('Kesalahan internal sistem');
      return false;
    }
  }


}