import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences _prefs;

mixin SharedPref{
  Future<T> read<T>(String key) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    return json.decode(_prefs.getString(key));
  }

  Future<void> save(String key, value) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    _prefs.setString(key, json.encode(value.toString()));
  }

  Future<void> remove(String key) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    _prefs.remove(key);
  }

  Future<void> clear() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    _prefs.clear();
  }
}

var token = "";

var isLogin = false;

num startUnix = 946656000;

var studentid = "";

var isBindTju = false;

var isBindLibrary = false;

var isBindBike = false;

var isAcceptTos = false;

var dropOut = 0;

var twtuname = "";

var password = "";

var realName = "";

var proxyAddress = "";

var proxyPort = 0;

var customThemeIndex = 0;

var tjuuname = "";
var tjupwd = "";
var tjuloginbind = false;
// class SharedPref {
//   SharedPref._();
//
//   static SharedPref _instance;
//
//   SharedPreferences _prefs;
//
//   Future<SharedPref> create() async {
//     if (_instance == null) _instance = SharedPref._();
//     if (_prefs == null) _prefs = await SharedPreferences.getInstance();
//     return _instance;
//   }
//
//   read(String key) => json.decode(_prefs.getString(key));
//
//   void save(String key,value) => _prefs.setString(key, json.decode(value));
//
//   void remove(String key) => _prefs.remove(key);
//
//   void clear() => _prefs.clear();
// }
