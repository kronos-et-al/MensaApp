import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MealImageView extends StatefulWidget {
  final ImageData imageData;
  final double minScale;
  final double maxScale;
  final void Function(double)? onScaleChanged;

  final double doubleTapScale = 3.5;
  final Curve curve = Curves.fastLinearToSlowEaseIn;

  const MealImageView(
      {super.key,
      required this.imageData,
      this.minScale = 1.0,
      this.maxScale = 5.0,
      this.onScaleChanged});

  @override
  State<MealImageView> createState() => _MealImageViewState();
}

class _MealImageViewState extends State<MealImageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;
  late TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        _transformationController.value = _zoomAnimation!.value;
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final newValue = _transformationController.value.isIdentity()
        ? _applyZoom()
        : _revertZoom();
    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: newValue,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );
    _animationController.forward(from: 0.0);
  }

  Matrix4 _applyZoom() {
    final tapPosition = _doubleTapDetails!.localPosition;
    final translationCorrection = widget.doubleTapScale - 1;
    final zoomed = Matrix4.identity()
      ..translate(
        -tapPosition.dx * translationCorrection,
        -tapPosition.dy * translationCorrection,
      )
      ..scale(widget.doubleTapScale);
    if (widget.onScaleChanged != null) {
      widget.onScaleChanged!(widget.doubleTapScale);
    }
    return zoomed;
  }

  Matrix4 _revertZoom() {
    return Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: widget.imageData.url,
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
              child:
                  CircularProgressIndicator(value: downloadProgress.progress),
            ),
        imageBuilder: (context, imageProvider) => GestureDetector(
              onDoubleTapDown: _handleDoubleTapDown,
              onDoubleTap: _handleDoubleTap,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0),
                  transformationController: _transformationController,
                  minScale: widget.minScale,
                  maxScale: widget.maxScale,
                  onInteractionEnd: (details) {
                    double scale =
                        _transformationController.value.getMaxScaleOnAxis();

                    if (widget.onScaleChanged != null) {
                      widget.onScaleChanged!(scale);
                    }
                  },
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ));
  }
}
