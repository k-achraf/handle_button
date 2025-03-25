import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:handle_button/handle_button.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handle Button Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HandleButtonController _btnController1 =
  HandleButtonController();

  final HandleButtonController _btnController2 =
  HandleButtonController();

  void _doSomething(HandleButtonController controller) async {
    Timer(Duration(seconds: 10), () {
      controller.success();
    });
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Handle Button Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HandleButton(
                successIcon: Icons.cloud,
                failedIcon: Icons.cottage,
                controller: _btnController1,
                onPressed: () => _doSomething(_btnController1),
                child: Text('Tap me!', style: TextStyle(color: Colors.white)),
                loadingWidget: SpinKitChasingDots(
                  color: const Color(0xFF5D3FC5),
                  size: 20,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              HandleButton(
                color: Colors.amber,
                successColor: Colors.amber,
                controller: _btnController2,
                onPressed: () => _doSomething(_btnController2),
                valueColor: Colors.black,
                borderRadius: 10,
                child: Text('''
Tap me i have a huge text''', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(
                height: 50,
              ),
              OutlinedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                  ),
                  onPressed: () {
                    _btnController1.reset();
                    _btnController2.reset();
                  },
                  child: Text('Reset')),
              SizedBox(
                height: 20,
              ),
              OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
                ),
                onPressed: () {
                  _btnController1.error();
                  _btnController2.error();
                },
                child: Text('Error'),
              ),
              SizedBox(
                height: 20,
              ),
              OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
                ),
                onPressed: () {
                  _btnController1.success();
                  _btnController2.success();
                  // _btnController1
                },
                child: Text('Success'),
              )
            ],
          ),
        ));
  }
}
