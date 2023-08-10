import 'package:equatable/equatable.dart';

import '../../models/video_player.dart';

abstract class VideoListState extends Equatable {
  final int playing;
  final List<IVideoPlayer> videoPlayer;

  const VideoListState(this.playing, this.videoPlayer);

  @override
  List<Object> get props => [playing, videoPlayer];
}

class VideoListStateInitial extends VideoListState {
  const VideoListStateInitial(super.playing, super.videoPlayer);
}

class VideoListStateLoading extends VideoListState {
  const VideoListStateLoading(super.playing, super.videoPlayer);
}

class VideoListStateLoadingMore extends VideoListState {
  const VideoListStateLoadingMore(super.playing, super.videoPlayer);
}

class VideoListStateError extends VideoListState {
  final String message;

  const VideoListStateError(super.playing, super.videoPlayer, this.message);

  @override
  List<Object> get props => [message];
}

class VideoListStateLoaded extends VideoListState {
  const VideoListStateLoaded(super.playing, super.videoPlayer);
}
