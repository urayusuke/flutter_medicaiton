import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../services/database_service.dart';

class MedicationAddView extends StatefulWidget {
  MedicationAddView({Key? key}) : super(key: key);

  @override
  _MedicationAddViewState createState() => _MedicationAddViewState();
}

class _MedicationAddViewState extends State<MedicationAddView> {
  final DatabaseService _databaseService = DatabaseService();
  late Future<List<Map<String, dynamic>>> _medicationsFuture;
  final Map<int, int> _dosesCount = {};
  final Map<int, int> _initialDosesCount = {};

  @override
  void initState() {
    super.initState();
    _medicationsFuture = _getMedications();
  }

  Future<List<Map<String, dynamic>>> _getMedications() async {
    final allMedications = await _databaseService.getMedications();
    final DateTime now = DateTime.now();

    final medications = allMedications!.where((medication) {
      final startDateStr = medication['startDate'];
      final endDateStr = medication['endDate'];

      if (startDateStr == null || endDateStr == null) {
        return false;
      }

      final startDate = DateTime.parse(medication['startDate'] as String);
      final endDate = DateTime.parse(medication['endDate'] as String);

      return startDate.isBefore(now) && endDate.isAfter(now);
    }).toList();

    for (final medication in medications) {
      final medicationId = medication['id'] as int;
      final initialDose =
          await _databaseService.getMedicationDose(medicationId);
      _initialDosesCount[medicationId] = initialDose ?? 0;
      _dosesCount[medicationId] = _initialDosesCount[medicationId]!;
    }

    return medications;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy年 MM月 dd 日').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('薬のカウント'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Center(
              child: Text(today),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _medicationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error occurred');
                } else {
                  final medications = snapshot.data!;
                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: medications.length,
                      itemBuilder: (context, index) {
                        final medication = medications[index];
                        final medicationId = medication['id'] as int;
                        final medicationDose = medication['dose'] as int;
                        final takenDoseCount = _dosesCount[medicationId]!;

                        return Container(
                          color: takenDoseCount == medicationDose
                              ? Colors.green
                              : null,
                          child: ListTile(
                            title: Text(medication['name']),
                            subtitle: Text('服用回数: ' +
                                medication['dose'].toString() +
                                ' 飲んだ回数: ' +
                                takenDoseCount.toString()),
                            leading: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: takenDoseCount > 0
                                  ? () {
                                      setState(() {
                                        _dosesCount[medicationId] =
                                            takenDoseCount - 1;
                                      });
                                    }
                                  : null,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: takenDoseCount < medicationDose
                                  ? () {
                                      setState(() {
                                        _dosesCount[medicationId] =
                                            takenDoseCount + 1;
                                      });
                                    }
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  for (final entry in _dosesCount.entries) {
                    if (_initialDosesCount[entry.key] != entry.value) {
                      final dose = {
                        'medicationId': entry.key,
                        'dose': entry.value,
                        'date': DateTime.now().toIso8601String(),
                      };
                      await _databaseService.insertOrUpdateMedicationDose(dose);
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('MedicationDoseが保存されました')),
                  );
                },
                child: Text('保存'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  context.go('/medication-calendar-view');
                },
                child: Text('カレンダーへ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
