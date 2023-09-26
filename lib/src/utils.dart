import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Directory> get appDocumentsDirectory async {
  return await getApplicationDocumentsDirectory();
}

Future<File?> createFile({required String database}) async {
  final Directory directory = await appDocumentsDirectory;
  File file = File("${directory.path}/$database.json");
  await file.create(recursive: true);
  return file;
}

Future<File?> deleteFile({required String database}) async {
  final Directory directory = await appDocumentsDirectory;
  File file = File("${directory.path}/$database.json");
  await file.delete(recursive: true);
  return file;
}

Future<File?> renameFile(
    {required String database, required String newName}) async {
  final Directory directory = await appDocumentsDirectory;
  File file = File("${directory.path}/$database.json");
  await file.rename("${directory.path}/$newName.json");
  return file;
}

Future<bool> exists({required String database}) async {
  final Directory directory = await appDocumentsDirectory;
  File file = File("${directory.path}/$database.json");
  return await file.exists();
}

Future<File?> databaseFile({required String database}) async {
  final Directory directory = await appDocumentsDirectory;
  File? file;
  await exists(database: database).then(
    (exists) async {
      if (exists) {
        file = File("${directory.path}/$database.json");
      } else {
        await createFile(database: database).then(
          (created) {
            if (created != null) {
              file = created;
            }
          },
        );
      }
    },
  );
  return file;
}

String generatedID() {
  String characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();
  String id = '';

  for (int i = 0; i < characters.length; i++) {
    int randomIndex = random.nextInt(characters.length);
    id += characters[randomIndex];
  }

  return id;
}

Future<Map<String, dynamic>> processedData(
    {required Map<String, dynamic> data}) async {
      
  Map<String, dynamic> output = {};

  try {
    data.forEach((key, value) {
      if (value is DateTime) {
        output[key] = value.toIso8601String();
      } else if (_isSupportedType(value)) {
        output[key] = value;
      } else {
        throw FormatException("Unsupported type encountered for key '$key'");
      }
    });
  } catch (e) {
    throw Exception("Error processing data: $e");
  }

  return output;
}

bool _isSupportedType(dynamic value) {
  return value is String ||
      value is num ||
      value is bool ||
      value is DateTime ||
      value is Map<String, dynamic> ||
      value is List<dynamic>;
}
