import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/core/network/api_client.dart';
import 'src/core/storage/app_storage.dart';
import 'src/core/storage/token_store.dart';
import 'src/features/auth/data/auth_repository.dart';
import 'src/features/dashboard/data/dashboard_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final storage = AppStorage(preferences);
  final apiClient = ApiClient();

  runApp(
    AemEnergyApp(
      storage: storage,
      authRepository: AuthRepository(
        apiClient: apiClient,
        tokenStore: SecureTokenStore(),
      ),
      dashboardRepository: DashboardRepository(apiClient: apiClient),
    ),
  );
}
