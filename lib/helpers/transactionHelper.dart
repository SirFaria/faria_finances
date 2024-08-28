import 'package:faria_finances/database/config.dart';

// CRIAR TRANSAÇÃO

Future<void> createTransaction(
    String title,
    String description,
    double value,
    String type,
    int categoryId,
    int cashierId,
    DateTime transactionDate,
    String? userId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para cadastrar marcadores
    await conn!.execute(
      r'INSERT INTO transactions (title, description, value, transaction_type, category_id, cashier_id, transaction_date, created_at, updated_at, user_id) VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW(), NOW(), $8)',
      parameters: [
        title,
        description,
        value,
        type,
        categoryId,
        cashierId,
        transactionDate, // NAO UTILIZADO POR ENQUANTO
        userId,
      ],
    );

    print('Transaction created!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error creating Transaction: $e');
    rethrow;
  }
}

// LISTAR TRANSAÇÕES

Future<List<dynamic>> getTransactions(String? userId, String cashierId) async {
  try {
    // Verifico se o usuário está logado, caso não estiver, um erro será gerado
    if (userId == null) {
      throw Error();
    }

    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para buscar marcadores
    final results = await conn!.execute(
      r'SELECT transaction_id, title, description, value, transaction_type, category_id, transaction_date, created_at, updated_at FROM tags WHERE user_id = $1 AND cashier_id = $2',
      parameters: [userId, cashierId],
    );

    // Finalizo a conexão com o banco
    await conn.close();

    // Retorno os dados do marcador já formatados no padrão necessário
    return results
        .map((row) => {
              'transaction_id': row[0],
              'title': row[1],
              'description': row[2],
              'value': row[3],
              'transaction_type': row[4],
              'category_id': row[5],
              'transaction_date': row[6],
              'created_at': row[7],
            })
        .toList();
  } catch (e) {
    print('Error listing tag: $e');
    rethrow;
  }
}
