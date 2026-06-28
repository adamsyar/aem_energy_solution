import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aem_energy_solution/src/core/network/api_client.dart';
import 'package:aem_energy_solution/src/core/storage/app_storage.dart';
import 'package:aem_energy_solution/src/core/storage/token_store.dart';
import 'package:aem_energy_solution/src/features/auth/data/auth_repository.dart';
import 'package:aem_energy_solution/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aem_energy_solution/src/features/dashboard/data/dashboard_repository.dart';
import 'package:aem_energy_solution/src/features/auth/presentation/pages/login_page.dart';
import 'package:aem_energy_solution/src/features/dashboard/presentation/pages/main_shell_page.dart';
import 'package:aem_energy_solution/src/features/navigation/presentation/bloc/navigation_cubit.dart';
import 'package:aem_energy_solution/src/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Auth bootstrap', () {
    test('emits unauthenticated when no saved token exists', () async {
      final bloc = AuthBloc(
        authRepository: AuthRepository(
          apiClient: ApiClient(),
          tokenStore: InMemoryTokenStore(),
        ),
      );

      expectLater(
        bloc.stream,
        emits(
          isA<AuthState>().having(
            (state) => state.status,
            'status',
            AuthStatus.unauthenticated,
          ),
        ),
      );

      bloc.add(const AuthStarted());
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
    });

    test('emits authenticated when a saved token exists', () async {
      final tokenStore = InMemoryTokenStore();
      await tokenStore.write('saved-token');

      final bloc = AuthBloc(
        authRepository: AuthRepository(
          apiClient: ApiClient(),
          tokenStore: tokenStore,
        ),
      );

      expectLater(
        bloc.stream,
        emits(
          isA<AuthState>()
              .having(
                (state) => state.status,
                'status',
                AuthStatus.authenticated,
              )
              .having((state) => state.token, 'token', 'saved-token'),
        ),
      );

      bloc.add(const AuthStarted());
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
    });

    test('emits unauthenticated when token restore throws', () async {
      final bloc = AuthBloc(
        authRepository: AuthRepository(
          apiClient: ApiClient(),
          tokenStore: _ThrowingTokenStore(onRead: true),
        ),
      );

      expectLater(
        bloc.stream,
        emits(
          isA<AuthState>().having(
            (state) => state.status,
            'status',
            AuthStatus.unauthenticated,
          ),
        ),
      );

      bloc.add(const AuthStarted());
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
    });
  });

  group('Auth repository resilience', () {
    test(
      'returns token even when token persistence fails after login',
      () async {
        final repository = AuthRepository(
          apiClient: ApiClient(
            client: MockClient((request) async {
              return http.Response('"jwt-token"', 200);
            }),
          ),
          tokenStore: _ThrowingTokenStore(onWrite: true),
        );

        final token = await repository.login(
          email: 'user@aemenersol.com',
          password: 'Test@123',
        );

        expect(token, 'jwt-token');
      },
    );

    test('logout completes even when token deletion fails', () async {
      final repository = AuthRepository(
        apiClient: ApiClient(),
        tokenStore: _ThrowingTokenStore(onDelete: true),
      );

      await repository.logout();
    });
  });

  group('API client error mapping', () {
    test('maps timeout to a user-friendly ApiException', () async {
      final apiClient = ApiClient(
        client: MockClient((request) async {
          throw TimeoutException('timeout');
        }),
      );

      await expectLater(
        () => apiClient.get('/dashboard', token: 'token'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Request timed out. Please check your connection and try again.',
          ),
        ),
      );
    });

    test('maps network failures to a user-friendly ApiException', () async {
      final apiClient = ApiClient(
        client: MockClient((request) async {
          throw const SocketException('offline');
        }),
      );

      await expectLater(
        () => apiClient.get('/dashboard', token: 'token'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'No internet connection. Please check your network and try again.',
          ),
        ),
      );
    });
  });

  group('Dashboard repository validation', () {
    test('fails fast when access token is missing', () async {
      final repository = DashboardRepository(
        apiClient: ApiClient(
          client: MockClient((request) async {
            return http.Response(jsonEncode(<String, dynamic>{}), 200);
          }),
        ),
      );

      await expectLater(
        () => repository.fetchDashboard(token: ''),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Missing access token. Please log in again.',
          ),
        ),
      );
    });
  });

  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => AuthBloc(
            authRepository: AuthRepository(
              apiClient: ApiClient(),
              tokenStore: InMemoryTokenStore(),
            ),
          ),
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('navigates directly to settings from home', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => NavigationCubit(),
          child: const MainShellPage(
            pages: [
              Center(child: Text('Home Page')),
              Center(child: Text('Info Page')),
              Center(child: Text('Settings Page')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Home Page'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings Page'), findsOneWidget);
    expect(find.text('Info Page'), findsNothing);
  });

  testWidgets('settings cubit persists toggle values', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = AppStorage(preferences);
    final cubit = SettingsCubit(storage: storage);

    cubit.loadPreferences();
    expect(cubit.state.notificationsEnabled, isTrue);
    expect(cubit.state.isDarkMode, isFalse);

    await cubit.toggleNotifications(false);
    await cubit.toggleDarkMode(true);

    expect(cubit.state.notificationsEnabled, isFalse);
    expect(cubit.state.isDarkMode, isTrue);

    await cubit.close();
  });
}

class _ThrowingTokenStore implements TokenStore {
  _ThrowingTokenStore({
    this.onRead = false,
    this.onWrite = false,
    this.onDelete = false,
  });

  final bool onRead;
  final bool onWrite;
  final bool onDelete;

  @override
  Future<void> delete() async {
    if (onDelete) {
      throw Exception('delete failed');
    }
  }

  @override
  Future<String?> read() async {
    if (onRead) {
      throw Exception('read failed');
    }
    return null;
  }

  @override
  Future<void> write(String token) async {
    if (onWrite) {
      throw Exception('write failed');
    }
  }
}
