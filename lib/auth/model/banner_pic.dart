// @dart = 2.12
class BannerPic {
  final int id;
  final String picUrl;
  final String url;

  BannerPic(this.id, this.picUrl, this.url);

  BannerPic.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        picUrl = map['picUrl'],
        url = map['url'];

  @override
  String toString() => 'BannerPic id: $id, picUrl: $picUrl, url: $url';
}
