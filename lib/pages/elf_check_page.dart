import 'dart:io';

import 'package:flutter/material.dart';

class ElfCheckPage extends StatefulWidget {
  const ElfCheckPage({super.key, required this.path});
  final String path;

  @override
  State<ElfCheckPage> createState() => _ElfCheckPageState();
}

class _ElfCheckPageState extends State<ElfCheckPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elf Analyze'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Image.file(
            File(widget.path),
            fit: BoxFit.fill,
          ),
          Center(child: Text(widget.path)),
        ],
      ),
    );
  }
}
