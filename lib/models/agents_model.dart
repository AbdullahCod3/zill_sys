import 'package:equatable/equatable.dart';

import '../core/utils/json_time.dart';

/// Firestore `agents/{agentId}` (PRD §10).
class AgentsModel extends Equatable {
  final String agentId;
  final String name;
  final String email;
  final String department;
  final String status; // available / on_call / offline
  final List<String> languages;
  final DateTime? createdAt;

  const AgentsModel({
    required this.agentId,
    required this.name,
    this.email = '',
    this.department = '',
    this.status = 'available',
    this.languages = const [],
    this.createdAt,
  });

  factory AgentsModel.fromJson(Map<String, dynamic> json, {String? id}) =>
      AgentsModel(
        agentId: id ?? json['agent_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        department: json['department'] as String? ?? '',
        status: json['status'] as String? ?? 'available',
        languages: (json['languages'] as List<dynamic>? ?? []).cast<String>(),
        createdAt: parseTimestamp(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'department': department,
    'status': status,
    'languages': languages,
    'created_at': dateTimeToJson(createdAt),
  };

  AgentsModel copyWith({
    String? agentId,
    String? name,
    String? email,
    String? department,
    String? status,
    List<String>? languages,
    DateTime? createdAt,
  }) => AgentsModel(
    agentId: agentId ?? this.agentId,
    name: name ?? this.name,
    email: email ?? this.email,
    department: department ?? this.department,
    status: status ?? this.status,
    languages: languages ?? this.languages,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [
    agentId,
    name,
    email,
    department,
    status,
    languages,
    createdAt,
  ];
}
