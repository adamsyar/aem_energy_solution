import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> postJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final headers = {'Content-Type': 'application/json'};
    final encodedBody = jsonEncode(body);
    final stopwatch = Stopwatch()..start();

    _logRequest(method: 'POST', uri: uri, headers: headers, body: body);

    final response = await _guardRequest(
      () => _client
          .post(uri, headers: headers, body: encodedBody)
          .timeout(const Duration(seconds: 15)),
    );
    stopwatch.stop();

    _logResponse(
      method: 'POST',
      uri: uri,
      response: response,
      elapsed: stopwatch.elapsed,
    );

    return _parseResponse(response);
  }

  Future<dynamic> get(String path, {String? token}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final headers = {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final stopwatch = Stopwatch()..start();

    _logRequest(method: 'GET', uri: uri, headers: headers);

    final response = await _guardRequest(
      () => _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15)),
    );
    stopwatch.stop();

    _logResponse(
      method: 'GET',
      uri: uri,
      response: response,
      elapsed: stopwatch.elapsed,
    );

    return _parseResponse(response);
  }

  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    throw ApiException(_extractErrorMessage(response));
  }

  Future<http.Response> _guardRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Please check your connection and try again.',
      );
    } on SocketException {
      throw const ApiException(
        'No internet connection. Please check your network and try again.',
      );
    } on http.ClientException {
      throw const ApiException('Network error. Please try again.');
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message =
            decoded['message'] ?? decoded['error'] ?? decoded['title'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Fall back to generic messaging when the backend returns plain text.
    }

    return switch (response.statusCode) {
      401 => 'Invalid email or password.',
      500 => 'Server error. Please try again in a moment.',
      _ => 'Request failed with status ${response.statusCode}.',
    };
  }

  void _logRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    Object? body,
  }) {
    if (!kDebugMode) {
      return;
    }

    _logBlock([
      '[API] REQUEST  $method',
      'url: $uri',
      if (headers.isNotEmpty) ...[
        'headers:',
        _indent(_prettyData(_sanitizeHeaders(headers))),
      ],
      if (body != null) ...['body:', _indent(_prettyData(body))],
    ]);
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required http.Response response,
    required Duration elapsed,
  }) {
    if (!kDebugMode) {
      return;
    }

    _logBlock([
      '[API] RESPONSE $method',
      'url: $uri',
      'status: ${response.statusCode} ${response.reasonPhrase ?? ''}',
      'time: ${elapsed.inMilliseconds} ms',
      'body:',
      _indent(_prettyData(_decodedOrRaw(response.body))),
    ]);
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization' && value.length > 20) {
        final visibleTail = value.substring(value.length - 8);
        return MapEntry(key, 'Bearer ***$visibleTail');
      }
      return MapEntry(key, value);
    });
  }

  String _prettyData(Object data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  Object _decodedOrRaw(String body) {
    if (body.isEmpty) {
      return '(empty)';
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _indent(String value) {
    return value.split('\n').map((line) => '  $line').join('\n');
  }

  void _logBlock(List<String> lines) {
    const maxWidth = 88;
    final normalized = <String>[];

    for (final line in lines) {
      normalized.addAll(line.split('\n'));
    }

    final wrapped = <String>[];
    for (final line in normalized) {
      wrapped.addAll(_wrapLine(line, maxWidth));
    }

    final title = wrapped.isEmpty ? '[API]' : wrapped.first;
    final body = wrapped.length <= 1 ? const <String>[] : wrapped.sublist(1);
    final topBorder = '┌${_padTitle(title, maxWidth)}┐';

    debugPrint(topBorder);
    for (final line in body) {
      debugPrint('│ ${line.padRight(maxWidth - 1)}│');
    }
    debugPrint('└${'─' * maxWidth}┘');
  }

  List<String> _wrapLine(String line, int width) {
    if (line.isEmpty) {
      return [''];
    }

    final result = <String>[];
    final words = line.split(' ');
    var current = '';

    for (final word in words) {
      final candidate = current.isEmpty ? word : '$current $word';
      if (candidate.length <= width - 2) {
        current = candidate;
        continue;
      }

      if (current.isNotEmpty) {
        result.add(current);
        current = '';
      }

      if (word.length <= width - 2) {
        current = word;
        continue;
      }

      var start = 0;
      while (start < word.length) {
        final end = (start + width - 2).clamp(0, word.length);
        result.add(word.substring(start, end));
        start = end;
      }
    }

    if (current.isNotEmpty) {
      result.add(current);
    }

    return result;
  }

  String _padTitle(String title, int width) {
    final trimmed = title.length > width - 2
        ? title.substring(0, width - 2)
        : title;
    final remaining = width - trimmed.length - 1;
    return '─ $trimmed${'─' * remaining}';
  }
}
