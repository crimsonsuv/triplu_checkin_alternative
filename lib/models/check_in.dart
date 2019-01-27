// To parse this JSON data, do
//
//     final checkIn = checkInFromJson(jsonString);

import 'dart:convert';

CheckIn checkInFromJson(String str) {
  final jsonData = json.decode(str);
  return CheckIn.fromJson(jsonData);
}

String checkInToJson(CheckIn data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class CheckIn {
  bool status;
  String previousStatus;
  bool pass;
  String name;
  String paymentDate;
  String address;
  String city;
  String state;
  String country;
  String checksum;
  List<List<String>> customFields;

  CheckIn({
    this.status,
    this.previousStatus,
    this.pass,
    this.name,
    this.paymentDate,
    this.address,
    this.city,
    this.state,
    this.country,
    this.checksum,
    this.customFields,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) => new CheckIn(
    status: json["status"],
    previousStatus: json["previous_status"],
    pass: json["pass"],
    name: json["name"],
    paymentDate: json["payment_date"],
    address: json["address"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    checksum: json["checksum"],
    customFields: new List<List<String>>.from(json["custom_fields"].map((x) => new List<String>.from(x.map((x) => x)))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "previous_status": previousStatus,
    "pass": pass,
    "name": name,
    "payment_date": paymentDate,
    "address": address,
    "city": city,
    "state": state,
    "country": country,
    "checksum": checksum,
    "custom_fields": new List<dynamic>.from(customFields.map((x) => new List<dynamic>.from(x.map((x) => x)))),
  };
}
