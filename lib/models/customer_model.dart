import 'package:equatable/equatable.dart';

import '../core/utils/json_time.dart';

/// Firestore `customers/{customerId}` (PRD §10).
class CustomerModel extends Equatable {
  final String customerId;
  final String name;
  final String phone;
  final String accountNumber;
  final String languagePreference; // 'ar' | 'en'
  final List<String> recentIssues;
  final DateTime? createdAt;

  const CustomerModel({
    required this.customerId,
    required this.name,
    this.phone = '',
    this.accountNumber = '',
    this.languagePreference = 'en',
    this.recentIssues = const [],
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json, {String? id}) =>
      CustomerModel(
        customerId: id ?? json['customer_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        phone:
            json['phone'] as String? ?? json['phone_number'] as String? ?? '',
        accountNumber: json['account_number'] as String? ?? '',
        languagePreference: json['language_preference'] as String? ?? 'en',
        recentIssues: (json['recent_issues'] as List<dynamic>? ?? [])
            .cast<String>(),
        createdAt: parseTimestamp(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'account_number': accountNumber,
    'language_preference': languagePreference,
    'recent_issues': recentIssues,
    'created_at': dateTimeToJson(createdAt),
  };

  CustomerModel copyWith({
    String? customerId,
    String? name,
    String? phone,
    String? accountNumber,
    String? languagePreference,
    List<String>? recentIssues,
    DateTime? createdAt,
  }) => CustomerModel(
    customerId: customerId ?? this.customerId,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    accountNumber: accountNumber ?? this.accountNumber,
    languagePreference: languagePreference ?? this.languagePreference,
    recentIssues: recentIssues ?? this.recentIssues,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [
    customerId,
    name,
    phone,
    accountNumber,
    languagePreference,
    recentIssues,
    createdAt,
  ];
}
