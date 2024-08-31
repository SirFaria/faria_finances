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
  final String _cashierId = '1';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await getTransactions(_cashierId);
      setState(() {
        _transactions = transactions;
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
      // Você pode exibir uma mensagem de erro aqui
    }
  }

  Future<void> _deleteTransaction(int transactionId) async {
    try {
      // Implemente aqui a função para deletar a transação pelo ID
      // await deleteTransaction(transactionId);
      // Atualiza a lista após deletar
      _loadTransactions();
    } catch (e) {
      print('Erro ao deletar transação: $e');
      // Exiba uma mensagem de erro aqui se necessário
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olá, Mateus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account),
            onPressed: () {
              // Lógica para trocar caixa
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Lógica para logout
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
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
                onPressed: () async {
                  await _showAddTransactionModal(context);
                  _loadTransactions();
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
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final transaction = _transactions[index];
                  final value =
                      double.parse(transaction['value'].replaceAll(',', '.'));
                  return TransactionCard(
                    name: transaction['title'] ?? '',
                    value: value,
                    category: transaction['category_title'] ?? 'Sem Categoria',
                    tags: List<String>.from(transaction['tag_titles'] ?? []),
                    date: DateFormat('dd/MM/yyyy').format(
                      transaction['transaction_date'],
                    ),
                    transactionType: transaction['transaction_type'],
                    onEdit: () async {
                      await _showEditTransactionModal(context, transaction);
                      _loadTransactions(); // Atualiza a lista após editar uma transação
                    },
                    onDelete: () async {
                      await _deleteTransaction(transaction['transaction_id']);
                    },
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: InfoCard(
                          title: 'Entradas', value: 15382.64, isIncome: true)),
                  SizedBox(width: 8),
                  Expanded(
                      child: InfoCard(
                          title: 'Saídas', value: -483.96, isIncome: false)),
                  SizedBox(width: 8),
                  Expanded(
                      child: InfoCard(
                          title: 'Saldo', value: 14898.68, isIncome: true)),
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
              const UserAccountsDrawerHeader(
                accountName: Text("Mateus"),
                accountEmail: Text("mateus@exemplo.com"),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Transações"),
                onTap: () {
                  // Lógica para navegação
                  Navigator.pop(context);
                  _loadTransactions(); // Atualiza a lista após fechar o drawer
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
                    _loadTransactions(); // Atualiza a lista após fechar o drawer
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
                    _loadTransactions(); // Atualiza a lista após fechar o drawer
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
                    _loadTransactions(); // Atualiza a lista após fechar o drawer
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

  Future<void> _showAddTransactionModal(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddTransactionModal();
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
}

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Carrega as categorias quando o modal é inicializado
    _loadTags(); // Carrega as tags
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

      try {
        int categoryId = int.parse(_selectedCategoryId!);
        double value = double.parse(_valor.replaceAll(',', '.'));

        // Suponha que cashierId é um valor fixo para exemplo. Substitua por lógica apropriada.
        int cashierId = 1;

        await createTransaction(
          _titulo,
          _descricao,
          value,
          _tipo,
          categoryId,
          cashierId,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título';
                  }
                  return null;
                },
                onSaved: (value) => _titulo = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
                onSaved: (value) => _descricao = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione uma categoria';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tags'),
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
                validator: (value) {
                  if (_selectedTagIds.isEmpty) {
                    return 'Por favor, selecione ao menos uma tag';
                  }
                  return null;
                },
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
                validator: (value) {
                  return null;
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
          onPressed: _createTransaction,
          child: const Text('Salvar'), // Chama a função de criação de transação
        ),
        // ElevatedButton(
        //   child: const Text('Salvar'),
        //   onPressed: () {
        //     if (_formKey.currentState!.validate()) {
        //       _formKey.currentState!.save();
        //       // Lógica para salvar a transação
        //       Navigator.of(context).pop();
        //     }
        //   },
        // ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o título';
                  }
                  return null;
                },
                onSaved: (value) => _titulo = value!,
              ),
              TextFormField(
                initialValue: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
                onSaved: (value) => _descricao = value!,
              ),
              TextFormField(
                initialValue: _valor,
                decoration: const InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o valor';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione uma categoria';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tags'),
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
                validator: (value) {
                  if (_selectedTagIds.isEmpty) {
                    return 'Por favor, selecione ao menos uma tag';
                  }
                  return null;
                },
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
