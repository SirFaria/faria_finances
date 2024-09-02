import 'package:flutter/material.dart';
import 'package:faria_finances/helpers/userHelper.dart';
import 'package:faria_finances/screens/login/index.dart';

// Classe que define a página de registro
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores para capturar o texto inserido nos campos de nome, e-mail, senha e confirmação de senha
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return Scaffold(
      // Scaffold fornece a estrutura básica da página
      body: Center(
        // Centraliza o conteúdo na tela
        child: Card(
          // Card que envolve o formulário de registro
          elevation: 4, // Elevação para sombra do card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Borda arredondada do card
          ),
          child: Padding(
            // Espaçamento interno do card
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              // Limita a largura máxima do conteúdo
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Título da seção de registro
                  const Text(
                    'Registre-se',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20), // Espaçamento
                  // Campo de texto para inserir o nome
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      hintText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16), // Espaçamento
                  // Campo de texto para inserir o e-mail
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      hintText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16), // Espaçamento
                  // Campo de texto para inserir a senha
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      hintText: '',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true, // Oculta a senha digitada
                  ),
                  const SizedBox(height: 16), // Espaçamento
                  // Campo de texto para confirmar a senha
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirme sua senha',
                      hintText: '',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true, // Oculta a senha digitada
                  ),
                  const SizedBox(height: 24), // Espaçamento
                  // Botão de registro
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      // Captura os valores dos campos de nome, e-mail, senha e confirmação de senha
                      String name = nameController.text;
                      String email = emailController.text;
                      String password = passwordController.text;
                      String confirmPassword = confirmPasswordController.text;

                      // Verifica se algum campo está vazio
                      if (name.isEmpty ||
                          email.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty) {
                        // Exibe uma mensagem de erro se algum campo estiver vazio
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Erro ao registrar usuário!'),
                            content:
                                const Text('Todos os campos são obrigatórios.'),
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
                        return; // Interrompe a execução do método se algum campo estiver vazio
                      }

                      // Verifica se as senhas coincidem
                      if (password == confirmPassword) {
                        try {
                          // Chama a função de criação de usuário
                          await createUser(name, email, password);
                          // Exibe uma mensagem de sucesso e navega para a tela de login
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Usuário registrado com sucesso!')));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        } catch (e) {
                          // Exibe uma mensagem de erro em caso de falha no registro
                          if (e == 'email_already_exists') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Erro ao registrar usuário!'),
                                content: const Text(
                                    'O email já se encontra registrado no sistema, tente um email diferente.'),
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

                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Erro ao registrar usuário!'),
                              content: const Text(
                                  'Ocorreu um erro ao tentar registrar o usuário. Verifique os dados e tente novamente.'),
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
                      } else {
                        // Exibe mensagem de erro se as senhas não coincidirem
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Erro ao registrar usuário!'),
                            content: const Text('As senhas não coincidem.'),
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
                    child: const Text('Registrar'),
                  ),
                  const SizedBox(height: 10), // Espaçamento
                  // Texto informativo para usuários que já possuem conta
                  const Text(
                    'Ainda não tem uma conta?',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 10), // Espaçamento
                  // Botão para redirecionar à página de login
                  ElevatedButton(
                    onPressed: () {
                      // Navega para a tela de login
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Fazer login'),
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
