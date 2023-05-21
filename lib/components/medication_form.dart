import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class MedicationForm extends StatefulWidget {
  final String? id;
  const MedicationForm({Key? key, this.id}) : super(key: key);

  @override
  _MedicationFormState createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  DatabaseService dbService = DatabaseService();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _timing;
  String? _medicationType;
  final _medicationNameController = TextEditingController();
  final _timesPerDayController = TextEditingController();
  final _doseController = TextEditingController();
  
  Future<void> _loadMedicationDetails() async {
    if (widget.id != null) {
      final medication = await dbService.getMedicationById(widget.id!);
      if (medication != null) {
        setState(() {
          _medicationNameController.text = medication['name'];
          _startDate = DateTime.parse(medication['startDate']);
          _endDate = DateTime.parse(medication['endDate']);
          _timesPerDayController.text = medication['timesPerDay'].toString();
          _doseController.text = medication['dose'].toString();
          _timing = medication['timing'];
          _medicationType = medication['type'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMedicationDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _medicationNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '薬名',
                  ),
                ),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: _startDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(_startDate!)),
                  decoration: InputDecoration(labelText: '服用開始日'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                      });
                    }
                  },
                ),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: _endDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(_endDate!)),
                  decoration: InputDecoration(labelText: '服用終了日'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate:
                          _startDate ?? DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                      });
                    }
                  },
                ),
                TextFormField(
                  controller: _timesPerDayController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '服用回数',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '数字を入力してください';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _doseController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '服用量',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '数字を入力してください';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '服用タイミング',
                  ),
                  value: _timing,
                  onChanged: (String? newValue) {
                    setState(() {
                      _timing = newValue;
                    });
                  },
                  items: <String>['毎食後', '食間', '就寝前', 'その他']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '薬の種類',
                  ),
                  value: _medicationType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _medicationType = newValue;
                    });
                  },
                  items: <String>['錠剤', '粉末', '塗り薬', 'その他']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                        Map<String, dynamic> medication = {
                          'name': _medicationNameController.text,
                          'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
                          'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
                          'timesPerDay': int.parse(_timesPerDayController.text),
                          'dose': int.parse(_doseController.text),
                          'timing': _timing!,
                          'type': _medicationType!,
                          'id': widget.id,
                        };
                        await dbService.saveMedication(medication);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('保存しました')),
                        );
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          );
  }
}
