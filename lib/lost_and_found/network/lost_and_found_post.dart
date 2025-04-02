 import 'package:image_size_getter/image_size_getter.dart';
 class LostAndFoundPost {
   LostAndFoundPost({
     required this.id,
     required this.createdAt,
     required this.uid,
     required this.type,
     required this.category,
     required this.campus,
     required this.solved,
     required this.title,
     required this.content,
     required this.location,
     required this.hot,
     required this.value,
     required this.eTag,
     required this.tag,
     required this.tagContent,
     required this.imageUrls,
     required this.time,
     required this.deleted,
   });

   int id;
   String createdAt;
   String uid;
   int type;
   int category;
   int campus;
   bool solved;
   String title;
   String content;
   String location;
   int hot;
   int value;
   int? eTag;
   int? tag;
   int? tagContent;
   List<String> imageUrls;
   String time;
   bool deleted;

   factory LostAndFoundPost.fromJson(Map<String, dynamic> json) {
     return LostAndFoundPost(
       id: json['id'],
       createdAt: json['created_at'],
       uid: json['uid'],
       type: json['type'],
       category: json['category'],
       campus: json['campus'],
       solved: json['solved'],
       title: json['title'],
       content: json['content'],
       location: json['location'],
       hot: json['hot'],
       value: json['value'],
       eTag: json['e_tag'],
       tag: json['tag'],
       tagContent: json['tagContent'],
       imageUrls: List<String>.from(json['image_urls'] ?? []),
       time: json['time'],
       deleted: json['_deleted'],
     );
   }
 }
//
// class LostAndFoundPost {
//   LostAndFoundPost({
//     required this.id,
//     required this.author,
//     required this.type,
//     required this.category,
//     required this.title,
//     required this.text,
//     required this.location,
//     required this.uploadTime,
//     required this.detailedUploadTime,
//     required this.phone,
//     this.coverPhotoPath,
//     required this.hot,
//     required this.coverPhotoPathInDetail,
//   });
//   int id;
//   String author;
//   String type;
//   String category;
//   String title;
//   String text;
//   String uploadTime;
//
//   ///yyyymmdd
//   String detailedUploadTime;
//
//   ///yyyymmddhhmmss
//   String location;
//   String phone;
//   String? coverPhotoPath;
//   int hot;
//   Size? coverPhotoSize;
//   List<String> coverPhotoPathInDetail;
//
//   LostAndFoundPost.fromJson(Map<String, dynamic> json)
//       : id = json['laf']['id'],
//         author = json['laf']['author'],
//         type = json['laf']['type'],
//         category = json['laf']['category'],
//         title = json['laf']['title'],
//         text = json['laf']['text'],
//         uploadTime = json['laf']['yyyymmdd'],
//         detailedUploadTime = json['laf']['yyyymmddhhmmss'],
//         location = json['laf']['location'],
//         phone = json['laf']['phone'],
//         hot = json['laf']['hot'],
//         coverPhotoPath = json['pho'] != null ? json['pho']['url'] : null,
//         coverPhotoPathInDetail = json['phos'] != null
//             ? (json['phos'] as List)
//                 .map((item) => item['url'] as String)
//                 .toList()
//             : [];
// }
