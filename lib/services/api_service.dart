import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service class to handle all HTTP requests to the ClaimSure backend
/// 
/// This service manages communication with the backend server running on
/// http://10.186.50.129:8000/ and handles user authentication and data operations.
class ApiService {
  /// Base URL for the ClaimSure API server
  static const String _baseUrl = 'http://10.186.50.129:8000';
  
  /// Timeout duration for HTTP requests (30 seconds)
  static const Duration _timeout = Duration(seconds: 30);

  /// Creates a new user account on the server
  /// 
  /// This method sends a POST request to the /create-user endpoint with the
  /// user's registration details.
  /// 
  /// **Parameters:**
  /// - [username]: The user's chosen username (required)
  /// - [phoneNo]: The user's phone number for 2FA (required)
  /// - [password]: The user's chosen password (required)
  /// 
  /// **Returns:**
  /// - `Map<String, dynamic>`: Server response containing user data or error
  /// 
  /// **Throws:**
  /// - `Exception`: If network request fails or server returns error
  /// 
  /// **Example Usage:**
  /// ```dart
  /// try {
  ///   final result = await ApiService.createUser(
  ///     username: 'john_doe',
  ///     phoneNo: '9876543210',
  ///     password: 'securePassword123'
  ///   );
  ///   print('User created: ${result['message']}');
  /// } catch (e) {
  ///   print('Error: $e');
  /// }
  /// ```
  static Future<Map<String, dynamic>> createUser({
    required String username,
    required String phoneNo,
    required String password,
  }) async {
    try {
      // Prepare the request URL
      final Uri url = Uri.parse('$_baseUrl/create-user');
      
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'username': username,
        'phone_no': phoneNo,
        'pwd': password,
      };

      // Log the request for debugging (remove in production)
      print('🚀 API Request: POST ${url.toString()}');
      print('📦 Request Body: ${jsonEncode(requestBody)}');

      // Make the HTTP POST request
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(_timeout);

      // Log the response for debugging (remove in production)
      print('📨 Response Status: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      // Parse the response body
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if the request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success: Return the response data
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'User created successfully',
        };
      } else {
        // Server returned an error status code
        throw Exception(
          'Server Error (${response.statusCode}): ${responseData['message'] ?? 'Unknown error occurred'}'
        );
      }
    } on http.ClientException catch (e) {
      // Network connectivity issues
      throw Exception('Network Error: Please check your internet connection. Details: $e');
    } on FormatException catch (e) {
      // JSON parsing errors
      throw Exception('Data Format Error: Invalid response from server. Details: $e');
    } on Exception catch (e) {
      // Re-throw known exceptions
      rethrow;
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Validates if the server is reachable
  /// 
  /// This method performs a simple health check to ensure the API server
  /// is running and accessible.
  /// 
  /// **Returns:**
  /// - `bool`: true if server is reachable, false otherwise
  /// 
  /// **Example Usage:**
  /// ```dart
  /// bool isServerOnline = await ApiService.checkServerHealth();
  /// if (!isServerOnline) {
  ///   showDialog(context, 'Server is currently unavailable');
  /// }
  /// ```
  static Future<bool> checkServerHealth() async {
    try {
      final Uri url = Uri.parse('$_baseUrl/health');
      final http.Response response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server Health Check Failed: $e');
      return false;
    }
  }
}
