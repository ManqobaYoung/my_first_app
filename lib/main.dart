import 'package:flutter/material.dart';
import 'dart:async'; // To use Future.delayed

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the main page after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ToDoListPage(), // Main page
      ));
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
                '/home/manqoba-young/Downloads/depositphotos_582842176-stock-illustration-african-mammal-logo-african-continent.jpg'), // Display your Africa image
            SizedBox(height: 20),
            Text(
              "-MR - MASON-", // The text below the image
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
    ]
  };

  final TextEditingController _taskController = TextEditingController();
  String _selectedUser = "Mom"; // Default selected user

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Task for $_selectedUser"),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(hintText: "Enter task name"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () {
                setState(() {
                  if (_taskController.text.isNotEmpty) {
                    usersTasks[_selectedUser]!.add({"title": _taskController.text, "done": false});
                    _taskController.clear();
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskList(String user) {
    return ExpansionTile(
      title: Text(user),
      children: [
        for (int i = 0; i < usersTasks[user]!.length; i++)
          ListTile(
            leading: GestureDetector(
              onTap: () {
                setState(() {
                  usersTasks[user]![i]['done'] = !usersTasks[user]![i]['done'];
                });
              },
              child: Container(
                width: 20,
                height: 20,
                color: usersTasks[user]![i]['done'] ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              "${i + 1}. ${usersTasks[user]![i]['title']}",
              style: TextStyle(
                decoration: usersTasks[user]![i]['done']
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  usersTasks[user]!.removeAt(i);
                });
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: _selectedUser,
          onChanged: (String? newUser) {
            setState(() {
              _selectedUser = newUser!;
            });
          },
          items: usersTasks.keys.map<DropdownMenuItem<String>>((String user) {
            return DropdownMenuItem<String>(
              value: user,
              child: Text(user),
            );
          }).toList(),
        ),
        actions: [
          IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          IconButton(icon: Icon(Icons.account_circle), onPressed: () {}),
        ],
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: usersTasks.keys.map((user) => _buildTaskList(user)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
