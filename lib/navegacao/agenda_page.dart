import 'package:flutter/material.dart';
import 'package:jurisolutions/models/calendar_service.dart';
import 'package:jurisolutions/models/google_login_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:googleapis/calendar/v3.dart' as cal;

class AgendaWidget extends StatefulWidget {
  final GoogleLoginService loginService;
  const AgendaWidget({super.key, required this.loginService});

  @override
  State<AgendaWidget> createState() => _AgendaWidgetState();
}

class _AgendaWidgetState extends State<AgendaWidget> {
  List<cal.Event> _eventos = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  CalendarService? get _calendarService {
    final user = widget.loginService.currentUser;
    return user != null ? CalendarService(user) : null;
  }

  @override
  void initState() {
    super.initState();

    // Tenta login silencioso
    widget.loginService.signInSilently().then((_) {
      if (widget.loginService.currentUser != null) {
        _carregarEventos(); // Carrega os eventos se já estiver logado
      }
      setState(() {});
    });
    // Listener para mudanças de usuário
    widget.loginService.onCurrentUserChanged.listen((user) {
      if (user != null) _carregarEventos();
      setState(() {});
    });
  }

  Future<void> _carregarEventos() async {
    if (_calendarService == null) return;
    final eventos = await _calendarService!.listarEventos();
    setState(() {
      _eventos = eventos;
    });
  }

  List<cal.Event> _eventosDoDia(DateTime dia) {
    return _eventos.where((e) {
      final start = e.start?.dateTime ?? e.start?.date;
      return start != null &&
          start.year == dia.year &&
          start.month == dia.month &&
          start.day == dia.day;
    }).toList();
  }

  Future<void> _abrirDialogoNovoEvento() async {
    final tituloController = TextEditingController();
    DateTime? inicio;
    DateTime? fim;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Novo Evento'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: tituloController,
                        decoration: const InputDecoration(labelText: 'Título'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        child: Text(
                          inicio == null
                              ? 'Escolher Início'
                              : 'Início: ${inicio!.day}/${inicio!.month} ${inicio!.hour}:${inicio!.minute.toString().padLeft(2, '0')}',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: inicio ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                inicio ?? DateTime.now(),
                              ),
                            );
                            if (time != null) {
                              setStateDialog(() {
                                inicio = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      ElevatedButton(
                        child: Text(
                          fim == null
                              ? 'Escolher Fim'
                              : 'Fim: ${fim!.day}/${fim!.month} ${fim!.hour}:${fim!.minute.toString().padLeft(2, '0')}',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: fim ?? inicio ?? DateTime.now(),
                            firstDate: inicio ?? DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                fim ?? inicio ?? DateTime.now(),
                              ),
                            );
                            if (time != null) {
                              setStateDialog(() {
                                fim = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: const Text('Salvar'),
                      onPressed: () async {
                        if (tituloController.text.isNotEmpty &&
                            inicio != null &&
                            fim != null &&
                            _calendarService != null) {
                          await _calendarService!.criarEvento(
                            inicio!,
                            fim!,
                            tituloController.text,
                          );
                          await _carregarEventos();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _deletarEvento(cal.Event evento) async {
    if (_calendarService == null) return;
    await _calendarService!.deletarEvento(evento);
    await _carregarEventos();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.loginService.currentUser;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (user == null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone ou ilustração
                      Icon(
                        Icons.calendar_today,
                        size: 120,
                        color: Color(0xff5E293B),
                      ),
                      const SizedBox(height: 24),
                      // Texto explicativo
                      const Text(
                        'Para acessar sua agenda e receber notificações, faça login com sua conta Google.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botão de login
                      ElevatedButton.icon(
                        onPressed: () async {
                          await widget.loginService.signIn();
                          await _carregarEventos();
                        },
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text(
                          'Login com Google',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xff5E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (user.photoUrl != null)
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(user.photoUrl!),
                      )
                    else
                      const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await widget.loginService.signOut();
                        setState(() {
                          _eventos = [];
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(10, 35),
                        elevation: 2,
                        shadowColor: const Color.fromARGB(255, 64, 27, 39),
                        backgroundColor: const Color(0xff5E293B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Sair',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _abrirDialogoNovoEvento,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(10, 45),
                elevation: 2,
                shadowColor: const Color.fromARGB(255, 64, 27, 39),
                backgroundColor: const Color(0xff5E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Criar novo evento',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    eventLoader: _eventosDoDia,
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    locale: 'pt_BR',
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child:
                        _selectedDay == null
                            ? const Center(
                              child: Text(
                                'Selecione um dia para ver os eventos',
                              ),
                            )
                            : ListView(
                              children:
                                  _eventosDoDia(_selectedDay!).map((e) {
                                    final start =
                                        e.start?.dateTime ??
                                        e.start?.date ??
                                        DateTime.now();
                                    final end =
                                        e.end?.dateTime ??
                                        e.end?.date ??
                                        DateTime.now();
                                    return Card(
                                      color: Colors.deepPurple[400],
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          e.summary ?? 'Sem título',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - '
                                          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () async {
                                            final confirma = await showDialog<
                                              bool
                                            >(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: const Text(
                                                      'Confirmar exclusão',
                                                    ),
                                                    content: Text(
                                                      'Deseja realmente deletar o evento "${e.summary}"?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'Cancelar',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          'Deletar',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                            if (confirma == true) {
                                              await _deletarEvento(e);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Evento "${e.summary}" deletado',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
