import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:seminar_1/todo_provider.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // Stav aplikácie je v TodoProvider; tu zostáva iba textový controller.
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    context.read<TodoProvider>().addTodo(_controller.text);
    _controller.clear();
  }

  static Color _priorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  static String _priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'Vysoká';
      case Priority.medium:
        return 'Stredná';
      case Priority.low:
        return 'Nízka';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TodoProvider>(
          builder: (context, provider, child) {
            return Text(
              'To-Do (${provider.doneCount}/${provider.todos.length})',
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nová úloha',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<TodoProvider>(
                  builder: (context, provider, child) {
                    return DropdownButton<Priority>(
                      value: provider.selectedPriority,
                      onChanged: (value) {
                        if (value != null) {
                          provider.setSelectedPriority(value);
                        }
                      },
                      items: Priority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(
                            _priorityLabel(priority),
                            style: TextStyle(color: _priorityColor(priority)),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, child) {
                final todos = provider.todos;

                if (todos.isEmpty) {
                  return const Center(child: Text('Zatiaľ žiadne úlohy.'));
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final color = _priorityColor(todo.priority);

                    return ListTile(
                      leading: Checkbox(
                        value: todo.done,
                        onChanged: (_) => provider.toggleTodo(index),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration:
                              todo.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        'Priorita: ${_priorityLabel(todo.priority)}',
                        style: TextStyle(color: color),
                      ),
                      tileColor: color.withAlpha(30),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => provider.removeTodo(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
