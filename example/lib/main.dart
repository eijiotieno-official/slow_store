import 'package:flutter/material.dart';
import 'package:slow_store/slow_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  createDataWithSpecifiedID(
      {required Map<String, dynamic> data, required String id}) {
    SlowStore.database(name: "name").entry(id).create(data: data);
  }

  createDataWithoutSpecifiedID({required Map<String, dynamic> data}) {
    SlowStore.database(name: "name").entry().create(data: data);
  }

  readSpecificEntryData({required String id}) {
    SlowStore.database(name: "name").entry(id).read().then(
      (value) {
        debugPrint(value);
      },
    );
  }

  readAllData() {
    SlowStore.database(name: "name").entry().read().then(
      (value) {
        debugPrint(value);
      },
    );
  }

  updateSpecificEntryData(
      {required String id, required Map<String, dynamic> data}) {
    SlowStore.database(name: "name").entry(id).update(data: data);
  }

  deleteSpecificEntryData({required String id}) {
    SlowStore.database(name: "name").entry(id).delete();
  }

  deleteDatabase({required String name}) {
    SlowStore.database(name: name).delete();
  }

  renameDatabase({required String oldName, required String newName}) {
    SlowStore.database(name: oldName).rename(newName: newName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SlowStore Examples"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ButtonWidget(
            action: () {
              createDataWithSpecifiedID(
                data: {
                  'name': "Eiji Otieno",
                  'hobby': 'Gaming',
                  'time': DateTime.now(),
                },
                id: "iddweewi3",
              );
            },
            title: "Create data with specified ID",
          ),
          ButtonWidget(
            action: () {
              createDataWithoutSpecifiedID(
                data: {
                  'name': "Eiji Otieno",
                  'hobby': 'Gaming',
                  'time': DateTime.now(),
                },
              );
            },
            title: "Create data without specified ID",
          ),
          ButtonWidget(
            action: () {
              readSpecificEntryData(id: "iddweewi3");
            },
            title: "Read a specific entry",
          ),
          ButtonWidget(
            action: () {
              readAllData();
            },
            title: "Read all entries in the database",
          ),
          ButtonWidget(
            action: () {
              updateSpecificEntryData(
                id: "iddweewi3",
                data: {
                  'name': "John",
                },
              );
            },
            title: "Update an entry",
          ),
          ButtonWidget(
            action: () {
              deleteSpecificEntryData(id: "iddweewi3");
            },
            title: "Delete an entry",
          ),
          ButtonWidget(
            action: () {
              deleteDatabase(name: "name");
            },
            title: "Delete a database",
          ),
          ButtonWidget(
            action: () {
              renameDatabase(oldName: "name", newName: "newName");
            },
            title: "Rename a database",
          ),
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final Function action;
  final String title;
  const ButtonWidget({super.key, required this.action, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FilledButton(
          onPressed: () {
            action();
          },
          child: Text(title),
        ),
      ),
    );
  }
}
