import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:slow_store/src/utils.dart';

class SlowStore {
  static DataBase database({required String name}) {
    return DataBase(database: name);
  }
}

class DataBase {
  final String database;
  DataBase({required this.database});

  Entry entry([String id = ""]) {
    return Entry(database: database, id: id);
  }

  void delete() async {
    await deleteFile(database: database);
  }

  void rename({required String newName}) async {
    await renameFile(database: database, newName: newName);
  }
}

class Entry {
  final String database;
  final String id;

  Entry({
    required this.database,
    required this.id,
  });

  //Add data into the specified [database]
  Future<void> create({required Map<String, dynamic> data}) async {
    //Get the file that hold data in the specified [database]
    File? file = await databaseFile(database: database);
    if (file != null) {
      final content = await file.readAsString();
      List<dynamic> jsonList = [];
      if (content.isNotEmpty) {
        jsonList = jsonDecode(content) as List<dynamic>;
      }
      if (id.isNotEmpty) {
        //If [id] is specified, add a key-value of it into the data
        data['id'] = id;
      } else {
        //If not specified, create generate an id and add a key-value of it into the data
        //Ensure there is no duplicated id in the database
        String nID = generatedID();
        bool contains = jsonList.any((element) => element['id'] == nID);
        if (contains) {
          data['id'] = nID + generatedID() + generatedID();
        } else {
          data['id'] = nID;
        }
      }
      //Filter out data types that can not be encoded
      Map<String, dynamic> processed = await processedData(data: data);
      //Add the new data
      jsonList.add(processed);
      jsonList.removeWhere((element) => element.isEmpty);
      try {
        //write the updated data into the database file
        await file.writeAsString(jsonEncode(jsonList)).then(
          (_) {
            debugPrint("Successfully added : $data");
          },
        );
      } catch (e) {
        throw Exception("Error: $e");
      }
    }
  }

  //Get a specific data is [id] is specified or return the all the data in the database if [id] is not specified
  Future<dynamic> read() async {
    List<Map<String, dynamic>> results = [];
    Map<String, dynamic> result = {};
    bool entryExists = true;
    //Get the file that hold data in the specified [database]
    File? file = await databaseFile(database: database);
    if (file != null) {
      final content = await file.readAsString();
      List<dynamic> jsonList = [];
      if (content.isNotEmpty) {
        jsonList = jsonDecode(content) as List<dynamic>;
        if (id.isNotEmpty) {
          //Get the specific data that matches the specified [id]
          bool contains = jsonList.any((element) => element['id'] == id);
          if (contains) {
            result = jsonList.firstWhere((element) => element['id'] == id);
          } else {
            //Data matching the specified [id] is present
            debugPrint("Entry doesn't exist");
            entryExists = false;
          }
        } else {
          //Get all data in the database
          for (var element in jsonList) {
            results.add(element);
          }
        }
      }
    }
    return entryExists == false
        ? null
        : id.isNotEmpty
            ? result
            : results;
  }

  Future<void> update({required Map<String, dynamic> data}) async {
    if (id.isEmpty) {
      throw Exception("Entry id is empty");
    } else {
      File? file = await databaseFile(database: database);
      if (file != null) {
        final content = await file.readAsString();
        List<dynamic> jsonList = [];
        if (content.isNotEmpty) {
          jsonList = jsonDecode(content) as List<dynamic>;
        }

        bool contains = jsonList.any((element) => element['id'] == id);
        if (contains == false) {
          debugPrint("Entry doesn't exist");
        } else {
          int index = jsonList
              .indexOf(jsonList.firstWhere((element) => element['id'] == id));

          Map<String, dynamic> storedData = jsonList[index];

          data.forEach(
            (key, value) {
              if (storedData.containsKey(key)) {
                storedData[key] = value;
              } else {
                storedData[key] = value;
              }
            },
          );

          jsonList.removeAt(index);

          Map<String, dynamic> processed =
              await processedData(data: storedData);

          jsonList.add(processed);

          await file.writeAsString(jsonEncode(jsonList)).then(
            (_) {
              debugPrint("Updated Successfully");
            },
          );
        }
      }
    }
  }

  Future<void> delete() async {
    File? file = await databaseFile(database: database);
    if (file != null) {
      if (id.isEmpty) {
        throw Exception("Entry id is empty");
      } else {
        final content = await file.readAsString();
        List<dynamic> jsonList = [];
        if (content.isNotEmpty) {
          jsonList = jsonDecode(content) as List<dynamic>;
        }
        int index = jsonList
            .indexOf(jsonList.firstWhere((element) => element['id'] == id));
        jsonList.removeAt(index);
        await file.writeAsString(jsonEncode(jsonList)).then(
          (_) {
            debugPrint("Deleted Successfully");
          },
        );
      }
    }
  }
}
