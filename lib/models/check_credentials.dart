// To parse this JSON data, do
//
//     final checkCredentials = checkCredentialsFromJson(jsonString);
import 'package:flutter/material.dart';
import 'dart:convert';

CheckCredentials checkCredentialsFromJson(String str) {
  final jsonData = json.decode(str);
  return CheckCredentials.fromJson(jsonData);
}

String checkCredentialsToJson(CheckCredentials data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class CheckCredentials {
  bool pass;

  CheckCredentials({
    this.pass,
  });

  factory CheckCredentials.fromJson(Map<String, dynamic> json) => new CheckCredentials(
    pass: json["pass"],
  );

  Map<String, dynamic> toJson() => {
    "pass": pass,
  };
}
