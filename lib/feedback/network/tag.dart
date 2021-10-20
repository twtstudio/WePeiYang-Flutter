import 'package:flutter/material.dart';

class Tag with ChangeNotifier {
  int id;
  String name;
  String description;

  Tag({
    this.id,
    this.name,
    this.description,
  });

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['tag_description'] = this.description;
    return data;
  }
}
