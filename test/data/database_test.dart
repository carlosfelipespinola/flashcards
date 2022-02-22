import 'dart:convert';

import 'package:flashcards/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var dbProvider = DatabaseProvider(test: true);
  test('save and load simple string using dbProvider.sharedPreferences should work ...', () async {
    final prefs = await dbProvider.sharedPreferences;
    final key = 'key';
    final data = 'simplestring';
    await prefs.save(key, data);
    expect(await prefs.load(key), data);
  });

  test('save and load json string using dbProvider.sharedPreferences should work ...', () async {
    final prefs = await dbProvider.sharedPreferences;
    final key = 'key';
    final map = {'some': 'json', 'number': 10};
    final encodedData = jsonEncode(map);
    await prefs.save(key, encodedData);
    final loadedData = await prefs.load(key);
    final decodedData = jsonDecode(loadedData!) as Map;
    expect(decodedData, map);
  });


  test('save string with existing key using dbProvider.sharedPreferences should update previous value ...', () async {
    final prefs = await dbProvider.sharedPreferences;
    final key = 'key';
    final data = 'simplestring';
    await prefs.save(key, data);
    expect(await prefs.load(key), data);
    final updated  = 'updated';
    await prefs.save(key, updated);
    expect(await prefs.load(key), updated);
  });

  test('load unexisting key using dbProvider.sharedPreferences.load should return null ...', () async {
    final prefs = await dbProvider.sharedPreferences;
    final key = 'unexisting_key';
    expect(await prefs.load(key), null);
  });
}