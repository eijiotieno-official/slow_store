import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:slow_store/src/utils.dart';

/// The SlowStore class provides methods for creating and managing databases.
class SlowStore {
  /// Creates a new database with the specified name.
  ///
  /// If a database with the same name already exists, it will be opened.
  ///
  /// [name]: The name of the database file (e.g., 'my_database.json').
  static DataBase database({required String name}) {
    return DataBase(database: name);
  }
}

/// The DataBase class represents a database that contains multiple entries.
class DataBase {
  final String database;

  /// Creates a DataBase instance with the specified name.
  ///
  /// [database]: The name of the database file (e.g., 'my_database.json').
  DataBase({required this.database});

  /// Creates a new Entry instance to work with individual data entries within the database.
  ///
  /// [id]: The optional ID for the entry. If not specified, a unique ID will be generated.
  Entry entry([String id = ""]) {
    return Entry(database: database, id: id);
  }

  /// Deletes the entire database.
  void delete() async {
    await deleteFile(database: database);
  }

  /// Renames the database to a new name.
  ///
  /// [newName]: The new name for the database.
  void rename({required String newName}) async {
    await renameFile(database: database, newName: newName);
  }
}

/// The Entry class represents an individual data entry within a database.
class Entry {
  final String database;
  final String id;

  /// Creates an Entry instance with the specified database name and entry ID.
  Entry({
    required this.database,
    required this.id,
  });

  /// Adds data into the specified database.
  ///
  /// [data]: A map containing the data to be added.
  ///
  /// If [id] is not specified, a unique ID will be generated for the entry.
  ///
  /// Data types that cannot be encoded will be filtered out.
  Future<void> create({required Map<String, dynamic> data}) async {
    //Get the file that holds data in the specified [database]
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

  /// Get a specific data is [id] is specified or return the all the data in the database if [id] is not specified
  Future<dynamic> read() async {
    List<Map<String, dynamic>> results = [];
    Map<String, dynamic> result = {};
    bool entryExists = true;
    //Get the file that holds data in the specified [database]
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

  /// Update an existing data entry.
  ///
  /// [data]: A map containing the updated data.
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

  /// Deletes the data entry.
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
