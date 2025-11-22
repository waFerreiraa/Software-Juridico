import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'editarPerfil.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF490A1D),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),

      body: user == null
          ? Center(
              child: Text(
                "Usuário não logado",
                style: theme.textTheme.bodyLarge,
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 30),

                // FOTO
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : const AssetImage('assets/profile.png')
                          as ImageProvider,
                ),

                const SizedBox(height: 20),

                // NOME
                Text(
                  user.displayName ?? "Nome não disponível",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                // EMAIL
                Text(
                  user.email ?? "Email não disponível",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 30),

                // Botão de EDITAR PERFIL
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: theme.cardColor,
                    child: ListTile(
                      leading: const Icon(Icons.edit, color: Color(0xff5E293B)),
                      title: Text(
                        'Editar Perfil',
                        style: theme.textTheme.bodyLarge,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF490A1D), 
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => Theme(
                              data: theme,
                              child: const EditarPerfil(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
