import 'dart:convert';

class Operator {
  final int operatorId;
  final String username;
  final String fullName;
  final String role;

  Operator({
    required this.operatorId,
    required this.username,
    required this.fullName,
    required this.role,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      operatorId: json['operatorId'] ?? json['OPERATOR_ID'] ?? 0,
      username: json['username'] ?? json['USERNAME'] ?? '',
      fullName: json['fullName'] ?? json['FULL_NAME'] ?? '',
      role: json['role'] ?? json['ROLE'] ?? 'OPERATOR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operatorId': operatorId,
      'username': username,
      'fullName': fullName,
      'role': role,
    };
  }

  factory Operator.fromJsonString(String jsonString) {
    return Operator.fromJson(json.decode(jsonString));
  }

  String toJsonString() => json.encode(toJson());

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  
  // Compatibility alias
  String get name => fullName;
}
