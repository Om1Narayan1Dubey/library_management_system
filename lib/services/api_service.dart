import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {

  static const String baseUrl = 'https://wiring-fondue-path.ngrok-free.dev/api';

  static const _storage = FlutterSecureStorage();
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'jwt_token');
        }
        handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String mobile,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'username': username,
      'email':    email,
      'password': password,
      'mobile':   mobile,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'email':    email,
      'password': password,
    });
    if (res.data['token'] != null) {
      await _storage.write(key: 'jwt_token', value: res.data['token']);
    }
    return res.data;
  }

  Future<void> sendOtp(String email) async {
    await _dio.post('/auth/send-otp', data: {'email': email});
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final res = await _dio.post('/auth/verify-otp', data: {
      'email':   email,
      'otpCode': otpCode,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/auth/me');
    return res.data;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  Future<void> deleteUnverifiedUser(String email) async {
    await _dio.delete('/auth/delete-unverified',
        data: {'email': email});
  }

  Future<List<dynamic>> getAllUsers() async {
    final res = await _dio.get('/auth/users');
    return res.data;
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await _dio.get('/admin/dashboard');
    return res.data;
  }

  Future<List<dynamic>?> getAllMembers({int page = 0, int size = 20, String? search}) async {
    try {
      String url = '/admin/members?page=$page&size=$size';

      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching members: $e');
      return null;
    }
  }

  Future<List<dynamic>> getMemberBorrowHistory(int userId) async {
    try {
      final response = await _dio.get('/admin/members/$userId/history');
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to retrieve member log history');
    }
  }

  Future<void> addMember(String username, String email, String password, String role) async {
    try {
      await _dio.post('/admin/members', data: {
        'username': username,
        'email': email,
        'password': password, // Now sending the password to the backend
        'role': role,
      });
    } catch (e) {
      throw Exception('Failed to add member');
    }
  }

  Future<void> deleteMember(int userId) async {
    try {
      await _dio.delete('/admin/members/$userId');
    } catch (e) {
      throw Exception('Failed to delete member');
    }
  }

  Future<void> updateUserRole(int userId, String role) async {
    try {
      await _dio.put('/admin/members/$userId/role', data: {'role': role});
    } catch (e) {
      throw Exception('Failed to update role');
    }
  }

  Future<bool> addNewBook({
    required String title,
    required String author,
    required String isbn,
    required String category,
    required int copies,
  }) async {
    try {
      final response = await _dio.post('/admin/books/add', data: {
        'title': title,
        'author': author,
        'isbn': isbn,
        'category': category,
        'totalCopies': copies,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getAllBooks() async {
    try {
      final response = await _dio.get('/books');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching books: $e');
      return [];
    }
  }

  Future<bool> updateBook({
    required int id,
    required String title,
    required String author,
    required String isbn,
    required String category,
    required int totalCopies,
  }) async {
    try {
      final response = await _dio.put(
        '/books/$id',
        data: {
          'title': title,
          'author': author,
          'isbn': isbn,
          'category': category,
          'totalCopies': totalCopies,
          'availableCopies': totalCopies,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating book: $e');
      return false;
    }
  }

  Future<bool> deleteBook(int id) async {
    try {
      final response = await _dio.delete('/books/$id');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting book: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDailyActivityLogs() async {
    try {
      final response = await _dio.get('/reports/daily-activity');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching daily activity: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getGlobalBorrowHistory({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get('/reports/borrow-history?page=$page&size=$size');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching borrow history: $e');
      return null;
    }
  }

}