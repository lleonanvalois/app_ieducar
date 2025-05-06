import 'package:app_ieducar/database/db.dart';
import 'package:app_ieducar/models/ponto.dart';
import 'package:app_ieducar/globals.dart' as globals;

class PontoRepository {
  static Future<List<Ponto>> carregarPontos() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(globals.cTabPonto);
    return List.generate(maps.length, (i) {
      return Ponto.fromMap(maps[i]);
    });
  }

  static Future<void> salvarPonto(Ponto ponto) async {
    try {
      final db = await DatabaseHelper().database;
      if (ponto.id == null) {
        await db.insert(globals.cTabPonto, ponto.toMap());
      } else {
        await db.update(
          globals.cTabPonto,
          ponto.toMap(),
          where: 'id_ponto = ?',
          whereArgs: [ponto.id],
        );
      }
    } catch (e) {
      print("Error saving Ponto: $e");
      rethrow;
    }
  }

  static Future<void> excluirPonto(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete(globals.cTabPonto, where: 'id_ponto = ?', whereArgs: [id]);
  }
}
