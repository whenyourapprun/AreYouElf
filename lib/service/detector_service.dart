import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as image_lib;
import 'package:are_you_elf/models/recognition.dart';
import 'package:are_you_elf/utils/image_utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum _Codes {
  init,
  busy,
  ready,
  detect,
  result,
}

class _Command {
  const _Command(this.code, {this.args});

  final _Codes code;
  final List<Object>? args;
}

class Detector {
  // ssd single shot detect
  static const String _modelPath = 'assets/models/ssd_mobilenet.tflite';
  static const String _labelPath = 'assets/models/ssd_mobilenet.txt';
  // yolov8
  // static const String _modelPath = 'assets/models/yolov8n_float16.tflite';
  // static const String _labelPath = 'assets/models/yolov8n.txt';

  Detector._(this._isolate, this._interpreter, this._labels);

  final Isolate _isolate;
  late final Interpreter _interpreter;
  late final List<String> _labels;

  late final SendPort _sendPort;

  bool _isReady = false;

  final StreamController<Map<String, dynamic>> resultsStream =
      StreamController<Map<String, dynamic>>();

  static Future<Detector> start() async {
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate =
        await Isolate.spawn(_DetectorServer._run, receivePort.sendPort);

    final Detector result = Detector._(
      isolate,
      await _loadModel(),
      await _loadLabels(),
    );
    receivePort.listen((message) {
      result._handleCommand(message as _Command);
    });
    return result;
  }

  static Future<Interpreter> _loadModel() async {
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      // CPU
      interpreterOptions.addDelegate(XNNPackDelegate());
      /*/ GPU
      final gpuDelegateV2 = GpuDelegateV2(
        options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
        ),
      );
      interpreterOptions.addDelegate(gpuDelegateV2);
      // */
    }
    if (Platform.isIOS) {
      // Use Metal Delegate
      interpreterOptions.addDelegate(GpuDelegate());
    }
    return await Interpreter.fromAsset(
      _modelPath,
      options: interpreterOptions..threads = 4,
    );
  }

  static Future<List<String>> _loadLabels() async {
    return (await rootBundle.loadString(_labelPath)).split('\n');
  }

  void processFrame(CameraImage cameraImage) {
    if (_isReady) {
      _sendPort.send(
        _Command(
          _Codes.detect,
          args: [cameraImage],
        ),
      );
    }
  }

  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.args?[0] as SendPort;
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(
          _Command(
            _Codes.init,
            args: [
              rootIsolateToken,
              _interpreter.address,
              _labels,
            ],
          ),
        );
      case _Codes.ready:
        _isReady = true;
      case _Codes.busy:
        _isReady = false;
      case _Codes.result:
        _isReady = true;
        resultsStream.add(command.args?[0] as Map<String, dynamic>);
      default:
        debugPrint('Detector unrecognized command: ${command.code}');
    }
  }

  void stop() {
    _isolate.kill();
  }
}

class _DetectorServer {
  // Input size of image (height = width = 300)
  // ssd
  static const int mlModelInputSize = 300;
  // yolov8n
  // static const int mlModelInputSize = 640;
  // Result confidence threshold
  static const double confidence = 0.5;
  Interpreter? _interpreter;
  List<String>? _labels;
  _DetectorServer(this._sendPort);
  final SendPort _sendPort;
  static void _run(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    final _DetectorServer server = _DetectorServer(sendPort);
    receivePort.listen((message) async {
      final _Command command = message as _Command;
      await server._handleCommand(command);
    });
    sendPort.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }

  Future<void> _handleCommand(_Command command) async {
    switch (command.code) {
      case _Codes.init:
        RootIsolateToken rootIsolateToken =
            command.args?[0] as RootIsolateToken;
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        _interpreter = Interpreter.fromAddress(command.args?[1] as int);
        _labels = command.args?[2] as List<String>;
        _sendPort.send(const _Command(_Codes.ready));
      case _Codes.detect:
        _sendPort.send(const _Command(_Codes.busy));
        _convertCameraImage(command.args?[0] as CameraImage);
      default:
        debugPrint('_DetectorService unrecognized command ${command.code}');
    }
  }

  void _convertCameraImage(CameraImage cameraImage) {
    var preConversionTime = DateTime.now().millisecondsSinceEpoch;
    convertCameraImageToImage(cameraImage).then((image) {
      if (image != null) {
        if (Platform.isAndroid) {
          image = image_lib.copyRotate(image, angle: 90);
        }

        final results = analyseImage(image, preConversionTime);
        _sendPort.send(_Command(_Codes.result, args: [results]));
      }
    });
  }

  Map<String, dynamic> analyseImage(
      image_lib.Image? image, int preConversionTime) {
    var conversionElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;
    var preProcessStart = DateTime.now().millisecondsSinceEpoch;
    // Resizing image for model [300, 300]
    final imageInput = image_lib.copyResize(
      image!,
      width: mlModelInputSize,
      height: mlModelInputSize,
    );
    // Creating matrix representation, [300, 300, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;
    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;
    final output = _runInference(imageMatrix);
    // Location
    final locationsRaw = output.first.first as List<List<double>>;
    final List<Rect> locations = locationsRaw
        .map((list) => list.map((value) => (value * mlModelInputSize)).toList())
        .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
        .toList();

    // ssd
    final classesRaw = output.elementAt(1).first as List<double>;
    // yolov8
    // final classesRaw = output.elementAt(1).first as List<num>;
    final classes = classesRaw.map((value) => value.toInt()).toList();
    // ssd
    final scores = output.elementAt(2).first as List<double>;
    // yolov8
    // final scores = output.elementAt(2).first as List<num>;
    final numberOfDetectionsRaw = output.last.first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();
    final List<String> classification = [];
    for (var i = 0; i < numberOfDetections; i++) {
      classification.add(_labels![classes[i]]);
    }

    List<Recognition> recognitions = [];
    for (int i = 0; i < numberOfDetections; i++) {
      var score = scores[i];
      var label = classification[i];
      if (score > confidence) {
        recognitions.add(
          // ssd
          Recognition(i, label, score, locations[i]),
          // yolov8
          // Recognition(i, label, score.toDouble(), locations[i]),
        );
      }
    }

    var inferenceElapsedTime =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;
    var totalElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;

    return {
      "recognitions": recognitions,
      "stats": <String, String>{
        'Conversion time:': conversionElapsedTime.toString(),
        'Pre-processing time:': preProcessElapsedTime.toString(),
        'Inference time:': inferenceElapsedTime.toString(),
        'Total prediction time:': totalElapsedTime.toString(),
        'Frame': '${image.width} X ${image.height}',
      },
    };
  }

  List<List<Object>> _runInference(
    List<List<List<num>>> imageMatrix,
  ) {
    // Set input tensor [1, 300, 300, 3]
    final input = [imageMatrix];
    // Set output tensor
    // Locations: [1, 10, 4]
    // Classes: [1, 10],
    // Scores: [1, 10],
    // Number of detections: [1]
    // ssd
    final output = {
      0: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
      1: [List<num>.filled(10, 0)],
      2: [List<num>.filled(10, 0)],
      3: [0.0],
    };
    // yolov8
    // final output = {
    //   0: [List<List<num>>.filled(84, List<num>.filled(8400, 0))],
    //   1: [List<num>.filled(10, 0)],
    //   2: [List<num>.filled(10, 0)],
    //   3: [0.0],
    // };
    debugPrint('=====================inputTensors=====================');
    for (var input in _interpreter!.getInputTensors()) {
      debugPrint('$input');
    }
    debugPrint('=====================outputTensors=====================');
    for (var output in _interpreter!.getOutputTensors()) {
      debugPrint('$output');
    }
    _interpreter!.runForMultipleInputs([input], output);
    return output.values.toList();
  }
}
