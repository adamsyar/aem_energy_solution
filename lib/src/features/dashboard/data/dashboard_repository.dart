import '../../../core/network/api_client.dart';
import '../domain/models/dashboard_data.dart';

class DashboardRepository {
  DashboardRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<DashboardData> fetchDashboard({required String token}) async {
    if (token.trim().isEmpty) {
      throw const ApiException('Missing access token. Please log in again.');
    }

    final response = await _apiClient.get('/dashboard', token: token);

    if (response is! Map<String, dynamic>) {
      throw const ApiException('Unexpected dashboard response.');
    }

    return DashboardData.fromJson(response);
  }
}
