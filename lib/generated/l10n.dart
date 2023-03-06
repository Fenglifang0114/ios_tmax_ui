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
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Automatic weight tool V1.0.2`
  String get title {
    return Intl.message(
      'Automatic weight tool V1.0.2',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Chinese`
  String get zh_cn {
    return Intl.message(
      'Chinese',
      name: 'zh_cn',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get en {
    return Intl.message(
      'English',
      name: 'en',
      desc: '',
      args: [],
    );
  }

  /// `Scale: `
  String get scale_information {
    return Intl.message(
      'Scale: ',
      name: 'scale_information',
      desc: '',
      args: [],
    );
  }

  /// `Operation Tips:`
  String get operation_tips {
    return Intl.message(
      'Operation Tips:',
      name: 'operation_tips',
      desc: '',
      args: [],
    );
  }

  /// `Model: `
  String get model {
    return Intl.message(
      'Model: ',
      name: 'model',
      desc: '',
      args: [],
    );
  }

  /// `SN: `
  String get sn {
    return Intl.message(
      'SN: ',
      name: 'sn',
      desc: '',
      args: [],
    );
  }

  /// `clean`
  String get clean {
    return Intl.message(
      'clean',
      name: 'clean',
      desc: '',
      args: [],
    );
  }

  /// `start`
  String get start {
    return Intl.message(
      'start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `cancel`
  String get cancel {
    return Intl.message(
      'cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get sure {
    return Intl.message(
      'OK',
      name: 'sure',
      desc: '',
      args: [],
    );
  }

  /// `confirm cancellation? `
  String get cancel_confirm {
    return Intl.message(
      'confirm cancellation? ',
      name: 'cancel_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Please load the scale after the platform has moved, then enter the serial number!`
  String get loading_msg {
    return Intl.message(
      'Please load the scale after the platform has moved, then enter the serial number!',
      name: 'loading_msg',
      desc: '',
      args: [],
    );
  }

  /// `WeightMachine: `
  String get wt {
    return Intl.message(
      'WeightMachine: ',
      name: 'wt',
      desc: '',
      args: [],
    );
  }

  /// `xSpeed: `
  String get x_speed {
    return Intl.message(
      'xSpeed: ',
      name: 'x_speed',
      desc: '',
      args: [],
    );
  }

  /// `ySpeed: `
  String get y_speed {
    return Intl.message(
      'ySpeed: ',
      name: 'y_speed',
      desc: '',
      args: [],
    );
  }

  /// `zSpeed: `
  String get z_speed {
    return Intl.message(
      'zSpeed: ',
      name: 'z_speed',
      desc: '',
      args: [],
    );
  }

  /// `warn: `
  String get warn {
    return Intl.message(
      'warn: ',
      name: 'warn',
      desc: '',
      args: [],
    );
  }

  /// `xFailure`
  String get isxfail {
    return Intl.message(
      'xFailure',
      name: 'isxfail',
      desc: '',
      args: [],
    );
  }

  /// `yFailure`
  String get isyfail {
    return Intl.message(
      'yFailure',
      name: 'isyfail',
      desc: '',
      args: [],
    );
  }

  /// `zFailure`
  String get iszfail {
    return Intl.message(
      'zFailure',
      name: 'iszfail',
      desc: '',
      args: [],
    );
  }

  /// `xRightLimit`
  String get isxrightlimit {
    return Intl.message(
      'xRightLimit',
      name: 'isxrightlimit',
      desc: '',
      args: [],
    );
  }

  /// `xLeftLimit`
  String get isxleftlimit {
    return Intl.message(
      'xLeftLimit',
      name: 'isxleftlimit',
      desc: '',
      args: [],
    );
  }

  /// `yFrontLimit`
  String get isyfrontlimit {
    return Intl.message(
      'yFrontLimit',
      name: 'isyfrontlimit',
      desc: '',
      args: [],
    );
  }

  /// `yBackLimit`
  String get isybacklimit {
    return Intl.message(
      'yBackLimit',
      name: 'isybacklimit',
      desc: '',
      args: [],
    );
  }

  /// `zUpLimit`
  String get iszuplimit {
    return Intl.message(
      'zUpLimit',
      name: 'iszuplimit',
      desc: '',
      args: [],
    );
  }

  /// `zDownLimit`
  String get iszdownlimit {
    return Intl.message(
      'zDownLimit',
      name: 'iszdownlimit',
      desc: '',
      args: [],
    );
  }

  /// `safetyLight`
  String get issafegate {
    return Intl.message(
      'safetyLight',
      name: 'issafegate',
      desc: '',
      args: [],
    );
  }

  /// `Perform Tasks: `
  String get perform_tasks {
    return Intl.message(
      'Perform Tasks: ',
      name: 'perform_tasks',
      desc: '',
      args: [],
    );
  }

  /// `Result: `
  String get result {
    return Intl.message(
      'Result: ',
      name: 'result',
      desc: '',
      args: [],
    );
  }

  /// `Tare: `
  String get tare {
    return Intl.message(
      'Tare: ',
      name: 'tare',
      desc: '',
      args: [],
    );
  }

  /// `Net: `
  String get net {
    return Intl.message(
      'Net: ',
      name: 'net',
      desc: '',
      args: [],
    );
  }

  /// `Innercode: `
  String get innercode {
    return Intl.message(
      'Innercode: ',
      name: 'innercode',
      desc: '',
      args: [],
    );
  }

  /// `Tare`
  String get tare_s {
    return Intl.message(
      'Tare',
      name: 'tare_s',
      desc: '',
      args: [],
    );
  }

  /// `Stable`
  String get stable {
    return Intl.message(
      'Stable',
      name: 'stable',
      desc: '',
      args: [],
    );
  }

  /// `Coordinate: `
  String get coordinate {
    return Intl.message(
      'Coordinate: ',
      name: 'coordinate',
      desc: '',
      args: [],
    );
  }

  /// ` X : `
  String get x_coordinate {
    return Intl.message(
      ' X : ',
      name: 'x_coordinate',
      desc: '',
      args: [],
    );
  }

  /// ` Y : `
  String get y_coordinate {
    return Intl.message(
      ' Y : ',
      name: 'y_coordinate',
      desc: '',
      args: [],
    );
  }

  /// ` Z : `
  String get z_coordinate {
    return Intl.message(
      ' Z : ',
      name: 'z_coordinate',
      desc: '',
      args: [],
    );
  }

  /// `isMoving: `
  String get ismoving {
    return Intl.message(
      'isMoving: ',
      name: 'ismoving',
      desc: '',
      args: [],
    );
  }

  /// `scaleZZero: `
  String get z_zero_coordinate {
    return Intl.message(
      'scaleZZero: ',
      name: 'z_zero_coordinate',
      desc: '',
      args: [],
    );
  }

  /// `weights: `
  String get weights_number {
    return Intl.message(
      'weights: ',
      name: 'weights_number',
      desc: '',
      args: [],
    );
  }

  /// `scale:`
  String get scale {
    return Intl.message(
      'scale:',
      name: 'scale',
      desc: '',
      args: [],
    );
  }

  /// `init`
  String get init {
    return Intl.message(
      'init',
      name: 'init',
      desc: '',
      args: [],
    );
  }

  /// `details`
  String get detailed_communication {
    return Intl.message(
      'details',
      name: 'detailed_communication',
      desc: '',
      args: [],
    );
  }

  /// `Communication`
  String get communication {
    return Intl.message(
      'Communication',
      name: 'communication',
      desc: '',
      args: [],
    );
  }

  /// `WeightMachineCommunication`
  String get wt_detailed_communication {
    return Intl.message(
      'WeightMachineCommunication',
      name: 'wt_detailed_communication',
      desc: '',
      args: [],
    );
  }

  /// `Error Message:`
  String get error {
    return Intl.message(
      'Error Message:',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Weight machine error`
  String get errcode0 {
    return Intl.message(
      'Weight machine error',
      name: 'errcode0',
      desc: '',
      args: [],
    );
  }

  /// `Can't read scale information`
  String get errcode1 {
    return Intl.message(
      'Can\'t read scale information',
      name: 'errcode1',
      desc: '',
      args: [],
    );
  }

  /// `Scale reply timed out`
  String get errcode2 {
    return Intl.message(
      'Scale reply timed out',
      name: 'errcode2',
      desc: '',
      args: [],
    );
  }

  /// `Scale replies wrong information`
  String get errcode3 {
    return Intl.message(
      'Scale replies wrong information',
      name: 'errcode3',
      desc: '',
      args: [],
    );
  }

  /// `Missing configuration file`
  String get errcode4 {
    return Intl.message(
      'Missing configuration file',
      name: 'errcode4',
      desc: '',
      args: [],
    );
  }

  /// `MyDevice`
  String get mydevice {
    return Intl.message(
      'MyDevice',
      name: 'mydevice',
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
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
