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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elf Result'),
        centerTitle: true,
      ),
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
          const Center(
            child: Text('data'),
          ),
        ],
      ),
    );
  }
}
