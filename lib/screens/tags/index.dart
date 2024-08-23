import 'package:faria_finances/helpers/tagHelper.dart';
import 'package:faria_finances/helpers/userHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Classe principal que cria a página de lista de marcadores
class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  @override
  _TagListPageState createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  // Future que armazenará a lista de marcadores obtidos do banco de dados
  late Future<List<dynamic>> futureTags;

  @override
  void initState() {
    super.initState();
    // Carrega os marcadores ao iniciar a página
    futureTags = getTags(loggedUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcadores'),
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
                // Botão para adicionar novo marcador
                onPressed: () {
                  _showAddTagDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Adicionar Marcador',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            Expanded(
              // Widget FutureBuilder para construir a interface de acordo com o estado do future
              child: FutureBuilder<List<dynamic>>(
                future: futureTags,
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
                        child: Text('Nenhum marcador encontrado.'));
                    // exibir os dados
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final tag = snapshot.data![index];
                        final date =
                            DateFormat('dd/MM/yyyy').format(tag['updated_at']);
                        return TagCard(
                          id: tag['tag_id'],
                          title: tag['title'],
                          description: tag['description'],
                          date: date,
                          // chamada ao modal de confirmação de exclusão
                          onDelete: () {
                            _showDeleteTagDialog(
                                context, tag['tag_id'], tag['title']);
                          },
                          // chamada ao modal de edição
                          onEdit: () {
                            _showEditTagDialog(context, tag['tag_id'],
                                tag['title'], tag['description']);
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

  // Função que exibe o modal para adicionar novo marcador
  void _showAddTagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final titleController = TextEditingController();
        final descriptionController = TextEditingController();

        return AlertDialog(
          title: const Text('Adicionar Novo Marcador'),
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
            // Botão de salvar o novo marcador
            TextButton(
              onPressed: () async {
                // Atribuo os textos inseridos pelo usuário nas variáveis abaixo
                String title = titleController.text;
                String description = descriptionController.text;
                // Verifico se os campos foram preenchidos
                if (title.isNotEmpty && description.isNotEmpty) {
                  try {
                    // Faço a chamada da função de criar marcador
                    await createTag(title, description, loggedUserId);
                    // Exibo uma mensagem de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Marcador criado com sucesso!')));
                    Navigator.of(context).pop();
                    setState(() {
                      futureTags = getTags(
                          loggedUserId); // Atualiza a lista após adicionar um marcador
                    });
                  } catch (e) {
                    // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title:
                            const Text('Não foi possível cadastrar Marcador'),
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
                      title: const Text('Não foi possível cadastrar Marcador'),
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

  // Função para exibir o modal de confirmação ao excluir marcador
  void _showDeleteTagDialog(BuildContext context, int tagId, String tagTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Marcador'),
          content:
              Text('Tem certeza que deseja excluir o marcador "$tagTitle"?'),
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
                  // Faço a chamada da função de excluir marcador
                  await deleteTag(tagId, loggedUserId);
                  // Exibo uma mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Marcador excluído com sucesso!')));
                  Navigator.of(context).pop();
                  setState(() {
                    futureTags = getTags(
                        loggedUserId); // Atualiza a lista após excluir um marcador
                  });
                } catch (e) {
                  // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Não foi possível excluir o Marcador'),
                      content: const Text(
                          'Ocorreu um erro ao tentar excluir o marcador.'),
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

  // Função para exibir o modal de edição de marcador
  void _showEditTagDialog(BuildContext context, int tagId, String currentTitle,
      String currentDescription) {
    // Atribuo os textos recebidos da chamada nos campos do modal
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController =
        TextEditingController(text: currentDescription);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Marcador'),
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
            // Botão para salvar a edição do marcador
            TextButton(
              onPressed: () async {
                // Atribuo os textos inseridos pelo usuário nas variáveis abaixo
                String title = titleController.text;
                String description = descriptionController.text;
                // Verifico se os campos foram preenchidos
                if (title.isNotEmpty && description.isNotEmpty) {
                  try {
                    // Faço a chamada da função de editar marcador
                    await updateTag(title, description, tagId, loggedUserId);
                    // Exibo uma mensagem de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Marcador atualizado com sucesso!')));
                    Navigator.of(context).pop();
                    setState(() {
                      futureTags = getTags(
                          loggedUserId); // Atualiza a lista após editar um marcador
                    });
                  } catch (e) {
                    // Caso ocorra algum erro, exibo um modal informando que não foi possível realizar a ação
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title:
                            const Text('Não foi possível atualizar o Marcador'),
                        content: const Text(
                            'Ocorreu um erro ao tentar atualizar o marcador.'),
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
                      title: const Text('Não foi possível cadastrar Marcador'),
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

// Widget que representa o cartão de marcador na lista
class TagCard extends StatelessWidget {
  final int id;
  final String title;
  final String description;
  final String date;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TagCard({
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
                    // Botão para editar o marcador
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    // Botão para excluir o marcador
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
