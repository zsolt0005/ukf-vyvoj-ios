import 'package:flutter/foundation.dart';

enum Priority { low, medium, high }

class Todo {
  Todo({
    required this.title,
    required this.priority,
    this.done = false,
  });

  final String title;
  final Priority priority;
  bool done;
}

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [];
  Priority _selectedPriority = Priority.medium;

  List<Todo> get todos => List.unmodifiable(_todos);
  Priority get selectedPriority => _selectedPriority;

  int get doneCount => _todos.where((todo) => todo.done).length;

  void setSelectedPriority(Priority priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void addTodo(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    _todos.add(Todo(title: trimmed, priority: _selectedPriority));
    notifyListeners();
  }

  void toggleTodo(int index) {
    _todos[index].done = !_todos[index].done;
    notifyListeners();
  }

  void removeTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }
}
