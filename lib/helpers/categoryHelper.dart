import 'package:faria_finances/database/config.dart';

// CRIAR CATEGORIA

Future<void> createCategory(
    String title, String description, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para cadastrar categorias
    await conn!.execute(
      r'INSERT INTO categories (title, description, created_at, updated_at, user_id) VALUES ($1, $2, NOW(), NOW(), $3)',
      parameters: [
        title,
        description,
        userId,
      ],
    );

    print('Category created!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error creating category: $e');
    rethrow;
  }
}

// LISTAR CATEGORIA

Future<List<dynamic>> getCategories(String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para buscar categorias
    final results = await conn!.execute(
      r'SELECT category_id, title, description, updated_at FROM categories WHERE user_id = $1',
      parameters: [userId],
    );

    // Finalizo a conexão com o banco
    await conn.close();

    // Retorno os dados da categoria já formatados no padrão necessário
    return results
        .map((row) => {
              'category_id': row[0],
              'title': row[1],
              'description': row[2],
              'updated_at': row[3],
            })
        .toList();
  } catch (e) {
    print('Error listing category: $e');
    rethrow;
  }
}

// ATUALIZAR CATEGORIA

Future<void> updateCategory(
    String title, String description, int id, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para atualizar categorias
    await conn!.execute(
      r'UPDATE categories SET title = $1, description = $2, updated_at = NOW() WHERE category_id = $3 AND user_id = $4',
      parameters: [
        title,
        description,
        id,
        userId,
      ],
    );

    print('Category updated!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error updating category: $e');
    rethrow;
  }
}

// EXCLUIR CATEGORIA

Future<List<dynamic>> deleteCategory(int id, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Verifico se há transações associadas a esta categoria
    final results = await conn!.execute(
      r'SELECT title FROM transactions WHERE category_id = $1',
      parameters: [id],
    );

    if (results.isNotEmpty) {
      // Se houver transações, retorno a lista de transações
      await conn.close();
      return results.map((row) => {'title': row[0]}).toList();
    }

    // Se não houver transações, excluo a categoria
    await conn!.execute(
      r'DELETE FROM categories WHERE category_id = $1 AND user_id = $2',
      parameters: [id, userId],
    );

    print('Category deleted!');

    // Finalizo a conexão com o banco
    await conn.close();

    // Retorno uma lista vazia, indicando que a categoria foi excluída
    return [];
  } catch (e) {
    print('Error deleting category: $e');
    rethrow;
  }
}
