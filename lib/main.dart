import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TodoHome());
  }
}

class TodoHome extends StatefulWidget {
  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  List tasks = [];
  final TextEditingController controller = TextEditingController();

  final url = 'http://10.0.2.2:8000/api/tasks';

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      setState(() => tasks = json.decode(res.body));
    }
  }

  Future<void> addTask(String title) async {
    await http.post(Uri.parse(url), body: {'title': title});
    controller.clear();
    loadTasks();
  }

  Future<void> toggleComplete(int id, bool completed) async {
    await http.put(Uri.parse('$url/$id'),
        body: {'completed': (!completed).toString()});
    loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('$url/$id'));
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("To-Do List")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: "New task"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask(controller.text),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: tasks.map((task) {
                return ListTile(
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      decoration: task['completed']
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: task['completed'],
                    onChanged: (_) =>
                        toggleComplete(task['id'], task['completed']),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteTask(task['id']),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
