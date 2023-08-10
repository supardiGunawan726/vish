import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:vish/cubits/video_list/video_list_cubit.dart';
import 'package:vish/cubits/video_list/video_list_state.dart';
import 'package:vish/widgets/video_player.dart';

class VideoListWidget extends StatefulWidget {
  const VideoListWidget({super.key});

  @override
  State<StatefulWidget> createState() => VideoListWidgetState();
}

class VideoListWidgetState extends State<VideoListWidget> {
  final _pageController = PageController(viewportFraction: 1);
  late VideoListCubit _currentVideoListCubit;
  late double _widgetHeight;

  void onPageChanged(BuildContext context, int page, VideoListState state) {
    var videoListCubit = BlocProvider.of<VideoListCubit>(context);
    videoListCubit.changePlaying(page);
  }

  void onPositionChanged() {
    var page = _pageController.page;
    var currentVideoListCubitState = _currentVideoListCubit.state;

    if (currentVideoListCubitState is VideoListStateLoaded &&
        page! >= _currentVideoListCubit.state.videoPlayer.length - 1 &&
        _pageController.offset > _widgetHeight * page) {
      _currentVideoListCubit.loadVideos().then((result) {
        if (result.isEmpty) {
          return;
        }

        _pageController.animateToPage(page.toInt() + 1,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
      });
    }
  }

  @override
  void didUpdateWidget(covariant VideoListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _pageController.removeListener(onPositionChanged);
  }

  @override
  Widget build(BuildContext context) {
    _pageController.addListener(onPositionChanged);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<VideoListCubit, VideoListState>(
        listener: (context, state) {
      _currentVideoListCubit = BlocProvider.of<VideoListCubit>(context);
      _widgetHeight = context.size!.height;
    }, builder: (context, state) {
      if (state is VideoListStateError) {
        return Text(state.message);
      }

      if (state is VideoListStateLoading || state is VideoListStateInitial) {
        return Center(
          child: SizedBox(
              width: 48,
              child: LoadingIndicator(
                  indicatorType: Indicator.ballPulseSync,
                  colors: [colorScheme.onBackground])),
        );
      }

      return PageView.builder(
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (page) => onPageChanged(context, page, state),
        scrollDirection: Axis.vertical,
        itemCount: state.videoPlayer.length,
        itemBuilder: (context, index) {
          if (state is VideoListStateLoadingMore &&
              index == state.videoPlayer.length - 1) {
            return ListView(
              reverse: true,
              children: [
                Center(
                  child: SizedBox(
                      width: 48,
                      child: LoadingIndicator(
                          indicatorType: Indicator.ballPulseSync,
                          colors: [colorScheme.onBackground])),
                ),
                VideoPlayerWidget(videoPlayer: state.videoPlayer[index]),
              ],
            );
          }

          return VideoPlayerWidget(videoPlayer: state.videoPlayer[index]);
        },
      );
    });
  }
}
