import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vish/models/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, required this.videoPlayer});
  final IVideoPlayer videoPlayer;

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.videoPlayer.controller;

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(controller),
          _ResumeButton(controller: controller),
          _VideoPlayerSlider(controller: controller),
        ],
      ),
    );
  }
}

class _ResumeButton extends StatefulWidget {
  const _ResumeButton({required this.controller});

  final VideoPlayerController controller;

  @override
  State<StatefulWidget> createState() => _ResumeButtonState();
}

class _ResumeButtonState extends State<_ResumeButton> {
  bool autoPlay = true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          autoPlay = false;
          widget.controller.value.isPlaying
              ? widget.controller.pause()
              : widget.controller.play();
        });
      },
      child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: widget.controller.value.isPlaying || autoPlay ? 0 : 0.7,
          child: const Center(
              child: RotatedBox(
            quarterTurns: 1,
            child: Icon(
              Icons.change_history_rounded,
              size: 64,
            ),
          ))),
    );
  }
}

class _VideoPlayerSlider extends StatefulWidget {
  const _VideoPlayerSlider({required this.controller});

  final VideoPlayerController controller;

  @override
  State<StatefulWidget> createState() => _VideoPlayerSliderState();
}

class _VideoPlayerSliderState extends State<_VideoPlayerSlider> {
  late Duration _currentPosition = const Duration(microseconds: 0);

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_handlePositionChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handlePositionChange);

    super.dispose();
  }

  void _handlePositionChange() {
    setState(() {
      _currentPosition = widget.controller.value.position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SliderTheme(
            data: Theme.of(context).sliderTheme.copyWith(
                  overlayShape: SliderComponentShape.noThumb,
                  thumbShape: SliderComponentShape.noThumb,
                ),
            child: Slider(
                value: _currentPosition.inMicroseconds.toDouble(),
                min: 0,
                max: controller.value.duration.inMicroseconds.toDouble(),
                onChanged: (double value) {
                  controller.seekTo(Duration(microseconds: value.toInt()));
                })));
  }
}
