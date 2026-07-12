import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionEntity extends Equatable {
  final String transactionId;
  final String jobId;
  final String jobTitle;
  final String providerId;
  final String providerName;
  final String youthId;
  final String youthName;
  final double amount;
  final double platformFee;
  final double netPayout;
  final String channel; // 'mpesa', 'airtel', 'tigo'
  final String status;  // 'paid', 'pending', 'disputed'
  final DateTime createdAt;
  final String? disputeNotes;

  const TransactionEntity({
    required this.transactionId,
    required this.jobId,
    required this.jobTitle,
    required this.providerId,
    required this.providerName,
    required this.youthId,
    required this.youthName,
    required this.amount,
    required this.platformFee,
    required this.netPayout,
    required this.channel,
    required this.status,
    required this.createdAt,
    this.disputeNotes,
  });

  @override
  List<Object?> get props => [
        transactionId,
        jobId,
        jobTitle,
        providerId,
        providerName,
        youthId,
        youthName,
        amount,
        platformFee,
        netPayout,
        channel,
        status,
        createdAt,
        disputeNotes,
      ];

  Map<String, dynamic> toMap() => {
        'transactionId': transactionId,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'providerId': providerId,
        'providerName': providerName,
        'youthId': youthId,
        'youthName': youthName,
        'amount': amount,
        'platformFee': platformFee,
        'netPayout': netPayout,
        'channel': channel,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'disputeNotes': disputeNotes,
      };

  factory TransactionEntity.fromMap(Map<String, dynamic> map) => TransactionEntity(
        transactionId: map['transactionId'] as String? ?? '',
        jobId: map['jobId'] as String? ?? '',
        jobTitle: map['jobTitle'] as String? ?? '',
        providerId: map['providerId'] as String? ?? '',
        providerName: map['providerName'] as String? ?? '',
        youthId: map['youthId'] as String? ?? '',
        youthName: map['youthName'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        platformFee: (map['platformFee'] as num?)?.toDouble() ?? 0.0,
        netPayout: (map['netPayout'] as num?)?.toDouble() ?? 0.0,
        channel: map['channel'] as String? ?? 'mpesa',
        status: map['status'] as String? ?? 'pending',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        disputeNotes: map['disputeNotes'] as String?,
      );
}
