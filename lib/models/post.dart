import 'package:equatable/equatable.dart';

enum PostType { video, photos }

class IPost extends Equatable {
  final PostType type;
  final String userId;
  final String caption;

  const IPost(
      {this.type = PostType.video,
      required this.userId,
      required this.caption});

  @override
  List<Object?> get props => [type, userId];
}

class IPostVideo extends IPost {
  final String videoUrl;

  const IPostVideo(
      {required super.userId,
      required super.caption,
      required this.videoUrl,
      super.type = PostType.video});

  factory IPostVideo.fromJSON(Map<Object?, dynamic> json) {
    return IPostVideo(
        userId: json['user_id'],
        videoUrl: json['video_url'],
        caption: json['caption']);
  }

  @override
  List<Object?> get props => [type, userId, videoUrl];
}
