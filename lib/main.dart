import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class Todo {
  String id;
  String title;
  String description;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];

  void _addTodo(String title, String description) {
    setState(() {
      _todos.add(
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
        ),
      );
    });
  }

  void _updateTodo(String id, String newTitle, String newDescription) {
    setState(() {
      int index = _todos.indexWhere((todo) => todo.id == id);
      _todos[index].title = newTitle;
      _todos[index].description = newDescription;
    });
  }

  void _toggleTodoCompletion(String id) {
    setState(() {
      int index = _todos.indexWhere((todo) => todo.id == id);
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: _todos.isEmpty
          ? const Center(
        child: Text('No todos yet! Add one by clicking the + button'),
      )
          : ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return Dismissible(
            key: Key(todo.id),
            background: Container(color: Colors.red),
            onDismissed: (direction) => _deleteTodo(todo.id),
            child: ListTile(
              title: Text(todo.title),
              subtitle: Text(todo.description),
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