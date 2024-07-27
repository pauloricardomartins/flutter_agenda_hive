import 'package:hive/hive.dart';


part 'contato.g.dart';

@HiveType(typeId: 0)


class Contato extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String telefone;

  @HiveField(2)
  bool ehPessoaJuridica;

  Contato(
      {required this.nome,
      required this.telefone,
      required this.ehPessoaJuridica});
}
