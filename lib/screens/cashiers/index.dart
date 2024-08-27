import 'package:faria_finances/helpers/cashierHelper.dart';
import 'package:faria_finances/helpers/userHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; // Import da biblioteca de máscara

class CashierListPage extends StatefulWidget {
  const CashierListPage({super.key});

  @override
  _CashierListPageState createState() => _CashierListPageState();
}

class _CashierListPageState extends State<CashierListPage> {
  late Future<List<dynamic>> futureCashiers;

  @override
  void initState() {
    super.initState();
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
              child: FutureBuilder<List<dynamic>>(
                future: futureCashiers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Nenhum caixa encontrado.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final cashier = snapshot.data![index];
                        final date =
                            DateFormat('dd/MM/yyyy').format(DateTime.now());

                        // Converter a String para double e depois formatar para moeda brasileira
                        final balance = NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                        ).format(double.parse(cashier['balance']));

                        return CashierCard(
                          id: cashier['cashier_id'],
                          balance: balance,
                          description: cashier['description'],
                          date: date,
                          onDelete: () {
                            _showDeleteCashierDialog(context,
                                cashier['cashier_id'], cashier['description']);
                          },
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

  void _showAddCashierDialog(BuildContext context) {
    // Usando o MoneyMaskedTextController para aplicar a máscara de moeda
    final balanceController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
    );
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Converter o valor formatado para double
                String formattedBalance = balanceController.text
                    .replaceAll('R\$ ', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                double? balance = double.tryParse(formattedBalance);
                String description = descriptionController.text;

                if (balance != null && description.isNotEmpty) {
                  try {
                    await createCashier(balance, description, loggedUserId);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Caixa criado com sucesso!')));
                    Navigator.of(context).pop();
                    setState(() {
                      futureCashiers = getCashiers(loggedUserId);
                    });
                  } catch (e) {
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await deleteCashier(cashierId, loggedUserId);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Caixa excluído com sucesso!')));
                  Navigator.of(context).pop();
                  setState(() {
                    futureCashiers = getCashiers(loggedUserId);
                  });
                } catch (e) {
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

  void _showEditCashierDialog(BuildContext context, int cashierId,
      String currentBalance, String currentDescription) {
    print(currentBalance);
    final balanceController = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
      initialValue:
          double.tryParse(currentBalance.replaceAll('R\$ ', '')) ?? 0.0,
    );
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String formattedBalance = balanceController.text
                    .replaceAll('R\$ ', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                double? newBalance = double.tryParse(formattedBalance);
                String newDescription = descriptionController.text;

                if (newBalance != null && newDescription.isNotEmpty) {
                  try {
                    await updateCashier(
                        newBalance, newDescription, cashierId, loggedUserId);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Caixa atualizado com sucesso!')));
                    Navigator.of(context).pop();
                    setState(() {
                      futureCashiers = getCashiers(loggedUserId);
                    });
                  } catch (e) {
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

class CashierCard extends StatelessWidget {
  final int id;
  final String balance;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    // Botão para editar a categoria
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: onEdit,
                    ),
                    // Botão para excluir o marcador
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Saldo inicial: $balance'),
          ],
        ),
      ),
    );
  }
}
