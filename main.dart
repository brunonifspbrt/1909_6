import 'dart:convert';

import 'package:ex1/coordenadas.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var conteudo = '';
  var msg = '';
  //TextEditingController tfCep = TextEditingController();
  TextEditingController contLat = TextEditingController();
  TextEditingController contLong = TextEditingController();
  TextEditingController contTemp = TextEditingController();
  TextEditingController contHum = TextEditingController();

  void limpaCampos() {
    contLat.clear();
    contLong.clear();
    contTemp.clear();
    contHum.clear();
  }

  void buscaCoord() async {
    String lat = contLat.text;
    String long = contLong.text;
    lat = lat.replaceAll(",", ".");
    long = long.replaceAll(",", ".");

    // define url com cep ja embutido
    // String url =
    //     'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m&forecast_days=1';
    String url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m,relative_humidity_2m&forecast_days=1';

    // verifica tamanho do campo
    if ((lat.length < 2) || (long.length < 2)) {
      // limpa todos os campos
      limpaCampos();
      setState(() {
        msg = 'Informe Lat. e Long. Válidos!';
      });
    } else {
      // objeto Json retornado da APi
      final resposta = await http.get(Uri.parse(url));

      if (resposta.statusCode == 200) {
        // resposta 200 OK
        // o body contém JSON
        // obtem todo conteudo de json
        var jsonValor = jsonDecode(resposta.body);
        // como a chave que desejo está em um objeto DENTRO do Objeto Json, informo somente ele, no caso o current
        var coord = Coordenada.fromJson(jsonValor['current']);
        setState(() {
          msg = 'CEP encontrado';
        });
        contTemp.text = coord.temperature2m.toString();
        contHum.text = coord.humidity2m.toString();
      } else {
        // diferente de 200 exibe mensagem de erro
        // throw Exception('Falha no carregamento.');
        setState(() {
          msg = 'Lat. e Long informados NÃO encontrado';
        });
        limpaCampos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contLat,
                  decoration: const InputDecoration(labelText: 'Latitude:'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contLong,
                  decoration: const InputDecoration(labelText: 'Longitude:'),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: TextField(
              //     controller: contCep,
              //     maxLines: 5,
              //   ),
              // ),
              // TextField(
              //   controller: tfCep,
              //   decoration: const InputDecoration(labelText: 'Digite o CEP'),
              // ),
              const SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: () {
                  buscaCoord();
                },
                child: const Text('Buscar'),
              ),
              Text('Resultado: $msg'),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: contTemp,
                  decoration:
                      const InputDecoration(labelText: 'Temperatura Atual:'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: contHum,
                  decoration:
                      const InputDecoration(labelText: 'Umidade Relativa:'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
