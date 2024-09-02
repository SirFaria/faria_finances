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
  List<String> tagIds, // Adiciona o parâmetro de tagIds
) async {
  try {
    // Faço a conexão com o banco
    final conn = await database();

    // Executa a query para cadastrar a transação e retorna o ID da transação criada
    final transactionResult = await conn!.execute(
      r'''
      INSERT INTO transactions (
        title, description, value, transaction_type, category_id, cashier_id, transaction_date, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
      RETURNING transaction_id
      ''',
      parameters: [
        title,
        description,
        value,
        type,
        categoryId,
        cashierId,
        transactionDate,
      ],
    );

    // Obtém o ID da transação criada
    final transactionId = transactionResult[0][0];

    // Insere as tags associadas na tabela transaction_tags
    for (final tagId in tagIds) {
      await conn.execute(
        r'INSERT INTO transaction_tags (transaction_id, tag_id) VALUES ($1, $2)',
        parameters: [transactionId, tagId],
      );
    }

    print('Transaction and tags created successfully!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error creating transaction and tags: $e');
    rethrow;
  }
}

// LISTAR TRANSAÇÕES

Future<List<dynamic>> getTransactions(String cashierId) async {
  try {
    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para buscar transações com detalhes de categorias e tags
    final transactionResults = await conn!.execute(
      r'''
      SELECT
        t.transaction_id,
        t.title,
        t.description,
        t.value,
        t.transaction_type,
        c.title AS category_title,
        c.category_id as category_id,
        t.transaction_date,
        (
          SELECT array_agg(tag.title)
          FROM transaction_tags tt
          JOIN tags tag ON tt.tag_id = tag.tag_id
          WHERE tt.transaction_id = t.transaction_id
        ) AS tag_titles,
        (
          SELECT array_agg(tag.tag_id)
          FROM transaction_tags tt
          JOIN tags tag ON tt.tag_id = tag.tag_id
          WHERE tt.transaction_id = t.transaction_id
        ) AS tag_ids
      FROM transactions t
      LEFT JOIN categories c ON t.category_id = c.category_id
      WHERE t.cashier_id = $1
      ''',
      parameters: [cashierId],
    );

    // Finalizo a conexão com o banco
    await conn.close();

    // Retorno os dados da transação já formatados no padrão necessário
    return transactionResults
        .map((row) => {
              'transaction_id': row[0],
              'title': row[1],
              'description': row[2],
              'value': row[3],
              'transaction_type': row[4],
              'category_title': row[5],
              'category_id': row[6],
              'transaction_date': row[7],
              'tag_titles': row[8] ?? [],
              'tag_ids': row[9] ?? [],
            })
        .toList();
  } catch (e) {
    print('Error listing transactions: $e');
    rethrow;
  }
}

// EDITAR TRANSAÇÕES

Future<void> updateTransaction(
  int transactionId, // Adiciona o parâmetro para o ID da transação
  String title,
  String description,
  double value,
  String type,
  int categoryId,
  int cashierId,
  DateTime transactionDate,
  List<int> tagIds, // Parâmetro para IDs de tags
) async {
  try {
    // Faz a conexão com o banco
    final conn = await database();

    // Atualiza os detalhes da transação na tabela transactions
    await conn!.execute(
      r'''
      UPDATE transactions
      SET title = $1,
          description = $2,
          value = $3,
          transaction_type = $4,
          category_id = $5,
          cashier_id = $6,
          transaction_date = $7,
          updated_at = NOW()
      WHERE transaction_id = $8
      ''',
      parameters: [
        title,
        description,
        value,
        type,
        categoryId,
        cashierId,
        transactionDate,
        transactionId, // Utiliza o ID da transação para encontrar e atualizar a transação
      ],
    );

    // Remove todas as tags antigas associadas à transação
    await conn.execute(
      r'DELETE FROM transaction_tags WHERE transaction_id = $1',
      parameters: [transactionId],
    );

    // Adiciona as novas tags associadas à transação
    for (final tagId in tagIds) {
      await conn.execute(
        r'INSERT INTO transaction_tags (transaction_id, tag_id) VALUES ($1, $2)',
        parameters: [transactionId, tagId],
      );
    }

    print('Transaction and tags updated successfully!');

    // Finaliza a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error updating transaction and tags: $e');
    rethrow;
  }
}

// EXCLUIR MARCADOR

Future<void> deleteTransaction(int transactionId) async {
  try {
    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para excluir transações
    await conn!.execute(
      r'DELETE FROM transactions WHERE transaction_id = $1',
      parameters: [transactionId],
    );

    // Remove todas as tags antigas associadas à transação
    await conn.execute(
      r'DELETE FROM transaction_tags WHERE transaction_id = $1',
      parameters: [transactionId],
    );

    print('Transaction deleted!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error deleting transaction: $e');
    rethrow;
  }
}
