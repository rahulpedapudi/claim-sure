import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service class to handle all HTTP requests to the ClaimSure backend
///
/// This service manages communication with the backend server running on
/// http://10.186.50.129:8000/ and handles user authentication and data operations.
class ApiService {
  /// Base URL for the ClaimSure API server
  static const String _baseUrl = 'http://10.186.50.136:8000';

  /// Timeout duration for HTTP requests (30 seconds)
  static const Duration _timeout = Duration(seconds: 30);

  /// Cached access token returned by the server after successful login
  static String? _accessToken;

  /// Getter for the currently stored access token
  static String? get accessToken => _accessToken;

  /// Clears the stored access token (useful for logout flows)
  static void clearAccessToken() {
    _accessToken = null;
  }

  /// Retrieves the authenticated user's profile information from the server.
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final Uri url = Uri.parse('$_baseUrl/profile');

      print('🚀 API Request: GET ${url.toString()}');

      final http.Response response = await http
          .get(url, headers: _buildHeaders())
          .timeout(_timeout);

      print('📨 Response Status: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
          'message':
              responseData['message'] ?? 'Profile retrieved successfully',
        };
      } else {
        throw Exception(
          'Server Error (${response.statusCode}): '
          '${responseData['message'] ?? responseData['detail'] ?? 'Unable to fetch profile'}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Network Error: Please check your internet connection. Details: $e',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Data Format Error: Invalid response from server. Details: $e',
      );
    } on Exception catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Updates the authenticated user's profile with the provided details.
  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required int age,
    required String sex,
    required String location,
  }) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/profile');

      final Map<String, dynamic> requestBody = {
        'fullname': fullName,
        'age': age,
        'sex': sex,
        'location': location,
      };

      print('🚀 API Request: POST ${url.toString()}');
      print('📦 Request Body: ${jsonEncode(requestBody)}');

      final http.Response response = await http
          .post(url, headers: _buildHeaders(), body: jsonEncode(requestBody))
          .timeout(_timeout);

      print('📨 Response Status: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Profile updated successfully',
        };
      } else {
        throw Exception(
          'Server Error (${response.statusCode}): '
          '${responseData['message'] ?? responseData['detail'] ?? 'Unable to update profile'}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Network Error: Please check your internet connection. Details: $e',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Data Format Error: Invalid response from server. Details: $e',
      );
    } on Exception catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Retrieves the authenticated user's assets from the server.
  static Future<Map<String, dynamic>> getMyAssets() async {
    try {
      final Uri url = Uri.parse('$_baseUrl/my-assets');

      print('🚀 API Request: GET ${url.toString()}');

      final http.Response response = await http
          .get(url, headers: _buildHeaders())
          .timeout(_timeout);

      print('📨 Response Status: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      final dynamic responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData is Map<String, dynamic>) {
          return {
            'success': true,
            'data': responseData,
            'message': responseData['message'] ?? 'Assets fetched successfully',
          };
        } else if (responseData is List) {
          return {
            'success': true,
            'data': responseData,
            'message': 'Assets fetched successfully',
          };
        } else {
          throw Exception('Unexpected response format from /my-assets');
        }
      } else {
        throw Exception(
          'Server Error (${response.statusCode}): '
          '${responseData is Map && responseData['message'] != null
              ? responseData['message']
              : responseData is Map && responseData['detail'] != null
              ? responseData['detail']
              : 'Unable to fetch assets'}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Network Error: Please check your internet connection. Details: $e',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Data Format Error: Invalid response from server. Details: $e',
      );
    } on Exception catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Creates a new asset entry on the server
  ///
  /// Uses the authenticated user's access token to authorize the request.
  /// The nominee user ID is optional and can be supplied by the user.
  static Future<Map<String, dynamic>> createAsset({
    required String title,
    required String type,
    required double value,
    required String institution,
    required String accountNumber,
    required String description,
    String? nomineeUserId,
  }) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/create-asset');

      final Map<String, dynamic> requestBody = {
        'title': title,
        'type': type,
        'value': value,
        'institution': institution,
        'accountNumber': accountNumber,
        'description': description,
        'nominee_name': nomineeUserId,
      };

      if (nomineeUserId != null && nomineeUserId.isNotEmpty) {
        requestBody['nominee_user_id'] = nomineeUserId;
      }

      print('🚀 API Request: POST ${url.toString()}');
      print('📦 Request Body: ${jsonEncode(requestBody)}');

      final http.Response response = await http
          .post(url, headers: _buildHeaders(), body: jsonEncode(requestBody))
          .timeout(_timeout);

      print('📨 Response Status: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Asset created successfully',
        };
      } else {
        throw Exception(
          'Server Error (${response.statusCode}): '
          '${responseData['message'] ?? responseData['detail'] ?? 'Unknown error occurred'}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Network Error: Please check your internet connection. Details: $e',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Data Format Error: Invalid response from server. Details: $e',
      );
    } on Exception catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

  /// Builds the standard headers for API requests, automatically attaching the
  /// `Authorization` header when an access token is available.
  static Map<String, String> _buildHeaders({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_accessToken!}';
    }

    if (extra != null) {
      headers.addAll(extra);
    }

    return headers;
  }

  /// Attempts to authenticate the user with the provided credentials.
  ///
  /// Sends a POST request to the `/token` endpoint with the username and
  /// password. On success, the returned access token is cached for subsequent
  /// API calls that require authentication.
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/token');

      print('🚀 API Request: POST ${url.toString()}');
      print('📦 Request Body: username=$username');
      print('📦 Request Body: password=$password');

      final http.Response response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: {'username': username, 'password': password},
          )
          .timeout(_timeout);

      print('📨 Response Status: ${response.statusCode}');
      print('📨 Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final dynamic tokenValue =
            responseData['access_token'] ??
            responseData['access'] ??
            responseData['token'];

        if (tokenValue is String && tokenValue.isNotEmpty) {
          _accessToken = tokenValue;
        }

        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Login successful',
        };
      } else {
        throw Exception(
          'Authentication Failed (${response.statusCode}): '
          '${responseData['detail'] ?? responseData['message'] ?? 'Invalid credentials'}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception(
        'Network Error: Please check your internet connection. Details: $e',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Data Format Error: Invalid response from server. Details: $e',
      );
    } on Exception catch (_) {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }

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
      final http.Response response = await http
          .post(url, headers: _buildHeaders(), body: jsonEncode(requestBody))
          .timeout(_timeout);

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
          'Server Error (${response.statusCode}): ${responseData['message'] ?? 'Unknown error occurred'}',
        );
      }
    } on http.ClientException catch (e) {
      // Network connectivity issues
      throw Exception(
        'Network Error: Please check your internet connection. Details: $e',
      );
    } on FormatException catch (e) {
      // JSON parsing errors
      throw Exception(
        'Data Format Error: Invalid response from server. Details: $e',
      );
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
      final http.Response response = await http
          .get(url, headers: _buildHeaders())
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server Health Check Failed: $e');
      return false;
    }
  }
}
