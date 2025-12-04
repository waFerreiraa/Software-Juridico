import 'package:flutter/material.dart';

class SuportePage extends StatefulWidget {
  const SuportePage({super.key});

  @override
  State<SuportePage> createState() => _SuportePageState();
}

class _SuportePageState extends State<SuportePage> {
  final List<Map<String, String>> faqs = [
    {
      "pergunta": "Como cadastrar um novo processo?",
      "resposta": "Clique no botão 'Adicionar Processos' na tela Inicial e preencha os campos necessários."
    },
    {
      "pergunta": "Onde está localizado os processos ativos?",
      "resposta": "Clique no botão 'Casos Ativos' na tela Inicial, onde estarão todos os seus processos ativos."
    },
    {
      "pergunta": "Para onde vão os processos que já se encerraram?",
      "resposta": "Vá até o menu e clique no botão 'Casos Vencidos', lá estarão todos os processos que já finalizaram."
    },
    {
      "pergunta": "Não estou recebendo notificações, o que fazer?",
      "resposta": "Verifique se as permissões de notificação estão ativadas no seu dispositivo e se o app está atualizado."
    },
    {
      "pergunta": "Como alterar minha senha?",
      "resposta": "No menu lateral, clique em 'Resetar Senha' e siga as instruções."
    },
    {
      "pergunta": "O que fazer se o app travar ou apresentar erro?",
      "resposta": "Feche o app e abra novamente. Se o problema persistir, entre em contato com o suporte."
    },
    {
      "pergunta": "Como enviar feedback ou sugestões?",
      "resposta": "Envie um e-mail para solutionsjuri@gmail.com"
    },
  ];

  final String suporteEmail = "solutionsjuri@gmail.com";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Suporte",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF490A1D),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          children: [
            // Parte rolável
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Perguntas Frequentes",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // FAQs
                  ...faqs.map((faq) {
                    return Card(
                      color: theme.cardColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          faq["pergunta"]!,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              faq["resposta"]!,
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 10),

                  
                  
                    // Card de Dicas Rápidas
                    Card(
                      color: Colors.orange.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.lightbulb, color: Colors.orange),
                        title: const Text(
                          "Dica Rápida",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // fixo preto
                          ),
                        ),
                        subtitle: const Text(
                          "Sempre revise os prazos dos seus processos para evitar atrasos.",
                          style: TextStyle(
                            color: Colors.black, // fixo preto
                          ),
                        ),
                      ),
                    ),


                  

                ],
              ),
            ),

            
            Card(
              color: const Color(0xFF490A1D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.white),
                title: Text(
                  suporteEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  "Entre em contato conosco",
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Abrir app de e-mail (opcional)"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
