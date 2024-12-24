import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DataFormatter {
  static String format(dynamic value, String type, BuildContext context) {
    if (value == null) return '';

    // Gestion des types de dates
    switch (type) {
      case 'DateTime':
      case 'DateTime?':
      case 'DateOnly':
      case 'DateOnly?':
        return _formatDateOnly(value, context);
      case 'TimeOnly':
      case 'TimeOnly?':
        return _formatTimeOnly(value, context);
      default:
        return value.toString();
    }
  }

  static String _formatDateOnly(dynamic value, BuildContext context) {
    try {
      final date = DateTime.parse(value.toString());
      return DateFormat.yMd(Localizations.localeOf(context).languageCode)
          .format(date);
    } catch (e) {
      return value.toString();
    }
  }

  static String _formatTimeOnly(dynamic value, BuildContext context) {
    try {
      // TimeOnly est généralement au format "HH:mm:ss"
      final parts = value.toString().split(':');
      final time = TimeOfDay(
        hour: int.parse(parts[0]), 
        minute: int.parse(parts[1])
      );
      return time.format(context);
    } catch (e) {
      return value.toString();
    }
  }
} 