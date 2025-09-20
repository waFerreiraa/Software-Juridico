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
  bool _isLoading = false; // Adicionar estado de loading

  CalendarService? get _calendarService {
    final user = widget.loginService.currentUser;
    return user != null ? CalendarService(user) : null;
  }

  @override
  void initState() {
    super.initState();

<<<<<<< Updated upstream
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
=======
  void _initLogin() async {
    setState(() {
      _isLoading = true;
>>>>>>> Stashed changes
    });

    try {
      await widget.loginService.signInSilently();
      if (widget.loginService.currentUser != null) {
        await _carregarEventos();
      }

      widget.loginService.onCurrentUserChanged.listen((user) async {
        if (user != null) {
          await _carregarEventos();
        } else {
          // Limpar eventos quando usuário sair
          _eventosNotifier.value = [];
        }
      });
    } catch (e) {
      print('Erro no login: $e');
      // Mostrar erro para o usuário se necessário
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _carregarEventos() async {
    if (_calendarService == null) return;
<<<<<<< Updated upstream
    final eventos = await _calendarService!.listarEventos();
    setState(() {
      _eventos = eventos;
    });
=======

    try {
      final eventos = await _calendarService!.listarEventos();
      if (mounted) {
        _eventosNotifier.value = eventos;
      }
    } catch (e) {
      print('Erro ao carregar eventos: $e');
      // Mostrar erro para o usuário se necessário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar eventos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
>>>>>>> Stashed changes
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
                  content: SingleChildScrollView(
                    // Adicionar scroll para evitar overflow
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: tituloController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
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
                          try {
                            await _calendarService!.criarEvento(
                              inicio!,
                              fim!,
                              tituloController.text,
                            );
                            await _carregarEventos();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            print('Erro ao criar evento: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao criar evento: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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
      await _carregarEventos();
    } catch (e) {
      print('Erro ao deletar evento: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.loginService.currentUser;
<<<<<<< Updated upstream
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
=======

    // Mostrar loading se estiver carregando
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // Envolver com Scaffold
      backgroundColor: Colors.white, // Definir cor de fundo explicitamente
      body: SafeArea(
        // Adicionar SafeArea
        child:
            user == null
                ? _LoginView(
                  loginService: widget.loginService,
                  onLogin: _carregarEventos,
                )
                : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      UserHeader(
                        user: user,
                        onSignOut: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await widget.loginService.signOut();
                          _eventosNotifier.value = [];
                          setState(() {
                            _isLoading = false;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _abrirDialogoNovoEvento,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(10, 45),
                          elevation: 2,
                          shadowColor: const Color.fromARGB(255, 64, 27, 39),
>>>>>>> Stashed changes
                          backgroundColor: const Color(0xff5E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
<<<<<<< Updated upstream
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
=======
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
                              // Envolver o calendário em um Container
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                                selectedDayPredicate:
                                    (day) => isSameDay(day, _selectedDay),
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
                                  outsideDaysVisible: true,
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ValueListenableBuilder<List<cal.Event>>(
                                  valueListenable: _eventosNotifier,
                                  builder: (context, eventos, _) {
                                    final eventosDia =
                                        _selectedDay == null
                                            ? []
                                            : _eventosDoDia(_selectedDay!);

                                    if (_selectedDay == null) {
                                      return const Center(
                                        child: Text(
                                          'Selecione um dia para ver os eventos',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
>>>>>>> Stashed changes
                                          ),
                                        ),
                                      );
                                    }

                                    if (eventosDia.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.event_busy,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Nenhum evento neste dia',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return RefreshIndicator(
                                      onRefresh: _carregarEventos,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount: eventosDia.length,
                                        itemBuilder: (context, index) {
                                          final e = eventosDia[index];
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
                                              horizontal: 4,
                                              vertical: 6,
                                            ),
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
                                                  final confirma = await showDialog<
                                                    bool
                                                  >(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          title: const Text(
                                                            'Confirmar exclusão',
                                                          ),
                                                          content: Text(
                                                            'Deseja realmente deletar o evento "${e.summary}"?',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                        false,
                                                                      ),
                                                              child: const Text(
                                                                'Cancelar',
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                        true,
                                                                      ),
                                                              child: const Text(
                                                                'Deletar',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
<<<<<<< Updated upstream
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
=======
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
                              ),
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
}

// =================== COMPONENTES ===================

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
          Icon(Icons.calendar_today, size: 120, color: const Color(0xFF490A1D)),
          const SizedBox(height: 24),
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
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await loginService.signIn();
                onLogin();
              } catch (e) {
                print('Erro no login: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao fazer login: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
              backgroundColor: const Color(0xFF490A1D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            user.photoUrl != null
                ? CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(user.photoUrl!),
                )
                : const CircleAvatar(radius: 20, child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.email ?? 'Usuário',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onSignOut,
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
>>>>>>> Stashed changes
              ),
            ),
          ],
        ],
      ),
    );
  }
}