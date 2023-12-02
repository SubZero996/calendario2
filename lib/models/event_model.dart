import 'package:calendario2/common/util_event.dart';

class EventModel {
  final int id;
  final String name;
  final DateTime date;

  EventModel({this.id = -1, required this.name, required this.date});

  EventModel copyWith({int? id, String? name, DateTime? date}) {
    return EventModel(
        name: name ?? this.name, id: id ?? this.id, date: date ?? this.date);
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
        name: map['name'], id: map['id'], date: unixToDateTime(map['date']));
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'date': date};
}
