import 'package:flutter/material.dart';
import 'package:faria_finances/helpers/userHelper.dart';
import 'package:faria_finances/screens/dashboard/index.dart';
import 'package:faria_finances/screens/register/index.dart';

// Classe que define a página de login
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores para capturar o texto inserido nos campos de email e senha
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      // Scaffold fornece a estrutura básica da página
      body: Center(
        // Centraliza o conteúdo na tela
        child: SingleChildScrollView(
          // Permite rolar o conteúdo caso seja necessário
          padding: const EdgeInsets.all(24.0),
          child: Card(
            // Card que envolve o formulário de login
            elevation: 2.0, // Elevação para sombra do card
            margin: const EdgeInsets.all(8.0), // Margem ao redor do card
            child: Padding(
              // Espaçamento interno do card
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Título da seção de login
                    const Text(
                      'Acesse sua conta',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20), // Espaçamento
                    // Campo de texto para inserir o e-mail
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10), // Espaçamento
                    // Campo de texto para inserir a senha
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true, // Oculta a senha digitada
                    ),
                    const SizedBox(height: 20), // Espaçamento
                    // Botão de login
                    ElevatedButton(
                      onPressed: () async {
                        // Captura os valores dos campos de e-mail e senha
                        String email = emailController.text;
                        String password = passwordController.text;

                        // Chama a função de login e verifica se a autenticação foi bem-sucedida
                        bool isAuthenticated = await loginUser(email, password);
                        if (isAuthenticated) {
                          // Exibe uma mensagem de sucesso e navega para o dashboard
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Login bem-sucedido!')));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DashboardPage()),
                          );
                        } else {
                          // Exibe uma mensagem de erro em caso de falha no login
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Falha no login!'),
                              content:
                                  const Text('Verifique seu e-mail e senha.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Entrar'),
                    ),
                    const SizedBox(height: 10), // Espaçamento
                    // Texto informativo para usuários sem conta
                    const Text(
                      'Ainda não tem uma conta?',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10), // Espaçamento
                    // Botão para redirecionar à página de registro
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Criar uma conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
