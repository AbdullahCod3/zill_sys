import 'package:equatable/equatable.dart';

/// Firestore `supervisors/{supervisorId}` (PRD §10). Resolved into the
/// escalation dialog by matching the call's issue category to [department].
class SupervisorModel extends Equatable {
  final String supervisorId;
  final String name;
  final String department;
  final String email;
  final bool available;

  const SupervisorModel({
    required this.supervisorId,
    required this.name,
    required this.department,
    this.email = '',
    this.available = true,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json, {String? id}) =>
      SupervisorModel(
        supervisorId: id ?? json['supervisor_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        department: json['department'] as String? ?? '',
        email: json['email'] as String? ?? '',
        available: json['available'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'department': department,
    'email': email,
    'available': available,
  };

  SupervisorModel copyWith({
    String? supervisorId,
    String? name,
    String? department,
    String? email,
    bool? available,
  }) => SupervisorModel(
    supervisorId: supervisorId ?? this.supervisorId,
    name: name ?? this.name,
    department: department ?? this.department,
    email: email ?? this.email,
    available: available ?? this.available,
  );

  @override
  List<Object?> get props => [supervisorId, name, department, email, available];
}
