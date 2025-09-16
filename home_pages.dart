import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prova/produtos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Produtos> produtos = [];
  TextEditingController nomeEC = TextEditingController();
  TextEditingController valorEC = TextEditingController();
  TextEditingController imagemEC = TextEditingController();
  final dio = Dio();
  //https://api-produtos-pedidos.onrender.com

  Future<void> buscarProdutos() async {
    final resposta = await dio.get(
      'https://api-produtos-pedidos.onrender.com/produtos',
    );
    produtos.clear();
    for (var p in resposta.data) {
      final novoProduto = Produtos(
        p['id'],
        p['nome'],
        double.parse(p['valor']),
        p['imagem'],
      );
      produtos.add(novoProduto);
    }
    setState(() {});
  }

  Future<void> deletarProdutos(int id) async {
    await dio.delete('https://api-produtos-pedidos.onrender.com/produtos/$id');
    buscarProdutos();
  }

  Future<void> addProduto(String nome, String valor, String imagem) async {
    await dio.post(
      'https://api-produtos-pedidos.onrender.com/produtos',
      data: {'nome': nome, 'valor': double.parse(valor), 'imagem': imagem},
    );
    buscarProdutos();
  }

  Future<void> updateProduto(
    int id,
    String nome,
    String valor,
    String imagem,
  ) async {
    await dio.put(
      'https://api-produtos-pedidos.onrender.com/produtos/$id',
      data: {'nome': nome, 'valor': double.parse(valor), 'imagem': imagem},
    );
    buscarProdutos();
  }

  @override
  void initState() {
    super.initState();
    buscarProdutos();
  }

  void modalAddProduto(BuildContext ctx) {
    nomeEC.clear();
    valorEC.clear();
    imagemEC.clear();
    showModalBottomSheet(
      context: ctx,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nomeEC),
            TextField(controller: valorEC),
            TextField(controller: imagemEC),
            ElevatedButton(
              onPressed: () {
                addProduto(nomeEC.text, valorEC.text, imagemEC.text);
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void modalAlterarProduto(BuildContext ctx, Produtos p) {
    nomeEC.clear();
    valorEC.clear();
    imagemEC.clear();
    nomeEC.text = p.nome;
    valorEC.text = p.valor.toString();
    imagemEC.text = p.imagem;
    showModalBottomSheet(
      context: ctx,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nomeEC),
            TextField(controller: valorEC),
            TextField(controller: imagemEC),
            ElevatedButton(
              onPressed: () {
                updateProduto(p.id, nomeEC.text, valorEC.text, imagemEC.text);
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista dos produtos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modalAddProduto(context);
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: produtos.length,
        itemBuilder: (context, int index) => Card(
          child: ListTile(
            leading: IconButton(
              onPressed: () {
                modalAlterarProduto(context, produtos[index]);
              },
              icon: Icon(Icons.edit),
            ),
            trailing: IconButton(
              onPressed: () {
                deletarProdutos(produtos[index].id);
              },
              icon: Icon(Icons.delete),
            ),
            title: Text(produtos[index].nome),
            subtitle: Text(produtos[index].valor.toString()),
          ),
        ),
      ),
    );
  }
}