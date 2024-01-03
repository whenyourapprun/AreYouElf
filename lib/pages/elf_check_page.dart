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
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'Elf Analyze',
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
          // Center(child: Text(widget.path)),
          Positioned(
            bottom: 16,
            left: MediaQuery.of(context).size.width * 0.15,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.white30,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              icon: const Icon(Icons.analytics),
              onPressed: () async {
                debugPrint('button press');
              },
              label: const Text('Diagonitics'),
            ),
          )
        ],
      ),
    );
  }
}