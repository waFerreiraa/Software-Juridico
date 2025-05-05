import 'package:jurisolutions/models/cadastro_model.dart';
import 'package:flutter/material.dart';
import 'package:jurisolutions/navegacao/perfil.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Deslogar"),
              onTap: () {
                AutenticacaoServicos().deslogar();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("perfil"),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => PerfilPage()),);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(child: Text("essa é a pagina de menu")),
          Positioned(
            top: 40,
            right: 20,
            child: Builder(
              builder:
                  (context) => FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
