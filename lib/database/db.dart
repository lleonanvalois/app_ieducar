import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_ieducar/globals.dart' as globals;

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
      version: 4, // Aumentar a versão para incluir a nova tabela
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Criação da tabela de usuários
    await db.execute('''CREATE TABLE ${globals.cTabUsuario}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Criação da tabela de pontos
    await db.execute('''
      CREATE TABLE ${globals.cTabPonto} (
       id_ponto INTEGER PRIMARY KEY AUTOINCREMENT,
       no_ponto TEXT NOT NULL,
       ds_ponto TEXT NOT NULL,
       nu_latitude REAL NOT NULL,
       nu_longitude REAL NOT NULL,
       dh_ponto TEXT NOT NULL,
       id_usuario INTEGER,
       FOREIGN KEY (id_usuario) REFERENCES ${globals.cTabUsuario}(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE ${globals.cTabCoordenada}(
        id_coordenada INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        dh_coordenada TEXT NOT NULL, 
        nu_latitude REAL NOT NULL,
        nu_longitude REAL NOT NULL,
        FOREIGN KEY (id_usuario) REFERENCES ${globals.cTabUsuario}(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE ${globals.cTabPonto}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          no_ponto TEXT NOT NULL,
          ds_ponto TEXT NOT NULL,
          nu_latitude REAL NOT NULL,
          nu_longitude REAL NOT NULL,
          dh_ponto TEXT NOT NULL,
          id_usuario INTEGER,
          FOREIGN KEY (usuario_id) REFERENCES ${globals.cTabUsuario}(id)
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS ${globals.cTabCoordenada}');
      await db.execute('''
        CREATE TABLE ${globals.cTabCoordenada}(
        id_coordenada INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        dh_coordenada TEXT NOT NULL,
        nu_latitude REAL NOT NULL,
        nu_longitude REAL NOT NULL,
        FOREIGN KEY (id_usuario) REFERENCES ${globals.cTabUsuario}(id)
      )
    ''');
    }
  }

  // Métodos para usuários
  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return await db.insert(globals.cTabUsuario, {
      'username': username,
      'password': password,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final results = await db.query(
      globals.cTabUsuario,
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
    return await db.insert(globals.cTabPonto, ponto);
  }

  Future<List<Map<String, dynamic>>> getPontos() async {
    final db = await database;
    return await db.query(globals.cTabPonto);
  }

  Future<int> updatePonto(int id, Map<String, dynamic> ponto) async {
    final db = await database;
    return await db.update(
      globals.cTabPonto,
      ponto,
      where: 'id_ponto = ?',
      whereArgs: [id],
    );
  }

  //editar ponto no mapa

  Future<int> updateCoordenada(int id, Map<String, dynamic> coordenada) async {
    final db = await database;
    return await db.update(
      globals.cTabCoordenada,
      coordenada,
      where: 'id_coordenada = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePonto(int id) async {
    final db = await database;
    return await db.delete(
      globals.cTabPonto,
      where: 'id_ponto  = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getRotas() async {
    final db = await database;
    return await db.query(
      globals.cTabCoordenada,
      where: 'id_usuario = ?',
      whereArgs: [1],
      orderBy: 'dh_coordenada ASC',
    );
  }

  Future<int> insertPontoRota(double latitude, double longitude) async {
    final db = await database;
    return await db.insert(globals.cTabCoordenada, {
      'nu_latitude': latitude,
      'nu_longitude': longitude,
      'dh_coordenada': DateTime.now().millisecondsSinceEpoch,
      'id_usuario': 1,
    });
  }
}
