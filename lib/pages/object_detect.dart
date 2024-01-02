import 'package:are_you_elf/models/screen_params.dart';
import 'package:are_you_elf/widgets/detector_widget.dart';
import 'package:flutter/material.dart';

class ObjectDetectPage extends StatefulWidget {
  const ObjectDetectPage({super.key});

  @override
  State<ObjectDetectPage> createState() => _ObjectDetectPageState();
}

class _ObjectDetectPageState extends State<ObjectDetectPage> {
  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      key: GlobalKey(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Object Detect on Yolov8'),
        centerTitle: true,
      ),
      body: const DetectorWidget(),
    );
  }
}
