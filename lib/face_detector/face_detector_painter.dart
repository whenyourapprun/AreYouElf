import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'coordinates_translator.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final Color faceColor = Colors.white;
  final double faceWidth = 0.2;
  final Color lineColor = Colors.white;
  final double lineWidth = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = faceWidth
      ..color = faceColor;

    final Paint paint2 = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;
    final Paint paint3 = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;
    final Paint paint4 = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;
    final Paint paint5 = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;
    final Paint paint6 = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;
    final Paint paint7 = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;
    final Paint paint8 = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;
    final Paint paint9 = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineWidth;

    for (final Face face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint1,
      );

      var width = right - left;
      var delta = width * 0.2;
      Offset p21 = Offset(left, top);
      Offset p22 = Offset(left + delta, top);
      Offset p31 = Offset(left, top);
      Offset p32 = Offset(left, top - delta);
      Offset p41 = Offset(left, bottom);
      Offset p42 = Offset(left + delta, bottom);
      Offset p51 = Offset(left, bottom);
      Offset p52 = Offset(left, bottom + delta);
      Offset p61 = Offset(right, bottom);
      Offset p62 = Offset(right, bottom + delta);
      Offset p71 = Offset(right, bottom);
      Offset p72 = Offset(right - delta, bottom);
      Offset p81 = Offset(right, top);
      Offset p82 = Offset(right, top - delta);
      Offset p91 = Offset(right, top);
      Offset p92 = Offset(right - delta, top);

      canvas.drawLine(p21, p22, paint2);
      canvas.drawLine(p31, p32, paint3);
      canvas.drawLine(p41, p42, paint4);
      canvas.drawLine(p51, p52, paint5);
      canvas.drawLine(p61, p62, paint6);
      canvas.drawLine(p71, p72, paint7);
      canvas.drawLine(p81, p82, paint8);
      canvas.drawLine(p91, p92, paint9);
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
