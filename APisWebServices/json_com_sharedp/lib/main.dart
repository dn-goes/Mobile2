import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _temaEscuro = false;
  late TextEditingController _nomeController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _carregarPreferencias();
  }

  void _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonConfig = prefs.getString("config");
    if (jsonConfig != null) {
      Map<String, dynamic> config = json.decode(jsonConfig);
      setState(() {
        _temaEscuro = config["temaEscuro"] ?? false;
        _nomeController.text = config["nome"] ?? "";
      });
    }
  }

  void _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> config = {
      "temaEscuro": _temaEscuro,
      "nome": _nomeController.text.trim()
    };
    prefs.setString("config", json.encode(config));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Preferências Salvas!"),
        backgroundColor: _temaEscuro ? Colors.tealAccent.shade700 : Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _temaEscuro ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Preferências do Usuário"),
          backgroundColor: _temaEscuro ? Colors.tealAccent.shade700 : Colors.blue,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _temaEscuro ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text(
                    "Tema Escuro",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  activeColor: Colors.tealAccent.shade700,
                  value: _temaEscuro,
                  onChanged: (value) {
                    setState(() => _temaEscuro = value);
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: "Nome do Usuário",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _salvarPreferencias,
                    icon: const Icon(Icons.save),
                    label: const Text("Salvar Preferências"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _temaEscuro
                          ? Colors.tealAccent.shade700
                          : Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1.5),
                const SizedBox(height: 10),
                const Text(
                  "Configurações Atuais:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text("Tema: ${_temaEscuro ? "Escuro" : "Claro"}",
                    style: const TextStyle(fontSize: 15)),
                Text("Usuário: ${_nomeController.text}",
                    style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
