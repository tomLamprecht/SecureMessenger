import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Messenger Test'),
        ),
        body: const MyStatefulWidget(),
      ),
    );

  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  late TextEditingController _controller;

  List<String> myList = List.generate(0, (index) => 'Sample Item - $index');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: myList.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.all(32),
                child: Row(
                  children: [
                    const Text(
                      'Tom15_01: ',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                          letterSpacing: 1,
                          fontStyle: FontStyle.italic),
                    ),
                    Text(
                      myList[index],
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.deepPurple,
                          letterSpacing: 1,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (String value) async {
                      setState(() {
                        myList.add(value);
                      });
                      _controller.clear();
                    },
                  ),
                ),
              ),
              FloatingActionButton(
                  onPressed: () {}, child: const Icon(Icons.send)),
            ],
          ),
        ),
      ],
    );
  }
}
