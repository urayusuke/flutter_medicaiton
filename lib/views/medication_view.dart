import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_app/view_models/medication_view_model.dart';

class MedicationView extends ConsumerWidget {
  const MedicationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(medicationViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('薬一覧'),
      ),
      body: viewModel.when(
        data: (medications) => ListView(
          children: medications.map((medication) {
            return Dismissible(
                key: UniqueKey(),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  ref.read(medicationViewModelProvider.notifier).deleteMedication(medication.id);
                },
                child: ListTile(
                  title: Text(medication.name),
                  subtitle: Text(
                      '${medication.startDate} ~ ${medication.endDate} ${medication.timesPerDay} ${medication.dose} ${medication.timing} ${medication.type}'),
                  onTap: () {
                    context.go('/medication-detail/${medication.id}');
                  },
                ));
          }).toList(),
        ),
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            key: UniqueKey(),
            child: Icon(Icons.medication),
            onPressed: () {
              context.go('/medication-add-view');
            },
          ),
          FloatingActionButton(
            key: UniqueKey(),
            child: Icon(Icons.add),
            onPressed: () {
              context.go('/medication-detail');
            },
          ),
        ],
      )
    );
  }
}
