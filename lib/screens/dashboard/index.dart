import 'package:faria_finances/helpers/cashierHelper.dart';
import 'package:faria_finances/helpers/categoryHelper.dart';
import 'package:faria_finances/helpers/tagHelper.dart';
import 'package:faria_finances/helpers/transactionHelper.dart';
import 'package:faria_finances/helpers/userHelper.dart';
import 'package:faria_finances/screens/cashiers/index.dart';
import 'package:faria_finances/screens/categories/index.dart';
import 'package:faria_finances/screens/login/index.dart';
import 'package:faria_finances/screens/tags/index.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> _transactions = [];
  String? _selectedCashierId; // ID do caixa selecionado
  List<Map<String, dynamic>> _cashiers = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _tags = [];
  String? _selectedCategoryId; // Categoria selecionada para o filtro
  List<String> _selectedTagIds = []; // Tags selecionadas para o filtro
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _cashierBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCashiers(); // Carrega a lista de caixas
    _loadCategories(); // Carrega a lista de categorias para o filtro
    _loadTags(); // Carrega a lista de tags para o filtro
  }

  Future<void> _loadCashiers() async {
    try {
      final cashiers = await getCashiers(loggedUserId);
      setState(() {
        _cashiers = cashiers
            .map<Map<String, dynamic>>((cashier) => {
                  'cashier_id': cashier['cashier_id'],
                  'balance': cashier['balance'],
                  'description': cashier['description'],
                })
            .toList();
        // Seleciona automaticamente o primeiro caixa se nenhum estiver selecionado
        if (_cashiers.isNotEmpty && _selectedCashierId == null) {
          _selectedCashierId = _cashiers[0]['cashier_id'].toString();
          _cashierBalance = double.parse(_cashiers[0]['balance']) ?? 0.0;
          _loadTransactions(); // Carrega as transações do caixa selecionado
        }
      });
    } catch (e) {
      print('Erro ao carregar caixas: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories =
          await getCategories(loggedUserId); // Função de listar categorias
      setState(() {
        _categories = categories
            .map<Map<String, dynamic>>((category) => {
                  'category_id': category['category_id'],
                  'title': category['title'],
                })
            .toList();
      });
    } catch (e) {
      print('Erro ao carregar categorias: $e');
    }
  }

  Future<void> _loadTags() async {
    try {
      final tags = await getTags(loggedUserId); // Função de listar tags
      print(tags);
      setState(() {
        _tags = tags
            .map<Map<String, dynamic>>((tag) => {
                  'tag_id': tag['tag_id'],
                  'title': tag['title'],
                })
            .toList();
      });
    } catch (e) {
      print('Erro ao carregar tags: $e');
    }
  }

  Future<void> _loadTransactions() async {
    if (_selectedCashierId == null) return;

    try {
      var transactions = await getTransactions(_selectedCashierId!);

      // Filtrar transações pela categoria selecionada
      if (_selectedCategoryId != null) {
        transactions = transactions
            .where((transaction) =>
                transaction['category_id'].toString() == _selectedCategoryId)
            .toList();
      }

      // Filtrar transações pelas tags selecionadas
      if (_selectedTagIds.isNotEmpty) {
        transactions = transactions
            .where((transaction) => _selectedTagIds.every((tagId) =>
                transaction['tag_ids'] != null &&
                transaction['tag_ids'].contains(int.parse(tagId))))
            .toList();
      }

      setState(() {
        _transactions = transactions;
        _calculateTotals(); // Calcula os totais para os InfoCards
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
    }
  }

  void _calculateTotals() {
    _totalIncome = 0.0;
    _totalExpense = 0.0;
    for (final transaction in _transactions) {
      final value = double.parse(transaction['value']) ?? 0.0;
      if (transaction['transaction_type'] == 'income') {
        print('income');
        _totalIncome += value;
      } else if (transaction['transaction_type'] == 'expense') {
        _totalExpense += value;
      }
    }
  }

  Future<void> _showChangeCashierModal(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeCashierModal(
          cashiers: _cashiers,
          selectedCashierId: _selectedCashierId,
          onCashierSelected: (String cashierId, double balance) {
            setState(() {
              _selectedCashierId = cashierId;
              _cashierBalance = balance;
              _loadTransactions(); // Recarrega transações após troca de caixa
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, $loggedUserName'),
        actions: [
          ElevatedButton(
              onPressed: () {
                _showChangeCashierModal(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(
                    vertical: 18.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Row(
                children: [
                  Text('Trocar caixa', style: TextStyle(color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(
                    Icons.switch_account,
                    color: Colors.white,
                  )
                ],
              )),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () {
                // Lógica para logout
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                    vertical: 18.0, horizontal: 25.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Row(
                children: [
                  Text('Fazer logout', style: TextStyle(color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(
                    Icons.logout,
                    color: Colors.white,
                  )
                ],
              )),
          const SizedBox(width: 8),
          // const SizedBox(width: 27),
        ],
      ),
      body: Container(
        child: _cashiers.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum caixa disponível.',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Crie um caixa para poder registrar transações.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  labelText: 'Filtrar por categoria'),
                              value: _selectedCategoryId,
                              items: _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category['category_id'].toString(),
                                  child: Text(category['title']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                  _loadTransactions(); // Recarrega as transações após mudar a categoria
                                });
                              },
                              isExpanded: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Filtrar por marcadores'),
                              readOnly: true,
                              onTap: () async {
                                final selectedTags =
                                    await showDialog<List<String>>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MultiSelectDialog(
                                      items: _tags,
                                      selectedItems: _selectedTagIds,
                                    );
                                  },
                                );

                                if (selectedTags != null) {
                                  setState(() {
                                    _selectedTagIds = selectedTags;
                                    _loadTransactions(); // Recarrega as transações após mudar as tags
                                  });
                                }
                              },
                              controller: TextEditingController(
                                text: _selectedTagIds.isNotEmpty
                                    ? _tags
                                        .where((tag) => _selectedTagIds
                                            .contains(tag['tag_id'].toString()))
                                        .map((tag) => tag['title'])
                                        .join(', ')
                                    : '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                              onPressed: _clearFilters,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Text('Remover filtros',
                                      style: TextStyle(color: Colors.black)),
                                  SizedBox(width: 8),
                                  Icon(Icons.clear)
                                ],
                              ))
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedCashierId == null
                            ? Colors.grey
                            : Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      onPressed: _selectedCashierId == null
                          ? null // Desabilita o botão se não houver caixa selecionado
                          : () async {
                              await _showAddTransactionModal(context,
                                  int.parse(_selectedCashierId.toString()));
                              _loadTransactions(); // Atualiza a lista após criar uma transação
                            },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Adicionar Transação',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _transactions.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhuma transação encontrada.',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black54),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              final value = double.parse(
                                  transaction['value'].replaceAll(',', '.'));
                              return TransactionCard(
                                name: transaction['title'] ?? '',
                                value: value,
                                category: transaction['category_title'] ??
                                    'Sem Categoria',
                                tags: List<String>.from(
                                    transaction['tag_titles'] ?? []),
                                date: DateFormat('dd/MM/yyyy').format(
                                  transaction['transaction_date'],
                                ),
                                transactionType:
                                    transaction['transaction_type'],
                                onEdit: () async {
                                  await _showEditTransactionModal(
                                      context, transaction);
                                  _loadTransactions(); // Atualiza a lista após editar uma transação
                                },
                                onDelete: () async {
                                  await _showDeleteTransactionModal(
                                      context, transaction);
                                  _loadTransactions(); // Atualiza a lista após excluir uma transação
                                },
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoCard(
                            title: 'Entradas',
                            value: _totalIncome,
                            isIncome: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InfoCard(
                            title: 'Saídas',
                            value: _totalExpense,
                            isIncome: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InfoCard(
                            title: 'Saldo',
                            value:
                                _cashierBalance + _totalIncome - _totalExpense,
                            isIncome: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      drawer: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(loggedUserName),
                accountEmail: Text(loggedUserEmail),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Transações"),
                onTap: () {
                  // Lógica para navegação
                  _loadCashiers();
                  _loadTransactions(); // Atualiza a lista após fechar o drawer
                  _loadCategories(); // Carrega a lista de categorias para o filtro
                  _loadTags(); // Carrega a lista de marcadores para o filtro
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text("Categorias"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CategoryListPage()),
                  ).then((_) {
                    _loadCashiers();
                    _loadTransactions(); // Atualiza a lista após fechar o drawer
                    _loadCategories(); // Carrega a lista de categorias para o filtro
                    _loadTags(); // Carrega a lista de marcadores para o filtro
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.label),
                title: const Text("Tags"),
                onTap: () {
                  // Lógica para navegação
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TagListPage()),
                  ).then((_) {
                    _loadCashiers();
                    _loadTransactions(); // Atualiza a lista após fechar o drawer
                    _loadCategories(); // Carrega a lista de categorias para o filtro
                    _loadTags(); // Carrega a lista de marcadores para o filtro
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text("Caixas"),
                onTap: () {
                  // Lógica para navegação
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CashierListPage()),
                  ).then((_) {
                    _loadCashiers();
                    _loadTransactions(); // Atualiza a lista após fechar o drawer
                    _loadCategories(); // Carrega a lista de categorias para o filtro
                    _loadTags(); // Carrega a lista de marcadores para o filtro
                  });
                },
              ),
              // Navegação do Drawer...
            ],
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedTagIds.clear();
      _loadTransactions(); // Recarrega a lista de transações sem filtros
    });
  }

  Future<void> _showAddTransactionModal(
      BuildContext context, int cashierId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionModal(cashierId: cashierId);
      },
    );
  }

  Future<void> _showEditTransactionModal(
      BuildContext context, Map<String, dynamic> transaction) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTransactionModal(transaction: transaction);
      },
    );
  }

  Future<void> _showDeleteTransactionModal(
      BuildContext context, Map<String, dynamic> transaction) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteTransactionModal(transaction: transaction);
      },
    );
  }
}

class AddTransactionModal extends StatefulWidget {
  final int cashierId;
  const AddTransactionModal({super.key, required this.cashierId});

  @override
  _AddTransactionModalState createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  String _titulo = '';
  String _descricao = '';
  String _valor = '';
  String _tipo = 'income';
  final String _categoria = '';
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _tags = [];
  List<String> _selectedTagIds = [];
  DateTime _data = DateTime.now();
  late int _cashierId;

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Carrega as categorias quando o modal é inicializado
    _loadTags(); // Carrega as tags
    _cashierId = widget.cashierId;
  }

  Future<void> _loadCategories() async {
    try {
      // Chama a função que carrega as categorias
      final categories = await getCategories(loggedUserId);

      // Atualiza o estado com as categorias carregadas
      setState(() {
        _categories = categories
            .map<Map<String, dynamic>>((category) => {
                  'category_id': category['category_id'],
                  'title': category['title'],
                })
            .toList();
      });
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      // Handle error, talvez mostrar uma mensagem para o usuário
    }
  }

  Future<void> _loadTags() async {
    try {
      final tags = await getTags(loggedUserId);
      setState(() {
        _tags = tags
            .map<Map<String, dynamic>>((tag) => {
                  'tag_id': tag['tag_id'],
                  'title': tag['title'],
                })
            .toList();
      });
    } catch (e) {
      print('Erro ao carregar tags: $e');
    }
  }

  Future<void> _createTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formInputs = [
        _titulo.isEmpty,
        _descricao.isEmpty,
        _valor.isEmpty,
        double.tryParse(_valor) == null,
        _selectedCategoryId == null,
        _selectedTagIds.isEmpty,
        _data == null
      ];

      final hasError = formInputs.any((input) => input);

      if (hasError) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Não foi possível criar a Transação'),
            content: const Text('Verifique os campos e tente novamente.'),
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

      try {
        int categoryId = int.parse(_selectedCategoryId!);
        double value = double.parse(_valor.replaceAll(',', '.'));

        await createTransaction(
          _titulo,
          _descricao,
          value,
          _tipo,
          categoryId,
          _cashierId,
          _data,
          _selectedTagIds,
        );

        // Mostrar uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação registrada com sucesso!')),
        );

        // Fechar o modal após sucesso
        Navigator.of(context).pop();
      } catch (e) {
        // Mostrar mensagem de erro
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro ao registrar transação!'),
            content:
                const Text('Ocorreu um erro ao tentar registrar a transação.'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Transação'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
                onSaved: (value) => _titulo = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
                onSaved: (value) => _descricao = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   if (double.tryParse(value) == null) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
                onSaved: (value) => _valor = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo'),
                value: _tipo,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Entrada')),
                  DropdownMenuItem(value: 'expense', child: Text('Saída')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['category_id'].toString(),
                    child: Text(category['title']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId =
                        value; // Salva o ID da categoria selecionada
                  });
                },
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Marcadores'),
                onTap: () async {
                  final selectedTags = await showDialog<List<String>>(
                    context: context,
                    builder: (BuildContext context) {
                      return MultiSelectDialog(
                        items: _tags,
                        selectedItems: _selectedTagIds,
                      );
                    },
                  );

                  if (selectedTags != null) {
                    setState(() {
                      _selectedTagIds = selectedTags;
                    });
                  }
                },
                readOnly: true,
                // validator: (value) {
                //   if (_selectedTagIds.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
                controller: TextEditingController(
                    text: _selectedTagIds.isNotEmpty
                        ? _tags
                            .where((tag) => _selectedTagIds
                                .contains(tag['tag_id'].toString()))
                            .map((tag) => tag['title'])
                            .join(', ')
                        : ''),
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Data da Transação'),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('pt', 'BR'),
                  );

                  if (pickedDate != null && pickedDate != _data) {
                    setState(() {
                      _data = pickedDate;
                    });
                  }
                },
                // validator: (value) {
                //   return null;
                // },
                controller: TextEditingController(
                    text: DateFormat('dd/MM/yyyy').format(_data)),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _createTransaction,
          child: const Text('Salvar'), // Chama a função de criação de transação
        ),
      ],
    );
  }
}

class EditTransactionModal extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const EditTransactionModal({super.key, required this.transaction});

  @override
  _EditTransactionModalState createState() => _EditTransactionModalState();
}

class _EditTransactionModalState extends State<EditTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  late String _titulo;
  late String _descricao;
  late String _valor;
  late String _tipo;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _tags = [];
  List<String> _selectedTagIds = [];
  late DateTime _data;

  @override
  void initState() {
    super.initState();
    _titulo = widget.transaction['title'] ?? '';
    _descricao = widget.transaction['description'] ?? '';
    _valor = widget.transaction['value']?.toString() ?? '';
    _tipo = widget.transaction['transaction_type'] ?? 'income';
    _selectedCategoryId = widget.transaction['category_id']?.toString();
    _selectedTagIds = List<String>.from(widget.transaction['tag_ids']
            .map((tagId) => tagId.toString())
            .toList() ??
        []);
    _data = DateTime.parse(widget.transaction['transaction_date'].toString());

    _loadCategories();
    _loadTags();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await getCategories(
          loggedUserId); // Substitua pelo ID do usuário logado
      setState(() {
        _categories = categories
            .map<Map<String, dynamic>>((category) => {
                  'category_id': category['category_id'],
                  'title': category['title'],
                })
            .toList();
      });
    } catch (e) {
      print('Erro ao carregar categorias: $e');
    }
  }

  Future<void> _loadTags() async {
    try {
      final tags =
          await getTags(loggedUserId); // Substitua pelo ID do usuário logado
      setState(() {
        _tags = tags
            .map<Map<String, dynamic>>((tag) => {
                  'tag_id': tag['tag_id'],
                  'title': tag['title'],
                })
            .toList();
      });
    } catch (e) {
      print('Erro ao carregar tags: $e');
    }
  }

  Future<void> _updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final formInputs = [
        _titulo.isEmpty,
        _descricao.isEmpty,
        _valor.isEmpty,
        double.tryParse(_valor) == null,
        _selectedCategoryId == null,
        _selectedTagIds.isEmpty,
        _data == null
      ];

      final hasError = formInputs.any((input) => input);

      if (hasError) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Não foi possível criar a Transação'),
            content: const Text('Verifique os campos e tente novamente.'),
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

      try {
        int categoryId = int.parse(_selectedCategoryId!);
        double value = double.parse(_valor.replaceAll(',', '.'));
        int transactionId =
            widget.transaction['transaction_id']; // Obtém o ID da transação

        // Suponha que cashierId é um valor fixo para exemplo. Substitua por lógica apropriada.
        int cashierId = 1;

        await updateTransaction(
          transactionId,
          _titulo,
          _descricao,
          value,
          _tipo,
          categoryId,
          cashierId,
          _data,
          _selectedTagIds.map((tagId) => int.parse(tagId)).toList(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transação atualizada com sucesso!')),
        );

        Navigator.of(context).pop();
      } catch (e) {
        print('Erro ao atualizar transação: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro ao atualizar transação!'),
            content:
                const Text('Ocorreu um erro ao tentar atualizar a transação.'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Transação'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _titulo,
                decoration: const InputDecoration(labelText: 'Título'),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
                onSaved: (value) => _titulo = value!,
              ),
              TextFormField(
                initialValue: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
                onSaved: (value) => _descricao = value!,
              ),
              TextFormField(
                initialValue: _valor,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   if (double.tryParse(value.replaceAll(',', '.')) == null) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
                onSaved: (value) => _valor = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo'),
                value: _tipo,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Entrada')),
                  DropdownMenuItem(value: 'expense', child: Text('Saída')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria'),
                value: _selectedCategoryId,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['category_id'].toString(),
                    child: Text(category['title']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Marcadores'),
                readOnly: true,
                onTap: () async {
                  final selectedTags = await showDialog<List<String>>(
                    context: context,
                    builder: (BuildContext context) {
                      return MultiSelectDialog(
                        items: _tags,
                        selectedItems: _selectedTagIds,
                      );
                    },
                  );

                  if (selectedTags != null) {
                    setState(() {
                      _selectedTagIds = selectedTags;
                    });
                  }
                },
                // validator: (value) {
                //   if (_selectedTagIds.isEmpty) {
                //     return 'Campo obrigatório';
                //   }
                //   return null;
                // },
                controller: TextEditingController(
                    text: _selectedTagIds.isNotEmpty
                        ? _tags
                            .where((tag) => _selectedTagIds
                                .contains(tag['tag_id'].toString()))
                            .map((tag) => tag['title'])
                            .join(', ')
                        : ''),
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Data da Transação'),
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('pt', 'BR'),
                  );

                  if (pickedDate != null && pickedDate != _data) {
                    setState(() {
                      _data = pickedDate;
                    });
                  }
                },
                controller: TextEditingController(
                    text: DateFormat('dd/MM/yyyy').format(_data)),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _updateTransaction,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class DeleteTransactionModal extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const DeleteTransactionModal({super.key, required this.transaction});

  @override
  _DeleteTransactionModalState createState() => _DeleteTransactionModalState();
}

class _DeleteTransactionModalState extends State<DeleteTransactionModal> {
  late int _transactionId;
  late String _titulo;

  @override
  void initState() {
    super.initState();
    _transactionId = widget.transaction['transaction_id'];
    _titulo = widget.transaction['title'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir Transação'),
      content: Text('Tem certeza que deseja excluir a transação "$_titulo"?'),
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
              await deleteTransaction(_transactionId);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Transação excluída com sucesso!')));
              Navigator.of(context).pop();
            } catch (e) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Não foi possível excluir a Transação'),
                  content: const Text(
                      'Ocorreu um erro ao tentar excluir a transação.'),
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
  }
}

class ChangeCashierModal extends StatelessWidget {
  final List<Map<String, dynamic>> cashiers;
  final String? selectedCashierId;
  final Function(String, double) onCashierSelected;

  const ChangeCashierModal({
    super.key,
    required this.cashiers,
    required this.selectedCashierId,
    required this.onCashierSelected,
  });

  @override
  Widget build(BuildContext context) {
    String? cashierId = selectedCashierId;
    double balance = 0.0;

    return AlertDialog(
      title: const Text('Selecionar Caixa'),
      content: DropdownButtonFormField<String>(
        value: cashierId,
        items: cashiers.map((cashier) {
          return DropdownMenuItem<String>(
            value: cashier['cashier_id'].toString(),
            child: Text(cashier['description']),
          );
        }).toList(),
        onChanged: (value) {
          cashierId = value;
          balance = double.parse(cashiers.firstWhere((cashier) =>
              cashier['cashier_id'].toString() == value)['balance']);
        },
        decoration: const InputDecoration(labelText: 'Caixa'),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Selecionar'),
          onPressed: () {
            if (cashierId != null) {
              onCashierSelected(cashierId!, balance);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<String> selectedItems;

  const MultiSelectDialog({
    super.key,
    required this.items,
    required this.selectedItems,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _tempSelectedItems;

  @override
  void initState() {
    super.initState();
    _tempSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione as Tags'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value:
                        _tempSelectedItems.contains(item['tag_id'].toString()),
                    title: Text(item['title']),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) {
                      setState(() {
                        if (isChecked!) {
                          _tempSelectedItems.add(item['tag_id'].toString());
                        } else {
                          _tempSelectedItems.remove(item['tag_id'].toString());
                        }
                      });
                    },
                  ))
              .toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Selecionar'),
          onPressed: () {
            Navigator.of(context).pop(_tempSelectedItems);
          },
        ),
      ],
    );
  }
}

class TransactionCard extends StatelessWidget {
  final String name;
  final double value;
  final String category;
  final List<String> tags;
  final String date;
  final String transactionType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.name,
    required this.value,
    required this.category,
    required this.tags,
    required this.date,
    required this.transactionType,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedValue = transactionType == 'income' ? value : value * -1;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: const EdgeInsets.all(8.0),
      // color: const Color(0xFFF8F9FA),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
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
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${formattedValue.toStringAsFixed(2)}',
              style: TextStyle(
                color: formattedValue < 0 ? Colors.red : Colors.green,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(category),
            const SizedBox(height: 8),
            Row(
              children: [
                Wrap(
                  spacing: 4.0,
                  children: tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
                const Spacer(),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final double value;
  final bool isIncome;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title),
            Text(
              'R\$ ${value.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
