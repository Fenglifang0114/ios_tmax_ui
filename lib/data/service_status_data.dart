import 'dart:convert';

ServiceAction serviceActionFromJson(String str) =>
    ServiceAction.fromJson(json.decode(str));

String serviceActionToJson(ServiceAction data) => json.encode(data.toJson());

class ServiceAction {
  String action;
  int serviceId;

  ServiceAction({
    required this.action,
    required this.serviceId,
  });

  factory ServiceAction.fromJson(Map<String, dynamic> json) => ServiceAction(
        action: json["Action"],
        serviceId: json["ServiceId"],
      );

  Map<String, dynamic> toJson() => {
        "Action": action,
        "ServiceId": serviceId,
      };
}
