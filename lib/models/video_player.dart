import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';
import 'package:vish/models/post.dart';

class IVideoPlayer extends Equatable {
  final IPost post;
  final VideoPlayerController controller;

  const IVideoPlayer({required this.post, required this.controller});

  @override
  List<Object?> get props => [post, controller];
}
