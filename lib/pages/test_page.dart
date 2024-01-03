import 'dart:io';

import 'package:are_you_elf/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late ModelObjectDetection _objectModelYoloV8;
  String? textToShow;
  bool objectDetection = false;
  File? _image;
  List<ResultObjectDetection?> objDetect = [];
  late ByteData imageData;

  @override
  void initState() {
    super.initState();
    rootBundle
        .load('assets/images/test.jpg')
        .then((data) => setState(() => imageData = data));
    loadModel();
  }

  Future loadModel() async {
    String pathObjectDetectionModelYolov8 = 'assets/models/yolov8n.torchscript';
    try {
      _objectModelYoloV8 = await PytorchLite.loadObjectDetectionModel(
          pathObjectDetectionModelYolov8, 80, 640, 640,
          labelPath: 'assets/models/yolov8n.txt',
          objectDetectionModelType: ObjectDetectionModelType.yolov8);
    } catch (e) {
      if (e is PlatformException) {
        debugPrint('only supported for android, error is $e');
      } else {
        debugPrint('Error is $e');
      }
    }
  }

  Future runObjectDetectionYoloV8() async {
    Stopwatch stopwatch = Stopwatch()..start();
    objDetect = await _objectModelYoloV8.getImagePrediction(
        imageData.buffer.asUint8List(),
        minimumScore: 0.1,
        iOUThreshold: 0.3);
    textToShow = inferenceTimeAsString(stopwatch);
    debugPrint('object executed in ${stopwatch.elapsed.inMilliseconds} ms');
    for (var element in objDetect) {
      debugPrint(
          'score: ${element?.score} className: ${element?.className} class: ${element?.classIndex} rect left: ${element?.rect.left} top: ${element?.rect.top} width: ${element?.rect.width} height: ${element?.rect.height} right: ${element?.rect.right} bottom: ${element?.rect.bottom}');
    }
    File imageFile = await getImageFileFromAssets('images/test.jpg');
    setState(() {
      _image = imageFile;
    });
  }

  String inferenceTimeAsString(Stopwatch stopwatch) =>
      "Inference Took ${stopwatch.elapsed.inMilliseconds} ms";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yolov8 Test'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          objDetect.isNotEmpty
              ? _objectModelYoloV8.renderBoxesOnImage(_image!, objDetect)
              : _image == null
                  ? Image.asset(
                      'assets/images/test.jpg',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.fill,
                    )
                  : Image.file(_image!),
          Positioned(
            left: 16,
            bottom: 16,
            child: TextButton(
              onPressed: runObjectDetectionYoloV8,
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "Run object detection YoloV8 with labels",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
