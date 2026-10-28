class AttendanceDay {
  const AttendanceDay(this.raw);
  final Map<String, dynamic> raw;

  int get employeeId => (raw['employeeId'] as num?)?.toInt() ?? 0;
  String get date => raw['date'] as String? ?? '';
  String get timeZone => raw['timeZone'] as String? ?? '';
  String get state => raw['state'] as String? ?? 'noShift';
  List<String> get allowedActions =>
      ((raw['allowedActions'] as List?) ?? const [])
          .map((value) => '$value')
          .toList(growable: false);
  int get workedMinutes => (raw['workedMinutes'] as num?)?.toInt() ?? 0;
  int get breakMinutes => (raw['breakMinutes'] as num?)?.toInt() ?? 0;
  String get serverTime => raw['serverTime'] as String? ?? '';
  List<AttendanceShift> get shifts => [
    for (final item in (raw['shifts'] as List? ?? const []))
      if (item is Map)
        AttendanceShift(item.cast<String, dynamic>()),
  ];
}

class AttendanceShift {
  const AttendanceShift(this.raw);
  final Map<String, dynamic> raw;

  int get shiftNo => (raw['shiftNo'] as num?)?.toInt() ?? 0;
  String get shiftName => raw['shiftName'] as String? ?? '';
  String get shiftDate => raw['shiftDate'] as String? ?? '';
  String get plannedStart => raw['plannedStart'] as String? ?? '';
  String get plannedEnd => raw['plannedEnd'] as String? ?? '';
  String get status => raw['status'] as String? ?? '';
  String? get punchIn => raw['punchIn'] as String?;
  String? get punchOut => raw['punchOut'] as String?;
  int get lateMinutes => (raw['lateMinutes'] as num?)?.toInt() ?? 0;
  int get workedMinutes => (raw['workedMinutes'] as num?)?.toInt() ?? 0;
  int get breakMinutes => (raw['breakMinutes'] as num?)?.toInt() ?? 0;
  bool get crossesMidnight => raw['crossesMidnight'] as bool? ?? false;
}


