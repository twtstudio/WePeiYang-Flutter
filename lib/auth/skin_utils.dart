// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

class Skin {
  Skin({
    this.id,
    this.name,
    this.description,
    this.selfPageImage,
    this.mainPageImage,
    this.colorA,
    this.colorB,
    this.colorC,
    this.colorD,
    this.colorE,
    this.colorF
  });

  int id;
  String name;
  String description;
  String selfPageImage;
  String mainPageImage;
  String colorA;
  String colorB;
  String colorC;
  String colorD;
  String colorE;
  String colorF;

  bool operator ==(Object other) => other is Skin && other.id == id;

  factory Skin.fromJson(Map<String, dynamic> json) => Skin(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    selfPageImage: json["self_page_image"],
    mainPageImage: json["main_page_image"],
    colorA: json["color_a"],
    colorB: json["color_b"],
    colorC: json["color_c"],
    colorD: json["color_d"],
    colorE: json["color_e"],
    colorF: json["color_f"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "self_page_image": selfPageImage,
    "main_page_image": mainPageImage,
    "color_a": colorA,
    "color_b": colorB,
    "color_c": colorC,
    "color_d": colorD,
    "color_e": colorE,
    "color_f": colorF,
  };
}
