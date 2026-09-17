import 'package:modular_erp/core/preferences/app_preferences_repository.dart';

/// Same persistence contract as the device adapter; reused across app restarts.
class MemoryPreferences implements AppPreferencesLocalDataSource {
  MemoryPreferences({this.code});
  String? code;
  bool? sidebarCollapsed;
  @override
  Future<bool?> readSidebarCollapsed() async {
    if (failReads) throw StateError("read");
    return sidebarCollapsed;
  }

  @override
  Future<void> writeSidebarCollapsed(bool value) async {
    if (failWrites) throw StateError("write");
    sidebarCollapsed = value;
  }

  bool failReads = false;
  bool failWrites = false;
  final List<String> writes = [];

  @override
  Future<String?> readLanguageCode() async {
    if (failReads) throw StateError('Test storage read failure');
    return code;
  }

  @override
  Future<void> writeLanguageCode(String code) async {
    if (failWrites) throw StateError('Test storage write failure');
    writes.add(code);
    this.code = code;
  }
}
