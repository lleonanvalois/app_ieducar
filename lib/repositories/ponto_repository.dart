import 'package:app_ieducar/database/db.dart';
import 'package:app_ieducar/models/ponto.dart';

class PontoRepository {
  static Future<List<Ponto>> carregarPontos() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('pontos');
    return List.generate(maps.length, (i) {
      return Ponto.fromMap(maps[i]);
    });
  }

  static Future<void> salvarPonto(Ponto ponto) async {
    final db = await DatabaseHelper().database;
    if (ponto.id == null) {
      await db.insert('pontos', ponto.toMap());
    } else {
      await db.update(
        'pontos',
        ponto.toMap(),
        where: 'id = ?',
        whereArgs: [ponto.id],
      );
    }
  }

  static Future<void> excluirPonto(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('pontos', where: 'id = ?', whereArgs: [id]);
  }
}
