import 'package:filecrypt/vaultGrid.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableName="archive_table";
final String columnId="id";
final String columnArchiveName="archive_name";

class ArchiveDatabase {
  static final ArchiveDatabase instance = ArchiveDatabase._init();

  static Database? _database;

  ArchiveDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnArchiveName TEXT NOT NULL)
        ''');
  }

  Future<int>  add_new_archive(String archiveName) async {//ok check
    final db = await instance.database;
    int result = await db.rawInsert('INSERT INTO $tableName($columnArchiveName) VALUES("$archiveName")');
    return result;
  }

  Future<String> readVault(int id) async {
    final db = await instance.database;

    List<String> columnsToSelect = [columnArchiveName,];
    final results = await db.query(
      tableName,
      columns: columnsToSelect,
      where: '${columnId} = ?',
      whereArgs: [id],
    );
    String archive_name="";
    results.forEach((element)
    {
      var list=element.values.toList();
      archive_name=list[0].toString();
    });
    return archive_name;
  }

  Future<List<vaultData>> readAllVault() async {//ok check
    final db = await instance.database;
    var result = await db.query(tableName);
    List<vaultData> vaultDataList=[];
    result.forEach((element) {
      vaultData data=new vaultData();
      var list=element.values.toList();
      data.id=list[0] as int;
      data.vaultName=list[1].toString();
      vaultDataList.add(data);
    });
    return vaultDataList;
  }

  Future<int> update(int id,String new_archive_name) async {
    final db = await instance.database;
    Map<String, dynamic> row = {
      columnId : id,
      columnArchiveName : new_archive_name
    };
    return db.update(
      tableName,
      row,
      where: '${columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {//ok check
    final db = await instance.database;

    return await db.delete(
      tableName,
      where: '${columnId} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}