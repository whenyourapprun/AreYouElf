import 'package:are_you_elf/service/yolov8_detector.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _predictionTime = 0;
  @override
  void initState() {
    super.initState();
    () async {
      _predictionTime = await testYolov8();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yolov8 Test'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/test.jpg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fitHeight,
          ),
          Center(
            child: Text(
              '예측시간 $_predictionTime',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
