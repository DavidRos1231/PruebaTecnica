import 'dart:convert';
import 'package:http/http.dart' as http;

import '../enviroment.dart';
import '../models/capacidad_demanda.dart';

class ApiService {
  static const String baseUrl = '${Environment.apiUrl}/api/capacidad-demanda';

  static Future<ApiResponse<List<CapacidadDemanda>>> downloadAndSaveFile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/downloadFile'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 500) {
        final jsonData = json.decode(response.body);
        return ApiResponse<List<CapacidadDemanda>>.fromJson(
          jsonData,
              (data) => (data as List).map((item) => CapacidadDemanda.fromJson(item)).toList(),
        );
      } else {
        throw Exception('Hubo un error al intentar obtener la informacion: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse<List<CapacidadDemanda>>(
        data: null,
        message: 'Hubo un error al intentar descargar el la informacion',
        success: false,
      );
    }
  }

  static Future<ApiResponse<PageableResponse>> getPaginatedData({
    required int page,
    required int size,
    required String sortBy,
    required String direction,
    required String filter,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getPaginated/$page/$size/$sortBy/$direction/$filter'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<PageableResponse>.fromJson(
          jsonData,
              (data) => PageableResponse.fromJson(data),
        );
      } else {
        throw Exception('Hubo un error al intentar obtener la informacion: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse<PageableResponse>(
        data: null,
        message: 'Hubo un error al intentar descargar el la informacion',
        success: false,
      );
    }
  }
}