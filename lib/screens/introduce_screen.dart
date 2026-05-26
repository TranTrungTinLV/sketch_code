import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sketch/model/guideModel.dart';
import 'package:sketch/untils/gardientText.dart';

class IntroduceScreen extends StatefulWidget {
  const IntroduceScreen({super.key});

  @override
  State<IntroduceScreen> createState() => _IntroduceScreenState();
}

class _IntroduceScreenState extends State<IntroduceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem({required Widget child, required double delay}) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final nav = ['Feature', 'Gallery', 'Pricing'];
    final btn = ['Try for Free', 'Watch Demo'];
    List<GuidModel> guides = [
      GuidModel(
        title: 'Step 1: Sketch Your Idea',
        description:
            'Use our intuitive sketching tools to draw your concept. Don\'t worry about perfection; our algorithm will handle the details.',
      ),
      GuidModel(
        title: 'Step 2: Let it Snap',
        description:
            'Hold your pen at the end of the stroke. Watch as our heuristic engine transforms your sketch into a perfect geometric shape.',
      ),
      GuidModel(
        title: 'Step 3: Export & Share',
        description:
            'Export your perfect creations in high-quality PNG or JSON formats. Show the world your precise doodle masterpieces.',
      ),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF150B1E),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16.w : 48.w,
          vertical: 16.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ! Navbar
              _buildAnimatedItem(
                delay: 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      spacing: 12.w,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.88.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment(0.8, 1),
                              colors: [Color(0xff00D2FF), Color(0xffBD00FF)],
                            ),
                          ),
                          child: Image.asset(
                            'assets/icon/draw.png',
                            width: 20,
                            height: 28,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.brush, color: Colors.white, size: 20),
                          ),
                        ),
                        Text(
                          'DoodleMaster',
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18.sp : 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (!isMobile) ...[
                      Row(
                        spacing: 32,
                        children: List.generate(nav.length, (index) {
                          return InkWell(
                            onTap: () => debugPrint("nav:::${index}"),
                            child: Text(
                              nav[index],
                              style: GoogleFonts.inter(color: const Color(0xffA1A1AA)),
                            ),
                          );
                        }),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/editor');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment(0.8, 1),
                              colors: [Color(0xff00D2FF), Color(0xffBD00FF)],
                            ),
                          ),
                          child: Text(
                            'Try demo',
                            style: GoogleFonts.playfairDisplay(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ] else
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {},
                      ),
                  ],
                ),
              ),

              // ! Body Hero Section
              Container(
                margin: EdgeInsets.only(top: isMobile ? 30.h : 55.h),
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedItem(
                      delay: 0.2,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xff00D2FF), width: 1.w),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10.w,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                color: Color(0xff00D2FF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              "Welcome to DoodleMaster",
                              style: GoogleFonts.inter(
                                color: const Color(0xff00D2FF),
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 12.sp : 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                      children: [
                        _buildAnimatedItem(
                          delay: 0.3,
                          child: Text(
                            "Your Doodles,",
                            textAlign: isMobile ? TextAlign.left : TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: isMobile ? 40.sp : 96.sp,
                            ),
                          ),
                        ),
                        _buildAnimatedItem(
                          delay: 0.4,
                          child: GradientText(
                            "Masterpieces Refined",
                            gradient: const LinearGradient(
                              colors: [Color(0xff00D2FF), Color(0xffBD00FF)],
                            ),
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: isMobile ? 36.sp : 90.sp,
                            ),
                          ),
                        ),
                        _buildAnimatedItem(
                          delay: 0.5,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: isMobile ? 10.w : 382.w,
                              vertical: 24.h,
                            ),
                            child: Text(
                              'Transform simple sketches into breathtaking artworks instantly. Experience the smooth strokes and automatic QuickShape heuristics perfectly tailored for your digital creations.',
                              textAlign: isMobile ? TextAlign.justify : TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: isMobile ? 14.sp : 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              _buildAnimatedItem(
                delay: 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16.w,
                  children: List.generate(btn.length, (index) {
                    return InkWell(
                      onTap: () {
                        if (index == 0) {
                          Navigator.pushNamed(context, '/editor');
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: index == 1 ? const Color(0xff1A0B2E) : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 17.h, horizontal: 32.w),
                        child: Text(
                          btn[index],
                          style: GoogleFonts.inter(
                            color: index == 1 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              _buildAnimatedItem(
                delay: 0.7,
                child: Container(
                  height: isMobile ? 300.h : 600.h,
                  width: isMobile ? double.infinity : 1000.w,
                  margin: EdgeInsets.only(bottom: 100.h, top: 90.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffBD00FF).withAlpha(51), // 0.2 * 255
                        blurRadius: 40,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: BeforeAfterSlider(
                    beforeImage: Image.asset(
                      'assets/images/van_gogh.png',
                      fit: BoxFit.fill,
                    ),
                    afterImage: Image.asset(
                      'assets/images/sketch.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              _buildAnimatedItem(
                delay: 0.8,
                child: Container(
                  margin: EdgeInsets.only(bottom: 64.h),
                  child: Text(
                    "How It Works",
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: isMobile ? 28.sp : 48.sp,
                    ),
                  ),
                ),
              ),

              _buildAnimatedItem(
                delay: 0.9,
                child: isMobile 
                  ? Column(
                      spacing: 16.h,
                      children: List.generate(guides.length, (index) {
                        final guide = guides[index];
                        return Container(
                          padding: EdgeInsets.all(32.sp),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A0B2E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Column(
                            spacing: 12.h,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 19.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A0B2E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white24, width: 1),
                                ),
                                child: Image.asset(
                                  'assets/images/guide_${index}.png',
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.info, color: Colors.white),
                                ),
                              ),
                              Text(
                                guide.title,
                                style: GoogleFonts.playfairDisplay(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                guide.description,
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    )
                  : Row(
                      spacing: 32.w,
                      children: List.generate(guides.length, (index) {
                        final guide = guides[index];
                        return Expanded(
                          child: Container(
                            padding: EdgeInsets.all(32.sp),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A0B2E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24, width: 1),
                            ),
                            child: Column(
                              spacing: 12.h,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 19.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A0B2E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: Image.asset(
                                    'assets/images/guide_${index}.png',
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.info, color: Colors.white),
                                  ),
                                ),
                                Text(
                                  guide.title,
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  guide.description,
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
              ),
              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }
}

class BeforeAfterSlider extends StatefulWidget {
  final Widget beforeImage;
  final Widget afterImage;

  const BeforeAfterSlider({
    Key? key,
    required this.beforeImage,
    required this.afterImage,
  }) : super(key: key);

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      value: 0.5,
    );
    _controller.addListener(() => setState(() {}));
    _startAutoSlide();
  }

  void _startAutoSlide() async {
    while (mounted) {
      if (!_isDragging) {
        await _controller.animateTo(0.9, duration: const Duration(seconds: 3), curve: Curves.easeInOut);
      }
      if (!_isDragging) {
        await _controller.animateTo(0.1, duration: const Duration(seconds: 3), curve: Curves.easeInOut);
      }
      if (_isDragging) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final sliderPos = _controller.value;

        return GestureDetector(
          onHorizontalDragStart: (_) {
            _isDragging = true;
            _controller.stop();
          },
          onHorizontalDragUpdate: (details) {
            final delta = details.delta.dx / maxWidth;
            _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
          },
          onHorizontalDragEnd: (_) {
            _isDragging = false;
            // The loop will pick it up and animate to boundaries
          },
          onHorizontalDragCancel: () {
            _isDragging = false;
          },
          child: Stack(
            children: [
              SizedBox(
                width: maxWidth,
                height: maxHeight,
                child: widget.afterImage,
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: sliderPos,
                  child: SizedBox(
                    width: maxWidth,
                    height: maxHeight,
                    child: widget.beforeImage,
                  ),
                ),
              ),
              Positioned(
                left: (maxWidth * sliderPos) - 1.5,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: const Color(0xff00D2FF)),
              ),
              Positioned(
                left: (maxWidth * sliderPos) - 18,
                top: (maxHeight / 2) - 18,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF150B1E),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xff00D2FF), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(128), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(
                    Icons.code,
                    color: Color(0xff00D2FF),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

