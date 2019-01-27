// To parse this JSON data, do
//
//     final ticketInfo = ticketInfoFromJson(jsonString);

import 'dart:convert';

List<TicketInfo> ticketInfoFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<TicketInfo>.from(jsonData.map((x) => TicketInfo.fromJson(x)));
}

String ticketInfoToJson(List<TicketInfo> data) {
  final dyn = new List<dynamic>.from(data.map((x) => x.toJson()));
  return json.encode(dyn);
}

class TicketInfo {
  Data data;
  Additional additional;

  TicketInfo({
    this.data,
    this.additional,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) => new TicketInfo(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    additional: json["additional"] == null ? null : Additional.fromJson(json["additional"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : data.toJson(),
    "additional": additional == null ? null : additional.toJson(),
  };
}

class Additional {
  int resultsCount;
  double executionTime;

  Additional({
    this.resultsCount,
    this.executionTime,
  });

  factory Additional.fromJson(Map<String, dynamic> json) => new Additional(
    resultsCount: json["results_count"],
    executionTime: json["execution_time"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "results_count": resultsCount,
    "execution_time": executionTime,
  };
}

class Data {
  String dateChecked;
  String paymentDate;
  String transactionId;
  String checksum;
  String buyerFirst;
  String buyerLast;
  List<dynamic> customFields;
  int customFieldCount;
  int allowedCheckins;

  Data({
    this.dateChecked,
    this.paymentDate,
    this.transactionId,
    this.checksum,
    this.buyerFirst,
    this.buyerLast,
    this.customFields,
    this.customFieldCount,
    this.allowedCheckins,
  });

  factory Data.fromJson(Map<String, dynamic> json) => new Data(
    dateChecked: json["date_checked"],
    paymentDate: json["payment_date"],
    transactionId: json["transaction_id"],
    checksum: json["checksum"],
    buyerFirst: json["buyer_first"],
    buyerLast: json["buyer_last"],
    customFields: json["custom_fields"],
    customFieldCount: json["custom_field_count"],
    allowedCheckins: json["allowed_checkins"],
  );

  Map<String, dynamic> toJson() => {
    "date_checked": dateChecked,
    "payment_date": paymentDate,
    "transaction_id": transactionId,
    "checksum": checksum,
    "buyer_first": buyerFirst,
    "buyer_last": buyerLast,
    "custom_fields": customFields,
    "custom_field_count": customFieldCount,
    "allowed_checkins": allowedCheckins,
  };
}
