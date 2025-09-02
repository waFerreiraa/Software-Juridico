import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';

class UpdateChecker extends StatefulWidget {
  @override
  _UpdateCheckerState createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  String? latestVersion;
  String? downloadUrl;
  double progress = 0.0;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://api.github.com/repos/waFerreiraa/Software-Juridico/releases/latest",
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        latestVersion = data["tag_name"];
        downloadUrl = data["assets"][0]["browser_download_url"];

        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String currentVersion = packageInfo.version;

        String latest = latestVersion!.replaceAll("v", "");

        if (latest != currentVersion) {
          _showUpdateDialog();
        }
      }
    } catch (e) {
      print("Erro ao checar atualização: $e");
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Nova versão disponível 🚀"),
            content: Text("Deseja atualizar para $latestVersion?"),
            actions: [
              TextButton(
                child: Text("Mais tarde"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("Atualizar"),
                onPressed: () {
                  Navigator.pop(context);
                  if (downloadUrl != null) {
                    _startOtaUpdate(downloadUrl!);
                  }
                },
              ),
            ],
          ),
    );
  }

  void _startOtaUpdate(String url) {
    setState(() {
      downloading = true;
      progress = 0.0;
    });

    OtaUpdate()
        .execute(url, destinationFilename: "update.apk")
        .listen(
          (event) {
            setState(() {
              // Atualiza status de download
              if (event.status == OtaStatus.DOWNLOADING) {
                progress = double.tryParse(event.value ?? "0")! / 100;
              } else if (event.status == OtaStatus.INSTALLING) {
                progress = 1.0;
              }
            });
          },
          onError: (e) {
            setState(() {
              downloading = false;
              progress = 0.0;
            });
            print("Erro no OTA Update: $e");
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meu App Jurídico")),
      body: Center(
        child:
            downloading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Baixando atualização... ${(progress * 100).toStringAsFixed(0)}%",
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(value: progress),
                  ],
                )
                : Text("Rodando versão atual do app"),
      ),
    );
  }
}
