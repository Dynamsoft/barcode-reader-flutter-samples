import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';

/// Builds a human-readable GS1 message from the AI (Application Identifier)
/// fields contained in [item].
///
/// For every AI field found in [item.parsedFields], the matching "AI" and
/// "Data" entries are combined into a single line in the form
/// "aiDescription: aiData". Fields whose data failed validation are skipped.
/// If the AI description indicates a date (contains "date", case-insensitive),
/// the raw digits are formatted via [_parseDateAndTimeString].
String buildGS1Message(ParsedResultItem item) {
  final fields = item.parsedFields;
  final List<String> contents = [];

  for (final fieldName in fields.keys) {
    if (!_isAI(fieldName)) continue;
    if (fields['${fieldName}Data']?.validationStatus ==
        EnumValidationStatus.failed) {
      continue;
    }

    final aiDescription = fields['${fieldName}AI']?.value;
    String? aiData = fields['${fieldName}Data']?.value;
    if (aiDescription != null && aiDescription.toLowerCase().contains('date')) {
      aiData = _parseDateAndTimeString(aiData);
    }
    if (aiData != null) {
      contents.add('$aiDescription: $aiData');
    }
  }

  return contents.join('\n');
}

bool _isAI(String? str) {
  return str != null && RegExp(r'^\d{2,4}$').hasMatch(str);
}

/// Supported input formats:
/// - yyMMdd (6 digits): Returns a date in the format "yy/MM/dd".
/// - yyMMddHHmm (10 digits): Returns a date and time in the format "yy/MM/dd HH:mm".
/// - yyMMddHHmmss (12 digits): Returns a date and time in the format "yy/MM/dd HH:mm:ss".
///
/// Returns null if [dateStr] does not match any of the supported formats.
String? _parseDateAndTimeString(String? dateStr) {
  final validPattern = RegExp(r'^(\d{6}|\d{10}|\d{12})$');
  if (dateStr == null || dateStr.isEmpty || !validPattern.hasMatch(dateStr)) {
    return null;
  }

  final length = dateStr.length;
  final year = 2000 + int.parse(dateStr.substring(0, 2));
  final month = int.parse(dateStr.substring(2, 4));
  var day = int.parse(dateStr.substring(4, 6));

  // Handle day=0 -> last day of the month.
  if (day == 0) {
    day = DateTime(year, month + 1, 0).day;
  }

  var hour = 0, minute = 0, second = 0;
  if (length >= 10) {
    hour = int.parse(dateStr.substring(6, 8));
    minute = int.parse(dateStr.substring(8, 10));
    if (length == 12) {
      second = int.parse(dateStr.substring(10, 12));
    }
  }

  final date = DateTime(year, month, day, hour, minute, second);
  final yy = (date.year % 100).toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');

  if (length == 6) {
    return '$yy/$mm/$dd';
  }

  final hh = date.hour.toString().padLeft(2, '0');
  final mi = date.minute.toString().padLeft(2, '0');
  if (length == 10) {
    return '$yy/$mm/$dd $hh:$mi';
  }

  final ss = date.second.toString().padLeft(2, '0');
  return '$yy/$mm/$dd $hh:$mi:$ss';
}