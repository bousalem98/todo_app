// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:todo_app/widgets/counter.dart';
import 'package:todo_app/widgets/todo-card.dart';
import 'package:todo_app/utils/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

// class for task(todo-card)
class Task {
  late int id;
  late String title;
  late bool status;
  Task({
    required this.id,
    required this.title,
    required this.status,
  });
  Task.withoutId({
    required this.title,
    required this.status,
  });
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] = title;
    map['status'] = status;
    return map;
  }

  // Extract a Note object from a Map object
  Task.fromMapObject(Map<String, dynamic> map) {
    this.id = map['id'];
    this.title = map['title'];
    if (map['status'] == 0)
      this.status = false;
    else
      this.status = true;
  }
}

class _TodoAppState extends State<TodoApp> {
  SqlDb sqlDb = SqlDb();
// Create controller to  get the text inside the textfield  in the dialog widget
  final myController = TextEditingController();
  // list of todos
  List<Task> allTasks = [];

// To remove todo  when clicking on "delete" icon
  delete(int clickedTask, int id) async {
    int response = await sqlDb.deleteData("DELETE FROM tasks where id=$id");
    if (response > 0) {
      setState(() {
        allTasks.remove(allTasks[clickedTask]);
      });
    }
  }

  Future getData() async {
    var taskMapList = await sqlDb.readData("select * from tasks");
    int count =
        taskMapList.length; // Count the number of map entries in db table
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      setState(() {
        allTasks.add(Task.fromMapObject(taskMapList[i]));
      });
    }
  }

// To remove all todos  when clicking on "delete" icon in the appBar
  deleteAll() async {
    int response = await sqlDb.deleteData("DELETE FROM tasks");
    if (response > 0) {
      setState(() {
        allTasks.removeRange(0, allTasks.length);
      });
    }
  }

// To change the state of the todo (completed or not completed) when click on the todo
  changeStatus(int taskIndex, int id) async {
    int response = await sqlDb.updateData(
        "update tasks set status=${allTasks[taskIndex].status ? 0 : 1} where id=$id");
    if (response > 0) {
      setState(() {
        allTasks[taskIndex].status = !allTasks[taskIndex].status;
      });
    }
  }

// To add new todo when clicking on "ADD" in the dialog widget
  addnewtask() async {
    int response = await sqlDb.insertData(
        '''insert into tasks(title,status)values("${myController.text}",0)''');
    print(response);
    if (response > 0) {
      setState(() {
        allTasks
            .add(Task(id: response, title: myController.text, status: false));
      });
    }
  }

// To calculate only completed todos
// we will explain the difference between forEach & for loop in the next lesson (lesson11)
  int calculateCompletedTasks() {
    int completedTasks = 0;

    for (var item in allTasks) {
      if (item.status) {
        completedTasks++;
      }
    }

    return completedTasks;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
                child: Container(
                  padding: EdgeInsets.all(22),
                  height: 200,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                            controller: myController,
                            maxLength: 20,
                            decoration:
                                InputDecoration(hintText: "Add new Task")),
                        SizedBox(
                          height: 22,
                        ),
                        TextButton(
                            onPressed: () {
                              addnewtask();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "ADD",
                              style: TextStyle(fontSize: 22),
                            ))
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
      backgroundColor: Color.fromRGBO(58, 66, 86, 0.7),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              deleteAll();
            },
            icon: Icon(Icons.delete_forever),
            iconSize: 37,
            color: Color.fromARGB(255, 255, 188, 214),
          )
        ],
        elevation: 0,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1),
        title: Text(
          "TO DO APP",
          style: TextStyle(
              fontSize: 33, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Counter(
                  allTodos: allTasks.length,
                  allCompleted: calculateCompletedTasks()),
              Container(
                margin: EdgeInsets.only(top: 22),
                height: 617,
                child: ListView.builder(
                    itemCount: allTasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Todecard(
                          // I will pass all these information when create the Todecard() widget in "todo-card.dart" file
                          vartitle: allTasks[index].title,
                          doneORnot: allTasks[index].status,
                          changeStatus: changeStatus,
                          id: allTasks[index].id,
                          index: index,
                          delete: delete);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
