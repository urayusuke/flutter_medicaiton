class Medication {
  final int id;
  final String name;
  final String startDate;
  final String endDate;
  final int timesPerDay;
  final int dose;
  final String timing;
  final String type;

  Medication({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.timesPerDay,
    required this.dose,
    required this.timing,
    required this.type,
  });

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as int,
      name: map['name'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      timesPerDay: map['timesPerDay'] as int,
      dose: map['dose'] as int,
      timing: map['timing'] as String,
      type: map['type'] as String,
    );
  }
}
