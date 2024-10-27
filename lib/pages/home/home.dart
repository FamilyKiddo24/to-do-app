import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeS extends StatefulWidget {
  const HomeS({super.key});

  @override
  State<HomeS> createState() => _HomeState();
}

class TodoItem extends StatelessWidget {
  final ToDo todo;
  final onTodoChanged;
  final onDeleteItem;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onTodoChanged,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          onTodoChanged(todo);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: Colors.blue,
        ),
        title: Text(
          todo.todoText!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(5),
          ),
          child: IconButton(
            color: Colors.white,
            iconSize: 18,
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDeleteItem(todo.id);
            },
          ),
        ),
      ),
    );
  }
}

class ToDo {
  String? id;
  String? todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });

  // Convert ToDo object to a JSON-friendly map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
    };
  }

  // Factory method to create a ToDo object from a map
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'],
    );
  }

  // Example static method to generate an initial list of ToDo items
  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: 'Add Your First Item!'),
    ];
  }
}

class _HomeState extends State<HomeS> {
  List<ToDo> todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToDoList(); // Call the load function and update _foundToDo.
  }

  // Toggle the done state of a ToDo item
  void _toggleDone(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    saveToDoList(_foundToDo); // Save the list after modification
  }

  // Save the List<ToDo> to shared_preferences
  Future<void> saveToDoList(List<ToDo> toDoList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the list to a JSON string
    String jsonString = jsonEncode(toDoList.map((todo) => todo.toJson()).toList());

    // Save the JSON string to shared preferences
    await prefs.setString('toDoList', jsonString);
  }

  // Load the List<ToDo> from shared_preferences
  Future<void> _loadToDoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string
    String? jsonString = prefs.getString('_foundToDo');

    if (jsonString != null) {
      // Decode the JSON string into a list of maps
      List<dynamic> jsonList = jsonDecode(jsonString);

      // Convert each map into a ToDo object
      List<ToDo> loadedList = jsonList.map((json) => ToDo.fromJson(json)).toList();

      // Update the state with the loaded list
      setState(() {
        _foundToDo = loadedList;
      });
    } else {
      // If nothing was loaded, use the default todosList
      setState(() {
        _foundToDo = todosList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 233, 240),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 232, 233, 240),
        automaticallyImplyLeading: false,
        title: const Icon(Icons.menu, color: Color(0xFF3A3A3A), size: 30),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              children: [
                searchBox(),
                Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 20),
                  child: const Text(
                    textAlign: TextAlign.left,
                    'All ToDos',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (ToDo todoo in _foundToDo)
                        TodoItem(
                          todo: todoo,
                          onTodoChanged: _toggleDone,
                          onDeleteItem: _deleteToDoItem,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 0.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new item',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      _addToDoItem(_todoController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(60, 60),
                      elevation: 10,
                    ),
                    child: const Text('+', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    saveToDoList(_foundToDo); // Save the list after toggling
  }

  void _deleteToDoItem(String id) {
    setState(() {
      _foundToDo.removeWhere((item) => item.id == id);
    });
    saveToDoList(_foundToDo); // Save the list after deletion
  }

  void _addToDoItem(String toDoText) {
    setState(() {
      _foundToDo.add(ToDo(id: DateTime.now().millisecondsSinceEpoch.toString(), todoText: toDoText));
    });
    _todoController.clear();
    saveToDoList(_foundToDo); // Save the list after adding a new item
  }

  void _runFlutter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _foundToDo = results;
    });
  }

  Widget searchBox() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value) => _runFlutter(value),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(Icons.search),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
