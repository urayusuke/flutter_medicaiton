import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../components/medication_form.dart';
import '../services/database_service.dart';

class MedicationDetailView extends StatefulWidget {
  final String? id;
  const MedicationDetailView({Key? key, this.id}) : super(key: key);

  @override
  _MedicationDetailViewState createState() =>
      _MedicationDetailViewState();
}

class _MedicationDetailViewState extends State<MedicationDetailView> {  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MedicationDetails'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/');
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
                child: Center(
          child: MedicationForm(id: widget.id),
        ))));
  }
}
