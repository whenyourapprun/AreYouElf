import 'package:flutter/material.dart';

class Bbox extends StatelessWidget {
  const Bbox({
    super.key,
    required this.displayWidth,
    required this.displayHeight,
    required this.box,
    required this.name,
    required this.score,
  });
  final double displayWidth;
  final double displayHeight;
  final List<double> box;
  final String name;
  final double score;

  @override
  Widget build(BuildContext context) {
    final double width = box[2] * displayWidth;
    final double height = box[3] * displayHeight;
    final double left = (box[0] * displayWidth) - (width / 2);
    final double top = (box[1] * displayHeight) - (height / 2);
    // debugPrint('box $box name $name score $score');
    return Positioned(
      left: left < 0 ? 0 : left,
      top: top < 0 ? 0 : top,
      width: left + width > displayWidth ? displayWidth - left : width,
      height: top + height > displayHeight ? displayHeight - top : height,
      child: Container(
        width: left + width > displayWidth ? displayWidth - left : width,
        height: top + height > displayHeight ? displayHeight - top : height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: FittedBox(
            child: Container(
              color: Colors.black38,
              width: width,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        name,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        ' ${score.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
