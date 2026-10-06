// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

class AttemptRecord {
  final String code;
  final DateTime timestamp;
  final bool isSolved;

  AttemptRecord({
    required this.code,
    required this.timestamp,
    this.isSolved = false,
  });

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'timestamp': timestamp.toIso8601String(),
        'isSolved': isSolved,
      };

  factory AttemptRecord.fromJson(Map<String, dynamic> json) => AttemptRecord(
        code: json['code'] as String,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
        isSolved: json['isSolved'] as bool? ?? false,
      );
}
