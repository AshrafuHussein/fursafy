import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiKeyEntity extends Equatable {
  final String keyId;
  final String name;
  final String keyValue;
  final String environment;
  final DateTime createdAt;

  const ApiKeyEntity({
    required this.keyId,
    required this.name,
    required this.keyValue,
    required this.environment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [keyId, name, keyValue, environment, createdAt];

  Map<String, dynamic> toMap() => {
        'keyId': keyId,
        'name': name,
        'keyValue': keyValue,
        'environment': environment,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory ApiKeyEntity.fromMap(Map<String, dynamic> map) => ApiKeyEntity(
        keyId: map['keyId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        keyValue: map['keyValue'] as String? ?? '',
        environment: map['environment'] as String? ?? 'test',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
