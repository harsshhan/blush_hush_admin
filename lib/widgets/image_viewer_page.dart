import 'package:flutter/material.dart';

class ImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late TransformationController _transformController;
  int _currentIndex = 0;
  Animation<Matrix4>? _zoomAnimation;
  AnimationController? _animController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformController = TransformationController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformController.dispose();
    _animController?.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  void _handleDoubleTap(TapDownDetails details) async {
    final position = details.localPosition;
    final current = _transformController.value;
    final double currentScale = current.getMaxScaleOnAxis();
    final double targetScale = currentScale > 1.0 ? 1.0 : 2.5;

    final zoomed = Matrix4.identity()
      ..translate(
        -position.dx * (targetScale - 1),
        -position.dy * (targetScale - 1),
      )
      ..scale(targetScale);

    _animController?.dispose();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _zoomAnimation =
        Matrix4Tween(
          begin: current,
          end: targetScale == 1.0 ? Matrix4.identity() : zoomed,
        ).animate(
          CurvedAnimation(parent: _animController!, curve: Curves.easeInOut),
        );
    _animController!.addListener(() {
      _transformController.value = _zoomAnimation!.value;
    });
    _animController!.forward();
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) {
              setState(() => _currentIndex = i);
              _resetZoom();
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              final url = widget.imageUrls[index];

              // Validate URL before trying to load
              if (!_isValidUrl(url)) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, color: Colors.white70, size: 60),
                      SizedBox(height: 16),
                      Text(
                        'Invalid image URL',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'URL: $url',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return GestureDetector(
                onDoubleTapDown: _handleDoubleTap,
                onDoubleTap: () {},
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: EdgeInsets.all(20),
                  child: Hero(
                    tag: url,
                    child: Image.network(
                      url,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                  : null,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.white70,
                                size: 60,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Image unable to load',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Error: ${error.toString()}',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          // Page indicator at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
