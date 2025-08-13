import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProdutoPage(),
  ));
}

class ProdutoPage extends StatefulWidget {
  const ProdutoPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProdutoPageState();
}

class _ProdutoPageState extends State<ProdutoPage> {
  List<Map<String, dynamic>> produtos = [];
  final TextEditingController _nomeProdutoController = TextEditingController();
  final TextEditingController _valorProdutoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<File> _getArquivo() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/produtos.json");
  }

  void _carregarProdutos() async {
    try {
      final file = await _getArquivo();
      String conteudo = await file.readAsString();
      List<dynamic> dados = json.decode(conteudo);
      setState(() {
        produtos = dados.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() {
        produtos = [];
      });
    }
  }

  void _salvarProdutos() async {
    try {
      final file = await _getArquivo();
      String jsonProdutos = json.encode(produtos);
      await file.writeAsString(jsonProdutos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Lista de Produtos salva com sucesso!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void _adicionarProduto() {
    String nome = _nomeProdutoController.text.trim();
    String valorStr = _valorProdutoController.text.trim();
    if (nome.isEmpty || valorStr.isEmpty) return;
    double? valor = double.tryParse(valorStr);
    if (valor == null) return;
    final novoProduto = {"nome": nome, "valor": valor};
    setState(() {
      produtos.add(novoProduto);
    });
    _nomeProdutoController.clear();
    _valorProdutoController.clear();
    _salvarProdutos();
  }

  void _removerProduto(int index) {
    setState(() {
      produtos.removeAt(index);
    });
    _salvarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Produtos"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeProdutoController,
              decoration: InputDecoration(
                labelText: "Nome do Produto",
                prefixIcon: const Icon(Icons.shopping_bag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _valorProdutoController,
              decoration: InputDecoration(
                labelText: "Valor (ex: 15.55)",
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _adicionarProduto,
                icon: const Icon(Icons.save),
                label: const Text("Salvar Produto"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Divider(height: 25, thickness: 1.2),
            Expanded(
              child: produtos.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inbox, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          "Nenhum produto salvo",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: produtos.length,
                      itemBuilder: (context, index) {
                        final produto = produtos[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.shopping_cart,
                                color: Colors.blueAccent),
                            title: Text(
                              produto["nome"],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              "R\$ ${produto["valor"].toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 15),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerProduto(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
