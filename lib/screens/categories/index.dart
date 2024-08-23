import 'package:faria_finances/helpers/categoryHelper.dart';
import 'package:faria_finances/helpers/userHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Classe principal que cria a página de lista de categorias
class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  _CategoryListPageState createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  // Future que armazenará a lista de categorias obtidas do banco de dados
  late Future<List<dynamic>> futureCategories;

  @override
  void initState() {
    super.initState();
    // Carrega as categorias ao iniciar a página
    futureCategories = getCategories(loggedUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
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
                // Botão para adicionar nova categoria
                onPressed: () {
                  _showAddCategoryDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Adicionar Categoria',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            Expanded(
              // Widget FutureBuilder para construir a interface de acordo com o estado do future
              child: FutureBuilder<List<dynamic>>(
                future: futureCategories,
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
                        child: Text('Nenhuma categoria encontrada.'));
                    // exibir os dados
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final category = snapshot.data![index];
                        final date = DateFormat('dd/MM/yyyy')
                            .format(category['updated_at']);
                        return CategoryCard(
                          id: category['category_id'],
                          title: category['title'],
                          description: category['description'],
                          date: date,
                          // chamada ao modal de confirmação de exclusão
                          onDelete: () {
                            _showDeleteCategoryDialog(context,
                                category['category_id'], category['title']);
                          },
                          // chamada ao modal de edição
                          onEdit: () {
                            _showEditCategoryDialog(
                                context,
                                category['category_id'],
                                category['title'],
                                category['description']);
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

  // Função que exibe o modal para adicionar nova categoria
  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final titleController = TextEditingController();
        final descriptionController = TextEditingController();

        return AlertDialog(
          title: const Text('Adicionar Nova Categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                ),
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
            // Botão de salvar a nova categoria
            TextButton(
              onPressed: () async {
                // Atribuo os textos inseridos pelo usuário nas variáveis abaixo
                String title = titleController.text;
                String description = descriptionController.text;
                // Verifico se os campos foram preenchidos
                if (title.isNotEmpty && description.isNotEmpty) {
                  try {
                    // Faço a chamada da função de criar categoria
                    await createCategory(title, description, loggedUserId);
                    // Exibo uma mensagem de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Categoria criada com sucesso!')));
                    Navigator.of(context).pop();
                    setState(() {
                      futureCategories = getCategories(
                          loggedUserId); // Atualiza a lista após adicionar uma categoria
                    });
                  } catch (e) {
                    // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title:
                            const Text('Não foi possível cadastrar Categoria'),
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
                      title: const Text('Não foi possível cadastrar Categoria'),
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

  // Função para exibir o modal de confirmação ao excluir categoria
  void _showDeleteCategoryDialog(
      BuildContext context, int categoryId, String categoryTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Categoria'),
          content: Text(
              'Tem certeza que deseja excluir a categoria "$categoryTitle"?'),
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
                  // Faço a chamada da função de excluir categoria
                  await deleteCategory(categoryId, loggedUserId);
                  // Exibo uma mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Categoria excluída com sucesso!')));
                  Navigator.of(context).pop();
                  setState(() {
                    futureCategories = getCategories(
                        loggedUserId); // Atualiza a lista após excluir uma categoria
                  });
                } catch (e) {
                  // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Não foi possível excluir a Categoria'),
                      content: const Text(
                          'Ocorreu um erro ao tentar excluir a categoria.'),
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

  // Função para exibir o modal de edição de categoria
  void _showEditCategoryDialog(BuildContext context, int categoryId,
      String currentTitle, String currentDescription) {
    // Atribuo os textos recebidos da chamada nos campos do modal
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                ),
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
            // Botão para salvar a edição da categoria
            TextButton(
              onPressed: () async {
                // Atribuo os textos inseridos pelo usuário nas variáveis abaixo
                String title = titleController.text;
                String description = descriptionController.text;
                // Verifico se os campos foram preenchidos
                if (title.isNotEmpty && description.isNotEmpty) {
                  try {
                    // Faço a chamada da função de editar categoria
                    await updateCategory(
                        title, description, categoryId, loggedUserId);
                    // Exibo uma mensagem de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Categoria atualizada com sucesso!')));
                    Navigator.of(context).pop();
                    setState(() {
                      futureCategories = getCategories(
                          loggedUserId); // Atualiza a lista após editar uma categoria
                    });
                  } catch (e) {
                    // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                            'Não foi possível atualizar a Categoria'),
                        content: const Text(
                            'Ocorreu um erro ao tentar atualizar a categoria.'),
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
                  // Caso o usuário não insira nada, exibo uma mensagem de aviso para verificar os campos
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Não foi possível cadastrar Categoria'),
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

// Widget que representa o cartão de categoria na lista
class CategoryCard extends StatelessWidget {
  final int id;
  final String title;
  final String description;
  final String date;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CategoryCard({
    super.key,
    required this.id,
    required this.title,
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
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    // Botão para editar a categoria
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    // Botão para excluir a categoria
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
