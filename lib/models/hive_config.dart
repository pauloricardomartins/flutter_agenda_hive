import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:agenda_hive/models/contato.dart';

class HiveConfig {
  static Future<void> start() async {
    Directory dir = await getApplicationDocumentsDirectory();

    await Hive.initFlutter(dir.path);
    
    Hive.registerAdapter(ContatoAdapter());
    await Hive.openBox<Contato>('contatos');
  }
}