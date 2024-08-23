import 'package:faria_finances/screens/tags/index.dart';
import 'package:flutter/material.dart';
import 'package:faria_finances/screens/categories/index.dart';
import 'package:faria_finances/screens/login/index.dart';

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
        // color: const Color(0xFFE9ECEF),
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
                  // Lógica para adicionar nova categoria
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
                },
              ),
            ],
          ),
        ),
      ),
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
