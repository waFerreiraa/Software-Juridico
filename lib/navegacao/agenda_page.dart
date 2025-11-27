import 'package:flutter/material.dart';
import 'package:jurisolutions/models/calendar_service.dart';
import 'package:jurisolutions/models/google_login_service.dart';
import 'package:jurisolutions/models/meu_snakbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:googleapis/calendar/v3.dart' as cal;

// An explicit enum for better state management
enum AgendaState {
  loading,
  loginRequired,
  eventsLoaded,
  error,
}

class AgendaWidget extends StatefulWidget {
  final GoogleLoginService loginService;
  const AgendaWidget({super.key, required this.loginService});

  @override
  State<AgendaWidget> createState() => _AgendaWidgetState();
}

class _AgendaWidgetState extends State<AgendaWidget> {
  final ValueNotifier<List<cal.Event>> _eventosNotifier = ValueNotifier([]);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  AgendaState _currentState = AgendaState.loading;
  String _errorMessage = '';

  CalendarService? get _calendarService {
    final user = widget.loginService.currentUser;
    return user != null ? CalendarService(user) : null;
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await widget.loginService.signInSilently();
      if (widget.loginService.currentUser != null) {
        await _loadEvents();
      } else {
        _updateState(AgendaState.loginRequired);
      }
    } catch (e) {
      _handleError('Erro ao iniciar: $e');
    }

    widget.loginService.onCurrentUserChanged.listen((user) async {
      if (user != null) {
        await _loadEvents();
      } else {
        _eventosNotifier.value = [];
        _updateState(AgendaState.loginRequired);
      }
    });
  }

  void _updateState(AgendaState newState, {String? message}) {
    if (mounted) {
      setState(() {
        _currentState = newState;
        if (message != null) _errorMessage = message;
      });
    }
  }

  void _handleError(String message) {
    print(message);
    mostrarSnackBar(
      context: context,
      texto: message,
      backgroundColor: Colors.red,
    );
    _updateState(AgendaState.error, message: message);
  }

  Future<void> _loadEvents() async {
    _updateState(AgendaState.loading);
    try {
      final eventos = await _calendarService!.listarEventos();
      _eventosNotifier.value = eventos;
      _updateState(AgendaState.eventsLoaded);
    } catch (e) {
      _handleError('Erro ao carregar eventos: $e');
    }
  }

  List<cal.Event> _eventosDoDia(DateTime dia) {
    return _eventosNotifier.value.where((e) {
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
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Novo Evento', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: TextStyle(color: Theme.of(context).hintColor),
                  ),
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
                      builder: (context, child) => Theme(
                        data: Theme.of(context),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(inicio ?? DateTime.now()),
                      );
                      if (time != null) {
                        setStateDialog(() {
                          inicio = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 8),
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
                      builder: (context, child) => Theme(
                        data: Theme.of(context),
                        child: child!,
                      ),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(fim ?? inicio ?? DateTime.now()),
                      );
                      if (time != null) {
                        setStateDialog(() {
                          fim = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () async {
                if (tituloController.text.isNotEmpty &&
                    inicio != null &&
                    fim != null &&
                    _calendarService != null) {
                  try {
                    await _calendarService!.criarEvento(inicio!, fim!, tituloController.text);
                    if (context.mounted) Navigator.pop(context);
                    await _loadEvents();
                  } catch (e) {
                    _handleError('Erro ao criar evento: $e');
                  }
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

    try {
      await _calendarService!.deletarEvento(evento);
      await _loadEvents();
    } catch (e) {
      _handleError('Erro ao deletar evento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case AgendaState.loading:
        return _buildLoadingView();
      case AgendaState.loginRequired:
        return _buildLoginView();
      case AgendaState.eventsLoaded:
      case AgendaState.error:
        return _buildAgendaView();
    }
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF490A1D)),
            ),
            const SizedBox(height: 20),
            Text(
              'Carregando...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Isso pode levar alguns segundos...',
              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _LoginView(
        loginService: widget.loginService,
        onLogin: _loadEvents,
      ),
    );
  }

  Widget _buildAgendaView() {
    final user = widget.loginService.currentUser;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (user != null)
                UserHeader(
                  user: user,
                  onSignOut: () async {
                    await widget.loginService.signOut();
                  },
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _abrirDialogoNovoEvento,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(10, 45),
                  elevation: 2,
                  shadowColor: const Color.fromARGB(255, 64, 27, 39),
                  backgroundColor: const Color(0xFF490A1D),
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
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TableCalendar(
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
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: true,
                          defaultTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                          weekendTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                        ),
                        locale: 'pt_BR',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildEventList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ValueListenableBuilder<List<cal.Event>>(
        valueListenable: _eventosNotifier,
        builder: (context, eventos, _) {
          if (_selectedDay == null) {
            return Center(
              child: Text(
                'Selecione um dia para ver os eventos',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                ),
              ),
            );
          }

          final eventosDia = _eventosDoDia(_selectedDay!);
          if (eventosDia.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum evento neste dia',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadEvents,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: eventosDia.length,
              itemBuilder: (context, index) {
                final e = eventosDia[index];
                final start = e.start?.dateTime ?? e.start?.date ?? DateTime.now();
                final end = e.end?.dateTime ?? e.end?.date ?? DateTime.now();

                return Card(
                  color: Colors.deepPurple[400],
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      e.summary ?? 'Sem título',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
                        final confirma = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Theme.of(context).cardColor,
                            title: Text('Confirmar exclusão', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                            content: Text(
                              'Deseja realmente deletar o evento "${e.summary}"?',
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Deletar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirma == true) {
                          await _deletarEvento(e);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class _LoginView extends StatelessWidget {
  final GoogleLoginService loginService;
  final VoidCallback onLogin;
  const _LoginView({required this.loginService, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 120, color: Color(0xFF490A1D)),
          const SizedBox(height: 24),
          Text(
            'Para acessar sua agenda e receber notificações, faça login com sua conta Google.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                mostrarSnackBar(
                  context: context,
                  texto: 'Fazendo login...',
                  backgroundColor: const Color(0xFF490A1D),
                );

                await loginService.signIn();

                onLogin();
              } catch (e) {
                print('Erro no login: $e');
                mostrarSnackBar(
                  context: context,
                  texto: 'Erro ao fazer login: $e',
                  backgroundColor: Colors.red,
                );
              }
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Login com Google',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF490A1D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  final dynamic user;
  final VoidCallback onSignOut;
  const UserHeader({super.key, required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl ?? ''),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? 'Usuário',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  Text(
                    user.email ?? '',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
              onPressed: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}