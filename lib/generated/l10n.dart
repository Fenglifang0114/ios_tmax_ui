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

  /// `Connect`
  String get button_connect {
    return Intl.message(
      'Connect',
      name: 'button_connect',
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

  /// `Contact us: sales@taiwanscale.com`
  String get contact_us {
    return Intl.message(
      'Contact us: sales@taiwanscale.com',
      name: 'contact_us',
      desc: '',
      args: [],
    );
  }

  /// `Serial Port Connection`
  String get title_serial_port_connection {
    return Intl.message(
      'Serial Port Connection',
      name: 'title_serial_port_connection',
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

  /// `Not authenticed. Please send the ID to us.`
  String get passed_fail_message {
    return Intl.message(
      'Not authenticed. Please send the ID to us.',
      name: 'passed_fail_message',
      desc: '',
      args: [],
    );
  }

  /// `Email:sales@taiwanscale.com`
  String get text_email {
    return Intl.message(
      'Email:sales@taiwanscale.com',
      name: 'text_email',
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

  /// `Free Trial`
  String get button_trial {
    return Intl.message(
      'Free Trial',
      name: 'button_trial',
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

  /// `Confirm`
  String get button_ok {
    return Intl.message(
      'Confirm',
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

  /// `Wi-Fi configured successfully!`
  String get set_wifi_success {
    return Intl.message(
      'Wi-Fi configured successfully!',
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

  /// `Discover SSID`
  String get find_ssid {
    return Intl.message(
      'Discover SSID',
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

  /// `Gateway:`
  String get gateway {
    return Intl.message(
      'Gateway:',
      name: 'gateway',
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

  /// `Connect`
  String get button_set {
    return Intl.message(
      'Connect',
      name: 'button_set',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth Configurations`
  String get bluetooth_modification {
    return Intl.message(
      'Bluetooth Configurations',
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

  /// `Serial port has been disconnected. Please check the settings.`
  String get serial_error {
    return Intl.message(
      'Serial port has been disconnected. Please check the settings.',
      name: 'serial_error',
      desc: '',
      args: [],
    );
  }

  /// `Error: Cannot modify  bluetooth name .`
  String get bluetooth_modify_error {
    return Intl.message(
      'Error: Cannot modify  bluetooth name .',
      name: 'bluetooth_modify_error',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth name modified.`
  String get bluetooth_modify_ok {
    return Intl.message(
      'Bluetooth name modified.',
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

  /// `Save File (json)`
  String get save_file {
    return Intl.message(
      'Save File (json)',
      name: 'save_file',
      desc: '',
      args: [],
    );
  }

  /// `Open File (json)`
  String get open_file {
    return Intl.message(
      'Open File (json)',
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

  /// `Save as CSV`
  String get save_csv {
    return Intl.message(
      'Save as CSV',
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

  /// `Layer order:`
  String get tab_order {
    return Intl.message(
      'Layer order:',
      name: 'tab_order',
      desc: '',
      args: [],
    );
  }

  /// `No element selected.`
  String get no_element {
    return Intl.message(
      'No element selected.',
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

  /// `1. Please click on one or more elements on the left panel;`
  String get step1 {
    return Intl.message(
      '1. Please click on one or more elements on the left panel;',
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

  /// `Font Size:`
  String get select_fontsize {
    return Intl.message(
      'Font Size:',
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

  /// `Reverse Contrast:`
  String get font_reverse {
    return Intl.message(
      'Reverse Contrast:',
      name: 'font_reverse',
      desc: '',
      args: [],
    );
  }

  /// `HRI Alignment:`
  String get hr_alignment {
    return Intl.message(
      'HRI Alignment:',
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

  /// `Bold:`
  String get font_bold {
    return Intl.message(
      'Bold:',
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

  /// `Export`
  String get button_export_report {
    return Intl.message(
      'Export',
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

  /// `The value must be under 20 seconds.`
  String get stable_time_error_tip {
    return Intl.message(
      'The value must be under 20 seconds.',
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

  /// `PLU pretare cannot be empty .`
  String get plu_error_message {
    return Intl.message(
      'PLU pretare cannot be empty .',
      name: 'plu_error_message',
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

  /// `Gender:`
  String get user_sex {
    return Intl.message(
      'Gender:',
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

  /// `User Notes:`
  String get user_remarks {
    return Intl.message(
      'User Notes:',
      name: 'user_remarks',
      desc: '',
      args: [],
    );
  }

  /// `The User Id and Username cannot be empty!`
  String get user_error_message1 {
    return Intl.message(
      'The User Id and Username cannot be empty!',
      name: 'user_error_message1',
      desc: '',
      args: [],
    );
  }

  /// `User ID or Username cannot be the same!`
  String get user_error_message2 {
    return Intl.message(
      'User ID or Username cannot be the same!',
      name: 'user_error_message2',
      desc: '',
      args: [],
    );
  }

  /// `The User is not found!`
  String get user_error_message3 {
    return Intl.message(
      'The User is not found!',
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

  /// `Back`
  String get button_back {
    return Intl.message(
      'Back',
      name: 'button_back',
      desc: '',
      args: [],
    );
  }

  /// `Select Format`
  String get button_select_format {
    return Intl.message(
      'Select Format',
      name: 'button_select_format',
      desc: '',
      args: [],
    );
  }

  /// `Model Name`
  String get scale_model {
    return Intl.message(
      'Model Name',
      name: 'scale_model',
      desc: '',
      args: [],
    );
  }

  /// `Get IP Address`
  String get button_get_ip {
    return Intl.message(
      'Get IP Address',
      name: 'button_get_ip',
      desc: '',
      args: [],
    );
  }

  /// `Update Firmware`
  String get firmwart_update {
    return Intl.message(
      'Update Firmware',
      name: 'firmwart_update',
      desc: '',
      args: [],
    );
  }

  /// `Add License`
  String get button_add_license {
    return Intl.message(
      'Add License',
      name: 'button_add_license',
      desc: '',
      args: [],
    );
  }

  /// `New License:`
  String get new_license_text {
    return Intl.message(
      'New License:',
      name: 'new_license_text',
      desc: '',
      args: [],
    );
  }

  /// `Serial port connected`
  String get txt_serial_port_connected {
    return Intl.message(
      'Serial port connected',
      name: 'txt_serial_port_connected',
      desc: '',
      args: [],
    );
  }

  /// `Unable to connect`
  String get txt_serial_port_connected_fail {
    return Intl.message(
      'Unable to connect',
      name: 'txt_serial_port_connected_fail',
      desc: '',
      args: [],
    );
  }

  /// `Software Information`
  String get get_build_info {
    return Intl.message(
      'Software Information',
      name: 'get_build_info',
      desc: '',
      args: [],
    );
  }

  /// `OL mode`
  String get serial_page_ol {
    return Intl.message(
      'OL mode',
      name: 'serial_page_ol',
      desc: '',
      args: [],
    );
  }

  /// `UL mode`
  String get serial_page_ul {
    return Intl.message(
      'UL mode',
      name: 'serial_page_ul',
      desc: '',
      args: [],
    );
  }

  /// `Weight mode`
  String get serial_page_weight {
    return Intl.message(
      'Weight mode',
      name: 'serial_page_weight',
      desc: '',
      args: [],
    );
  }

  /// `Counting mode`
  String get serial_page_pcs {
    return Intl.message(
      'Counting mode',
      name: 'serial_page_pcs',
      desc: '',
      args: [],
    );
  }

  /// `Price Computing mode`
  String get serial_page_price {
    return Intl.message(
      'Price Computing mode',
      name: 'serial_page_price',
      desc: '',
      args: [],
    );
  }

  /// `Percent mode`
  String get serial_page_percent {
    return Intl.message(
      'Percent mode',
      name: 'serial_page_percent',
      desc: '',
      args: [],
    );
  }

  /// `Serial port status:`
  String get serial_port_status {
    return Intl.message(
      'Serial port status:',
      name: 'serial_port_status',
      desc: '',
      args: [],
    );
  }

  /// `Device Connection`
  String get device_connection_title {
    return Intl.message(
      'Device Connection',
      name: 'device_connection_title',
      desc: '',
      args: [],
    );
  }

  /// `Device Setting`
  String get device_setting_title {
    return Intl.message(
      'Device Setting',
      name: 'device_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth Setting`
  String get bt_setting_title {
    return Intl.message(
      'Bluetooth Setting',
      name: 'bt_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Wi-Fi Setting`
  String get wifi_setting_title {
    return Intl.message(
      'Wi-Fi Setting',
      name: 'wifi_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Customization Setting`
  String get customization_setting_title {
    return Intl.message(
      'Customization Setting',
      name: 'customization_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Label Design`
  String get label_design_title {
    return Intl.message(
      'Label Design',
      name: 'label_design_title',
      desc: '',
      args: [],
    );
  }

  /// `Print Format Download`
  String get print_format_download {
    return Intl.message(
      'Print Format Download',
      name: 'print_format_download',
      desc: '',
      args: [],
    );
  }

  /// `Serial Output`
  String get serial_output {
    return Intl.message(
      'Serial Output',
      name: 'serial_output',
      desc: '',
      args: [],
    );
  }

  /// `Update Firmware`
  String get update_firmware {
    return Intl.message(
      'Update Firmware',
      name: 'update_firmware',
      desc: '',
      args: [],
    );
  }

  /// `System Setting`
  String get system_setting_title {
    return Intl.message(
      'System Setting',
      name: 'system_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Set Language`
  String get set_language_title {
    return Intl.message(
      'Set Language',
      name: 'set_language_title',
      desc: '',
      args: [],
    );
  }

  /// `License Info`
  String get license_info_title {
    return Intl.message(
      'License Info',
      name: 'license_info_title',
      desc: '',
      args: [],
    );
  }

  /// `Open preview`
  String get open_preview {
    return Intl.message(
      'Open preview',
      name: 'open_preview',
      desc: '',
      args: [],
    );
  }

  /// `Close preview`
  String get close_preview {
    return Intl.message(
      'Close preview',
      name: 'close_preview',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear_btn {
    return Intl.message(
      'Clear',
      name: 'clear_btn',
      desc: '',
      args: [],
    );
  }

  /// `Serial port output preview`
  String get serial_port_output_preview {
    return Intl.message(
      'Serial port output preview',
      name: 'serial_port_output_preview',
      desc: '',
      args: [],
    );
  }

  /// `Weighing mode format:`
  String get weight_mode_format {
    return Intl.message(
      'Weighing mode format:',
      name: 'weight_mode_format',
      desc: '',
      args: [],
    );
  }

  /// `Accumulation mode format:`
  String get acc_mode_format {
    return Intl.message(
      'Accumulation mode format:',
      name: 'acc_mode_format',
      desc: '',
      args: [],
    );
  }

  /// `Counting mode format:`
  String get pcs_mode_format {
    return Intl.message(
      'Counting mode format:',
      name: 'pcs_mode_format',
      desc: '',
      args: [],
    );
  }

  /// `Percent mode format:`
  String get pct_mode_format {
    return Intl.message(
      'Percent mode format:',
      name: 'pct_mode_format',
      desc: '',
      args: [],
    );
  }

  /// `Scale Name:`
  String get scale_name {
    return Intl.message(
      'Scale Name:',
      name: 'scale_name',
      desc: '',
      args: [],
    );
  }

  /// `SN#:`
  String get scale_sn {
    return Intl.message(
      'SN#:',
      name: 'scale_sn',
      desc: '',
      args: [],
    );
  }

  /// `PLU Download`
  String get plu_download_title {
    return Intl.message(
      'PLU Download',
      name: 'plu_download_title',
      desc: '',
      args: [],
    );
  }

  /// `Weighing`
  String get weighing_title {
    return Intl.message(
      'Weighing',
      name: 'weighing_title',
      desc: '',
      args: [],
    );
  }

  /// `Weight Data Collection`
  String get weight_collection_title {
    return Intl.message(
      'Weight Data Collection',
      name: 'weight_collection_title',
      desc: '',
      args: [],
    );
  }

  /// `Check Weighing`
  String get checkweigher_title {
    return Intl.message(
      'Check Weighing',
      name: 'checkweigher_title',
      desc: '',
      args: [],
    );
  }

  /// `Increment Weighing`
  String get take_in_title {
    return Intl.message(
      'Increment Weighing',
      name: 'take_in_title',
      desc: '',
      args: [],
    );
  }

  /// `Take Out Scale`
  String get take_out_title {
    return Intl.message(
      'Take Out Scale',
      name: 'take_out_title',
      desc: '',
      args: [],
    );
  }

  /// `Get name`
  String get get_bt_name {
    return Intl.message(
      'Get name',
      name: 'get_bt_name',
      desc: '',
      args: [],
    );
  }

  /// `Modify name`
  String get modify_bt_name {
    return Intl.message(
      'Modify name',
      name: 'modify_bt_name',
      desc: '',
      args: [],
    );
  }

  /// `Emission Power:`
  String get bt_emission_power {
    return Intl.message(
      'Emission Power:',
      name: 'bt_emission_power',
      desc: '',
      args: [],
    );
  }

  /// `Modify emission power`
  String get bt_modify_emission {
    return Intl.message(
      'Modify emission power',
      name: 'bt_modify_emission',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm_btn {
    return Intl.message(
      'Confirm',
      name: 'confirm_btn',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation`
  String get confirm_title {
    return Intl.message(
      'Confirmation',
      name: 'confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm the order of the printing formats.`
  String get confirm_info {
    return Intl.message(
      'Please confirm the order of the printing formats.',
      name: 'confirm_info',
      desc: '',
      args: [],
    );
  }

  /// `Download is successful!`
  String get download_result_ok {
    return Intl.message(
      'Download is successful!',
      name: 'download_result_ok',
      desc: '',
      args: [],
    );
  }

  /// `Download failed!`
  String get download_result_fail {
    return Intl.message(
      'Download failed!',
      name: 'download_result_fail',
      desc: '',
      args: [],
    );
  }

  /// `Select Firmware`
  String get select_firmware_btn {
    return Intl.message(
      'Select Firmware',
      name: 'select_firmware_btn',
      desc: '',
      args: [],
    );
  }

  /// `The update process can not be canceled.\r\nPress confirm to continue.`
  String get update_firmware_info {
    return Intl.message(
      'The update process can not be canceled.\r\nPress confirm to continue.',
      name: 'update_firmware_info',
      desc: '',
      args: [],
    );
  }

  /// `Please wait...`
  String get update_firmware_wait {
    return Intl.message(
      'Please wait...',
      name: 'update_firmware_wait',
      desc: '',
      args: [],
    );
  }

  /// `Please reboot the device to begin update...`
  String get update_firmware_reboot {
    return Intl.message(
      'Please reboot the device to begin update...',
      name: 'update_firmware_reboot',
      desc: '',
      args: [],
    );
  }

  /// `Report Setting`
  String get report_set_btn {
    return Intl.message(
      'Report Setting',
      name: 'report_set_btn',
      desc: '',
      args: [],
    );
  }

  /// `Show Reports`
  String get report_show_btn {
    return Intl.message(
      'Show Reports',
      name: 'report_show_btn',
      desc: '',
      args: [],
    );
  }

  /// `Delete All`
  String get report_delete_btn {
    return Intl.message(
      'Delete All',
      name: 'report_delete_btn',
      desc: '',
      args: [],
    );
  }

  /// `Hide Report`
  String get report_hide_btn {
    return Intl.message(
      'Hide Report',
      name: 'report_hide_btn',
      desc: '',
      args: [],
    );
  }

  /// `Whether to delete all data?`
  String get data_delete_confirm {
    return Intl.message(
      'Whether to delete all data?',
      name: 'data_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Current weight:`
  String get show_current_weight {
    return Intl.message(
      'Current weight:',
      name: 'show_current_weight',
      desc: '',
      args: [],
    );
  }

  /// `Increment weight:`
  String get show_increment_weight {
    return Intl.message(
      'Increment weight:',
      name: 'show_increment_weight',
      desc: '',
      args: [],
    );
  }

  /// `Reduced weight:`
  String get show_reduced_weight {
    return Intl.message(
      'Reduced weight:',
      name: 'show_reduced_weight',
      desc: '',
      args: [],
    );
  }

  /// `General Configuration`
  String get general_configuration_title {
    return Intl.message(
      'General Configuration',
      name: 'general_configuration_title',
      desc: '',
      args: [],
    );
  }

  /// `Applications`
  String get application_title {
    return Intl.message(
      'Applications',
      name: 'application_title',
      desc: '',
      args: [],
    );
  }

  /// `Choose json`
  String get choose_json_file {
    return Intl.message(
      'Choose json',
      name: 'choose_json_file',
      desc: '',
      args: [],
    );
  }

  /// `Abnormal Data`
  String get abnormal_data_title {
    return Intl.message(
      'Abnormal Data',
      name: 'abnormal_data_title',
      desc: '',
      args: [],
    );
  }

  /// `Device Time`
  String get device_time_title {
    return Intl.message(
      'Device Time',
      name: 'device_time_title',
      desc: '',
      args: [],
    );
  }

  /// `Batch Delivery`
  String get batch_delivery_title {
    return Intl.message(
      'Batch Delivery',
      name: 'batch_delivery_title',
      desc: '',
      args: [],
    );
  }

  /// `Parameter Setting`
  String get parameter_set_title {
    return Intl.message(
      'Parameter Setting',
      name: 'parameter_set_title',
      desc: '',
      args: [],
    );
  }

  /// `Save as`
  String get save_as {
    return Intl.message(
      'Save as',
      name: 'save_as',
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
      Locale.fromSubtags(languageCode: 'ru'),
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
