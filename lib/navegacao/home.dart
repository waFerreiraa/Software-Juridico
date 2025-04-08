// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jurisolutions/navegacao/agenda_page.dart';
import 'package:jurisolutions/navegacao/inicio.dart';
import 'package:jurisolutions/navegacao/notificacao_page.dart';
import 'package:jurisolutions/navegacao/processos_page.dart';
import 'package:jurisolutions/models/cadastro_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int myCurrentIndex = 0;
  late final List<Widget> pages;
  late final PageController _pageController;
  DateTime? ultimaPressao;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    pages = [ProcessosPage(), AgendaPage(), NotificacaoPage()];
    _pageController = PageController(initialPage: myCurrentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final agora = DateTime.now();
    if (ultimaPressao == null ||
        agora.difference(ultimaPressao!) > const Duration(seconds: 2)) {
      ultimaPressao = agora;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pressione novamente para sair do app')),
      );
      return false;
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final ThemeData theme =
        isDarkMode
            ? ThemeData.dark().copyWith(
              iconTheme: const IconThemeData(color: Color(0xFFE0D3CA)),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: const Color(0xFFE0D3CA),
                unselectedItemColor: const Color(0xFFE0D3CA).withOpacity(0.5),
                backgroundColor: Colors.black,
              ),
            )
            : ThemeData.light().copyWith(
              iconTheme: const IconThemeData(color: Colors.black),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedItemColor: Color(0xff5E293B),
                unselectedItemColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            );

    return Theme(
      data: theme,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.blue,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.06,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    "Conta",
                    style: TextStyle(fontSize: width * 0.045),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    AutenticacaoServicos().deslogar();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    "Deslogar",
                    style: TextStyle(fontSize: width * 0.045),
                  ),
                  onTap: () async {
                    await AutenticacaoServicos().deslogar();

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => InicioTela(),
                      ), // sua tela inicial
                      (route) => false,
                    );
                  },
                ),
                SwitchListTile(
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    "Modo Noturno",
                    style: TextStyle(fontSize: width * 0.045),
                  ),
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  myCurrentIndex = index;
                });
              },
              children: pages,
            ),
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.symmetric(
              horizontal: width * 0.02,
              vertical: height * 0.01,
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: Offset(2, height * 0.02),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BottomNavigationBar(
                currentIndex: myCurrentIndex,
                selectedFontSize: width * 0.04,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                onTap: (index) {
                  if (index == 3) {
                    _scaffoldKey.currentState?.openEndDrawer();
                  } else {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.folder_open),
                    label: "Processos",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    label: "Agenda",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications_active_outlined),
                    label: "Notificação",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: "Menu",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
