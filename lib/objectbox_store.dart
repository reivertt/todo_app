import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'objectbox.g.dart';
import 'models.dart';

class ObjectBox {
  late final Store store;
  late final Box<Todo> todoBox;

  ObjectBox._create(this.store) {
    todoBox = Box<Todo>(store);
  }

  static Future<ObjectBox> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${dir.path}/objectbox');
    return ObjectBox._create(store);
  }
}