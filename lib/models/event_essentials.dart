// To parse this JSON data, do
//
//     final eventEssentials = eventEssentialsFromJson(jsonString);

import 'dart:convert';

EventEssentials eventEssentialsFromJson(String str) {
  final jsonData = json.decode(str);
  return EventEssentials.fromJson(jsonData);
}

String eventEssentialsToJson(EventEssentials data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class EventEssentials {
  String eventName;
  String eventDateTime;
  String eventLocation;
  int soldTickets;
  int checkedTickets;
  double executionTime;
  bool pass;

  EventEssentials({
    this.eventName,
    this.eventDateTime,
    this.eventLocation,
    this.soldTickets,
    this.checkedTickets,
    this.executionTime,
    this.pass,
  });

  factory EventEssentials.fromJson(Map<String, dynamic> json) => new EventEssentials(
    eventName: json["event_name"],
    eventDateTime: json["event_date_time"],
    eventLocation: json["event_location"],
    soldTickets: json["sold_tickets"],
    checkedTickets: json["checked_tickets"],
    executionTime: json["execution_time"].toDouble(),
    pass: json["pass"],
  );

  Map<String, dynamic> toJson() => {
    "event_name": eventName,
    "event_date_time": eventDateTime,
    "event_location": eventLocation,
    "sold_tickets": soldTickets,
    "checked_tickets": checkedTickets,
    "execution_time": executionTime,
    "pass": pass,
  };
}
