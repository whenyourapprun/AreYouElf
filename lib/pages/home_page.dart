import 'package:are_you_elf/models/constant.dart';
import 'package:are_you_elf/models/screen_params.dart';
import 'package:are_you_elf/pages/elf_page.dart';
import 'package:are_you_elf/pages/object_detect.dart';
import 'package:are_you_elf/pages/test_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      // key: GlobalKey(),
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('당신의 앱이 실행될 때'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: MediaQuery.of(context).size.width),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ElfPage(),
                ),
              );
            },
            child: const Text(
              'elf detect',
              style: textButtonStyle,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ObjectDetectPage(),
                ),
              );
            },
            child: const Text(
              'object detect',
              style: textButtonStyle,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TestPage(),
                ),
              );
            },
            child: const Text(
              'yolov8 test',
              style: textButtonStyle,
            ),
          ),
        ],
      ),
    );
  }
}
