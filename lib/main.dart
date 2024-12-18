import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ToDoListPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/depositphotos_582842176-stock-illustration-african-mammal-logo-african-continent.jpg',
            ),
            const SizedBox(height: 20),
            const Text(
              "-MR - MASON-",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final Map<String, List<Map<String, dynamic>>> usersTasks = {
    "Mom": [
      {"title": "Get food", "done": false},
      {"title": "Pick up kid", "done": false},
    ],
    "Dad": [
      {"title": "Buy groceries", "done": false},
      {"title": "Go to the bank", "done": false},
    ],
    "Team A": [
      {"title": "Check materials", "done": false},
      {"title": "Team meeting", "done": false},
    ],
  };

  final TextEditingController _taskController = TextEditingController();
  String _selectedUser = "Mom";

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(usersTasks));
  }

  void _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        usersTasks.clear();
        Map<String, dynamic> decodedTasks = jsonDecode(tasksString);
        decodedTasks.forEach((key, value) {
          usersTasks[key] = List<Map<String, dynamic>>.from(value);
        });
        _selectedUser = usersTasks.keys.first;
      });
    }
  }

  void _showAddTaskDialog() {
    bool isAddingUser = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isAddingUser ? "Add New User" : "Add New Task for $_selectedUser"),
              content: TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  hintText: isAddingUser ? "Enter user name" : "Enter task name",
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(isAddingUser ? "Switch to Task" : "Switch to User"),
                  onPressed: () {
                    setState(() {
                      isAddingUser = !isAddingUser;
                    });
                  },
                ),
                ElevatedButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    _taskController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text("Add"),
                  onPressed: () {
                    setState(() {
                      if (_taskController.text.isNotEmpty) {
                        if (isAddingUser) {
                          if (!usersTasks.containsKey(_taskController.text)) {
                            usersTasks[_taskController.text] = [];
                          }
                        } else {
                          usersTasks[_selectedUser]!.add({"title": _taskController.text, "done": false});
                        }
                        _taskController.clear();
                      }
                    });
                    Navigator.of(context).pop();
                    _saveTasks();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteUser(String user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete $user and all their tasks?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () {
              setState(() {
                usersTasks.remove(user);
                if (_selectedUser == user && usersTasks.isNotEmpty) {
                  _selectedUser = usersTasks.keys.first;
                }
              });
              Navigator.of(context).pop();
              _saveTasks();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(String user) {
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(user),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteUser(user),
          ),
        ],
      ),
      children: usersTasks[user]!.map((task) {
        return ListTile(
          title: Text(
            task['title'],
            style: TextStyle(
              decoration: task['done'] ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: Checkbox(
            value: task['done'],
            onChanged: (bool? value) {
              setState(() {
                task['done'] = value!;
              });
              _saveTasks();
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedUser,
            onChanged: (String? newValue) {
              setState(() {
                _selectedUser = newValue!;
              });
            },
            items: usersTasks.keys.map<DropdownMenuItem<String>>((String user) {
              return DropdownMenuItem<String>(
                value: user,
                child: Text(user),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView(
              children: usersTasks.keys.map((user) => _buildTaskList(user)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
