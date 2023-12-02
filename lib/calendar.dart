import 'package:calendario2/database/Event_dao.dart';
import 'package:calendario2/eventos.dart';
import 'package:calendario2/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class TableEventsExample extends StatefulWidget {
  const TableEventsExample({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final eventDao = EventDao();
  Map<DateTime, List<Event>> events = {};
  final TextEditingController _eventController = TextEditingController();
  List<EventModel> users = [];
  final dao = EventDao();
  // final LinkedHashMap<DateTime , List<EventModel>> resolver = LinkedHashMap();

  @override
  void initState() {
    super.initState();
    dao.getall().then((value) {
      setState(() {
        users = value;
        final eventT = users;
        for (var element in eventT) {
          if (!events.containsKey(element.date)) {
            events[element.date] = [];
          }
          final obj =
              eventT.where((objeto) => objeto.date == element.date).toList();
          events.addAll(
              {element.date: obj.map((e) => Event(e.name, e.id)).toList()});
        }
      });
    });

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    if (events.containsKey(day)) {
      // ignore: avoid_print
      print({'events': day});
    }
    return events[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario-Eventos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: const Text("Nombre del evento"),
                content: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _eventController,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      // Obtén el día seleccionado
                      DateTime selectedDay = _selectedDay ?? _focusedDay;

                      // Verifica si ya existen eventos para el día seleccionado
                      // if (events.containsKey(selectedDay)) {
                      //   // Agrega el nuevo evento a la lista existente
                      // }
                      EventModel event = EventModel(
                          name: _eventController.text, date: selectedDay);
                      await eventDao.insert(event);
                      _eventController.clear();

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      dao.getall().then((value) {
                        setState(() {
                          users = value;
                          final eventT = users;
                          for (var element in eventT) {
                            if (!events.containsKey(element.date)) {
                              events[element.date] = [];
                            }
                            final obj = eventT
                                .where((objeto) => objeto.date == element.date)
                                .toList();
                            events.addAll({
                              element.date:
                                  obj.map((e) => Event(e.name, e.id)).toList()
                            });
                          }
                        });
                      });
                    },
                    child: const Text("Agregar"),
                  )
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 4, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        // ignore: avoid_print
                        onTap: () => print('${value[index]}'),
                        title: Text('${value[index]}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Eliminar el evento
                            await eventDao.delete(value[index].id);
                            _deleteEvent(value[index]);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteEvent(Event event) {
    DateTime selectedDay = _selectedDay ?? _focusedDay;
    if (events.containsKey(selectedDay)) {
      // Elimina el evento de la lista
      events[selectedDay]!.remove(event);
      // Si la lista de eventos está vacía, elimina la entrada del día
      if (events[selectedDay]!.isEmpty) {
        events.remove(selectedDay);
      }
      // Actualiza la lista de eventos seleccionados
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  daysInRange(DateTime start, DateTime end) {}
}
