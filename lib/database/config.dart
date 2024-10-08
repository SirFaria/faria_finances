import 'package:postgres/postgres.dart';

Future database() async {
  final conn = await Connection.open(
    Endpoint(
        host: 'localhost',
        database: 'gestor_financas',
        username: 'postgres',
        password: 'admin',
        port: 5432),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
  print('Connected!');
  return conn;
}
