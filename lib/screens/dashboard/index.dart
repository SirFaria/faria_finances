import 'package:faria_finances/helpers/categoryHelper.dart';
import 'package:faria_finances/helpers/tagHelper.dart';
import 'package:faria_finances/helpers/userHelper.dart';
import 'package:faria_finances/screens/cashiers/index.dart';
import 'package:faria_finances/screens/categories/index.dart';
import 'package:faria_finances/screens/login/index.dart';
import 'package:faria_finances/screens/tags/index.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                onPressed: () {
                  _showAddTransactionModal(context);
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
              child: ListView(
                children: const [
                  // Lista de Transações...
                  TransactionCard(
                    name: 'Jacaré Lanches',
                    value: -32.00,
                    category: 'Alimentação',
                    tags: ['Lanches', 'Crédito', 'Ifood'],
                    date: '24/02/2024',
                  ),
                  TransactionCard(
                    name: 'Posto Shell',
                    value: -168.71,
                    category: 'Carro',
                    tags: ['Gasolina', 'Débito'],
                    date: '26/02/2024',
                  ),
                  TransactionCard(
                    name: 'Salário',
                    value: 15382.64,
                    category: 'Entradas',
                    tags: ['PIX'],
                    date: '26/02/2024',
                  ),
                  TransactionCard(
                    name: 'Amazon',
                    value: -283.25,
                    category: 'Compras',
                    tags: ['Crédito', 'Online'],
                    date: '28/02/2024',
                  ),
                ],
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
                  );
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
                  );
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
                  );
                },
              ),
              // Navegação do Drawer...
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddTransactionModal();
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
          child: const Text('Salvar'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              // Lógica para salvar a transação
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

  const TransactionCard({
    super.key,
    required this.name,
    required this.value,
    required this.category,
    required this.tags,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () {
                        // Lógica para editar transação
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Lógica para deletar transação
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${value.toStringAsFixed(2)}',
              style: TextStyle(
                color: value < 0 ? Colors.red : Colors.green,
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
