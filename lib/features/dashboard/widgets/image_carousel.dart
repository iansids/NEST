import 'package:flutter/material.dart';
import '../../../core/typography/app_text_styles.dart';

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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isNetworkImage(String imagePath) =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  Widget _buildImage(String imagePath) {
    if (_isNetworkImage(imagePath)) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _ErrorPlaceholder(
          message: 'Image failed to load',
          showIcon: true,
        ),
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => _ErrorPlaceholder(message: 'Image not found'),
    );
  }

  void _goTo(int index) {
    if (index == _currentIndex) return;
    _isMovingForward = index > _currentIndex;
    _previousIndex = _currentIndex;
    setState(() => _currentIndex = index);
    _animationController.forward(from: 0.0);
  }

  void _previousImage() {
    if (_currentIndex > 0) _goTo(_currentIndex - 1);
  }

  void _nextImage() {
    if (_currentIndex < widget.images.length - 1) _goTo(_currentIndex + 1);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) {
      _nextImage();
    } else if (velocity > 300) {
      _previousImage();
    }
  }

  void _openPreview() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, _, _) => _ImagePreviewPage(
          images: widget.images,
          initialIndex: _currentIndex,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slideIn = Tween<Offset>(
      begin: _isMovingForward ? const Offset(1, 0) : const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: _isMovingForward ? const Offset(-1, 0) : const Offset(1, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    return Column(
      children: [
        GestureDetector(
          onTap: _openPreview,
          onHorizontalDragStart: (_) {},
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SlideTransition(
                  position: slideOut,
                  child: _buildImage(widget.images[_previousIndex]),
                ),
                SlideTransition(
                  position: slideIn,
                  child: _buildImage(widget.images[_currentIndex]),
                ),
                if (widget.images.length > 1)
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
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Row(
                children: List.generate(
                  widget.images.length,
                  (index) => GestureDetector(
                    onTap: () => _goTo(index),
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
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Full-screen image preview with swipe navigation and pinch-to-zoom
// ---------------------------------------------------------------------------

class _ImagePreviewPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ImagePreviewPage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<_ImagePreviewPage> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isNetworkImage(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final src = widget.images[index];
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: _isNetworkImage(src)
                      ? Image.network(
                          src,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const _PreviewError(),
                        )
                      : Image.asset(
                          src,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const _PreviewError(),
                        ),
                ),
              );
            },
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.white54),
        SizedBox(height: 8),
        Text(
          'Image failed to load',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Carousel error placeholder
// ---------------------------------------------------------------------------

class _ErrorPlaceholder extends StatelessWidget {
  final String message;
  final bool showIcon;

  const _ErrorPlaceholder({required this.message, this.showIcon = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.outlineVariant,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.image_not_supported_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
            ],
            Text(message, style: AppTextStyles.body(context)),
          ],
        ),
      ),
    );
  }
}
