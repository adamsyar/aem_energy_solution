import 'package:equatable/equatable.dart';

class ChartItem extends Equatable {
  const ChartItem({required this.name, required this.value});

  final String name;
  final double value;

  factory ChartItem.fromJson(Map<String, dynamic> json) {
    return ChartItem(
      name: (json['name'] ?? '') as String,
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, value];
}
