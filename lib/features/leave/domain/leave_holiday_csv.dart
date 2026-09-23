import 'leave_models.dart';

const List<String> holidayCsvColumns = [
  'name',
  'date',
  'enddate',
  'type',
  'optional',
  'scope',
  'worklocations',
  'description',
  'countrycode',
  'regioncode',
];

/// Parses pasted CSV into holiday import rows. Purely structural — duplicate
/// and scope validation against the company happens in the repository so the
/// parser stays deterministic and dependency-free.
List<HolidayImportRow> parseHolidayCsv(String content) {
  final lines = content
      .split(RegExp(r'\r?\n'))
      .where((line) => line.trim().isNotEmpty)
      .toList();
  if (lines.isEmpty) return const [];

  final first = _split(lines.first).map((c) => c.trim().toLowerCase()).toList();
  final hasHeader = first.isNotEmpty && first.first == 'name';
  final header = hasHeader ? first : holidayCsvColumns;
  final startIndex = hasHeader ? 1 : 0;

  final rows = <HolidayImportRow>[];
  for (var i = startIndex; i < lines.length; i++) {
    final cells = _split(lines[i]);
    final map = <String, String>{};
    for (var j = 0; j < header.length && j < cells.length; j++) {
      map[header[j]] = cells[j].trim();
    }
    rows.add(_rowFrom(map));
  }
  return rows;
}

HolidayImportRow _rowFrom(Map<String, String> map) {
  try {
    final name = map['name'] ?? '';
    if (name.isEmpty) throw 'missingName';
    final date = _parseDate(map['date'] ?? '');
    if (date == null) throw 'invalidDate';
    final endRaw = map['enddate'] ?? '';
    final endDate = endRaw.isEmpty ? null : _parseDate(endRaw);
    if (endRaw.isNotEmpty && endDate == null) throw 'invalidEndDate';
    if (endDate != null && endDate.isBefore(date)) throw 'invalidDateRange';
    final locations = (map['worklocations'] ?? '')
        .split(RegExp(r'[;|]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    return HolidayImportRow(
      draft: HolidayDraft(
        name: name,
        date: date,
        endDate: endDate,
        type: _typeFrom(map['type']),
        isOptional: _boolFrom(map['optional']),
        scope: locations.isEmpty
            ? HolidayScope.companyWide
            : HolidayScope.specificWorkLocations,
        workLocationIds: locations,
        description: map['description'] ?? '',
        source: HolidaySource.imported,
        countryCode: _nullIfEmpty(map['countrycode']),
        regionCode: _nullIfEmpty(map['regioncode']),
      ),
    );
  } catch (error) {
    return HolidayImportRow(draft: const HolidayDraft(), error: '$error');
  }
}

List<String> _split(String line) => line.split(',');

String? _nullIfEmpty(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();

DateTime? _parseDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return null;
  return leaveDate(parsed);
}

HolidayType _typeFrom(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  for (final type in HolidayType.values) {
    if (type.name.toLowerCase() == normalized) return type;
  }
  return switch (normalized) {
    'government' || 'public' || 'national' => HolidayType.publicHoliday,
    'festival' || 'religious' => HolidayType.festivalHoliday,
    'regional' || 'state' => HolidayType.regionalHoliday,
    'company' => HolidayType.companyHoliday,
    'closure' || 'shutdown' => HolidayType.specialClosure,
    _ => HolidayType.companyHoliday,
  };
}

bool _boolFrom(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  return normalized == 'true' ||
      normalized == 'yes' ||
      normalized == 'y' ||
      normalized == '1';
}
