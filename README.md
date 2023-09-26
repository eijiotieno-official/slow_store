# SlowStore

SlowStore package is a versatile local data storage solution for Flutter developers, designed to make data persistence with your Flutter applications easy and efficient.

## Key Features

- Store data as key-value pairs.
- Support for various data types, including strings, num, boolean, date time, map, list.
- Retrieve specific data or entire data in the database.
- Easily create, update or delete stored data.
- Easily rename or delete a database.
- Asynchronous operations for smooth user experiences.
- Highly customizable to adapt to your specific app requirements.

### NOTE : DateTime is converted to string for encoding, use DateTime.parse("time")

## Installation

```sh
flutter pub add slow_store
```

## Using

**Import the Package**: Import the package in your Dart code.

```dart
import 'package:slow_store/slow_store.dart';
```

### Add Data

- Create data into a <span style="color: GREEN">database</span> with a specified <span style="color: aqua">id</span>, if none is provided, one will be generated for the data created.

```dart
SlowStore.database(name: "name").entry(id).create(data: data);
```

### Update Data

- Update data of the specified <span style="color: aqua">id</span>
in the specified <span style="color: GREEN">database</span>.

```dart
SlowStore.database(name: "name").entry(id).update(data: data);
```

### Read Data

- Get a data in the specified <span style="color: aqua">id</span>
or all data in the specified <span style="color: GREEN">database</span>, depending on if the <span style="color: aqua">id</span> is provided or not.

#### Read a single enty's data

```dart
SlowStore.database(name: "name").entry(id).read();
```

#### Read all data in the database

```dart
SlowStore.database(name: "name").entry().read();
```

### Delete data

```dart
SlowStore.database(name: "name").entry(id).delete();
```

### Delete a database

```dart
SlowStore.database(name: name).delete();
```

### Rename a database

```dart
SlowStore.database(name: oldName).rename(newName: newName);
```

## Contributing

Contributions are welcome! If you find any bugs or want to add new features, feel free to submit issues or pull requests.
