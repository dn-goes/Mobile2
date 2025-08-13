//converter Json <-> Dart
import 'dart:convert'; //não precisa instalar no PubSp

void main(){
  String jsonString = '''{
    "id": "abc123",
    "nome": "João",
    "idade": 30,
    "ativo": true,
    "login": "joao123",
    "senha": "senha123"
  }''';

  // Converter JSON para objeto Dart
  Map<String, dynamic> user = json.decode(jsonString);
  print('Nome: \'${user['nome']}\''); // João
  print('Login: \'${user['login']}\''); // joao123

  // Modificar a senha para 6 dígitos
  user['senha'] = 'nova12';
  print('Senha modificada: \'${user['senha']}\'');

  // Salvar no JsonString
  String updatedJsonString = json.encode(user);
  print('JSON atualizado: $updatedJsonString');
  // {"id":"abc123","nome":"João","idade":30,"ativo":true,"login":"joao123","senha":"nova12"}
}