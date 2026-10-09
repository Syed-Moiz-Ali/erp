import 'package:flutter_test/flutter_test.dart';
import 'package:modular_erp/core/api/models/api_envelope.dart';
import 'package:modular_erp/core/api/models/api_error.dart';
import 'package:modular_erp/core/api/models/paged_result.dart';

class _Item {
  const _Item(this.id, this.name);
  final int id;
  final String name;
  factory _Item.fromJson(Map<String, dynamic> json) =>
      _Item(json['id'] as int, json['name'] as String);
}

void main() {
  test('ApiError round-trips through JSON', () {
    const error = ApiError(code: 'X', message: 'm', field: 'f');
    final json = error.toJson();
    expect(json, {'code': 'X', 'message': 'm', 'field': 'f'});
    expect(ApiError.fromJson(json), error);
  });

  test('ApiError field is optional', () {
    final error = ApiError.fromJson({'code': 'C', 'message': 'm'});
    expect(error.field, isNull);
  });

  test('ApiEnvelope parses a success envelope with typed data', () {
    final json = {
      'success': true,
      'message': 'ok',
      'data': {'id': 1},
      'errors': <dynamic>[],
    };
    final envelope = ApiEnvelope<Map<String, dynamic>>.fromJson(
      json,
      (value) => (value as Map).cast<String, dynamic>(),
    );
    expect(envelope.success, isTrue);
    expect(envelope.data, {'id': 1});
    expect(envelope.errors, isEmpty);
  });

  test('ApiEnvelope parses a failure envelope with null data', () {
    final json = {
      'success': false,
      'message': 'bad',
      'data': null,
      'errors': [
        {'code': 'E', 'message': 'm'},
      ],
    };
    final envelope = ApiEnvelope<Object?>.fromJson(json, (value) => value);
    expect(envelope.success, isFalse);
    expect(envelope.data, isNull);
    expect(envelope.errors.single.code, 'E');
  });

  test('ApiEnvelope throws on a missing success flag', () {
    expect(
      () => ApiEnvelope<Object?>.fromJson({'data': null}, (value) => value),
      throwsA(anything),
    );
  });

  test('PagedResult parses items with a nested fromJson', () {
    final json = {
      'items': [
        {'id': 1, 'name': 'a'},
        {'id': 2, 'name': 'b'},
      ],
      'page': 1,
      'pageSize': 25,
      'totalItems': 2,
      'totalPages': 1,
    };
    final page = PagedResult<_Item>.fromJson(
      json,
      (value) => _Item.fromJson((value as Map).cast<String, dynamic>()),
    );
    expect(page.items.length, 2);
    expect(page.items.first.name, 'a');
    expect(page.totalItems, 2);
    expect(page.isEmpty, isFalse);
    expect(page.hasMore, isFalse);
  });

  test('PagedResult reports more pages and emptiness', () {
    final page = PagedResult<_Item>(
      items: const [],
      page: 1,
      pageSize: 10,
      totalItems: 30,
      totalPages: 3,
    );
    expect(page.hasMore, isTrue);
    expect(page.isEmpty, isTrue);
  });
}
