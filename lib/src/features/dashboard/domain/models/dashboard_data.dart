import 'package:equatable/equatable.dart';

import '../../../info/domain/models/employee.dart';
import 'chart_item.dart';

class DashboardData extends Equatable {
  const DashboardData({
    required this.chartDonut,
    required this.chartBar,
    required this.users,
  });

  final List<ChartItem> chartDonut;
  final List<ChartItem> chartBar;
  final List<Employee> users;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      chartDonut: _mapItems(json['chartDonut']),
      chartBar: _mapItems(json['chartBar'] ?? json['chartbar']),
      users: ((json['tableUsers'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => Employee.fromJson(item as Map<String, dynamic>))
          .toList()),
    );
  }

  static List<ChartItem> _mapItems(dynamic source) {
    return (source as List<dynamic>? ?? <dynamic>[])
        .map((item) => ChartItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  List<Object?> get props => [chartDonut, chartBar, users];
}
