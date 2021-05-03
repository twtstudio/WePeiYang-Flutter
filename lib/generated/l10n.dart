// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `wei jin lu`
  String get WJL {
    return Intl.message(
      'wei jin lu',
      name: 'WJL',
      desc: '',
      args: [],
    );
  }

  /// `bei yang yuan`
  String get BYY {
    return Intl.message(
      'bei yang yuan',
      name: 'BYY',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get autoBySystem {
    return Intl.message(
      'Auto',
      name: 'autoBySystem',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get language {
    return Intl.message(
      'English',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get ok {
    return Intl.message(
      '',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get pleaseWaiting {
    return Intl.message(
      '',
      name: 'pleaseWaiting',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get teachingBuilding {
    return Intl.message(
      '',
      name: 'teachingBuilding',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get area {
    return Intl.message(
      '',
      name: 'area',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get idle {
    return Intl.message(
      '',
      name: 'idle',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get occupy {
    return Intl.message(
      '',
      name: 'occupy',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get courseOccupy {
    return Intl.message(
      '',
      name: 'courseOccupy',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get cancelFavour {
    return Intl.message(
      '',
      name: 'cancelFavour',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get favour {
    return Intl.message(
      '',
      name: 'favour',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get myFavour {
    return Intl.message(
      '',
      name: 'myFavour',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get search {
    return Intl.message(
      '',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get cancel {
    return Intl.message(
      '',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get cannotFindRoom1 {
    return Intl.message(
      '',
      name: 'cannotFindRoom1',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get cannotFindRoom2 {
    return Intl.message(
      '',
      name: 'cannotFindRoom2',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get searchHistory {
    return Intl.message(
      '',
      name: 'searchHistory',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get notHaveLoungeFavour {
    return Intl.message(
      '',
      name: 'notHaveLoungeFavour',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get like {
    return Intl.message(
      '',
      name: 'like',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get comment {
    return Intl.message(
      '',
      name: 'comment',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get reply {
    return Intl.message(
      '',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get like_a_question {
    return Intl.message(
      '',
      name: 'like_a_question',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get comment_a_question {
    return Intl.message(
      '',
      name: 'comment_a_question',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get reply_a_question {
    return Intl.message(
      '',
      name: 'reply_a_question',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get feedback_message {
    return Intl.message(
      '',
      name: 'feedback_message',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get anonymous_user {
    return Intl.message(
      '',
      name: 'anonymous_user',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get unknown_department {
    return Intl.message(
      '',
      name: 'unknown_department',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get have_replied {
    return Intl.message(
      '',
      name: 'have_replied',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get not_reply {
    return Intl.message(
      '',
      name: 'not_reply',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get up_load {
    return Intl.message(
      '',
      name: 'up_load',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get load_fail {
    return Intl.message(
      '',
      name: 'load_fail',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get load_more {
    return Intl.message(
      '',
      name: 'load_more',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get no_more_data {
    return Intl.message(
      '',
      name: 'no_more_data',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get have_read {
    return Intl.message(
      '',
      name: 'have_read',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get not_read {
    return Intl.message(
      '',
      name: 'not_read',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}