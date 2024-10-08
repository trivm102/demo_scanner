import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ZoomScaleSlider extends StatefulWidget {
  const ZoomScaleSlider({super.key, required this.controller});

  final MobileScannerController controller;

  @override
  State<ZoomScaleSlider> createState() => _ZoomScaleSliderState();
}

class _ZoomScaleSliderState extends State<ZoomScaleSlider> {
  double _zoomFactor = 0.0;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              const Icon(Icons.zoom_out, color: Colors.white),
              Expanded(
                child: Slider(
                  value: _zoomFactor,
                  onChanged: (value) {
                    setState(() {
                      _zoomFactor = value;
                      widget.controller.setZoomScale(value);
                    });
                  },
                ),
              ),
              const Icon(Icons.zoom_in, color: Colors.white),
            ],
          ),
        );
      },
    );
  }
}
