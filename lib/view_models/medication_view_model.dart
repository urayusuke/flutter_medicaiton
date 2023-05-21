import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication_app/services/database_service.dart';
import 'package:medication_app/models/medication.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final medicationViewModelProvider = StateNotifierProvider<MedicationViewModel, AsyncValue<List<Medication>>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return MedicationViewModel(databaseService: databaseService);
});

class MedicationViewModel extends StateNotifier<AsyncValue<List<Medication>>> {
  final DatabaseService databaseService;

  MedicationViewModel({required this.databaseService}) : super(AsyncValue.loading()) {
    getMedications();
  }

  Future<void> getMedications() async {
    try {
      final medsData = await databaseService.getMedications();
      final meds = medsData!.map((medMap) => Medication.fromMap(medMap)).toList();
      state = AsyncValue.data(meds);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteMedication(int id) async {
    await databaseService.deleteMedication(id);
    getMedications(); // refresh the medications
  }
}
