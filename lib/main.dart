import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(
    MaterialApp(
      title: 'Reading and Writing Files',
      home: DataManage(storage: CounterStorage()),
    ),
  );
}

const borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(36)),
    borderSide: BorderSide(color: Color(0xFFbbbbbb), width: 2));

class DataManage extends StatefulWidget {
  final CounterStorage storage;
  const DataManage({Key? key, required this.storage}) : super(key: key);

  @override
  State<DataManage> createState() => _DataManageState();
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory =await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }
  Future<int> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }
  Future<File> writeCounter(int counter) async {
    final file = await _localFile;
    return file.writeAsString('$counter');
  }
}

class _DataManageState extends State<DataManage> {
  final List<int> _counter = [0,0];
  late TextEditingController _controller;
  late TextEditingController _controller1;

  @override
  void initState(){
    super.initState();
    _controller=TextEditingController(text: '');
    _controller1=TextEditingController(text: '');
    _loadCounter(0);
    _loadCounter(1);
  }

  void _loadCounter(int i) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      switch (i) {
        case 0:
          _counter[0] = prefs.getInt('counter') ?? 0;
          _controller.text= _counter[0].toString();
          break;
        case 1:
          widget.storage.readCounter().then((int value) {
            _counter[1] = value;
            _controller1.text= _counter[1].toString();
          });
          break;
      }
    });
  }
  void _incrementCounter(int i) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      switch (i) {
        case 0:
          _counter[0] = (prefs.getInt('counter') ?? 0) +1;
          prefs.setInt('counter', _counter[0]);
          _controller.text= _counter[0].toString();
          break;
        case 1:
          widget.storage.readCounter().then((int value) {
            _counter[1] = value+1;
            widget.storage.writeCounter(_counter[1]);
            _controller1.text= _counter[1].toString();
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(
        home: Scaffold(
            body: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60,),
                    ElevatedButton(
                      onPressed: (){_incrementCounter(0);},
                      child: const Text('+1'),
                    ),
                    TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFeceff1),
                        enabledBorder: borderStyle,
                        focusedBorder: borderStyle,
                        labelText: 'Prefs',
                      ),
                    ),
                    const SizedBox(height: 50,),
                    ElevatedButton(
                      onPressed: (){_incrementCounter(1);},
                      child: const Text('+1'),
                    ),
                    TextField(
                      controller: _controller1,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFeceff1),
                        enabledBorder: borderStyle,
                        focusedBorder: borderStyle,
                        labelText: 'File',
                      ),
                    ),
                  ],
                ),
              ),
            )
        ),
      );
  }
}