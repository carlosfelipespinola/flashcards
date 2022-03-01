import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:path/path.dart';

void main() {
  test('all arb files must have the same keys ...', () async {
    final l10nDir = Directory(join(Directory.current.path, 'lib', 'l10n'));
    final files = l10nDir.listSync();
    final keysOfEachArb = files.map((fileSystem) {
      final file = File(fileSystem.path); 
      final fileContent = file.readAsStringSync();
      final map = jsonDecode(fileContent) as Map<String, dynamic>;
      return Set.from(map.keys);
    });
    final baseKeys = keysOfEachArb.first.toSet();
    final unionKeys = keysOfEachArb.reduce((value, element) => value.union(element));
    expect(unionKeys.difference(baseKeys), Set.from([]));
    expect(baseKeys.difference(unionKeys), Set.from([]));
  });
}