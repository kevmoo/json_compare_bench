import 'dart:convert';
import 'dart:io';

import 'package:codable/codable_json.dart';
import 'package:json_compare_bench_dart/src/models/canada.dart';
import 'package:json_compare_bench_dart/src/models/citm_catalog.dart';
import 'package:json_compare_bench_dart/src/models/json_serializable/canada.dart'
    as js_canada;
import 'package:json_compare_bench_dart/src/models/json_serializable/citm_catalog.dart'
    as js_citm;
import 'package:json_compare_bench_dart/src/models/json_serializable/small.dart'
    as js_small;
import 'package:json_compare_bench_dart/src/models/json_serializable/twitter.dart'
    as js_twitter;
import 'package:json_compare_bench_dart/src/models/small.dart';
import 'package:json_compare_bench_dart/src/models/twitter.dart';
import 'package:test/test.dart';

final _utf8JsonDecoder = utf8.decoder.fuse(json.decoder);
final _utf8JsonEncoder = json.encoder.fuse(utf8.encoder);

void main() {
  group('Codable & json_serializable Models Roundtrip Verification', () {
    test('small.json decode and encode', () {
      final bytes = File('../data/small.json').readAsBytesSync();
      final doc = SmallDocument.decode(JsonCodableDecoder.fromBytes(bytes));
      expect(doc.id, equals(1024859));
      expect(doc.name, equals('Kevin Moore'));
      expect(doc.metadata.location.city, equals('San Francisco'));

      final outBytes = JsonCodableEncoder.toBytes(doc.encode);
      expect(outBytes.length, greaterThan(0));

      final doc2 = SmallDocument.decode(JsonCodableDecoder.fromBytes(outBytes));
      expect(doc2.id, equals(doc.id));
      expect(doc2.name, equals(doc.name));

      final jsDoc = js_small.SmallDocument.fromJson(
        _utf8JsonDecoder.convert(bytes) as Map<String, dynamic>,
      );
      expect(jsDoc.id, equals(doc.id));
      final jsOut = _utf8JsonEncoder.convert(jsDoc.toJson());
      expect(jsOut.length, greaterThan(0));
    });

    test('twitter.json decode and encode', () {
      final bytes = File('../data/twitter.json').readAsBytesSync();
      final resp = TwitterResponse.decode(JsonCodableDecoder.fromBytes(bytes));
      expect(resp.statuses.length, equals(100));
      expect(resp.statuses.first.id, equals(505874924095815700));

      final outBytes = JsonCodableEncoder.toBytes(resp.encode);
      expect(outBytes.length, greaterThan(0));

      final resp2 = TwitterResponse.decode(
        JsonCodableDecoder.fromBytes(outBytes),
      );
      expect(resp2.statuses.length, equals(100));
      expect(resp2.statuses.first.id, equals(resp.statuses.first.id));

      final jsResp = js_twitter.TwitterResponse.fromJson(
        _utf8JsonDecoder.convert(bytes) as Map<String, dynamic>,
      );
      expect(jsResp.statuses.length, equals(100));
      final jsOut = _utf8JsonEncoder.convert(jsResp.toJson());
      expect(jsOut.length, greaterThan(0));
    });

    test('canada.json decode and encode', () {
      final bytes = File('../data/canada.json').readAsBytesSync();
      final fc = CanadaFeatureCollection.decode(
        JsonCodableDecoder.fromBytes(bytes),
      );
      expect(fc.type, equals('FeatureCollection'));
      expect(fc.features.length, greaterThan(0));

      final outBytes = JsonCodableEncoder.toBytes(fc.encode);
      expect(outBytes.length, greaterThan(0));

      final jsFc = js_canada.CanadaFeatureCollection.fromJson(
        _utf8JsonDecoder.convert(bytes) as Map<String, dynamic>,
      );
      expect(jsFc.type, equals('FeatureCollection'));
      final jsOut = _utf8JsonEncoder.convert(jsFc.toJson());
      expect(jsOut.length, greaterThan(0));
    });

    test('citm_catalog.json decode and encode', () {
      final bytes = File('../data/citm_catalog.json').readAsBytesSync();
      final catalog = CitmCatalog.decode(JsonCodableDecoder.fromBytes(bytes));
      expect(catalog.events.length, greaterThan(0));
      expect(catalog.performances.length, greaterThan(0));

      final outBytes = JsonCodableEncoder.toBytes(catalog.encode);
      expect(outBytes.length, greaterThan(0));

      final jsCatalog = js_citm.CitmCatalog.fromJson(
        _utf8JsonDecoder.convert(bytes) as Map<String, dynamic>,
      );
      expect(jsCatalog.events.length, equals(catalog.events.length));
      final jsOut = _utf8JsonEncoder.convert(jsCatalog.toJson());
      expect(jsOut.length, greaterThan(0));
    });
  });
}
