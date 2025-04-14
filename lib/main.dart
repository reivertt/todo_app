import 'package:flutter/material.dart';
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

enum Filter {
  all,
  completed,
  active
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Filter _filter = Filter.all;
  late Box<Todo> todoBox;

  @override
  void initState() {
    super.initState();
    todoBox = objectBox.todoBox;
  }

  List<Todo> get filteredTodos {
    final queryBuilder = todoBox.query();

    switch (_filter) {
      case Filter.completed:
        return todoBox.query(Todo_.isCompleted.equals(true)).build().find();
      case Filter.active:
        return todoBox.query(Todo_.isCompleted.equals(false)).build().find();
      case Filter.all:
        return todoBox.getAll();
    }

    return queryBuilder.build().find();
  }

  void _addTodo(String title, String description) {
    final todo = Todo(
      title: title,
      description: description
    );

    todoBox.put(todo);
    setState(() {});
  }

  void _updateTodo(int id, String newTitle, String newDescription) {
    final todo = todoBox.get(id);
    if (todo != null) {
      todo.title = newTitle;
      todo.description = newDescription;
      todoBox.put(todo);
      setState(() {});
    }
  }

  void _toggleTodoCompletion(int id) {
    final todo = todoBox.get(id);
    if (todo != null) {
      todo.isCompleted = !todo.isCompleted;
      todoBox.put(todo);
      setState(() {});
    }
  }

  void _deleteTodo(int id) {
    todoBox.remove(id);
    setState(() {});
  }


  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => TodoDialog(
        onSave: (title, description) => _addTodo(title, description),
      ),
    );
  }

  void _showEditTodoDialog(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => TodoDialog(
        initialTitle: todo.title,
        initialDescription: todo.description,
        onSave: (newTitle, newDescription) =>
            _updateTodo(todo.id, newTitle, newDescription),
      ),
    );
  }

  Widget _buildFilterItem(Filter filter, String text) {
    final isSelected = _filter == filter;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent,
      ),
      child: ListTile(
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() => _filter = filter);
          Navigator.pop(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: RoundedRectangleBorder(
          // borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity, // Fill entire width
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500, // Medium weight
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildFilterItem(Filter.all, 'All Todos'),
                  _buildFilterItem(Filter.completed, 'Completed Todos'),
                  _buildFilterItem(Filter.active, 'Active Todos'),
                ],
              ),
            ),
          ],
        ),

      ),
      body: filteredTodos.isEmpty
          ? const Center(
        child: Text('No todos yet! Add one by clicking the + button'),
      )
          : ListView.builder(
        itemCount: filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = filteredTodos[index];
          return Dismissible(
            key: Key(todo.id.toString()),
            background: Container(color: Colors.red),
            onDismissed: (direction) => _deleteTodo(todo.id),
            child: todo.description.isNotEmpty ? ListTile(
              title: Text(todo.title),
              subtitle: Text(todo.description),
              leading: Checkbox(
                activeColor: Colors.blue,
                value: todo.isCompleted,
                onChanged: (_) => _toggleTodoCompletion(todo.id),
              ),
              onTap: () => _showEditTodoDialog(todo),
            )
            : ListTile(
              title: Text(todo.title),
              leading: Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => _toggleTodoCompletion(todo.id),
              ),
              onTap: () => _showEditTodoDialog(todo),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
        backgroundColor: Color.fromRGBO(50, 200, 250, 100),
      ),
    );
  }
}

class TodoDialog extends StatelessWidget {
  final Function(String, String) onSave;
  final String? initialTitle;
  final String? initialDescription;

  const TodoDialog({
    super.key,
    required this.onSave,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: initialTitle);
    final descriptionController = TextEditingController(text: initialDescription);

    return AlertDialog(
      title: Text(initialTitle == null ? 'Add Todo' : 'Edit Todo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onSave(
              titleController.text,
              descriptionController.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}