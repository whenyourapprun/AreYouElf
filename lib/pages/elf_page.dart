import 'package:are_you_elf/face_detector/face_detector_view.dart';
import 'package:flutter/material.dart';

class ElfPage extends StatefulWidget {
  const ElfPage({super.key});

  @override
  State<ElfPage> createState() => _ElfPageState();
}

class _ElfPageState extends State<ElfPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: FaceDetectorView(),
    );
  }
}
