import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:google_sign_in/google_sign_in.dart';
import 'google_auth_client.dart';

class CalendarService {
  final GoogleSignInAccount user;

  CalendarService(this.user);

  Future<cal.CalendarApi> _getApi() async {
    final headers = await user.authHeaders;
    final client = GoogleAuthClient(headers);
    return cal.CalendarApi(client);
  }

  Future<List<cal.Event>> listarEventos() async {
    final api = await _getApi();
    final eventos = await api.events.list(
      "primary",
      maxResults: 50,
      orderBy: "startTime",
      singleEvents: true,
      timeMin: DateTime.now().toUtc(),
    );
    return eventos.items ?? [];
  }

  Future<void> criarEvento(DateTime inicio, DateTime fim, String titulo) async {
    final api = await _getApi();
    final evento =
        cal.Event()
          ..summary = titulo
          ..start = cal.EventDateTime(dateTime: inicio)
          ..end = cal.EventDateTime(dateTime: fim);
    await api.events.insert(evento, "primary");
  }

  Future<void> deletarEvento(cal.Event evento) async {
    final api = await _getApi();
    if (evento.id != null) {
      await api.events.delete("primary", evento.id!);
    }
  }
}
