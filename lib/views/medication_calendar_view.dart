import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/database_service.dart';

class MedicationCalendarView extends StatefulWidget {
  const MedicationCalendarView({super.key});

  @override
  _MedicationCalendarViewState createState() => _MedicationCalendarViewState();
}

class _MedicationCalendarViewState extends State<MedicationCalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List> _medicationDoses = {};
  DatabaseService dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _fetchMedicationDoses();
  }

  Future<void> _fetchMedicationDoses() async {
    final startOfDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final doses =
        await dbService.getMedicationDosesBetween(startOfDay, endOfDay);

    Map<DateTime, List> temp = {};
    for (var dose in doses) {
      final date = DateTime.parse(dose['date']);
      final dateKey = DateTime(date.year, date.month, date.day);

      if (temp[dateKey] == null) {
        temp[dateKey] = [dose];
      } else {
        temp[dateKey]!.add(dose);
      }
    }

    setState(() {
      _medicationDoses = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/medication-add-view');
          },
        ),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
  onDaySelected: (selectedDay, focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    await _fetchMedicationDoses();

    var dayKey = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    var doses = _medicationDoses[dayKey] ?? [];

    if (doses.isNotEmpty) {
      List<Map<String, dynamic>> medications = [];
      for (var dose in doses) {
        String medicationId = dose['medicationId'].toString();
        var medication = await dbService.getMedicationById(medicationId);
        medications.add(medication!);
      }

showDialog(
  context: context,
  builder: (context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("飲んだ回数"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: doses.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('薬の名前: ${medications[index]['name'] ?? 'Unknown'}'),
                  subtitle: Text('飲んだ回数: ${doses.length}'),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('更新'),
              onPressed: () async {
                await _fetchMedicationDoses();

                var dayKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                doses = _medicationDoses[dayKey] ?? [];
                medications = [];
                for (var dose in doses) {
                  String medicationId = dose['medicationId'].toString();
                  var medication = await dbService.getMedicationById(medicationId);
                  medications.add(medication!);
                }
                setState(() {});
              },
            ),
            TextButton(
              child: Text('閉じる'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  },
);




    }
  }
},


        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });

          _fetchMedicationDoses();
        },
        eventLoader: (day) {
          var dayKey = DateTime(day.year, day.month, day.day);
          return _medicationDoses[dayKey] ?? [];
        },
        calendarStyle: CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _markerColor(events.length),
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Color _markerColor(int eventCount) {
    switch (eventCount) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
