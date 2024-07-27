import 'package:flutter/material.dart'; // Importa a biblioteca Flutter para construir a interface do usuário.
import 'package:flutter/services.dart'; // Importa a biblioteca de serviços do Flutter.
import 'package:hive/hive.dart'; // Importa a biblioteca Hive para armazenamento local.
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart'; // Importa a biblioteca para formatação de entrada de dados.
import 'package:agenda_hive/models/contato.dart'; // Importa o modelo Contato.

class TelaContatoFormulario extends StatefulWidget {
  // Define um widget com estado (StatefulWidget) para o formulário de contato.
  final Contato? contato; // Variável para armazenar um contato opcional.

  // Construtor que pode receber um contato para edição.
  TelaContatoFormulario({this.contato});

  @override
  _TelaContatoFormularioEstado createState() =>
      _TelaContatoFormularioEstado(); // Cria o estado associado a este widget.
}

class _TelaContatoFormularioEstado extends State<TelaContatoFormulario> {
  // Define a classe de estado para TelaContatoFormulario.
  final _chaveFormulario = GlobalKey<
      FormState>(); // Chave global para identificar o formulário e validar os campos.
  late String _nome; // Variável para armazenar o nome do contato.
  late String _telefone; // Variável para armazenar o telefone do contato.
  late bool
      _ehPessoaJuridica; // Variável para armazenar se o contato é pessoa jurídica.

  @override
  void initState() {
    // Método chamado quando o estado é inicializado.
    super.initState();
    if (widget.contato != null) {
      // Se um contato foi passado, inicializa os campos com os dados desse contato.
      _nome = widget.contato!.nome;
      _telefone = widget.contato!.telefone;
      _ehPessoaJuridica = widget.contato!.ehPessoaJuridica;
    } else {
      // Caso contrário, inicializa os campos com valores padrão.
      _nome = '';
      _telefone = '';
      _ehPessoaJuridica = false;
    }
  }

  void _salvarContato() {
    // Função para salvar o contato.
    if (_chaveFormulario.currentState!.validate()) {
      // Valida os campos do formulário.
      _chaveFormulario.currentState!.save(); // Salva os valores do formulário.
      final novoContato = Contato(
        // Cria um novo objeto Contato com os valores do formulário.
        nome: _nome,
        telefone: _telefone,
        ehPessoaJuridica: _ehPessoaJuridica,
      );
      final caixaContatos =
          Hive.box<Contato>('contatos'); // Obtém a caixa Hive de contatos.
      if (widget.contato != null) {
        // Se um contato foi passado, atualiza esse contato.
        widget.contato!.nome = _nome;
        widget.contato!.telefone = _telefone;
        widget.contato!.ehPessoaJuridica = _ehPessoaJuridica;
        widget.contato!.save(); // Salva as alterações no Hive.
      } else {
        // Caso contrário, adiciona um novo contato na caixa.
        caixaContatos.add(novoContato);
      }
      Navigator.pop(
          context); // Fecha o formulário e volta para a tela anterior.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Constrói a interface do formulário.
    return Scaffold(
      appBar: AppBar(
        // AppBar com título dinâmico baseado se é um novo contato ou edição.
        title: Text(
            widget.contato == null ? 'Adicionar Contato' : 'Editar Contato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
            16.0), // Adiciona padding ao redor do formulário.
        child: Form(
          key:
              _chaveFormulario, // Associa a chave do formulário para validação.
          child: Column(
            children: [
              TextFormField(
                // Campo de texto para o nome.
                initialValue: _nome, // Inicializa o campo com o valor do nome.
                decoration:
                    InputDecoration(labelText: 'Nome'), // Rótulo do campo.
                validator: (value) {
                  // Valida o valor do campo.
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um nome'; // Retorna uma mensagem de erro se o campo estiver vazio.
                  }
                  return null; // Retorna null se o valor for válido.
                },
                onSaved: (value) {
                  _nome = value!; // Salva o valor do campo na variável _nome.
                },
              ),
              TextFormField(
                // Campo de texto para o telefone.
                initialValue:
                    _telefone, // Inicializa o campo com o valor do telefone.
                decoration:
                    const InputDecoration(labelText: 'Telefone'), // Rótulo do campo.
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  MaskedInputFormatter(
                      '(###) #####-####'), // Formata a entrada do telefone.
                ],                
                keyboardType: TextInputType.phone, // Define o teclado numérico.
                validator: (value) {
                  // Valida o valor do campo.
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite um telefone'; // Retorna uma mensagem de erro se o campo estiver vazio.
                  }
                  return null; // Retorna null se o valor for válido.
                },
                onSaved: (value) {
                  _telefone =
                      value!; // Salva o valor do campo na variável _telefone.
                },
              ),
              SwitchListTile(
                // Switch para indicar se é pessoa jurídica.
                title: const Text('Pessoa Jurídica'), // Título do switch.
                value: _ehPessoaJuridica, // Valor do switch.
                onChanged: (value) {
                  // Função chamada quando o switch é alterado.
                  setState(() {
                    _ehPessoaJuridica = value; // Atualiza o valor do switch.
                  });
                },
              ),
              const SizedBox(height: 20), // Adiciona um espaço vertical de 20 pixels.
              ElevatedButton(
                // Botão para salvar o contato.
                onPressed:
                    _salvarContato, // Chama a função para salvar o contato.
                child: Text('Salvar'), // Texto do botão.
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 