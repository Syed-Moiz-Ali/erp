import 'package:drift/drift.dart';

@DataClassName('AppNotificationData')
class AppNotifications extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get priority => text().withDefault(const Constant('normal'))();
  TextColumn get source => text().withDefault(const Constant('local'))();
  TextColumn get route => text().nullable()();
  TextColumn get dedupeKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}
