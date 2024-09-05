import 'package:faria_finances/database/config.dart';

// CRIAR MARCADOR

Future<void> createTag(String title, String description, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para cadastrar marcadores
    await conn!.execute(
      r'INSERT INTO tags (title, description, created_at, updated_at, user_id) VALUES ($1, $2, NOW(), NOW(), $3)',
      parameters: [
        title,
        description,
        userId,
      ],
    );

    print('Tag created!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error creating Tag: $e');
    rethrow;
  }
}

// LISTAR MARCADORES

Future<List<dynamic>> getTags(String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para buscar marcadores
    final results = await conn!.execute(
      r'SELECT tag_id, title, description, updated_at FROM tags WHERE user_id = $1',
      parameters: [userId],
    );

    // Finalizo a conexão com o banco
    await conn.close();

    // Retorno os dados do marcador já formatados no padrão necessário
    return results
        .map((row) => {
              'tag_id': row[0],
              'title': row[1],
              'description': row[2],
              'updated_at': row[3],
            })
        .toList();
  } catch (e) {
    print('Error listing tag: $e');
    rethrow;
  }
}

// ATUALIZAR MARCADOR

Future<void> updateTag(
    String title, String description, int id, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para atualizar tags
    await conn!.execute(
      r'UPDATE tags SET title = $1, description = $2, updated_at = NOW() WHERE tag_id = $3 AND user_id = $4',
      parameters: [
        title,
        description,
        id,
        userId,
      ],
    );

    print('Tag updated!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error updating tag: $e');
    rethrow;
  }
}

// EXCLUIR MARCADOR

Future<List<dynamic>> deleteTag(int id, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Verifico se há transações associadas a este marcador
    final results = await conn!.execute(
      r'SELECT transaction_id FROM transaction_tags WHERE tag_id = $1',
      parameters: [id],
    );

    if (results.isNotEmpty) {
      // Se houver transações, retorno a lista de transações
      await conn.close();
      return results.map((row) => {'title': row[0]}).toList();
    }

    // Se não houver transações, excluo o marcador
    await conn!.execute(
      r'DELETE FROM tags WHERE tag_id = $1 AND user_id = $2',
      parameters: [id, userId],
    );

    print('Tag deleted!');

    // Finalizo a conexão com o banco
    await conn.close();

    // Retorno uma lista vazia, indicando que o marcador foi excluído
    return [];
  } catch (e) {
    print('Error deleting tag: $e');
    rethrow;
  }
}
