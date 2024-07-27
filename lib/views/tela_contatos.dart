import 'package:agenda_hive/views/tela_contato_formulario.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:agenda_hive/models/contato.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class TelaContatos extends StatefulWidget {
  const TelaContatos({super.key});
  @override
  State<TelaContatos> createState() => _TelaContatosState();
}

class _TelaContatosState extends State<TelaContatos> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  //copiar numero para a memoria
  void _copiaNumero(String telefone) {
    Clipboard.setData(ClipboardData(text: telefone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Número copiado com suceso!')),
    );
  }

  //função para abrir o whataspp
  void _abrirWhats(String telefone) async {
    final numero = toNumericString(telefone);
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
    final Box<Contato> caixaContatos = Hive.box<Contato>('contatos');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Procurar Contato...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable:
            caixaContatos.listenable(), //execura a mudanca na caixa de contatos
        builder: (context, Box<Contato> caixa, _) {
          final contatos = caixa.values
              .where((contato) =>
                  contato.nome != null &&
                  contato.nome!
                      .toLowerCase()
                      .contains(_searchTerm.toLowerCase()))
              .toList();

          if (contatos.isEmpty) {
            return const Center(child: Text('Nenhum Contato'));
          }
          return ListView.builder(
            itemCount: contatos.length,
            itemBuilder: (context, index) {
             final contato = contatos[index];
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
                                builder: (_) =>
                                    TelaContatoFormulario(contato: contato),
                              ))
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final shouldDelete =
                              await _showConfirmationDialog(context);
                          if (shouldDelete) {
                            contato?.delete();
                          }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => TelaContatoFormulario()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text('Tem certeza que deseja excluir este contato?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
