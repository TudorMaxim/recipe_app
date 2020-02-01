import 'package:exam_app/domain/Entity.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  static Repository _dbRepository;
  static Database _database;
  final String entityName = "recipes";
  final String firstTableName = "recipes";
  final String secondTableName = 'types';
  final String dbName = "exam_app.db";

  Repository._createInstance();

  factory Repository() {
    if (_dbRepository == null) {
      _dbRepository = Repository._createInstance(); // singleton
    }
    return _dbRepository;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await init();
    }
    return _database;
  }

  Future<Database> init() async {
    String dbPath = join(await getDatabasesPath(), dbName);
    var database = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
    return database;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $firstTableName(
      id INTEGER PRIMARY KEY,
      name TEXT,
      details TEXT,
      time INTEGER,
      type TEXT,
      rating INTEGER)
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $secondTableName(
      type TEXT PRIMARY KEY)
  ''');
  }

  Future<List<Entity>> getAllFirstTable() async {
    final Database db = await database;
    final result = await db.query(firstTableName);
    int len = result.length;
    List <Entity> items = List <Entity>();
    for (int i = 0; i < len; i++) {
      items.add(Entity.fromMap(result[i]));
    }
    int cnt = items.length;
    print("DB: Successfully fetched $cnt items from $firstTableName table.");

    return items;
  }

  Future<List<String>> getAllSecondTable() async {
    final Database db = await database;
    final result = await db.query(secondTableName);
    int len = result.length;
    List <String> items = List <String>();
    for (int i = 0; i < len; i++) {
      items.add(result[i]['type']);
    }
    int cnt = items.length;
    print("DB: Successfully fetched $cnt items from $secondTableName table.");

    return items;
  }

  addFirstTable(Entity entity) async {
    final Database db = await database;
    int id = await db.insert(firstTableName, entity.toMap());
    print("DB: Successfully insert in $firstTableName table");
    return id;
  }

  addSecondTable(String type) async {
    final Database db = await database;
    Map <String, dynamic> map = Map();
    map['type'] = type;

    await db.insert(secondTableName, map);
    print("DB: Successfull insert in $secondTableName table");
  }

  updateFirstTable(int id, Entity newEntity) async {
    final Database db = await database;
    await db.update(
        firstTableName,
        newEntity.toMap(),
        where: "id = ?",
        whereArgs: [id]
    );
    print("DB: Successfully updated entity with id $id from $firstTableName table");
  }

  updateSecondTable(int id, Entity newEntity) async {
    final Database db = await database;
    await db.update(
        secondTableName,
        newEntity.toMap(),
        where: "id = ?",
        whereArgs: [id]
    );
    print("DB: Successfully updated entity with id $id from $secondTableName table");
  }

  deleteFirstTable(int id) async {
    final Database db = await database;
    await db.delete(
        firstTableName,
        where: "id = ?",
        whereArgs: [id]
    );
    print("DB: Successfully deleted entity with id $id from $firstTableName table");
  }

  deleteSecondTable(int id) async {
    final Database db = await database;
    await db.delete(
        secondTableName,
        where: "id = ?",
        whereArgs: [id]
    );
    print("DB: Successfully deleted entity with id $id from $secondTableName table");
  }

  Future clearDb() async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        var batch = txn.batch();
        batch.delete(firstTableName);
        batch.delete((secondTableName));
        await batch.commit();
      });
    } catch(error){
      throw Exception('DbBase.cleanDatabase: ' + error.toString());
    }
  }

  Future clearFirstTable() async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        var batch = txn.batch();
        batch.delete(firstTableName);
        await batch.commit();
      });
    } catch(error){
      throw Exception('DbBase.cleanDatabase: ' + error.toString());
    }
    print("DB: Successfully cleared $firstTableName table.");
  }

  Future clearSecondTable() async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        var batch = txn.batch();
        batch.delete(secondTableName);
        await batch.commit();
      });
    } catch(error){
      throw Exception('DbBase.cleanDatabase: ' + error.toString());
    }
    print("DB: Successfully cleared $secondTableName table.");
  }
}