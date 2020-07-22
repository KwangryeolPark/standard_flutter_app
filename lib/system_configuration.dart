import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SystemConfiguration {
  final String name;
  String status;
  SystemConfiguration({this.name, this.status});

  Map<String, dynamic> toMap() => {
    'name' : name,
    'status' : status,
  };
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




class SystemConfigurationDatabase {
  Database database;
  final String databaseName;

  SystemConfigurationDatabase({this.databaseName});

  Future<void> open(String tableName) async {
    database = await openDatabase(
      join(await getDatabasesPath(), '$databaseName.db'),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE $tableName(name TEXT PRIMARY KEY, status TEXT)"
        );
      },
      version: 1,
    );
  }

  Future<int> getCount(String tableName) async {
    var temp = await database.rawQuery('SELECT COUNT (*) FROM $tableName');
    return Sqflite.firstIntValue(temp);
  }

  Future<void> insert(String tableName, SystemConfiguration systemConfiguration) async {
    await database.insert(tableName, systemConfiguration.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, SystemConfiguration>> systemConfigurations(String tableName) async {
    final List<Map<String, dynamic>> maps = await database.query(tableName);
    return Map.fromIterable(
        maps,
        key: (element) => element.name,
        value: (element) => element
    );
  }

  Future<void> update(String tableName, SystemConfiguration systemConfiguration) async {
    await database.update(
        tableName,
        systemConfiguration.toMap(),
        where: 'name = ?',
        whereArgs: [systemConfiguration.name]
    );
  }

  Future<void> delete(String tableName, SystemConfiguration systemConfiguration) async {
    await database.delete(
        tableName,
        where: 'name = ?',
        whereArgs: [systemConfiguration.name]
    );
  }

  Future<void> generateTable(String tableName) async {
    await database.execute(
        "CREATE TABLE IF NOT EXISTS $tableName(name TEXT PRIMARY KEY, status TEXT)"
    );
  }
}

String systemConfigurationDatabaseName = 'systemConfiguration';
String systemConfigurationTableName = 'systemConfigurationTable';

SystemConfigurationDatabase systemConfigurationDatabase =
SystemConfigurationDatabase(databaseName: systemConfigurationDatabaseName);



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






Map<String, SystemConfiguration> defaultSystemConfiguration = {
  'systemConfigurationCount' : SystemConfiguration(name: 'systemConfigurationCount', status:'2'),
  'alreadySetted' : SystemConfiguration(name: 'alreadySetted', status: 'false'),
};
Map<String, SystemConfiguration> systemConfiguration;



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




Future initSystemConfiguration() async {
  debugPrint('initSystemConfiguration 매서드 시작');
  int tableRowCnt;
  debugPrint('$systemConfigurationDatabaseName Database를 오픈합니다.');
  await systemConfigurationDatabase.open(systemConfigurationTableName);  //open SystemConfiguration database

  debugPrint('$systemConfigurationTableName Table의 데이터 값의 개수를 알아냅니다.');
  tableRowCnt = await systemConfigurationDatabase.getCount(systemConfigurationTableName);  //read the number of rows in the table
  debugPrint(tableRowCnt.toString());

  if(tableRowCnt == 0) {  //if there are no rows in the table, and it means it is the first time
    debugPrint('$systemConfigurationDatabaseName Databse에 데이터가 없습니다.');
    debugPrint('Default data를 넣습니다.');

    defaultSystemConfiguration.forEach((key, value) async {
      await systemConfigurationDatabase.insert(systemConfigurationTableName, value);   //insert a default data
    });
    systemConfiguration = defaultSystemConfiguration;
    debugPrint('Default data 넣기 끝');
  } else {  //there are rows in the table, and it means it is not the first time
    if(systemConfiguration['alreadySetted'] == false) {
      debugPrint('$systemConfigurationDatabaseName Databse에 데이터가 없습니다.');
      debugPrint('Default data를 넣습니다.');

      defaultSystemConfiguration.forEach((key, value) async {
        await systemConfigurationDatabase.insert(systemConfigurationTableName, value);   //insert a default data
      });
      debugPrint('실재 사용될 변수에 값을 옮깁니다.');
      systemConfiguration = defaultSystemConfiguration;   //copy the default data to actual used data
      debugPrint('Default data 넣기 끝');
    } else {
      debugPrint('기존 데이터가 있습니다.');
      debugPrint('값 불러오기');
      systemConfiguration =
      await systemConfigurationDatabase.systemConfigurations(
          systemConfigurationTableName); //read data from database and store in systemConfiguration Map
      int dataCntInDatabase = int.parse(
          systemConfiguration['systemConfigurationCount']
              .status); //the number of data in stored database
      int defaultDataCnt = int.parse(
          defaultSystemConfiguration['systemConfigurationCount']
              .status); //the number of data in default data
      if (dataCntInDatabase != defaultDataCnt) { //if there are new data
        debugPrint('Default 데이터 개수와 저장된 데이터 개수가 다릅니다.');
        defaultSystemConfiguration.forEach((key, value) { //data for each key
          if (!systemConfiguration.containsKey(key)) { //if there is no key
            debugPrint('없는 데이터 key : $key\tvalue : $value');
            systemConfiguration[key] = SystemConfiguration(name: key,
                status: value
                    .status); //copy the data to systemConfiguration value
            systemConfigurationDatabase.insert(systemConfigurationTableName,
                systemConfiguration[key]); //store the data to database
          }
        });
      }
    }
  }
  debugPrint('initSystemConfiguration 매서드 끝');
}

bool isAppReady() {
  if(systemConfiguration['alreadySetted'].status == 'false') return false;
  return true;
}

Function setAppReady() {
  systemConfiguration['alreadySetted'].status = 'true';
  systemConfigurationDatabase.insert(systemConfigurationTableName, systemConfiguration['alreadySetted']);
}