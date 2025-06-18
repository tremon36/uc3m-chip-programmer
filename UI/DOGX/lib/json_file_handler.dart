import 'dart:convert';
import 'dart:io';

import 'package:programmer/register.dart';

import 'chip.dart';

class JsonFileHandler {

  static Future<void> writeChipsToJsonFile(List<Chip> list) async {
    // Convert list of Register objects to list of Maps
    List<Map<String, dynamic>> jsonList = list.map((chip) => chip.toJson()).toList();

    // Convert list of Maps to JSON string with pretty printing
    String jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);

    // Get the current directory
    Directory current = Directory.current;

    // Write JSON string to a file
    File file = File('${current.path}/chips.json');
    await file.writeAsString(jsonString, flush: true);
  }

  static Future<List<Chip>> readChipsFromJsonFile() async {
    Directory current = Directory.current;
    File file = File('${current.path}/chips.json');
    if (await file.exists()) {
      String jsonString = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Chip> list = jsonList.map((json) => Chip.fromJson(json)).toList();
      return list;
    } else {
      return [];
    }
  }
}
