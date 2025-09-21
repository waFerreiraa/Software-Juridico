// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jurisolutions/navegacao/agenda_page.dart';
import 'package:jurisolutions/navegacao/inicio.dart';
import 'package:jurisolutions/navegacao/notificacao_page.dart';
import 'package:jurisolutions/navegacao/perfil.dart';
import 'package:jurisolutions/navegacao/processos_page.dart';
import 'package:jurisolutions/navegacao/reset_senha.dart';
import 'package:jurisolutions/navegacao/suporte.dart';
import 'package:jurisolutions/navegacao/vencidos.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/google_login_service.dart';

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
  String? _fcmToken;

  // Serviço de login Google
  final GoogleLoginService _loginService = GoogleLoginService();

  @override
  void initState() {
    super.initState();
    pages = [
      ProcessosPage(),
      AgendaWidget(loginService: _loginService), // <- Agenda integrada
      NotificacaoPage(),
    ];
    _pageController = PageController(initialPage: myCurrentIndex);
    _configurarFirebaseMessaging();
  }

  Future<void> _configurarFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissão concedida para notificações');
    }

    String? token = await messaging.getToken();
    print('Token FCM: $token');
    setState(() {
      _fcmToken = token;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida em foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Usuário abriu a notificação');
      _pageController.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              scaffoldBackgroundColor: Colors.black,
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: const Color(0xFFE0D3CA),
                unselectedItemColor: const Color(0xFFE0D3CA).withOpacity(0.5),
                backgroundColor: Colors.black,
              ),
            )
            : ThemeData.light().copyWith(
              iconTheme: const IconThemeData(color: Colors.black),
              scaffoldBackgroundColor: Colors.white,
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
          backgroundColor: theme.scaffoldBackgroundColor,
          key: _scaffoldKey,
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? Colors.grey[800] : const Color(0xFF490A1D),
                  ),
                  child: const Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 45),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Perfil", style: TextStyle(fontSize: width * 0.045)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Theme(data: theme, child: PerfilPage()),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text("Resetar Senha", style: TextStyle(fontSize: width * 0.045)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Theme(data: theme, child: ResetPass()),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.support_agent_rounded),
                  title: Text("Suporte", style: TextStyle(fontSize: width * 0.045)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Theme(data: theme, child: SuportePage()),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.close_sharp),
                  title: Text("Casos Vencidos", style: TextStyle(fontSize: width * 0.045)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Theme(data: theme, child: CasosVencidos()),
                    ),
                  ),
                ),
                SwitchListTile(
                  secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                  title: Text("Modo Noturno", style: TextStyle(fontSize: width * 0.045)),
                  value: isDarkMode,
                  onChanged: (value) => setState(() => isDarkMode = value),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Deslogar", style: TextStyle(fontSize: width * 0.045)),
                  onTap: () async {
                    await _loginService.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => Theme(data: theme, child: InicioTela()),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (width >= 800)
                  NavigationRail(
                    selectedIndex: myCurrentIndex,
                    onDestinationSelected: (index) {
                      if (index == 3) {
                        _scaffoldKey.currentState?.openEndDrawer();
                      } else {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() => myCurrentIndex = index);
                      }
                    },
                    labelType: NavigationRailLabelType.selected,
                    backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
                    selectedIconTheme: IconThemeData(
                      color: theme.bottomNavigationBarTheme.selectedItemColor,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: theme.bottomNavigationBarTheme.unselectedItemColor,
                    ),
                    selectedLabelTextStyle: TextStyle(
                      color: theme.bottomNavigationBarTheme.selectedItemColor,
                      fontSize: width * 0.012,
                      fontWeight: FontWeight.w500,
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.folder_open),
                        label: Text('Processos'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.calendar_month_outlined),
                        label: Text('Agenda'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.notifications_active_outlined),
                        label: Text('Notificação'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.menu),
                        label: Text('Menu'),
                      ),
                    ],
                  ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => myCurrentIndex = index),
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: width < 800
              ? Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.02,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.bottomNavigationBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BottomNavigationBar(
                      currentIndex: myCurrentIndex,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
                      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
                      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
                      elevation: 0,
                      selectedFontSize: width * 0.035,
                      unselectedFontSize: width * 0.03,
                      iconSize: 28,
                      onTap: (index) {
                        if (index == 3) {
                          _scaffoldKey.currentState?.openEndDrawer();
                        } else {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                          setState(() => myCurrentIndex = index);
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
                )
              : null,
        ),
      ),
    );
  }
}
