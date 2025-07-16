import 'package:flutter/material.dart';

class MeetingLoadingWidget extends StatefulWidget {
  const MeetingLoadingWidget({Key? key}) : super(key: key);

  @override
  State<MeetingLoadingWidget> createState() => _MeetingLoadingWidgetState();
}

class _MeetingLoadingWidgetState extends State<MeetingLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _bookController;
  late AnimationController _textController;
  late Animation<double> _bookOpenAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Book opening animation controller
    _bookController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Book opening animation (0 = closed, 1 = fully open)
    _bookOpenAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bookController,
      curve: Curves.easeInOut,
    ));
    
    // Text fade animation
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    ));
    
    // Text scale animation for pulsing effect
    _textScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _startAnimations();
  }
  
  void _startAnimations() {
    _bookController.forward();
    _textController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _bookController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Book Animation
          AnimatedBuilder(
            animation: _bookOpenAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 200,
                height: 160,
                child: CustomPaint(
                  painter: BookPainter(_bookOpenAnimation.value),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Loading Text
          AnimatedBuilder(
            animation: Listenable.merge([_textFadeAnimation, _textScaleAnimation]),
            builder: (context, child) {
              return Opacity(
                opacity: _textFadeAnimation.value,
                child: Transform.scale(
                  scale: _textScaleAnimation.value,
                  child: const Text(
                    'Hold on while we search the record...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Loading indicator dots
          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final animation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(CurvedAnimation(
                    parent: _textController,
                    curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
                  ));
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: Transform.scale(
                      scale: 0.5 + (animation.value * 0.5),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3 + (animation.value * 0.7)),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BookPainter extends CustomPainter {
  final double openProgress;
  
  BookPainter(this.openProgress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final bookWidth = size.width * 0.8;
    final bookHeight = size.height * 0.7;
    
    // Book spine (always visible)
    paint.color = Colors.brown.shade700;
    final spineRect = Rect.fromLTWH(
      centerX - 3,
      centerY - bookHeight / 2,
      6,
      bookHeight,
    );
    canvas.drawRect(spineRect, paint);
    
    // Left page
    paint.color = Colors.white;
    final leftPageAngle = -openProgress * 0.8; // Max 45 degrees
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(leftPageAngle);
    canvas.translate(-centerX, -centerY);
    
    final leftPageRect = Rect.fromLTWH(
      centerX - bookWidth / 2,
      centerY - bookHeight / 2,
      bookWidth / 2,
      bookHeight,
    );
    canvas.drawRect(leftPageRect, paint);
    
    // Left page border
    paint.color = Colors.grey.shade300;
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(leftPageRect, paint);
    
    // Left page lines (simulating text)
    paint.color = Colors.grey.shade400;
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final lineY = centerY - bookHeight / 2 + 20 + (i * 15);
      final lineRect = Rect.fromLTWH(
        centerX - bookWidth / 2 + 10,
        lineY,
        bookWidth / 2 - 20,
        2,
      );
      canvas.drawRect(lineRect, paint);
    }
    
    canvas.restore();
    
    // Right page
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    final rightPageAngle = openProgress * 0.8; // Max 45 degrees
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rightPageAngle);
    canvas.translate(-centerX, -centerY);
    
    final rightPageRect = Rect.fromLTWH(
      centerX,
      centerY - bookHeight / 2,
      bookWidth / 2,
      bookHeight,
    );
    canvas.drawRect(rightPageRect, paint);
    
    // Right page border
    paint.color = Colors.grey.shade300;
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(rightPageRect, paint);
    
    // Right page lines (simulating text)
    paint.color = Colors.grey.shade400;
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final lineY = centerY - bookHeight / 2 + 20 + (i * 15);
      final lineRect = Rect.fromLTWH(
        centerX + 10,
        lineY,
        bookWidth / 2 - 20,
        2,
      );
      canvas.drawRect(lineRect, paint);
    }
    
    canvas.restore();
    
    // Book shadow
    paint.color = Colors.black.withOpacity(0.1);
    paint.style = PaintingStyle.fill;
    final shadowOffset = 5.0;
    canvas.drawOval(
      Rect.fromLTWH(
        centerX - bookWidth / 2 + shadowOffset,
        centerY + bookHeight / 2 - 10,
        bookWidth - shadowOffset,
        20,
      ),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


