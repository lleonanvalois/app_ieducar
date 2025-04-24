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

    return await openDatabase(
      path,
      version: 2, // Aumente a versão para incluir a nova tabela
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Criação da tabela de usuários
    await db.execute('''
    CREATE TABLE TBL_usuario(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    )
  ''');

    // Criação da tabela de pontos
    await db.execute('''
    CREATE TABLE TBL_ponto(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      data TEXT NOT NULL,
      usuario_id INTEGER,
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    )
  ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE TBL_ponto(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        descricao TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        data TEXT NOT NULL,
        usuario_id INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');
    }
  }

  // Métodos para usuários
  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return await db.insert('usuarios', {
      'username': username,
      'password': password,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

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

  Future<bool> validateUser(String username, String password) async {
    final user = await getUser(username);
    return user != null && user['password'] == password;
  }

  // Métodos para pontos
  Future<int> insertPonto(Map<String, dynamic> ponto) async {
    final db = await database;
    return await db.insert('pontos', ponto);
  }

  Future<List<Map<String, dynamic>>> getPontos() async {
    final db = await database;
    return await db.query('pontos');
  }

  Future<int> updatePonto(int id, Map<String, dynamic> ponto) async {
    final db = await database;
    return await db.update('pontos', ponto, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePonto(int id) async {
    final db = await database;
    return await db.delete('pontos', where: 'id = ?', whereArgs: [id]);
  }
}
