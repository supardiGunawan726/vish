import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:vish/cubits/video_list/video_list_state.dart';
import 'package:vish/main.dart';
import 'package:vish/models/post.dart';
import 'package:vish/models/video_player.dart';
import 'package:cloud_functions/cloud_functions.dart';

class VideoListCubit extends Cubit<VideoListState> {
  VideoListCubit() : super(const VideoListStateInitial(0, []));
  int previousPlaying = 0;
  String? nextPageToken;
  final CacheManager _cacheManager = DefaultCacheManager();

  Future<List<IVideoPlayer>> loadVideos() async {
    try {
      if (state is VideoListStateLoading ||
          state is VideoListStateLoadingMore) {
        throw ErrorDescription('Still loading');
      }

      if (state is VideoListStateInitial) {
        emit(const VideoListStateLoading(0, []));
      } else if (state is VideoListStateLoaded && nextPageToken != null) {
        emit(VideoListStateLoadingMore(state.playing, state.videoPlayer));
      } else if (state is VideoListStateLoaded && nextPageToken == null) {
        throw ErrorDescription('The end of the file reached');
      }

      final postsResult = await functions.httpsCallable('getFeed')();

      final List<IPostVideo> posts = [];
      for (final postResult in postsResult.data['posts']) {
        posts.add(IPostVideo.fromJSON(postResult));
      }

      List<IVideoPlayer> videoPlayers =
          await Future.wait(posts.map((post) async {
        var file = await _cacheManager.getSingleFile(post.videoUrl);

        return IVideoPlayer(
            post: post, controller: VideoPlayerController.file(file));
      }));

      try {
        await Future.wait(
            videoPlayers.map((player) => player.controller.initialize()));
      } catch (e) {
        print("error initializing");
        videoPlayers = videoPlayers
            .where((videoPlayer) => videoPlayer.controller.value.isInitialized)
            .toList();
      }

      if (state is VideoListStateLoading) {
        videoPlayers[0].controller.play();
        emit(VideoListStateLoaded(0, videoPlayers));
      } else if (state is VideoListStateLoadingMore) {
        emit(VideoListStateLoaded(
            state.playing, [...state.videoPlayer, ...videoPlayers]));
      }

      return Future.value(videoPlayers);
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  void changePlaying(int index) {
    var previousPlayingController =
        state.videoPlayer[previousPlaying].controller;
    var nextPlayingController = state.videoPlayer[index].controller;

    previousPlayingController.seekTo(Duration.zero);
    previousPlayingController.pause();

    nextPlayingController.setLooping(true);
    nextPlayingController.play();

    if (state is VideoListStateLoadingMore) {
      emit(VideoListStateLoadingMore(index, state.videoPlayer));
    } else {
      emit(VideoListStateLoaded(index, state.videoPlayer));
    }

    previousPlaying = index;
  }
}
