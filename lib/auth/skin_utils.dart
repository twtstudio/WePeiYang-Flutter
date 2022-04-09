// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

class Skin {
  Skin(
      {this.id,
      this.name,
      this.description,
      this.selfPageImage,
      this.mainPageImage,
      this.schedulePageImage,
      this.gpaImageInner,
      this.gpaImageOuter,
      this.colorA,
      this.colorB,
      this.colorC,
      this.colorD,
      this.colorE,
      this.colorF,
      this.colorG,
      this.colorH,
      this.colorI,
      this.colorJ});

  int id;
  String name;
  String description;
  String selfPageImage;
  String mainPageImage;
  String schedulePageImage;
  String gpaImageInner;
  String gpaImageOuter;
  int colorA;
  int colorB;
  int colorC;
  int colorD;
  int colorE;
  int colorF;
  int colorG;
  int colorH;
  int colorI;
  int colorJ;

  bool operator ==(Object other) => other is Skin && other.id == id;

  factory Skin.fromJson(Map<String, dynamic> json) => Skin(
        id: json["id"],
        name: json["src"]["name"],
        description: json["src"]["description"],
        selfPageImage: json["src"]["self_page_image"],
        mainPageImage: json["src"]["main_page_image"],
        schedulePageImage: json["src"]["schedule_page_image"],
        gpaImageInner: json["src"]["gpa_image_inner"],
        gpaImageOuter: json["src"]["gpa_image_outer"],
        colorA: json["src"]["color_a"],
        colorB: json["src"]["color_b"],
        colorC: json["src"]["color_c"],
        colorD: json["src"]["color_d"],
        colorE: json["src"]["color_e"],
        colorF: json["src"]["color_f"],
        colorG: json["src"]["color_g"],
        colorH: json["src"]["color_h"],
        colorI: json["src"]["color_i"],
        colorJ: json["src"]["color_j"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "self_page_image": "'$selfPageImage'",
        "main_page_image": "'$mainPageImage'",
        'schedule_page_image': "'$schedulePageImage'",
        'gpa_image_inner': "'$gpaImageInner'",
        'gpa_image_outer': "'$gpaImageOuter'",
        "color_a": colorA,
        "color_b": colorB,
        "color_c": colorC,
        "color_d": colorD,
        "color_e": colorE,
        "color_f": colorF,
        "color_g": colorG,
        "color_h": colorH,
        "color_i": colorI,
        "color_j": colorJ,
      };
}
