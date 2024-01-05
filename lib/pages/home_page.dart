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
      appBar: AppBar(
        title: const Text(
          '당신의 앱이 실행될 때',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/elf_bg_1.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ElfPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'elf detect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => const ObjectDetectPage(),
              //       ),
              //     );
              //   },
              //   child: const Text(
              //     'object detect',
              //     style: textButtonStyle,
              //   ),
              // ),
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => const TestPage(),
              //       ),
              //     );
              //   },
              //   child: const Text(
              //     'yolov8 test',
              //     style: textButtonStyle,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
