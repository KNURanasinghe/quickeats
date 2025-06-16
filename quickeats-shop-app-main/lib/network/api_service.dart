import 'dart:async';
import 'package:shop_app/network/api_constants.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<dynamic> postRequest(
      {required String url, required Map<String, dynamic> body}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('token');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
      if (isJsonResponse(response)) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['message'] == 'jwt expired') {
          bool refreshed = await refreshToken();
          if (refreshed) {
            return await postRequest(url: url, body: body);
          } else {
            throw Exception("Failed to refresh token. Please log in again.");
          }
        }

        return jsonDecode(response.body);
      }
    } on TimeoutException {
      throw Exception("Request Timeout: The server took too long to respond.");
    } on http.ClientException catch (e) {
      throw Exception("Client Exception: ${e.message}");
    } catch (error, stackTrace) {
      print('error: $error');
      print('stackTrace: $stackTrace');

      throw Exception("An unexpected error occurred: $error");
    }
  }

  Future<dynamic> getRequest({required String url}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('token');
      final response = await http.get(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      }).timeout(const Duration(seconds: 60));
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['message'] == 'jwt expired') {
        bool refreshed = await refreshToken();
        if (refreshed) {
          return await getRequest(url: url);
        } else {
          throw Exception("Failed to refresh token. Please log in again.");
        }
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception("Request Timeout: The server took too long to respond.");
    } on http.ClientException catch (e) {
      throw Exception("Client Exception: ${e.message}");
    } catch (error) {
      throw Exception("An unexpected error occurred: $error");
    }
  }

  Future<dynamic> deleteRequest({required String url}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('token');
      final response = await http.delete(Uri.parse(url), headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      }).timeout(const Duration(seconds: 60));
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['message'] == 'jwt expired') {
        bool refreshed = await refreshToken();
        if (refreshed) {
          return await deleteRequest(url: url);
        } else {
          throw Exception("Failed to refresh token. Please log in again.");
        }
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception("Request Timeout: The server took too long to respond.");
    } on http.ClientException catch (e) {
      throw Exception("Client Exception: ${e.message}");
    } catch (error) {
      throw Exception("An unexpected error occurred: $error");
    }
  }

  Future<dynamic> putRequest(
      {required String url, required Map<String, dynamic> body}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('token');

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              "Accept": "application/json",
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['message'] == 'jwt expired') {
        bool refreshed = await refreshToken();
        if (refreshed) {
          return await putRequest(url: url, body: body);
        } else {
          throw Exception("Failed to refresh token. Please log in again.");
        }
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception("Request Timeout: The server took too long to respond.");
    } on http.ClientException catch (e) {
      throw Exception("Client Exception: ${e.message}");
    } catch (error) {
      throw Exception("An unexpected error occurred: $error");
    }
  }

  Future<dynamic> patchRequest(
      {required String url, required Map<String, dynamic> body}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? token = sharedPreferences.getString('token');

      final response = await http
          .patch(
            Uri.parse(url),
            headers: {
              "Accept": "application/json",
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['message'] == 'jwt expired') {
        bool refreshed = await refreshToken();
        if (refreshed) {
          return await patchRequest(url: url, body: body);
        } else {
          throw Exception("Failed to refresh token. Please log in again.");
        }
      }

      return jsonDecode(response.body);
    } on TimeoutException {
      throw Exception("Request Timeout: The server took too long to respond.");
    } on http.ClientException catch (e) {
      throw Exception("Client Exception: ${e.message}");
    } catch (error) {
      throw Exception("An unexpected error occurred: $error");
    }
  }

  Future<bool> refreshToken() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? oldToken = sharedPreferences.getString('token');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/refresh-token'),
        body: jsonEncode({"token": oldToken}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('token')) {
          await sharedPreferences.setString('token', responseData['token']);
          return true;
        }
      }

      return false;
    } catch (error) {
      return false;
    }
  }

  bool isJsonResponse(http.Response response) {
    // Fallback: Try checking if response starts with { or [
    final body = response.body.trim();
    return body.startsWith('{') || body.startsWith('[');
  }
}
