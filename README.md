This is a submission made for Mobile Programming Course.

# todo_app

A simple flutter todo app that was built on top of generative ai prompts.

| Name | NRP |  
| --- | --- |
| Muhammad Nabil Akhtar Raya Amoriza | 5025221021 |

## ObjectBox | Task 2
This is an updated version of my previous flutter app implementation being a simple todo app. It previously used a local storage system via variables, thus subject to deletion once the app shuts down.  
ObjectBox, however, is a proper NoSQL local database. Its fast and intuitive that supports both Android and iOS, which outperformes any other mobile database across all CRUD operations.


### Getting Started
Simply run this command in order to add ObjectBox to any of your projects
```shell
flutter pub add objectbox objectbox_flutter_libs:any
flutter pub add --dev build_runner objectbox_generator:any
flutter pub get
```

After which, you can start by configuring your objects / entities in a dedicated `models` folder or a compiled `models.dart` file, which i do [here](lib\models.dart), totally up to you. In this case, I'll be creating a todo entity consisting of:
- int id
- string title
- string description
- bool completed

Make sure to import the `objectbox.dart` file within that models file and an `@Entity()` tag so that the builder knows the appropriate code. Run the code below to generate the configurations to create your entities.
```shell
dart run build_runner build
```

Don't forget to also create a store, an interface that serves as the entry point while using ObjectBox. If you're done with all that, add these additional imports to your main file, another lines there, and you're all set.
```dart
//...
import 'package:objectbox/objectbox.dart';
import 'objectbox_store.dart';
import 'objectbox.g.dart';
import 'models.dart';

late ObjectBox objectBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();
  runApp(const MyApp());
}
//...
```
---

## Features | Task 1
- Create tasks
- Edit existing tasks
- Check them as done
- Filter as done
- Delete tasks by swiping left

Video Demo https://youtu.be/ikyX-Ma53og

## Getting Started

```
flutter pub get
flutter run
```
