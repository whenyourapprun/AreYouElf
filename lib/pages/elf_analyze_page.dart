import 'dart:io';
import 'package:are_you_elf/pages/elf_result_page.dart';
import 'package:are_you_elf/utils/admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class ElfAnalyzePage extends StatefulWidget {
  const ElfAnalyzePage({super.key, required this.path});
  final String path;

  @override
  State<ElfAnalyzePage> createState() => _ElfAnalyzePageState();
}

class _ElfAnalyzePageState extends State<ElfAnalyzePage>
    with TickerProviderStateMixin {
  bool _analyzed = false;
  // 애니메이션
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0.25, 0.0),
    end: const Offset(0.75, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  ));
  // yolov8
  late ModelObjectDetection _objectModelYoloV8;
  String? textToShow;
  bool objectDetection = false;
  late File _image;
  List<ResultObjectDetection?> objDetect = [];
  // 애드몹 광고
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _analyzed = false;
    // admob
    _loadRewardedAd();
    _image = File(widget.path);
    loadModel();
  }

  Future loadModel() async {
    String pathObjectDetectionModelYolov8 = 'assets/models/elf.torchscript';
    try {
      _objectModelYoloV8 = await PytorchLite.loadObjectDetectionModel(
          pathObjectDetectionModelYolov8, 2, 640, 640,
          labelPath: 'assets/models/elf.txt',
          objectDetectionModelType: ObjectDetectionModelType.yolov8);
    } catch (e) {
      if (e is PlatformException) {
        debugPrint('only supported for android, error is $e');
      } else {
        debugPrint('Error is $e');
      }
    }
    debugPrint('loadModel completed');
    // 모델 로딩 되었으니 이제 추론 해보자.
    runObjectDetectionYoloV8();
  }

  Future runObjectDetectionYoloV8() async {
    Stopwatch stopwatch = Stopwatch()..start();
    Uint8List imgData = await _image.readAsBytes();
    objDetect = await _objectModelYoloV8.getImagePrediction(imgData,
        minimumScore: 0.1, iOUThreshold: 0.3);
    debugPrint('object executed in ${stopwatch.elapsed.inMilliseconds} ms');
    debugPrint('objDetect ${objDetect.length}');
    for (var element in objDetect) {
      debugPrint(
          'score: ${element?.score} className: ${element?.className} class: ${element?.classIndex} rect left: ${element?.rect.left} top: ${element?.rect.top} width: ${element?.rect.width} height: ${element?.rect.height} right: ${element?.rect.right} bottom: ${element?.rect.bottom}');
    }
    setState(() {
      _analyzed = true;
    });
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewarded[Platform.isIOS ? 'ios' : 'android']!,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          // 광고 로딩 되면
          debugPrint('rainAd loaded');
          setState(() {
            _rewardedAd = ad;
          });
          // 광고 시청 완료
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad1) {
              // 광고 시청을 완료해도 다시 요청하지 않는다.
              ad1.dispose();
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint(
              'Failed to load a personalcolorRewarded ad ${err.message}');
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/elf_bg_3.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.01,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Image.asset(
                'assets/images/check_circle.png',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.1,
            child: RotationTransition(
              turns: _animation,
              child: Image.asset(
                'assets/images/check_pyramid.png',
                width: MediaQuery.of(context).size.width * 0.2,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.3,
            child: RotationTransition(
              turns: _animation,
              child: Image.asset(
                'assets/images/check_spring.png',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: MediaQuery.of(context).size.width * 0.01,
            child: RotationTransition(
              turns: _animation,
              child: Image.asset(
                'assets/images/check_pyramid_1.png',
                width: MediaQuery.of(context).size.width * 0.3,
              ),
            ),
          ),
          // 퍼스널 컬러 결과 표시
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.5),
              Text(
                _analyzed == true ? 'Completed' : 'Analyzing',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('analyzing touched');
                    _rewardedAd!.show(onUserEarnedReward: (_, reward) {
                      // 분석이 완료되었으면 결과창으로 이동
                      if (_analyzed) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ElfResultPage(
                              path: widget.path,
                              objDetect: objDetect,
                            ),
                          ),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white30,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 64,
                    ),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _analyzed == true ? 'Go Result' : 'Ready',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
