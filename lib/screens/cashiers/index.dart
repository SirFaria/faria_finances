import 'package:faria_finances/helpers/cashierHelper.dart';
import 'package:faria_finances/helpers/userHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Classe principal que cria a página de lista de caixas
class CashierListPage extends StatefulWidget {
  const CashierListPage({super.key});

  @override
  _CashierListPageState createState() => _CashierListPageState();
}

class _CashierListPageState extends State<CashierListPage> {
  // Future que armazenará a lista de caixas obtidas do banco de dados
  late Future<List<dynamic>> futureCashiers;

  @override
  void initState() {
    super.initState();
    // Carrega as caixas ao iniciar a página
    futureCashiers = getCashiers(loggedUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caixas'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                // Botão para adicionar novo caixa
                onPressed: () {
                  _showAddCashierDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Adicionar Caixa',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            Expanded(
              // Widget FutureBuilder para construir a interface de acordo com o estado do future
              child: FutureBuilder<List<dynamic>>(
                future: futureCashiers,
                builder: (context, snapshot) {
                  // enquanto está aguardando
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                    // em caso de erro
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                    // caso não hajam dados, exibe um texto informando que não há dados
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Nenhum caixa encontrado.'));
                    // exibir os dados
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final cashier = snapshot.data![index];
                        final date = DateFormat('dd/MM/yyyy').format(
                            DateTime.now()); // Atualiza com a data atual
                        return CashierCard(
                          id: cashier['cashier_id'],
                          balance: cashier['balance'],
                          description: cashier['description'],
                          date: date,
                          // chamada ao modal de confirmação de exclusão
                          onDelete: () {
                            _showDeleteCashierDialog(context,
                                cashier['cashier_id'], cashier['description']);
                          },
                          // chamada ao modal de edição
                          onEdit: () {
                            _showEditCashierDialog(
                                context,
                                cashier['cashier_id'],
                                cashier['balance'],
                                cashier['description']);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função que exibe o modal para adicionar novo caixa
  void _showAddCashierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final balanceController = TextEditingController();
        final descriptionController = TextEditingController();

        return AlertDialog(
          title: const Text('Adicionar Novo Caixa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(
                  labelText: 'Saldo',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
              ),
            ],
          ),
          actions: [
            // Botão de cancelar
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            // Botão de salvar o novo caixa
            TextButton(
              onPressed: () async {
                // Atribuo os textos inseridos pelo usuário nas variáveis abaixo
                double? balance = double.tryParse(balanceController.text);
                String description = descriptionController.text;
                // Verifico se os campos foram preenchidos
                if (balance != null && description.isNotEmpty) {
                  try {
                    // Faço a chamada da função de criar caixa
                    await createCashier(balance, description, loggedUserId);
                    // Exibo uma mensagem de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Caixa criado com sucesso!')));
                    Navigator.of(context).pop();
                    setState(() {
                      futureCashiers = getCashiers(
                          loggedUserId); // Atualiza a lista após adicionar um caixa
                    });
                  } catch (e) {
                    // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Não foi possível cadastrar Caixa'),
                        content: const Text(
                            'Cheque os caracteres e tente novamente.'),
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
                  // Caso o usuário não insira nada, exibo uma mensagem de aviso para verificar os campos
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Não foi possível cadastrar Caixa'),
                      content:
                          const Text('Verifique os campos e tente novamente.'),
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
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Função para exibir o modal de confirmação ao excluir caixa
  void _showDeleteCashierDialog(
      BuildContext context, int cashierId, String cashierDescription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Caixa'),
          content: Text(
              'Tem certeza que deseja excluir o caixa com a descrição "$cashierDescription"?'),
          actions: [
            // Botão de cancelar
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            // Botão para confirmar a exclusão
            TextButton(
              onPressed: () async {
                try {
                  // Faço a chamada da função de excluir caixa
                  await deleteCashier(cashierId, loggedUserId);
                  // Exibo uma mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Caixa excluído com sucesso!')));
                  Navigator.of(context).pop();
                  setState(() {
                    futureCashiers = getCashiers(
                        loggedUserId); // Atualiza a lista após excluir um caixa
                  });
                } catch (e) {
                  // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Não foi possível excluir o Caixa'),
                      content: const Text(
                          'Ocorreu um erro ao tentar excluir o caixa.'),
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
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  // Função para exibir o modal de edição de caixa
  void _showEditCashierDialog(BuildContext context, int cashierId,
      double currentBalance, String currentDescription) {
    // Atribuo os textos recebidos da chamada nos campos do modal
    final balanceController =
        TextEditingController(text: currentBalance.toString());
    final descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Caixa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(
                  labelText: 'Saldo',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
              ),
            ],
          ),
          actions: [
            // Botão de cancelar a edição
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            // Botão de salvar as alterações
            TextButton(
              onPressed: () async {
                double? newBalance = double.tryParse(balanceController.text);
                String newDescription = descriptionController.text;

                if (newBalance != null && newDescription.isNotEmpty) {
                  try {
                    // Chamada para a função de editar o caixa
                    await updateCashier(
                        newBalance, newDescription, cashierId, loggedUserId);
                    // Exibo uma mensagem de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Caixa atualizado com sucesso!')));
                    Navigator.of(context).pop();
                    setState(() {
                      futureCashiers = getCashiers(
                          loggedUserId); // Atualiza a lista após editar um caixa
                    });
                  } catch (e) {
                    // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Não foi possível editar o Caixa'),
                        content: const Text(
                            'Cheque os caracteres e tente novamente.'),
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
                  // Caso os campos estejam vazios, exibo uma mensagem de aviso para verificar os campos
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Não foi possível editar Caixa'),
                      content:
                          const Text('Verifique os campos e tente novamente.'),
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
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}

// Componente que renderiza os cartões de caixa com os botões de editar e excluir
class CashierCard extends StatelessWidget {
  final int id;
  final double balance;
  final String description;
  final String date;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CashierCard({
    super.key,
    required this.id,
    required this.balance,
    required this.description,
    required this.date,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(description),
        subtitle: Text('Saldo: R\$ $balance'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.blue,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
