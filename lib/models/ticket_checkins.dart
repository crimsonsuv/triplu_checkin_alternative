// To parse this JSON data, do
//
//     final ticketCheckins = ticketCheckinsFromJson(jsonString);

import 'dart:convert';

List<TicketCheckins> ticketCheckinsFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<TicketCheckins>.from(jsonData.map((x) => TicketCheckins.fromJson(x)));
}

String ticketCheckinsToJson(List<TicketCheckins> data) {
  final dyn = new List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class TicketCheckins {
  Data data;

  TicketCheckins({
    this.data,
  });

  factory TicketCheckins.fromJson(Map<String, dynamic> json) => new TicketCheckins(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
  };
}

class Data {
  String dateChecked;
  String status;

  Data({
    this.dateChecked,
    this.status,
  });

  factory Data.fromJson(Map<String, dynamic> json) => new Data(
    dateChecked: json["date_checked"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "date_checked": dateChecked,
    "status": status,
  };
}
