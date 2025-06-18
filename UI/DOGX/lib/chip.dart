import 'dart:convert';

import 'package:programmer/register.dart';

class Chip {
  String nameId = "";
  bool selected = false;
  List<Register> registers = [];

  Chip({this.nameId = "",this.selected = false , required this.registers});

  factory Chip.fromJson(Map<String, dynamic> json) {

    List<Register> rs = (json['registers'] as List<dynamic>).map((e) => Register.fromJson(e)).toList();

    return Chip(
      nameId: json['nameId'],
      selected: json['selected'],
      registers: rs
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'nameId': nameId,
      'selected': selected,
      'registers': registers.map((r) => r.toJson()).toList()
    };
  }

}

