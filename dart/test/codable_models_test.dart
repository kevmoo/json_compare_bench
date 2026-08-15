import 'dart:io';

import 'package:codable/codable.dart';
import 'package:json_compare_bench_dart/src/models/canada.dart';
import 'package:json_compare_bench_dart/src/models/citm_catalog.dart';
import 'package:json_compare_bench_dart/src/models/small.dart';
import 'package:json_compare_bench_dart/src/models/twitter.dart';
import 'package:test/test.dart';

void main() {
  group('Codable Models Roundtrip Verification', () {
    test('small.json decode and encode', () {
      final bytes = File('../data/small.json').readAsBytesSync();
      final reader = JsonTokenReader.fromBytes(bytes);
      final doc = SmallDocument.fromReader(reader);
      expect(doc.id, equals(1024859));
      expect(doc.name, equals('Kevin Moore'));
      expect(doc.metadata.location.city, equals('San Francisco'));

      final builder = BytesBuilder(copy: false);
      final writer = JsonTokenWriter.toSink(builder);
      doc.toWriter(writer);
      final outBytes = builder.toBytes();
      expect(outBytes.length, greaterThan(0));

      final reader2 = JsonTokenReader.fromBytes(outBytes);
      final doc2 = SmallDocument.fromReader(reader2);
      expect(doc2.id, equals(doc.id));
      expect(doc2.name, equals(doc.name));
    });

    test('twitter.json decode and encode', () {
      final bytes = File('../data/twitter.json').readAsBytesSync();
      final reader = JsonTokenReader.fromBytes(bytes);
      final resp = TwitterResponse.fromReader(reader);
      expect(resp.statuses.length, equals(100));
      expect(resp.statuses.first.id, equals(505874924095815700));

      final builder = BytesBuilder(copy: false);
      final writer = JsonTokenWriter.toSink(builder);
      resp.toWriter(writer);
      final outBytes = builder.toBytes();
      expect(outBytes.length, greaterThan(0));

      final reader2 = JsonTokenReader.fromBytes(outBytes);
      final resp2 = TwitterResponse.fromReader(reader2);
      expect(resp2.statuses.length, equals(100));
      expect(resp2.statuses.first.id, equals(resp.statuses.first.id));
    });

    test('canada.json decode and encode', () {
      final bytes = File('../data/canada.json').readAsBytesSync();
      final reader = JsonTokenReader.fromBytes(bytes);
      final fc = CanadaFeatureCollection.fromReader(reader);
      expect(fc.type, equals('FeatureCollection'));
      expect(fc.features.length, greaterThan(0));

      final builder = BytesBuilder(copy: false);
      final writer = JsonTokenWriter.toSink(builder);
      fc.toWriter(writer);
      final outBytes = builder.toBytes();
      expect(outBytes.length, greaterThan(0));
    });

    test('citm_catalog.json decode and encode', () {
      final bytes = File('../data/citm_catalog.json').readAsBytesSync();
      final reader = JsonTokenReader.fromBytes(bytes);
      final catalog = CitmCatalog.fromReader(reader);
      expect(catalog.events.length, greaterThan(0));
      expect(catalog.performances.length, greaterThan(0));

      final builder = BytesBuilder(copy: false);
      final writer = JsonTokenWriter.toSink(builder);
      catalog.toWriter(writer);
      final outBytes = builder.toBytes();
      expect(outBytes.length, greaterThan(0));
    });
  });
}
