import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  const Employee({
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  final String firstName;
  final String lastName;
  final String username;

  String get fullName => '$firstName $lastName'.trim();

  String get displayName => fullName.isEmpty ? username : fullName;

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    return displayName.toLowerCase().contains(normalized) ||
        username.toLowerCase().contains(normalized);
  }

  String get initials {
    final parts = displayName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      username: (json['username'] ?? '') as String,
    );
  }

  @override
  List<Object?> get props => [firstName, lastName, username];
}
