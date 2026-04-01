import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';

enum ThreatType { scam, suspect, safe }
enum ThreatCategory { sms, link, call }

class ThreatModel {
  final String id;
  final ThreatType type;
  final ThreatCategory category;
  final String sender;
  final String content;
  final String? url;
  final DateTime timestamp;
  final bool isBlocked;

  ThreatModel({
    required this.id,
    required this.type,
    required this.category,
    required this.sender,
    required this.content,
    this.url,
    required this.timestamp,
    required this.isBlocked,
  });

  factory ThreatModel.fromJson(Map<String, dynamic> json) {
    return ThreatModel(
      id: json['id'],
      type: ThreatType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ThreatType.suspect,
      ),
      category: ThreatCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ThreatCategory.sms,
      ),
      sender: json['sender'],
      content: json['content'],
      url: json['url'],
      timestamp: DateTime.parse(json['timestamp']),
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  String get verdictText {
    switch (type) {
      case ThreatType.scam:
        return 'DANGER';
      case ThreatType.suspect:
        return 'SUSPECT';
      case ThreatType.safe:
        return 'SUR';
    }
  }

  String get verdictIcon {
    switch (type) {
      case ThreatType.scam:
        return '🚨';
      case ThreatType.suspect:
        return '⚠️';
      case ThreatType.safe:
        return '✅';
    }
  }

  Color get verdictColor {
    switch (type) {
      case ThreatType.scam:
        return AppTheme.dangerRed;
      case ThreatType.suspect:
        return AppTheme.warningOrange;
      case ThreatType.safe:
        return AppTheme.successGreen;
    }
  }
}