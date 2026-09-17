enum ConfigurationStatus { active, inactive }

enum RecordSyncStatus { synced, pending, failed }

abstract interface class ConfigurationRecord {
  String get id;
  String get companyId;
  String get name;
  ConfigurationStatus get status;
  RecordSyncStatus get syncStatus;
  DateTime get createdAt;
  DateTime get updatedAt;
  Map<String, dynamic> toJson();
}

class ConfigurationItem<T extends ConfigurationRecord> {
  const ConfigurationItem(this.record, this.assignedEmployees);
  final T record;
  final int assignedEmployees;
}

class ConfigurationPageData<T extends ConfigurationRecord> {
  ConfigurationPageData(
    List<ConfigurationItem<T>> items,
    this.total,
    this.filtered,
  ) : items = List.unmodifiable(items);
  final List<ConfigurationItem<T>> items;
  final int total, filtered;
}
