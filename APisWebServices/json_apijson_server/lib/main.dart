import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(home: TarefaPage()));
}

class TarefaPage extends StatefulWidget {
  const TarefaPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TarefasPageState();
  }
}

class _TarefasPageState extends State<TarefaPage> {
  List tarefas = [];
  final TextEditingController _tarefaController = TextEditingController();
  static const String baseUrl = "http://10.109.197.12:3000/tarefas";

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  // carregar tarefas da API
  void _carregarTarefas() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> dados = json.decode(response.body);
          tarefas = dados.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      }
    } catch (e) {
      print("Erro ao buscar Tarefa: $e");
    }
  }

  // adicionar tarefa
  void _adicionarTarefa(String titulo) async {
    final novaTarefa = {"titulo": titulo, "concluida": false};
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(novaTarefa),
      );
      if (response.statusCode == 201) {
        _tarefaController.clear();
        _carregarTarefas();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tarefa Adicionada com Sucesso")),
        );
      }
    } catch (e) {
      print("Erro ao adicionar Tarefa: $e");
    }
  }

  // remover tarefa
  void _removerTarefa(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"));
      if (response.statusCode == 200) {
        _carregarTarefas();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tarefa Apagada com Sucesso")),
        );
      }
    } catch (e) {
      print("Erro ao deletar Tarefa: $e");
    }
  }

  // modificar tarefa (PUT -> atualizar concluída ou título)
  void _modificarTarefa(String id, String titulo, bool concluida) async {
    final tarefaAtualizada = {"titulo": titulo, "concluida": concluida};
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(tarefaAtualizada),
      );
      if (response.statusCode == 200) {
        _carregarTarefas();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tarefa Atualizada com Sucesso")),
        );
      }
    } catch (e) {
      print("Erro ao atualizar Tarefa: $e");
    }
  }

  // build da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tarefas Via API")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // campo de texto para nova tarefa
            TextField(
              controller: _tarefaController,
              decoration: const InputDecoration(
                labelText: "Nova Tarefa",
                border: OutlineInputBorder(),
              ),
              onSubmitted: _adicionarTarefa,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: tarefas.isEmpty
                  ? const Center(child: Text("Nenhuma Tarefa Adicionada"))
                  : ListView.builder(
                      itemCount: tarefas.length,
                      itemBuilder: (context, index) {
                        final tarefa = tarefas[index];
                        return ListTile(
                          // ✅ agora tem checkbox para marcar concluída/pendente
                          leading: Checkbox(
                            value: tarefa["concluida"] ?? false, // 
                            onChanged: (valor) {
                              if (valor != null) {
                                _modificarTarefa(
                                  tarefa["id"].toString(), // ou "_id" se sua API usar Mongo
                                  tarefa["titulo"],
                                  valor,
                                );
                              }
                            },
                          ),
                          title: Text(tarefa["titulo"]),
                          subtitle: Text(
                            tarefa["concluida"] ? "Concluída" : "Pendente",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removerTarefa(tarefa["id"].toString()),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
