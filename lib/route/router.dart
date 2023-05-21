import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medication_app/views/medication_add_view.dart';
import 'package:medication_app/views/medication_calendar_view.dart';
import 'package:medication_app/views/medication_view.dart';
import 'package:medication_app/views/medication_details_view.dart';

class Routes {
  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            MaterialPage(child: MedicationView()),
      ),
      GoRoute(
        path: '/medication-detail',
        pageBuilder: (context, state) => 
        MaterialPage(
          child: MedicationDetailView()
          ),
      ),
      GoRoute(
        path: '/medication-detail/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialPage(
            child: MedicationDetailView(id: id)
          );
        },
      ),
      GoRoute(
        path: '/medication-add-view',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: MedicationAddView()
          );
        },
      ),
      GoRoute(
        path: '/medication-calendar-view',
        pageBuilder: (context, state) {
          return MaterialPage(
            child: MedicationCalendarView()
          );
        },
      ),
  ]);

  static GoRouter get router => _router;
}
