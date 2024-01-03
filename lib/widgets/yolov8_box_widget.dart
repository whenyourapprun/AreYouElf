import 'package:are_you_elf/widgets/camera_view_singleton.dart';
import 'package:flutter/material.dart';
import 'package:pytorch_lite/lib.dart';

class Yolov8BoxWidget extends StatelessWidget {
  const Yolov8BoxWidget({
    super.key,
    required this.result,
    this.boxesColor,
    this.showPercentage = true,
  });
  final ResultObjectDetection result;
  final Color? boxesColor;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    Color? usedColor;
    Size screenSize = CameraViewSingleton.actualPreviewSizeH;
    double factorX = screenSize.width;
    double factorY = screenSize.height;
    if (boxesColor == null) {
      usedColor = Colors.primaries[
          ((result.className ?? result.classIndex.toString()).length +
                  (result.className ?? result.classIndex.toString())
                      .codeUnitAt(0) +
                  result.classIndex) %
              Colors.primaries.length];
    } else {
      usedColor = boxesColor;
    }

    return Positioned(
      left: result.rect.left * factorX,
      top: result.rect.top * factorY,
      width: result.rect.width * factorX,
      height: result.rect.height * factorY,
      child: Container(
        width: result.rect.width * factorX,
        height: result.rect.height * factorY,
        decoration: BoxDecoration(
          border: Border.all(color: usedColor!, width: 3),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: Container(
              color: usedColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(result.className ?? result.classIndex.toString()),
                  Text(' ${result.score.toStringAsFixed(2)}')
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
