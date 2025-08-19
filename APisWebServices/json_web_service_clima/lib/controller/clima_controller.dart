import 'dart:convert';
import '../models/clima_model.dart';
import 'package:http/http.dart' as http;

class ClimaController {
  final String _apiKey = "97ed514c93bca43c2e434bfd594965e8";

  // método busca (get)
  Future<ClimaModel?> buscarClima(String cidade) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$cidade&appid=$_apiKey&units=metric&lang=pt_br",
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      return ClimaModel.fromJson(dados);
    } else {
      return null;
    }
  }
}
