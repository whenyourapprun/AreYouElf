import 'dart:isolate';
import 'package:are_you_elf/helper/isolate_inference.dart';
import 'package:are_you_elf/models/person.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PoseEstimationHelper {
  late final Interpreter _interpreter;
  late final Tensor _inputTensor;
  late final IsolateInference _isolateInference;

  _loadModel() async {
    _interpreter =
        await Interpreter.fromAsset('assets/models/posenet_mobilenet.tflite');
    _inputTensor = _interpreter.getInputTensors().first;
  }

  initHelper() async {
    await _loadModel();
    _isolateInference = IsolateInference();
    await _isolateInference.start();
  }

  Future<Person> estimatePoses(CameraImage cameraImage) async {
    final isolateModel =
        InferenceModel(cameraImage, _interpreter.address, _inputTensor.shape);
    ReceivePort responsePort = ReceivePort();
    _isolateInference.sendPort
        ?.send(isolateModel..responsePort = responsePort.sendPort);
    // get inference result.
    return await responsePort.first;
  }

  close() {
    _interpreter.close();
  }
}
