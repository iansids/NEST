import 'package:flutter/material.dart';
import '../../../core/typography/app_text_styles.dart';

/// Reddit-style image carousel
/// Shows one image at a time with previous/next navigation buttons
class ImageCarousel extends StatefulWidget {
  final List<String> images;

  const ImageCarousel({super.key, required this.images});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  bool _isMovingForward = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _previousIndex = _currentIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _isMovingForward = false;
      _previousIndex = _currentIndex;
      setState(() => _currentIndex--);
      _animationController.forward(from: 0.0);
    }
  }

  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) {
      _isMovingForward = true;
      _previousIndex = _currentIndex;
      setState(() => _currentIndex++);
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate offsets for both images
    final animation =
        Tween<Offset>(
          begin: _isMovingForward ? const Offset(1, 0) : const Offset(-1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    return Column(
      children: [
        // Image display container
        Container(
          width: double.infinity,
          height: 300,
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Previous image slides out
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: Offset.zero,
                      end: _isMovingForward
                          ? const Offset(-1, 0)
                          : const Offset(1, 0),
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      ),
                    ),
                child: Center(
                  child: Image.asset(
                    widget.images[_previousIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        child: Center(
                          child: Text(
                            'Image not found',
                            style: AppTextStyles.body(context),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Current image slides in
              SlideTransition(
                position: animation,
                child: Center(
                  child: Image.asset(
                    widget.images[_currentIndex],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        child: Center(
                          child: Text(
                            'Image not found',
                            style: AppTextStyles.body(context),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Counter badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Dot pagination with navigation arrows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous arrow
            GestureDetector(
              onTap: _currentIndex > 0 ? _previousImage : null,
              child: Icon(
                Icons.chevron_left,
                size: 24,
                color: _currentIndex > 0
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(width: 8),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => GestureDetector(
                  onTap: () {
                    if (index != _currentIndex) {
                      _isMovingForward = index > _currentIndex;
                      _previousIndex = _currentIndex;
                      setState(() => _currentIndex = index);
                      _animationController.forward(from: 0.0);
                    }
                  },
                  child: Container(
                    width: _currentIndex == index ? 8 : 6,
                    height: _currentIndex == index ? 8 : 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Next arrow
            GestureDetector(
              onTap: _currentIndex < widget.images.length - 1
                  ? _nextImage
                  : null,
              child: Icon(
                Icons.chevron_right,
                size: 24,
                color: _currentIndex < widget.images.length - 1
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
