import 'package:are_you_elf/main.dart';
import 'package:flutter/material.dart';

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
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: false);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.0, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticIn,
  ));

  @override
  void initState() {
    super.initState();
    _analyzed = false;
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
            child: ScaleTransition(
              scale: _animation,
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
            child: ScaleTransition(
              scale: _animation,
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
                _analyzed == true ? 'mbtiAnalyzedCompleted' : 'Analyzing',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: seedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 64,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _analyzed == true
                        ? 'mbtiAnalyzedCompletedGuide'
                        : 'Analyzing',
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
