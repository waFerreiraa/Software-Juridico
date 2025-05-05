import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil'), elevation: 0),
      body:
          user == null
              ? Center(child: Text("Usuário não logado"))
              : Column(
                children: [
                  const SizedBox(height: 30),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : const AssetImage('assets/profile.png')
                                as ImageProvider,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.displayName ?? "Nome não disponível",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? "Email não disponível",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Color(0xff5E293B)),
                        title: Text('Editar Perfil'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navegar para edição
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: Icon(Icons.settings, color: Color(0xff5E293B)),
                        title: Text('Configurações'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navegar para configurações
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
