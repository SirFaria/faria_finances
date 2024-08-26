import 'package:faria_finances/database/config.dart';

// CRIAR CAIXA

Future<void> createCashier(
    double balance, String description, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para cadastrar caixas
    await conn!.execute(
      r'INSERT INTO cashier (balance, description, user_id) VALUES ($1, $2, $3)',
      parameters: [
        balance,
        description,
        userId,
      ],
    );

    print('Cashier created!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error creating cashier: $e');
    rethrow;
  }
}

// LISTAR CAIXAS

Future<List<dynamic>> getCashiers(String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para buscar caixas
    final results = await conn!.execute(
      r'SELECT cashier_id, balance, description FROM cashier WHERE user_id = $1',
      parameters: [userId],
    );

    // Finalizo a conexão com o banco
    await conn.close();

    // Retorno os dados do caixa já formatados no padrão necessário
    return results
        .map((row) => {
              'cashier_id': row[0],
              'balance': row[1],
              'description': row[2],
            })
        .toList();
  } catch (e) {
    print('Error listing cashier: $e');
    rethrow;
  }
}

// ATUALIZAR CAIXA

Future<void> updateCashier(
    double balance, String description, int id, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para atualizar caixas
    await conn!.execute(
      r'UPDATE cashier SET balance = $1, description = $2 WHERE cashier_id = $3 AND user_id = $4',
      parameters: [
        balance,
        description,
        id,
        userId,
      ],
    );

    print('Cashier updated!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error updating cashier: $e');
    rethrow;
  }
}

// EXCLUIR MARCADOR

Future<void> deleteCashier(int id, String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para excluir caixas
    await conn!.execute(
      r'DELETE FROM cashier WHERE cashier_id = $1 AND user_id = $2',
      parameters: [id, userId],
    );

    print('Cashier deleted!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error deleting cashier: $e');
    rethrow;
  }
}
