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

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Tare`
  String get button_tare {
    return Intl.message(
      'Tare',
      name: 'button_tare',
      desc: '',
      args: [],
    );
  }

  /// `Net`
  String get button_net {
    return Intl.message(
      'Net',
      name: 'button_net',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get button_save {
    return Intl.message(
      'Save',
      name: 'button_save',
      desc: '',
      args: [],
    );
  }

  /// `Serial port`
  String get com_port {
    return Intl.message(
      'Serial port',
      name: 'com_port',
      desc: '',
      args: [],
    );
  }

  /// `Contact us:sales@taiwanscale.com`
  String get contact_us {
    return Intl.message(
      'Contact us:sales@taiwanscale.com',
      name: 'contact_us',
      desc: '',
      args: [],
    );
  }

  /// `Serial port connection`
  String get home_page_title1 {
    return Intl.message(
      'Serial port connection',
      name: 'home_page_title1',
      desc: '',
      args: [],
    );
  }

  /// `Label Design`
  String get home_page_title2 {
    return Intl.message(
      'Label Design',
      name: 'home_page_title2',
      desc: '',
      args: [],
    );
  }

  /// `Wifi Setting`
  String get home_page_title3 {
    return Intl.message(
      'Wifi Setting',
      name: 'home_page_title3',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth Setting`
  String get home_page_title4 {
    return Intl.message(
      'Bluetooth Setting',
      name: 'home_page_title4',
      desc: '',
      args: [],
    );
  }

  /// `Update FW`
  String get home_page_title5 {
    return Intl.message(
      'Update FW',
      name: 'home_page_title5',
      desc: '',
      args: [],
    );
  }

  /// `Scale Records`
  String get home_page_title6 {
    return Intl.message(
      'Scale Records',
      name: 'home_page_title6',
      desc: '',
      args: [],
    );
  }

  /// `License Information`
  String get home_page_title7 {
    return Intl.message(
      'License Information',
      name: 'home_page_title7',
      desc: '',
      args: [],
    );
  }

  /// `Real-time Weight Data`
  String get home_page_title8 {
    return Intl.message(
      'Real-time Weight Data',
      name: 'home_page_title8',
      desc: '',
      args: [],
    );
  }

  /// `Language Setting`
  String get home_page_title9 {
    return Intl.message(
      'Language Setting',
      name: 'home_page_title9',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Authentication passed.\r\n`
  String get passed_message {
    return Intl.message(
      'Authentication passed.\r\n',
      name: 'passed_message',
      desc: '',
      args: [],
    );
  }

  /// `No authentication.\r\nPlease send the ID to us.\r\n\r\nEmail:sales@taiwanscale.com`
  String get passed_fail_message {
    return Intl.message(
      'No authentication.\r\nPlease send the ID to us.\r\n\r\nEmail:sales@taiwanscale.com',
      name: 'passed_fail_message',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get button_start {
    return Intl.message(
      'Start',
      name: 'button_start',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get button_exit {
    return Intl.message(
      'Exit',
      name: 'button_exit',
      desc: '',
      args: [],
    );
  }

  /// `System Unique ID:  `
  String get system_id {
    return Intl.message(
      'System Unique ID:  ',
      name: 'system_id',
      desc: '',
      args: [],
    );
  }

  /// `Expiration date:`
  String get expiration_date {
    return Intl.message(
      'Expiration date:',
      name: 'expiration_date',
      desc: '',
      args: [],
    );
  }

  /// `Serial port information modification`
  String get serial_modify_title {
    return Intl.message(
      'Serial port information modification',
      name: 'serial_modify_title',
      desc: '',
      args: [],
    );
  }

  /// `Serial port:`
  String get serial_port {
    return Intl.message(
      'Serial port:',
      name: 'serial_port',
      desc: '',
      args: [],
    );
  }

  /// `Refresh port`
  String get refresh_port {
    return Intl.message(
      'Refresh port',
      name: 'refresh_port',
      desc: '',
      args: [],
    );
  }

  /// `Data bits:`
  String get data_bits {
    return Intl.message(
      'Data bits:',
      name: 'data_bits',
      desc: '',
      args: [],
    );
  }

  /// `Baud rate:`
  String get baud_rate {
    return Intl.message(
      'Baud rate:',
      name: 'baud_rate',
      desc: '',
      args: [],
    );
  }

  /// `Parity:`
  String get Parity {
    return Intl.message(
      'Parity:',
      name: 'Parity',
      desc: '',
      args: [],
    );
  }

  /// `Stop bits:`
  String get stop_bits {
    return Intl.message(
      'Stop bits:',
      name: 'stop_bits',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get button_ok {
    return Intl.message(
      'OK',
      name: 'button_ok',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get button_cancel {
    return Intl.message(
      'Cancel',
      name: 'button_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Set wifi successful!`
  String get set_wifi_success {
    return Intl.message(
      'Set wifi successful!',
      name: 'set_wifi_success',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get button_home {
    return Intl.message(
      'Home',
      name: 'button_home',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh_tip {
    return Intl.message(
      'Refresh',
      name: 'refresh_tip',
      desc: '',
      args: [],
    );
  }

  /// `Find SSID`
  String get find_ssid {
    return Intl.message(
      'Find SSID',
      name: 'find_ssid',
      desc: '',
      args: [],
    );
  }

  /// `Wireless network settings`
  String get network_setting {
    return Intl.message(
      'Wireless network settings',
      name: 'network_setting',
      desc: '',
      args: [],
    );
  }

  /// `Password:`
  String get password {
    return Intl.message(
      'Password:',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `IPv4:`
  String get ip_address {
    return Intl.message(
      'IPv4:',
      name: 'ip_address',
      desc: '',
      args: [],
    );
  }

  /// `NetMask:`
  String get netmask {
    return Intl.message(
      'NetMask:',
      name: 'netmask',
      desc: '',
      args: [],
    );
  }

  /// `Gatway:`
  String get gatway {
    return Intl.message(
      'Gatway:',
      name: 'gatway',
      desc: '',
      args: [],
    );
  }

  /// `Static`
  String get button_static {
    return Intl.message(
      'Static',
      name: 'button_static',
      desc: '',
      args: [],
    );
  }

  /// `Dynamic`
  String get button_dynamic {
    return Intl.message(
      'Dynamic',
      name: 'button_dynamic',
      desc: '',
      args: [],
    );
  }

  /// `Set`
  String get button_set {
    return Intl.message(
      'Set',
      name: 'button_set',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth information modification`
  String get bluetooth_modification {
    return Intl.message(
      'Bluetooth information modification',
      name: 'bluetooth_modification',
      desc: '',
      args: [],
    );
  }

  /// `Device name:`
  String get device_name {
    return Intl.message(
      'Device name:',
      name: 'device_name',
      desc: '',
      args: [],
    );
  }

  /// `Serial port connection lost. Check the settings.`
  String get serial_error {
    return Intl.message(
      'Serial port connection lost. Check the settings.',
      name: 'serial_error',
      desc: '',
      args: [],
    );
  }

  /// `Modify bluetooth name error.`
  String get bluetooth_modify_error {
    return Intl.message(
      'Modify bluetooth name error.',
      name: 'bluetooth_modify_error',
      desc: '',
      args: [],
    );
  }

  /// `Modify bluetooth name successful.`
  String get bluetooth_modify_ok {
    return Intl.message(
      'Modify bluetooth name successful.',
      name: 'bluetooth_modify_ok',
      desc: '',
      args: [],
    );
  }

  /// `License information`
  String get license_title {
    return Intl.message(
      'License information',
      name: 'license_title',
      desc: '',
      args: [],
    );
  }

  /// `Printer:`
  String get printer {
    return Intl.message(
      'Printer:',
      name: 'printer',
      desc: '',
      args: [],
    );
  }

  /// `Direction:`
  String get print_direction {
    return Intl.message(
      'Direction:',
      name: 'print_direction',
      desc: '',
      args: [],
    );
  }

  /// `Page:`
  String get print_page {
    return Intl.message(
      'Page:',
      name: 'print_page',
      desc: '',
      args: [],
    );
  }

  /// `Save File`
  String get save_file {
    return Intl.message(
      'Save File',
      name: 'save_file',
      desc: '',
      args: [],
    );
  }

  /// `Open File`
  String get open_file {
    return Intl.message(
      'Open File',
      name: 'open_file',
      desc: '',
      args: [],
    );
  }

  /// `BarCode Edit`
  String get barcode_edit {
    return Intl.message(
      'BarCode Edit',
      name: 'barcode_edit',
      desc: '',
      args: [],
    );
  }

  /// `Qrcode Edit`
  String get qrcode_edit {
    return Intl.message(
      'Qrcode Edit',
      name: 'qrcode_edit',
      desc: '',
      args: [],
    );
  }

  /// `New Format`
  String get new_format {
    return Intl.message(
      'New Format',
      name: 'new_format',
      desc: '',
      args: [],
    );
  }

  /// `Save csv`
  String get save_csv {
    return Intl.message(
      'Save csv',
      name: 'save_csv',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Attribute`
  String get attribute {
    return Intl.message(
      'Attribute',
      name: 'attribute',
      desc: '',
      args: [],
    );
  }

  /// `Tab order:`
  String get tab_order {
    return Intl.message(
      'Tab order:',
      name: 'tab_order',
      desc: '',
      args: [],
    );
  }

  /// `You haven't selected any element.`
  String get no_element {
    return Intl.message(
      'You haven\'t selected any element.',
      name: 'no_element',
      desc: '',
      args: [],
    );
  }

  /// `Operation Steps:`
  String get operation_steps {
    return Intl.message(
      'Operation Steps:',
      name: 'operation_steps',
      desc: '',
      args: [],
    );
  }

  /// `1. Please click on one or more elements on the left side;`
  String get step1 {
    return Intl.message(
      '1. Please click on one or more elements on the left side;',
      name: 'step1',
      desc: '',
      args: [],
    );
  }

  /// `2. The selected elements will be displayed in the center of the page, and you can edit their attributes here. `
  String get step2 {
    return Intl.message(
      '2. The selected elements will be displayed in the center of the page, and you can edit their attributes here. ',
      name: 'step2',
      desc: '',
      args: [],
    );
  }

  /// `Editor`
  String get editor {
    return Intl.message(
      'Editor',
      name: 'editor',
      desc: '',
      args: [],
    );
  }

  /// `Text Content:`
  String get text_content {
    return Intl.message(
      'Text Content:',
      name: 'text_content',
      desc: '',
      args: [],
    );
  }

  /// `FontSize:`
  String get select_fontsize {
    return Intl.message(
      'FontSize:',
      name: 'select_fontsize',
      desc: '',
      args: [],
    );
  }

  /// `Rotation:`
  String get select_rotation {
    return Intl.message(
      'Rotation:',
      name: 'select_rotation',
      desc: '',
      args: [],
    );
  }

  /// `Font Reverse:`
  String get font_reverse {
    return Intl.message(
      'Font Reverse:',
      name: 'font_reverse',
      desc: '',
      args: [],
    );
  }

  /// `HR Alignment:`
  String get hr_alignment {
    return Intl.message(
      'HR Alignment:',
      name: 'hr_alignment',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get button_delete {
    return Intl.message(
      'Delete',
      name: 'button_delete',
      desc: '',
      args: [],
    );
  }

  /// `QRcode:`
  String get select_qrcode {
    return Intl.message(
      'QRcode:',
      name: 'select_qrcode',
      desc: '',
      args: [],
    );
  }

  /// `Qrcode Width:`
  String get select_qrcode_width {
    return Intl.message(
      'Qrcode Width:',
      name: 'select_qrcode_width',
      desc: '',
      args: [],
    );
  }

  /// `Position`
  String get position {
    return Intl.message(
      'Position',
      name: 'position',
      desc: '',
      args: [],
    );
  }

  /// `Font Bold:`
  String get font_bold {
    return Intl.message(
      'Font Bold:',
      name: 'font_bold',
      desc: '',
      args: [],
    );
  }

  /// `Alignment:`
  String get alignment {
    return Intl.message(
      'Alignment:',
      name: 'alignment',
      desc: '',
      args: [],
    );
  }

  /// `Max Length:`
  String get max_length {
    return Intl.message(
      'Max Length:',
      name: 'max_length',
      desc: '',
      args: [],
    );
  }

  /// `Type:`
  String get element_type {
    return Intl.message(
      'Type:',
      name: 'element_type',
      desc: '',
      args: [],
    );
  }

  /// `BarCode:`
  String get select_barcode {
    return Intl.message(
      'BarCode:',
      name: 'select_barcode',
      desc: '',
      args: [],
    );
  }

  /// `BarCode Height:`
  String get barcode_height {
    return Intl.message(
      'BarCode Height:',
      name: 'barcode_height',
      desc: '',
      args: [],
    );
  }

  /// `Zero`
  String get button_zero {
    return Intl.message(
      'Zero',
      name: 'button_zero',
      desc: '',
      args: [],
    );
  }

  /// `Zero:`
  String get zero {
    return Intl.message(
      'Zero:',
      name: 'zero',
      desc: '',
      args: [],
    );
  }

  /// `Tare:`
  String get tare {
    return Intl.message(
      'Tare:',
      name: 'tare',
      desc: '',
      args: [],
    );
  }

  /// `Net:`
  String get net {
    return Intl.message(
      'Net:',
      name: 'net',
      desc: '',
      args: [],
    );
  }

  /// `Stable:`
  String get stable {
    return Intl.message(
      'Stable:',
      name: 'stable',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get button_setting {
    return Intl.message(
      'Setting',
      name: 'button_setting',
      desc: '',
      args: [],
    );
  }

  /// `Export report`
  String get button_export_report {
    return Intl.message(
      'Export report',
      name: 'button_export_report',
      desc: '',
      args: [],
    );
  }

  /// `PLU Name:`
  String get plu_name {
    return Intl.message(
      'PLU Name:',
      name: 'plu_name',
      desc: '',
      args: [],
    );
  }

  /// `PLU Edit`
  String get plu_edit {
    return Intl.message(
      'PLU Edit',
      name: 'plu_edit',
      desc: '',
      args: [],
    );
  }

  /// `User Name:`
  String get user_name {
    return Intl.message(
      'User Name:',
      name: 'user_name',
      desc: '',
      args: [],
    );
  }

  /// `User Edit`
  String get user_edit {
    return Intl.message(
      'User Edit',
      name: 'user_edit',
      desc: '',
      args: [],
    );
  }

  /// `Parameter settings`
  String get parameter_settings_title {
    return Intl.message(
      'Parameter settings',
      name: 'parameter_settings_title',
      desc: '',
      args: [],
    );
  }

  /// `Save Mode:`
  String get save_mode {
    return Intl.message(
      'Save Mode:',
      name: 'save_mode',
      desc: '',
      args: [],
    );
  }

  /// `Manual`
  String get manual {
    return Intl.message(
      'Manual',
      name: 'manual',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `Stable Time`
  String get stable_time {
    return Intl.message(
      'Stable Time',
      name: 'stable_time',
      desc: '',
      args: [],
    );
  }

  /// `The stable time cannot exceed 20 seconds.`
  String get stable_time_error_tip {
    return Intl.message(
      'The stable time cannot exceed 20 seconds.',
      name: 'stable_time_error_tip',
      desc: '',
      args: [],
    );
  }

  /// `Date Format:`
  String get date_format {
    return Intl.message(
      'Date Format:',
      name: 'date_format',
      desc: '',
      args: [],
    );
  }

  /// `Zero Range:`
  String get zero_range {
    return Intl.message(
      'Zero Range:',
      name: 'zero_range',
      desc: '',
      args: [],
    );
  }

  /// `Product Information`
  String get product_information {
    return Intl.message(
      'Product Information',
      name: 'product_information',
      desc: '',
      args: [],
    );
  }

  /// `Pretare:`
  String get pretare {
    return Intl.message(
      'Pretare:',
      name: 'pretare',
      desc: '',
      args: [],
    );
  }

  /// `PLu Remarks:`
  String get plu_remarks {
    return Intl.message(
      'PLu Remarks:',
      name: 'plu_remarks',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get button_add {
    return Intl.message(
      'Add',
      name: 'button_add',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get button_edit {
    return Intl.message(
      'Edit',
      name: 'button_edit',
      desc: '',
      args: [],
    );
  }

  /// `PLU ID or PLU name cannot be empty.`
  String get plu_error_message1 {
    return Intl.message(
      'PLU ID or PLU name cannot be empty.',
      name: 'plu_error_message1',
      desc: '',
      args: [],
    );
  }

  /// `PLU ID or PLU name already exists.`
  String get plu_error_message2 {
    return Intl.message(
      'PLU ID or PLU name already exists.',
      name: 'plu_error_message2',
      desc: '',
      args: [],
    );
  }

  /// `User Info`
  String get user_info {
    return Intl.message(
      'User Info',
      name: 'user_info',
      desc: '',
      args: [],
    );
  }

  /// `User ID:`
  String get user_id {
    return Intl.message(
      'User ID:',
      name: 'user_id',
      desc: '',
      args: [],
    );
  }

  /// `Sex:`
  String get user_sex {
    return Intl.message(
      'Sex:',
      name: 'user_sex',
      desc: '',
      args: [],
    );
  }

  /// `Phone:`
  String get user_phone {
    return Intl.message(
      'Phone:',
      name: 'user_phone',
      desc: '',
      args: [],
    );
  }

  /// `User Remarks:`
  String get user_remarks {
    return Intl.message(
      'User Remarks:',
      name: 'user_remarks',
      desc: '',
      args: [],
    );
  }

  /// `The user id and user name can not be null !`
  String get user_error_message1 {
    return Intl.message(
      'The user id and user name can not be null !',
      name: 'user_error_message1',
      desc: '',
      args: [],
    );
  }

  /// `User ID or user name can not be repeated !`
  String get user_error_message2 {
    return Intl.message(
      'User ID or user name can not be repeated !',
      name: 'user_error_message2',
      desc: '',
      args: [],
    );
  }

  /// `The user record was not found !`
  String get user_error_message3 {
    return Intl.message(
      'The user record was not found !',
      name: 'user_error_message3',
      desc: '',
      args: [],
    );
  }

  /// `Language Setting`
  String get language_setting_title {
    return Intl.message(
      'Language Setting',
      name: 'language_setting_title',
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
