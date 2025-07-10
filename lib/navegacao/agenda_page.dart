import 'dart:convert'; // <--- IMPORTANTE!
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
  );

  List<dynamic> eventos = [];
  bool carregando = false;
  String erro = '';

  Future<bool> _requestCalendarPermission() async {
    // ignore: deprecated_member_use
    var status = await Permission.calendar.status;
    if (!status.isGranted) {
      // ignore: deprecated_member_use
      status = await Permission.calendar.request();
    }
    return status.isGranted;
  }

  Future<void> fazerLoginEListarEventos() async {
    setState(() {
      carregando = true;
      erro = '';
    });

    try {
      final conta = await _googleSignIn.signIn();
      final auth = await conta?.authentication;
      final token = auth?.accessToken;

      if (token == null) {
        setState(() {
          erro = 'Token de acesso não encontrado.';
          carregando = false;
        });
        return;
      }

      final hasPermission = await _requestCalendarPermission();
      if (!hasPermission) {
        setState(() {
          erro = 'Permissão de acesso ao calendário não concedida.';
          carregando = false;
        });
        return;
      }

      final agora = DateTime.now().toUtc().toIso8601String();
      final url =
          'https://www.googleapis.com/calendar/v3/calendars/primary/events'
          '?timeMin=$agora'
          '&singleEvents=true'
          '&orderBy=startTime'
          '&maxResults=10';

      final resposta = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        setState(() {
          eventos = dados['items'] ?? [];
        });
      } else {
        setState(() {
          erro = 'Erro ao carregar eventos: ${resposta.statusCode} - ${resposta.reasonPhrase ?? resposta.body}';
        });
      }
    } catch (e) {
      setState(() {
        erro = 'Erro: $e';
      });
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Agenda')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_googleSignIn.currentUser == null)
                    ElevatedButton.icon(
                      onPressed: fazerLoginEListarEventos,
                      icon: const Icon(Icons.login),
                      label: const Text('Login com Google'),
                    ),
                  const SizedBox(height: 20),
                  if (erro.isNotEmpty)
                    Text(erro, style: const TextStyle(color: Colors.red)),
                  if (eventos.isEmpty && erro.isEmpty)
                    const Text('Nenhum evento encontrado.')
                  else if (eventos.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: eventos.length,
                        itemBuilder: (context, index) {
                          final evento = eventos[index];
                          final titulo = evento['summary'] ?? 'Sem título';
                          final inicio = evento['start']?['dateTime'] ??
                              evento['start']?['date'] ??
                              '';
                          return ListTile(
                            leading: const Icon(Icons.event),
                            title: Text(titulo),
                            subtitle: Text('Início: $inicio'),
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
