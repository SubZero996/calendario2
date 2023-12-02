import 'package:calendario2/common/util_event.dart';
import 'package:calendario2/database/database_helper.dart';
import 'package:calendario2/models/event_model.dart';

class EventDao {
  final database = DatabaseHelper.instance.db;

  Future<List<EventModel>> getall() async {
    final data = await database.query('eventos');
    return data.map((e) => EventModel.fromMap(e)).toList();
  }

  Future<int> insert(EventModel user) async {
    return await database
        .insert('eventos', {'name': user.name, 'date': dateToUnix(user.date)});
  }

  Future<void> update(EventModel user) async {
    await database
        .update('eventos', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> delete(int id) async {
    await database.delete('eventos', where: 'id = ?', whereArgs: [id]);
  }
}
