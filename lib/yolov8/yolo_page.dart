import 'dart:async';
import 'package:are_you_elf/main.dart';
import 'package:are_you_elf/models/screen_params.dart';
import 'package:are_you_elf/yolov8/bbox.dart';
import 'package:are_you_elf/yolov8/detector_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class YoloPage extends StatefulWidget {
  const YoloPage({super.key});

  @override
  State<YoloPage> createState() => _YoloPageState();
}

class _YoloPageState extends State<YoloPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  // use only when initialized, so - not null
  get _controller => _cameraController;
  Detector? _detector;
  StreamSubscription? _subscription;
  int _cameraIndex = -1;
  final CameraLensDirection initialCameraLensDirection =
      CameraLensDirection.front;

  List<String> classes = [];
  List<List<double>> bboxes = [];
  List<double> scores = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStateAsync();
  }

  void _initStateAsync() async {
    // initialize preview and CameraImage stream
    _initializeCamera();
    // Spawn a new isolate
    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
        _subscription = instance.resultsStream.stream.listen((values) {
          // debugPrint('cls ${values['cls']}');
          // debugPrint('box ${values['box']}');
          debugPrint('conf ${values['conf']}');
          debugPrint('stats ${values['stats']}');
          // debugPrint('threads ${Platform.numberOfProcessors}');
          setState(() {
            classes = values['cls'];
            bboxes = values['box'];
            scores = values['conf'];
          });
        });
      });
    });
  }

  void _initializeCamera() async {
    for (var i = 0; i < pcameras.length; i++) {
      if (pcameras[i].lensDirection == initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    final camera = pcameras[_cameraIndex];
    // cameras[0] for back-camera
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    )..initialize().then((_) async {
        await _controller.startImageStream(onLatestImageAvailable);
        setState(() {});
        ScreenParams.previewSize = _controller.value.previewSize!;
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _cameraController?.stopImageStream();
        _detector?.stop();
        _subscription?.cancel();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  Widget _boundingBoxes() {
    List<Bbox> bboxesWidgets = [];
    for (int i = 0; i < bboxes.length; i++) {
      // box 좌표는 xywh 임, 고로 (xCenter, yCenter, xWidth, yHeight)
      bboxesWidgets.add(
        Bbox(
          box: bboxes[i],
          name: classes[i],
          score: scores[i],
        ),
      );
    }
    // debugPrint('bboxesWidgets ${bboxesWidgets.length}');
    return Stack(children: bboxesWidgets);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _detector?.stop();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    var aspect = 1 / _controller.value.aspectRatio;
    return Scaffold(
      appBar: AppBar(
        title: const Text('RealTime Test'),
        centerTitle: true,
        backgroundColor: Colors.black38,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () =>
              Navigator.popUntil(context, ModalRoute.withName("/")),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: CameraPreview(_controller),
          ),
          AspectRatio(
            aspectRatio: aspect,
            child: _boundingBoxes(),
          ),
        ],
      ),
    );
  }
}
