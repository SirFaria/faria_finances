import 'package:postgres/postgres.dart';
import 'package:faria_finances/database/config.dart';

String? loggedUserId;
String loggedUserName = '';
String loggedUserEmail = '';

Future<void> createUser(String name, String email, String password) async {
  try {
    // Faço a conexão com o banco
    final conn = await database();

    final result = await conn.execute(
      Sql.named(' SELECT COUNT(*) AS count FROM users WHERE email = @email'),
      parameters: {'email': email},
    );

    if (result.isNotEmpty && result[0][0] >= 1) {
      throw ('email_already_exists');
    }

    // Executo a query para cadastrar usuário
    await conn!.execute(
      r'INSERT INTO users (name, email, password) VALUES ($1, $2, $3)',
      parameters: [
        name,
        email,
        password,
      ],
    );

    print('User created!');

    // Finalizo a conexão com o banco
    await conn.close();
  } catch (e) {
    print('Error creating user: $e');
    rethrow;
  }
}

Future<bool> loginUser(String email, String password) async {
  try {
    // Faço a conexão com o banco
    final conn = await database();

    // Executo a query para cadastrar usuário
    final result = await conn.execute(
      Sql.named(
          ' SELECT * FROM users WHERE email = @email AND password = @password'),
      parameters: {
        'email': email,
        'password': password,
      },
    );

    print(result.first.toColumnMap());

    // Finalizo a conexão com o banco
    await conn.close();

    print(result);

    // Verifico se o resultado retornado é válido e retorno um booleano para cada situação
    if (result.isNotEmpty) {
      loggedUserId = result[0][0].toString(); // Armazena o user_id globalmente
      loggedUserName =
          result[0][1].toString(); // Armazena o user_id globalmente
      loggedUserEmail =
          result[0][2].toString(); // Armazena o user_id globalmente
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error logging in: $e');
    return false;
  }
}
