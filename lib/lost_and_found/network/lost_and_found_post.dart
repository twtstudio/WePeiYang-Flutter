import 'package:image_size_getter/image_size_getter.dart';

class LostAndFoundPost {
  LostAndFoundPost({
    required this.id,
    required this.author,
    required this.type,
    required this.category,
    required this.title,
    required this.text,
    required this.location,
    required this.uploadTime,
    required this.detailedUploadTime,
    required this.phone,
    this.coverPhotoPath,
    required this.hot,
    required this.coverPhotoPathInDetail,
  });
  int id;
  String author;
  String type;
  String category;
  String title;
  String text;
  String uploadTime;

  ///yyyymmdd
  String detailedUploadTime;

  ///yyyymmddhhmmss
  String location;
  String phone;
  String? coverPhotoPath;
  int hot;
  Size? coverPhotoSize;
  List<String> coverPhotoPathInDetail;

  LostAndFoundPost.fromJson(Map<String, dynamic> json)
      : id = json['laf']['id'],
        author = json['laf']['author'],
        type = json['laf']['type'],
        category = json['laf']['category'],
        title = json['laf']['title'],
        text = json['laf']['text'],
        uploadTime = json['laf']['yyyymmdd'],
        detailedUploadTime = json['laf']['yyyymmddhhmmss'],
        location = json['laf']['location'],
        phone = json['laf']['phone'],
        hot = json['laf']['hot'],
        coverPhotoPath = json['pho'] != null ? json['pho']['url'] : null,
        coverPhotoPathInDetail = json['phos'] != null
            ? (json['phos'] as List)
                .map((item) => item['url'] as String)
                .toList()
            : [];
}
