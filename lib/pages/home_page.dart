import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasklyapp/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double _deviceheight, _devicewidth;
  String? _newTaskcontent;
  Box? _box;
  @override
  Widget build(BuildContext context) {
    _deviceheight = MediaQuery.of(context).size.height;
    _devicewidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        toolbarHeight: _deviceheight * 0.15,
        title: Text(
          "Taskly!",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
      body: _tasksView(),
      floatingActionButton: _addTaskbutton(),
    );
  }

  Widget _tasksView() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _taskslist();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _taskslist() {
    List tasks = _box!.values.toList();
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext _context, int _index) {
          var task = Task.fromMap(tasks[_index]);
          return ListTile(
            title: Text(
              task.content,
              style: TextStyle(
                  decoration: task.done ? TextDecoration.lineThrough : null),
            ),
            subtitle: Text(task.timestamp.toString()),
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank_outlined,
              color: Colors.red,
            ),
            onTap: () {
              task.done = !task.done;
              _box!.putAt(_index, task.toMap());
              setState(() {});
            },
            onLongPress: () {
              _box!.deleteAt(_index);
              setState(() {});
            },
          );
        });
  }

  Widget _addTaskbutton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      backgroundColor: Colors.red,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  void _displayTaskPopup() {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: const Text("add new task!"),
            content: TextField(
              onSubmitted: (_value) {
                if (_newTaskcontent != null) {
                  var _task = Task(
                      content: _newTaskcontent!,
                      timestamp: DateTime.now(),
                      done: false);
                  _box!.add(_task.toMap());
                  setState(() {
                    _newTaskcontent = null;
                    Navigator.pop(context);
                  });
                }
              },
              onChanged: (_value) {
                setState(() {
                  _newTaskcontent = _value;
                });
              },
            ),
          );
        });
  }
}
