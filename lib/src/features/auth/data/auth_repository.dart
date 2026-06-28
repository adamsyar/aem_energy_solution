import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_store.dart';

class AuthRepository {
  AuthRepository({required this._apiClient, required this.tokenStore});

  final ApiClient _apiClient;
  final TokenStore tokenStore;

  Future<String?> getSavedToken() async {
    try {
      return await tokenStore.read();
    } catch (error, stackTrace) {
      _debugLogStorageIssue(
        operation: 'read persisted auth token',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.postJson(
      '/account/login',
      body: {'username': email, 'password': password},
    );

    if (response is String && response.isNotEmpty) {
      try {
        await tokenStore.write(response);
      } catch (error, stackTrace) {
        _debugLogStorageIssue(
          operation: 'persist auth token',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return response;
    }

    throw const ApiException('Unexpected login response from the server.');
  }

  Future<void> logout() async {
    try {
      await tokenStore.delete();
    } catch (error, stackTrace) {
      _debugLogStorageIssue(
        operation: 'delete persisted auth token',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _debugLogStorageIssue({
    required String operation,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (!kDebugMode) {
      return;
    }

    debugPrint(
      '[AUTH] Unable to $operation. The app will continue with in-memory auth only.\n'
      'error: $error\n'
      'stackTrace: $stackTrace',
    );
  }
}
