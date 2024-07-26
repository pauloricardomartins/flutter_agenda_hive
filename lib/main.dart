import 'package:agenda_hive/views/tela_contatos.dart';
import 'package:flutter/material.dart';
import 'package:agenda_hive/models/hive_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveConfig.start();
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Agenda",
      home: TelaContatos(),
    );
  }
}
