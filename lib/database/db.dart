import 'dart:async';

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
       nu_latitude REAL NOT NULL,
       nu_longitude REAL NOT NULL,
       dh_ponto TEXT,
       id_usuario INTEGER,
       FOREIGN KEY (id_usuario) REFERENCES ${globals.cTabUsuario}(id)
      )
    ''');

    // Criação da tabela de coordenadas
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

    // Criação da tabela de parâmetros
    await db.execute('''
      CREATE TABLE ${globals.cTabParametro}( 
        no_parametro TEXT PRIMARY KEY NOT NULL,
        vl_parametro TEXT NOT NULL)
    
    ''');

    // Criação da tabela de rotas
    await db.execute('''
      CREATE TABLE ${globals.cTabRota}(
      id_rota INTEGER PRIMARY KEY,
      nu_ano INTEGER NOT NULL,
      no_rota INTEGER NOT NULL,
      id_destino INTEGER,
      no_destino INTEGER,
      ds_rota_tipo TEXT,
      is_transportadora INTEGER,
      no_transportadora TEXT,
      is_terceirizado TEXT
      )
 ''');

    // Criação da tabela rota ponto
    await db.execute('''
      CREATE TABLE ${globals.ctabRotaPonto}(
      id_itinerario INTEGER PRIMARY KEY,
      id_rota INTEGER,
      id_ponto INTEGER,
      nu_sequencia INTEGER,
      hr_ponto TEXT NOT NULL,
      ds_rota_tipo TEXT NOT NULL,
      FOREIGN KEY (id_rota) REFERENCES ${globals.cTabRota}(id_rota),
      FOREIGN KEY (id_ponto) REFERENCES ${globals.cTabPonto}(id_ponto)
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

  //Métodos para inserir rotas
  Future<int> insertRota(Map<String, dynamic> rota) async {
    final db = await database;
    return await db.insert(globals.cTabRota, rota);
  }

  // Método para inserir rota_ponto
  Future<int> insertRotaPonto(Map<String, dynamic> rotaPonto) async {
    final db = await database;
    return await db.insert(globals.ctabRotaPonto, rotaPonto);
  }

  // Método para verificar se o parametro existe
  // Se existir atualiza o valor, se não existir insere o novo
  Future<int> fnAddParametro(String pNoParametro, String pVlParametro) async {
    final db = await database;
    final result = await db.query(
      globals.cTabParametro,
      where: 'no_parametro = ?',
      whereArgs: [pNoParametro],
    );
    if (result.isNotEmpty) {
      return await db.update(
        globals.cTabParametro,
        {'no_parametro': pNoParametro, 'vl_parametro': pVlParametro},
        where: 'no_parametro = ?',
        whereArgs: [pNoParametro],
      );
    } else {
      return await db.insert(globals.cTabParametro, {
        'no_parametro': pNoParametro,
        'vl_parametro': pVlParametro,
      });
    }
  }

  // Métordo para retornar parametro
  // Retorna o valor do parametro, se não existir retorna o valor padrão
  Future<String> fnRetParametro(String pNoParametro, String pDefault) async {
    final db = await database;
    final ret = await db.query(
      globals.cTabParametro,
      where: 'no_parametro = ?',
      whereArgs: [pNoParametro],
    );
    if (ret.isNotEmpty) {
      return ret[0]['vl_parametro'] as String;
    } else {
      return pDefault;
    }
  }

  Future<List<Map<String, dynamic>>> getPontos() async {
    final db = await database;
    return await db.query(globals.cTabPonto);
  }

  // Método para retornar apenas um ponto de um usuário
  Future<Map<String, dynamic>?> getPonto(int id) async {
    final db = await database;
    final results = await db.query(
      globals.cTabPonto,
      where: 'id_ponto = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
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
