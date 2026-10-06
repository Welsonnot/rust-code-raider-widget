// Copyright (c) 2026 Wilhelm San Pedro (https://minristudio.com).
// Licensed under the PolyForm Noncommercial License 1.0.0.
// See LICENSE in the project root for full license terms.

import 'attempt_record.dart';

class BaseSession {
  final String id;
  String name;
  int currentIndex;
  String? solvedCode;
  bool isSolved;
  DateTime createdAt;
  List<AttemptRecord> history;

  BaseSession({
    required this.id,
    required this.name,
    this.currentIndex = 0,
    this.solvedCode,
    this.isSolved = false,
    DateTime? createdAt,
    List<AttemptRecord>? history,
  })  : createdAt = createdAt ?? DateTime.now(),
        history = history ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'currentIndex': currentIndex,
        'solvedCode': solvedCode,
        'isSolved': isSolved,
        'createdAt': createdAt.toIso8601String(),
        'history': history.map((e) => e.toJson()).toList(),
      };

  factory BaseSession.fromJson(Map<String, dynamic> json) => BaseSession(
        id: json['id'] as String,
        name: json['name'] as String,
        currentIndex: json['currentIndex'] as int? ?? 0,
        solvedCode: json['solvedCode'] as String?,
        isSolved: json['isSolved'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        history: json['history'] != null
            ? (json['history'] as List<dynamic>)
                .map((e) => AttemptRecord.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
      );
}
