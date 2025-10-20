import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gestao_gado_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const doubleType = 'REAL';
    const intType = 'INTEGER';
    const boolType = 'INTEGER'; // SQLite não tem bool, usa 0/1

    // Tabela de pesagens offline
    await db.execute('''
      CREATE TABLE pesagens_offline (
        local_id $idType,
        animal_id $textType NOT NULL,
        animal_brinco $textType,
        peso_kg $doubleType NOT NULL,
        data_pesagem $textType NOT NULL,
        tipo_pesagem $textType,
        observacoes $textType,
        criado_em $textType NOT NULL,
        sincronizado $boolType NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de animais offline
    await db.execute('''
      CREATE TABLE animais_offline (
        local_id $idType,
        brinco $textType NOT NULL,
        nome $textType,
        grupo_id $textType,
        pai_id $textType,
        mae_id $textType,
        sexo $textType NOT NULL,
        tipo_pele $textType,
        raca $textType,
        data_nascimento $textType NOT NULL,
        peso_atual_kg $doubleType,
        url_imagem $textType,
        observacoes $textType,
        status $textType,
        criado_em $textType NOT NULL,
        sincronizado $boolType NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de eventos de saúde offline (vacinações)
    await db.execute('''
      CREATE TABLE saude_offline (
        local_id $idType,
        animal_id $textType NOT NULL,
        animal_brinco $textType,
        tipo_evento $textType NOT NULL,
        data_evento $textType NOT NULL,
        medicamento $textType,
        dose $textType,
        veterinario $textType,
        observacoes $textType,
        criado_em $textType NOT NULL,
        sincronizado $boolType NOT NULL DEFAULT 0
      )
    ''');

    // Tabela de cache de animais (para busca offline)
    await db.execute('''
      CREATE TABLE animais_cache (
        id $textType PRIMARY KEY,
        brinco $textType NOT NULL,
        nome $textType,
        sexo $textType,
        peso_atual_kg $doubleType,
        grupo_nome $textType,
        data_nascimento $textType,
        idade_meses $intType,
        atualizado_em $textType NOT NULL
      )
    ''');

    print('✅ Banco de dados local criado com sucesso!');
  }

  // ========== PESAGENS OFFLINE ==========

  Future<void> inserirPesagemOffline(Map<String, dynamic> pesagem) async {
    final db = await instance.database;
    await db.insert(
      'pesagens_offline',
      pesagem,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Pesagem salva offline: ${pesagem['animal_brinco']}');
  }

  Future<List<Map<String, dynamic>>> listarPesagensNaoSincronizadas() async {
    final db = await instance.database;
    return await db.query(
      'pesagens_offline',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
  }

  Future<void> marcarPesagemComoSincronizada(String localId) async {
    final db = await instance.database;
    await db.update(
      'pesagens_offline',
      {'sincronizado': 1},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<int> contarPesagensNaoSincronizadas() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pesagens_offline WHERE sincronizado = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ========== ANIMAIS OFFLINE ==========

  Future<void> inserirAnimalOffline(Map<String, dynamic> animal) async {
    final db = await instance.database;
    await db.insert(
      'animais_offline',
      animal,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Animal salvo offline: ${animal['brinco']}');
  }

  Future<List<Map<String, dynamic>>> listarAnimaisNaoSincronizados() async {
    final db = await instance.database;
    return await db.query(
      'animais_offline',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
  }

  Future<void> marcarAnimalComoSincronizado(String localId) async {
    final db = await instance.database;
    await db.update(
      'animais_offline',
      {'sincronizado': 1},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<int> contarAnimaisNaoSincronizados() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM animais_offline WHERE sincronizado = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ========== SAÚDE OFFLINE ==========

  Future<void> inserirSaudeOffline(Map<String, dynamic> saude) async {
    final db = await instance.database;
    await db.insert(
      'saude_offline',
      saude,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('✅ Evento de saúde salvo offline: ${saude['animal_brinco']}');
  }

  Future<List<Map<String, dynamic>>> listarSaudeNaoSincronizado() async {
    final db = await instance.database;
    return await db.query(
      'saude_offline',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
  }

  Future<void> marcarSaudeComoSincronizado(String localId) async {
    final db = await instance.database;
    await db.update(
      'saude_offline',
      {'sincronizado': 1},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<int> contarSaudeNaoSincronizado() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM saude_offline WHERE sincronizado = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ========== CACHE DE ANIMAIS ==========

  Future<void> salvarAnimaisNoCache(List<Map<String, dynamic>> animais) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var animal in animais) {
      batch.insert(
        'animais_cache',
        animal,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    print('✅ ${animais.length} animais salvos no cache');
  }

  Future<List<Map<String, dynamic>>> buscarAnimaisNoCache(String brinco) async {
    final db = await instance.database;
    return await db.query(
      'animais_cache',
      where: 'brinco LIKE ?',
      whereArgs: ['%$brinco%'],
      limit: 10,
    );
  }

  Future<Map<String, dynamic>?> buscarAnimalExatoNoCache(String brinco) async {
    final db = await instance.database;
    final results = await db.query(
      'animais_cache',
      where: 'brinco = ?',
      whereArgs: [brinco],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ========== UTILITÁRIOS ==========

  Future<Map<String, int>> contarTodosNaoSincronizados() async {
    return {
      'pesagens': await contarPesagensNaoSincronizadas(),
      'animais': await contarAnimaisNaoSincronizados(),
      'saude': await contarSaudeNaoSincronizado(),
    };
  }

  Future<void> limparDadosSincronizados() async {
    final db = await instance.database;
    await db.delete('pesagens_offline', where: 'sincronizado = 1');
    await db.delete('animais_offline', where: 'sincronizado = 1');
    await db.delete('saude_offline', where: 'sincronizado = 1');
    print('✅ Dados sincronizados limpos do banco local');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
