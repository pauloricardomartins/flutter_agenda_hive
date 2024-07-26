import 'package:agenda_hive/views/tela_contato_formulario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:agenda_hive/models/contato.dart';

class TelaContatos extends StatefulWidget {
  const TelaContatos({super.key});
  @override
  State<TelaContatos> createState() => _TelaContatosState();
}

class _TelaContatosState extends State<TelaContatos> {
  final Box<Contato> caixaContatos = Hive.box<Contato>('contatos');

  //copiar numero para a memoria
  void _copiaNumero(String telefone) {
    Clipboard.setData(ClipboardData(text: telefone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Número copiado com suceso!')),
    );
  }

  //função para abrir o whataspp
  void _abrirWhats(String telefone) async {
    final numero = telefone;
    final Uri url = Uri.parse('https://wa.me/55$numero');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi posssivel abrir o WhatAapp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agenda")),
      body: ValueListenableBuilder(
        valueListenable:
            caixaContatos.listenable(), //execura a mudanca na caixa de contatos
        builder: (context, Box<Contato> caixa, _) {
          if (caixa.values.isEmpty) {
            return const Center(child: Text('Nenhum Contato'));
          }
          return ListView.builder(
            itemCount: caixa.values.length,
            itemBuilder: (context, index) {
              final contato = caixa.getAt(index);
              return Slidable(
                key: ValueKey(contato!.nome),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _copiaNumero(contato.telefone),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.copy,
                      label: "Copiar",
                    ),
                    SlidableAction(
                      onPressed: (context) => _abrirWhats(contato.telefone),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: FontAwesomeIcons.whatsapp,
                      label: "Copiar",
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(contato.ehPessoaJuridica
                      ? FontAwesomeIcons.building
                      : FontAwesomeIcons.user),
                  title: Text(contato.nome),
                  subtitle: Text(contato.telefone),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TelaContatoFormulario(Contato: contato),
                            ))
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => {
                          contato.delete(),
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
