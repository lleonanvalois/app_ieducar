import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'ieducar.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,  // Nome de usuário único
        password TEXT         // Senha
      )
    ''');
  }

  // Método para inserir usuário
  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return await db.insert('usuarios', {
      'username': username,
      'password': password,
    });
  }

  // Método para buscar usuário
  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final results = await db.query(
      'usuarios',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Método para verificar credenciais
  Future<bool> validateUser(String username, String password) async {
    final user = await getUser(username);
    return user != null && user['password'] == password;
  }
}
