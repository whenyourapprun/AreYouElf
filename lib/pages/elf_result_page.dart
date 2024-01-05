import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class ElfResultPage extends StatefulWidget {
  const ElfResultPage({super.key, required this.path, required this.objDetect});
  final String path;
  final List<ResultObjectDetection?> objDetect;

  @override
  State<ElfResultPage> createState() => _ElfResultPageState();
}

class _ElfResultPageState extends State<ElfResultPage> {
  String _result = 'Your Human';

  @override
  void initState() {
    super.initState();
    for (var element in widget.objDetect) {
      debugPrint('score: ${element?.score} className: ${element?.className}');
      if (element?.className == 'elf') {
        _result = 'Your Elf';
      }
    }
    if (widget.objDetect.isNotEmpty) {
      setState(() {
        _result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Elf Result',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.popUntil(context, ModalRoute.withName('/')),
        ),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          Transform.flip(
            flipX: true,
            child: Image.file(
              File(widget.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
