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

  /// `EngLish`
  String get gLanguage {
    return Intl.message(
      'EngLish',
      name: 'gLanguage',
      desc: 'This is a prompt for the current language.',
      args: [],
    );
  }

  /// `Model Name:`
  String get gModelName {
    return Intl.message(
      'Model Name:',
      name: 'gModelName',
      desc: 'This is a prompt for model name.',
      args: [],
    );
  }

  /// `SN#:`
  String get gScaleSn {
    return Intl.message(
      'SN#:',
      name: 'gScaleSn',
      desc: 'This is a prompt for sn.',
      args: [],
    );
  }

  /// `Connect`
  String get gBtnConnect {
    return Intl.message(
      'Connect',
      name: 'gBtnConnect',
      desc: 'This is a button for testing the connection with the device.',
      args: [],
    );
  }

  /// `Tare`
  String get gBtnTare {
    return Intl.message(
      'Tare',
      name: 'gBtnTare',
      desc: 'This is a button for tare weight.',
      args: [],
    );
  }

  /// `Save`
  String get gBtnSave {
    return Intl.message(
      'Save',
      name: 'gBtnSave',
      desc: 'This is a button for saving.',
      args: [],
    );
  }

  /// `Serial Port Connection`
  String get gTitleSerialPortConnection {
    return Intl.message(
      'Serial Port Connection',
      name: 'gTitleSerialPortConnection',
      desc: 'This is the title of the serial port connection.',
      args: [],
    );
  }

  /// `Authentication passed.\r\n`
  String get gMsgAuthorityPassed {
    return Intl.message(
      'Authentication passed.\r\n',
      name: 'gMsgAuthorityPassed',
      desc:
          'This is the prompt indicating that the authentication has been passed.',
      args: [],
    );
  }

  /// `Not authenticed. Please send the ID to us.`
  String get gMsgAuthorityFail {
    return Intl.message(
      'Not authenticed. Please send the ID to us.',
      name: 'gMsgAuthorityFail',
      desc: 'This is the prompt indicating that the authentication has failed.',
      args: [],
    );
  }

  /// `Start`
  String get gBtnStart {
    return Intl.message(
      'Start',
      name: 'gBtnStart',
      desc: 'This is a button to start.',
      args: [],
    );
  }

  /// `Exit`
  String get gBtnExit {
    return Intl.message(
      'Exit',
      name: 'gBtnExit',
      desc: 'This is a button to exit.',
      args: [],
    );
  }

  /// `System Unique ID:  `
  String get gSystemId {
    return Intl.message(
      'System Unique ID:  ',
      name: 'gSystemId',
      desc: 'This is the prompt for the system authentication ID.',
      args: [],
    );
  }

  /// `Expiration date:`
  String get gExpirationDate {
    return Intl.message(
      'Expiration date:',
      name: 'gExpirationDate',
      desc: 'This is the prompt for the expiration date.',
      args: [],
    );
  }

  /// `Serial port information modification`
  String get gTitleSerialModify {
    return Intl.message(
      'Serial port information modification',
      name: 'gTitleSerialModify',
      desc: 'This is the title for modifying serial port information.',
      args: [],
    );
  }

  /// `Serial Port Status:`
  String get gSerialPortStatus {
    return Intl.message(
      'Serial Port Status:',
      name: 'gSerialPortStatus',
      desc: 'This is the title for serial port status.',
      args: [],
    );
  }

  /// `Serial port:`
  String get gSerialPort {
    return Intl.message(
      'Serial port:',
      name: 'gSerialPort',
      desc: 'This is the prompt for serial port.',
      args: [],
    );
  }

  /// `Refresh port`
  String get gRefreshPort {
    return Intl.message(
      'Refresh port',
      name: 'gRefreshPort',
      desc: 'This is the prompt to refresh port.',
      args: [],
    );
  }

  /// `Data bits:`
  String get gDataBits {
    return Intl.message(
      'Data bits:',
      name: 'gDataBits',
      desc: 'This is the prompt for data bits.',
      args: [],
    );
  }

  /// `Baud rate:`
  String get gBaudRate {
    return Intl.message(
      'Baud rate:',
      name: 'gBaudRate',
      desc: 'This is the prompt for baud rate.',
      args: [],
    );
  }

  /// `Parity:`
  String get gSerialParity {
    return Intl.message(
      'Parity:',
      name: 'gSerialParity',
      desc: 'This is the prompt for parity.',
      args: [],
    );
  }

  /// `Stop bits:`
  String get gStopBits {
    return Intl.message(
      'Stop bits:',
      name: 'gStopBits',
      desc: 'This is the prompt for stop bits.',
      args: [],
    );
  }

  /// `Confirm`
  String get gBtnConfirm {
    return Intl.message(
      'Confirm',
      name: 'gBtnConfirm',
      desc: 'This is a confirmation button.',
      args: [],
    );
  }

  /// `Cancel`
  String get gBtnCancel {
    return Intl.message(
      'Cancel',
      name: 'gBtnCancel',
      desc: 'This is a button to cancel',
      args: [],
    );
  }

  /// `Refresh`
  String get gMsgRefresh {
    return Intl.message(
      'Refresh',
      name: 'gMsgRefresh',
      desc: 'This is a button to refresh.',
      args: [],
    );
  }

  /// `Discover SSID`
  String get gFindSsid {
    return Intl.message(
      'Discover SSID',
      name: 'gFindSsid',
      desc: 'This is a prompt for discover ssid.',
      args: [],
    );
  }

  /// `Wireless network settings`
  String get gNetworkSetting {
    return Intl.message(
      'Wireless network settings',
      name: 'gNetworkSetting',
      desc: '',
      args: [],
    );
  }

  /// `Password:`
  String get gPassword {
    return Intl.message(
      'Password:',
      name: 'gPassword',
      desc: 'This is a prompt for password.',
      args: [],
    );
  }

  /// `IPv4:`
  String get gIpAddress {
    return Intl.message(
      'IPv4:',
      name: 'gIpAddress',
      desc: 'This is a prompt for IPv4.',
      args: [],
    );
  }

  /// `NetMask:`
  String get gNetmask {
    return Intl.message(
      'NetMask:',
      name: 'gNetmask',
      desc: 'This is a prompt for NetMask.',
      args: [],
    );
  }

  /// `Gateway:`
  String get gGateway {
    return Intl.message(
      'Gateway:',
      name: 'gGateway',
      desc: 'This is a prompt for Gateway.',
      args: [],
    );
  }

  /// `Static`
  String get gBtnStatic {
    return Intl.message(
      'Static',
      name: 'gBtnStatic',
      desc: 'This is a prompt for static IP.',
      args: [],
    );
  }

  /// `Dynamic`
  String get gBtnDynamic {
    return Intl.message(
      'Dynamic',
      name: 'gBtnDynamic',
      desc: 'This is a prompt for dynamic IP.',
      args: [],
    );
  }

  /// `Enter IP information and click the connect button!`
  String get gTipConnectStaticIp {
    return Intl.message(
      'Enter IP information and click the connect button!',
      name: 'gTipConnectStaticIp',
      desc: 'This is a prompt for connnecting static ip.',
      args: [],
    );
  }

  /// `Connecting...`
  String get gTipConnecting {
    return Intl.message(
      'Connecting...',
      name: 'gTipConnecting',
      desc: 'This is a prompt for connnecting.',
      args: [],
    );
  }

  /// `You are already connected!`
  String get gTipConnected {
    return Intl.message(
      'You are already connected!',
      name: 'gTipConnected',
      desc: 'This is a prompt for already connected .',
      args: [],
    );
  }

  /// `Connected AP Info:`
  String get gTipConnectedInfo {
    return Intl.message(
      'Connected AP Info:',
      name: 'gTipConnectedInfo',
      desc: 'This is a prompt for connected info .',
      args: [],
    );
  }

  /// `Obtaining AP list and Ip info,please wait...`
  String get gTipGetApListAndIP {
    return Intl.message(
      'Obtaining AP list and Ip info,please wait...',
      name: 'gTipGetApListAndIP',
      desc: 'This is a prompt for obtaining AP list and Ip info.',
      args: [],
    );
  }

  /// `Obtaining IP, please wait...`
  String get gTipGetIP {
    return Intl.message(
      'Obtaining IP, please wait...',
      name: 'gTipGetIP',
      desc: 'This is a prompt for obtaining Ip info.',
      args: [],
    );
  }

  /// `Get Ip OK !`
  String get gTipGetIpOk {
    return Intl.message(
      'Get Ip OK !',
      name: 'gTipGetIpOk',
      desc:
          'This is a prompt indicating that the IP information has been successfully obtained.',
      args: [],
    );
  }

  /// `Get Ip Fail !`
  String get gTipGetIpFail {
    return Intl.message(
      'Get Ip Fail !',
      name: 'gTipGetIpFail',
      desc:
          'This is a prompt indicating that the attempt to obtain IP information has failed.',
      args: [],
    );
  }

  /// `SSID:`
  String get gTipSSID {
    return Intl.message(
      'SSID:',
      name: 'gTipSSID',
      desc: 'This is a prompt for SSID.',
      args: [],
    );
  }

  /// `Bluetooth Configurations`
  String get gTitleBtSetting {
    return Intl.message(
      'Bluetooth Configurations',
      name: 'gTitleBtSetting',
      desc: 'This is a title for bluetooth configurations.',
      args: [],
    );
  }

  /// `Device name can not be empty,error.`
  String get gTipDeviceNameEmpty {
    return Intl.message(
      'Device name can not be empty,error.',
      name: 'gTipDeviceNameEmpty',
      desc: 'This is a prompt for empty device name.',
      args: [],
    );
  }

  /// `Time out!`
  String get gTipTimeOut {
    return Intl.message(
      'Time out!',
      name: 'gTipTimeOut',
      desc: 'This is a prompt for time out.',
      args: [],
    );
  }

  /// `Device name:`
  String get gDeviceName {
    return Intl.message(
      'Device name:',
      name: 'gDeviceName',
      desc: 'This is a prompt for device name.',
      args: [],
    );
  }

  /// `Serial port has been disconnected. Please check the settings.`
  String get gMsgSerialError {
    return Intl.message(
      'Serial port has been disconnected. Please check the settings.',
      name: 'gMsgSerialError',
      desc: 'This is a prompt for serial port has been disconnected.',
      args: [],
    );
  }

  /// `License information`
  String get gTitleLicense {
    return Intl.message(
      'License information',
      name: 'gTitleLicense',
      desc: 'This is a title for license information',
      args: [],
    );
  }

  /// `Printer Protocol:`
  String get gPrinter {
    return Intl.message(
      'Printer Protocol:',
      name: 'gPrinter',
      desc: 'This is a prompt for printer protocol.',
      args: [],
    );
  }

  /// `Direction:`
  String get gPrintDirection {
    return Intl.message(
      'Direction:',
      name: 'gPrintDirection',
      desc: 'This is a prompt regarding the printing direction.',
      args: [],
    );
  }

  /// `Open Json`
  String get gOpenJson {
    return Intl.message(
      'Open Json',
      name: 'gOpenJson',
      desc: 'This is a button about open print format. ',
      args: [],
    );
  }

  /// `BarCode Edit`
  String get gBarcodeEdit {
    return Intl.message(
      'BarCode Edit',
      name: 'gBarcodeEdit',
      desc: 'This is a button about barcode edit.',
      args: [],
    );
  }

  /// `Qrcode Edit`
  String get gQrcodeEdit {
    return Intl.message(
      'Qrcode Edit',
      name: 'gQrcodeEdit',
      desc: 'This is a button about qrcode edit.',
      args: [],
    );
  }

  /// `Save Format`
  String get gSaveFormat {
    return Intl.message(
      'Save Format',
      name: 'gSaveFormat',
      desc: 'This is a button to save format.',
      args: [],
    );
  }

  /// `Download`
  String get gBtnDownload {
    return Intl.message(
      'Download',
      name: 'gBtnDownload',
      desc: 'This is a button for downloading.',
      args: [],
    );
  }

  /// `Default Format`
  String get gBtnDownloadDefaultFormat {
    return Intl.message(
      'Default Format',
      name: 'gBtnDownloadDefaultFormat',
      desc: 'This is a button for downloading default format. ',
      args: [],
    );
  }

  /// `Attribute`
  String get gAttribute {
    return Intl.message(
      'Attribute',
      name: 'gAttribute',
      desc: 'This is a prompt about the attributes.',
      args: [],
    );
  }

  /// `Layer order:`
  String get gTabOrder {
    return Intl.message(
      'Layer order:',
      name: 'gTabOrder',
      desc: 'This is a prompt about the order of items in the printing format.',
      args: [],
    );
  }

  /// `No element selected.`
  String get gMsgNoElement {
    return Intl.message(
      'No element selected.',
      name: 'gMsgNoElement',
      desc: 'This is a prompt regarding no item being selected.',
      args: [],
    );
  }

  /// `Operation Steps:`
  String get gOperationSteps {
    return Intl.message(
      'Operation Steps:',
      name: 'gOperationSteps',
      desc: 'This is a prompt about operation steps.',
      args: [],
    );
  }

  /// `1. Please click on one or more elements on the left panel;`
  String get gMsgStep1 {
    return Intl.message(
      '1. Please click on one or more elements on the left panel;',
      name: 'gMsgStep1',
      desc: 'This is a prompt about operation step 1.',
      args: [],
    );
  }

  /// `2. The selected elements will be displayed in the center of the page, and you can edit their attributes here. `
  String get gMsgStep2 {
    return Intl.message(
      '2. The selected elements will be displayed in the center of the page, and you can edit their attributes here. ',
      name: 'gMsgStep2',
      desc: 'This is a prompt about operation step 2.',
      args: [],
    );
  }

  /// `Editor`
  String get gEditor {
    return Intl.message(
      'Editor',
      name: 'gEditor',
      desc: 'This is a prompt about editor.',
      args: [],
    );
  }

  /// `Text Content:`
  String get gTextContent {
    return Intl.message(
      'Text Content:',
      name: 'gTextContent',
      desc: 'This is a prompt about text content.',
      args: [],
    );
  }

  /// `Font Size:`
  String get gFontSize {
    return Intl.message(
      'Font Size:',
      name: 'gFontSize',
      desc: 'This is a prompt about font size.',
      args: [],
    );
  }

  /// `Rotation:`
  String get gRotation {
    return Intl.message(
      'Rotation:',
      name: 'gRotation',
      desc: 'This is a prompt about rotation.',
      args: [],
    );
  }

  /// `Reverse Contrast:`
  String get gFontReverse {
    return Intl.message(
      'Reverse Contrast:',
      name: 'gFontReverse',
      desc: 'This is a prompt about reverse contrast.',
      args: [],
    );
  }

  /// `HRI Alignment:`
  String get gHrAlignment {
    return Intl.message(
      'HRI Alignment:',
      name: 'gHrAlignment',
      desc: 'This is a prompt about HRI alignment.',
      args: [],
    );
  }

  /// `Delete`
  String get gBtnDelete {
    return Intl.message(
      'Delete',
      name: 'gBtnDelete',
      desc: 'This is a delete button.',
      args: [],
    );
  }

  /// `QRcode:`
  String get gQrcode {
    return Intl.message(
      'QRcode:',
      name: 'gQrcode',
      desc: 'This is a prompt about QRcode',
      args: [],
    );
  }

  /// `Qrcode Width:`
  String get gQrcodeWidth {
    return Intl.message(
      'Qrcode Width:',
      name: 'gQrcodeWidth',
      desc: 'This is a prompt about QRcode width.',
      args: [],
    );
  }

  /// `Position`
  String get gPosition {
    return Intl.message(
      'Position',
      name: 'gPosition',
      desc: 'This is a prompt about position.',
      args: [],
    );
  }

  /// `Bold:`
  String get gFontBold {
    return Intl.message(
      'Bold:',
      name: 'gFontBold',
      desc: 'This is a prompt about font bold.',
      args: [],
    );
  }

  /// `Alignment:`
  String get gAlignment {
    return Intl.message(
      'Alignment:',
      name: 'gAlignment',
      desc: 'This is a prompt about alignment.',
      args: [],
    );
  }

  /// `Max Length:`
  String get gMaxLength {
    return Intl.message(
      'Max Length:',
      name: 'gMaxLength',
      desc: 'This is a prompt about max length.',
      args: [],
    );
  }

  /// `Type:`
  String get gElementType {
    return Intl.message(
      'Type:',
      name: 'gElementType',
      desc: 'This is a prompt about item type in print format.',
      args: [],
    );
  }

  /// `BarCode:`
  String get gBarcode {
    return Intl.message(
      'BarCode:',
      name: 'gBarcode',
      desc: 'This is a prompt about BarCode.',
      args: [],
    );
  }

  /// `BarCode Height:`
  String get gBarcodeHeight {
    return Intl.message(
      'BarCode Height:',
      name: 'gBarcodeHeight',
      desc: 'This is a prompt about Barcode height.',
      args: [],
    );
  }

  /// `Zero`
  String get iBtnZero {
    return Intl.message(
      'Zero',
      name: 'iBtnZero',
      desc: 'This is a zeroing button in T-Industry,',
      args: [],
    );
  }

  /// `Zero:`
  String get iTextZero {
    return Intl.message(
      'Zero:',
      name: 'iTextZero',
      desc: 'This is a prompt about zero weight in T-Industry,',
      args: [],
    );
  }

  /// `Net:`
  String get iTextNet {
    return Intl.message(
      'Net:',
      name: 'iTextNet',
      desc: 'This is a prompt about net weight in T-Industry,',
      args: [],
    );
  }

  /// `Stable:`
  String get iStable {
    return Intl.message(
      'Stable:',
      name: 'iStable',
      desc: 'This is a prompt about stable weight in T-Industry,',
      args: [],
    );
  }

  /// `Setting`
  String get gBtnSetting {
    return Intl.message(
      'Setting',
      name: 'gBtnSetting',
      desc: 'This is a button about setting.',
      args: [],
    );
  }

  /// `Export`
  String get gBtnExport {
    return Intl.message(
      'Export',
      name: 'gBtnExport',
      desc: 'This is a export button.',
      args: [],
    );
  }

  /// `PLU Name:`
  String get gPluName {
    return Intl.message(
      'PLU Name:',
      name: 'gPluName',
      desc: 'This is a prompt about PLU name.',
      args: [],
    );
  }

  /// `PLU Edit`
  String get plu_edit {
    return Intl.message(
      'PLU Edit',
      name: 'plu_edit',
      desc: 'This is a prompt about PLU edit.',
      args: [],
    );
  }

  /// `User Name:`
  String get user_name {
    return Intl.message(
      'User Name:',
      name: 'user_name',
      desc: 'This is a prompt about user name.',
      args: [],
    );
  }

  /// `User Edit`
  String get user_edit {
    return Intl.message(
      'User Edit',
      name: 'user_edit',
      desc: 'This is a prompt about user edit.',
      args: [],
    );
  }

  /// `Parameter settings`
  String get parameter_settings_title {
    return Intl.message(
      'Parameter settings',
      name: 'parameter_settings_title',
      desc: 'This is a prompt about parameter settings.',
      args: [],
    );
  }

  /// `Save Mode:`
  String get save_mode {
    return Intl.message(
      'Save Mode:',
      name: 'save_mode',
      desc: 'This is a prompt about saving mode.',
      args: [],
    );
  }

  /// `Manual`
  String get manual {
    return Intl.message(
      'Manual',
      name: 'manual',
      desc: 'This is a prompt about manual mode.',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: 'This is a prompt about auto mode.',
      args: [],
    );
  }

  /// `Stable Time (s)`
  String get stable_time {
    return Intl.message(
      'Stable Time (s)',
      name: 'stable_time',
      desc: 'This is a prompt about stable time.',
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
  String get gBtnAdd {
    return Intl.message(
      'Add',
      name: 'gBtnAdd',
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

  /// `PLU pretare cannot be empty.`
  String get plu_error_message {
    return Intl.message(
      'PLU pretare cannot be empty.',
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
  String get iUserInfo {
    return Intl.message(
      'User Info',
      name: 'iUserInfo',
      desc: 'This is prompt for user info ,in T-Industry.',
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

  /// `Scale Model:`
  String get scale_model {
    return Intl.message(
      'Scale Model:',
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

  /// `Update Firmware Serial`
  String get firmware_update {
    return Intl.message(
      'Update Firmware Serial',
      name: 'firmware_update',
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
  String get gTitleGetBuildInfo {
    return Intl.message(
      'Software Information',
      name: 'gTitleGetBuildInfo',
      desc: '',
      args: [],
    );
  }

  /// `This ID is only to be used by device developers.`
  String get gBuildInfoTip {
    return Intl.message(
      'This ID is only to be used by device developers.',
      name: 'gBuildInfoTip',
      desc: 'This is a tip for build info.',
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

  /// `Device Info & Connection`
  String get device_connection_title {
    return Intl.message(
      'Device Info & Connection',
      name: 'device_connection_title',
      desc: '',
      args: [],
    );
  }

  /// `Basics`
  String get device_setting_title {
    return Intl.message(
      'Basics',
      name: 'device_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Device Configuration`
  String get device_configuration_title {
    return Intl.message(
      'Device Configuration',
      name: 'device_configuration_title',
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

  /// `Applications`
  String get customization_setting_title {
    return Intl.message(
      'Applications',
      name: 'customization_setting_title',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get advanced_setting_title {
    return Intl.message(
      'Advanced',
      name: 'advanced_setting_title',
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

  /// `Receipt Design`
  String get gTitleReceiptDesign {
    return Intl.message(
      'Receipt Design',
      name: 'gTitleReceiptDesign',
      desc: 'This is a title about receipt design app.',
      args: [],
    );
  }

  /// `This application is designed for the printing format of the receipt.`
  String get gTipReceiptDesign {
    return Intl.message(
      'This application is designed for the printing format of the receipt.',
      name: 'gTipReceiptDesign',
      desc: 'This is a prompt about receipt design app.',
      args: [],
    );
  }

  /// `Download Label Printing Formats`
  String get gTitleLabelFmtDownload {
    return Intl.message(
      'Download Label Printing Formats',
      name: 'gTitleLabelFmtDownload',
      desc: 'This is a title about downloading label printing Formats app.',
      args: [],
    );
  }

  /// `This application is used to download print format.`
  String get gTipLabelFmtDownload {
    return Intl.message(
      'This application is used to download print format.',
      name: 'gTipLabelFmtDownload',
      desc: 'This is a prompt about downloading label printing Formats app.',
      args: [],
    );
  }

  /// `Serial Output Design`
  String get gTitleSerialOutput {
    return Intl.message(
      'Serial Output Design',
      name: 'gTitleSerialOutput',
      desc: 'This is a title about serial output design',
      args: [],
    );
  }

  /// `Serial Output Download`
  String get gTitleSerialOutputDownload {
    return Intl.message(
      'Serial Output Download',
      name: 'gTitleSerialOutputDownload',
      desc: 'This is a title about serial output download.',
      args: [],
    );
  }

  /// `System Setting`
  String get gSystemSetting {
    return Intl.message(
      'System Setting',
      name: 'gSystemSetting',
      desc: 'This is a title about system setting.',
      args: [],
    );
  }

  /// `Set Language`
  String get gTitleSetLanguage {
    return Intl.message(
      'Set Language',
      name: 'gTitleSetLanguage',
      desc: 'This is a title about language setting.',
      args: [],
    );
  }

  /// `License Info`
  String get gTitleLicenseInfo {
    return Intl.message(
      'License Info',
      name: 'gTitleLicenseInfo',
      desc: 'This is a title about license info.',
      args: [],
    );
  }

  /// `Open preview`
  String get cBtnOpenPreview {
    return Intl.message(
      'Open preview',
      name: 'cBtnOpenPreview',
      desc: ' This is a button about open preview in T-Config.',
      args: [],
    );
  }

  /// `Close preview`
  String get cBtnClosePreview {
    return Intl.message(
      'Close preview',
      name: 'cBtnClosePreview',
      desc: 'This is a button about close preview in T-Config.',
      args: [],
    );
  }

  /// `Clear`
  String get gBtnClear {
    return Intl.message(
      'Clear',
      name: 'gBtnClear',
      desc: 'This is a button for clearing.',
      args: [],
    );
  }

  /// `Free format`
  String get gTipFreeFormat {
    return Intl.message(
      'Free format',
      name: 'gTipFreeFormat',
      desc: 'This is a prompt for free format.',
      args: [],
    );
  }

  /// `Total format:`
  String get gTotalFmt {
    return Intl.message(
      'Total format:',
      name: 'gTotalFmt',
      desc: 'This is a prompt for total format.',
      args: [],
    );
  }

  /// `PLU Download`
  String get gTitlePluDownload {
    return Intl.message(
      'PLU Download',
      name: 'gTitlePluDownload',
      desc: 'This is a title about downloading plu.',
      args: [],
    );
  }

  /// `This application is used to download product information.`
  String get gTipPluDownload {
    return Intl.message(
      'This application is used to download product information.',
      name: 'gTipPluDownload',
      desc: 'This is a tip about downloading plu.',
      args: [],
    );
  }

  /// `Weighing(Single)`
  String get iTitleWeighting {
    return Intl.message(
      'Weighing(Single)',
      name: 'iTitleWeighting',
      desc: 'This is a title about weighting,support one scale.',
      args: [],
    );
  }

  /// `Weighing Data Collection(Single)`
  String get iTitleWeightCollection {
    return Intl.message(
      'Weighing Data Collection(Single)',
      name: 'iTitleWeightCollection',
      desc:
          'This is a title about collect weight data,support one scale,in T-Industry',
      args: [],
    );
  }

  /// `This application is used to collect weighing data in real time`
  String get iTipWeightCollection {
    return Intl.message(
      'This application is used to collect weighing data in real time',
      name: 'iTipWeightCollection',
      desc: 'This is a prompt about collect weight data,in T-Industry',
      args: [],
    );
  }

  /// `Check Weighing(Single)`
  String get iTitleCheckWeigher {
    return Intl.message(
      'Check Weighing(Single)',
      name: 'iTitleCheckWeigher',
      desc:
          'This is a title about check weighing,support one scale,in T-Industry',
      args: [],
    );
  }

  /// `This application is used to check weighing data in real time`
  String get iTipCheckWeigher {
    return Intl.message(
      'This application is used to check weighing data in real time',
      name: 'iTipCheckWeigher',
      desc: 'This is a prompt about check weighing,in T-Industry',
      args: [],
    );
  }

  /// `Increment Weighing(Single)`
  String get iTitleIncrementWeighting {
    return Intl.message(
      'Increment Weighing(Single)',
      name: 'iTitleIncrementWeighting',
      desc:
          'This is a title about Increment Weighing,support one scale,in T-Industry',
      args: [],
    );
  }

  /// `This app is used to implement the increment scale.`
  String get iTipIncrementWeighting {
    return Intl.message(
      'This app is used to implement the increment scale.',
      name: 'iTipIncrementWeighting',
      desc: 'This is a prompt about Increment Weighing,in T-Industry',
      args: [],
    );
  }

  /// `Take Out Scale(Single)`
  String get gTitleTakeOut {
    return Intl.message(
      'Take Out Scale(Single)',
      name: 'gTitleTakeOut',
      desc:
          'This is a title about take out scale,support one scale,in T-Industry',
      args: [],
    );
  }

  /// `This app is used to implement the take out scale.`
  String get gTipTakeOut {
    return Intl.message(
      'This app is used to implement the take out scale.',
      name: 'gTipTakeOut',
      desc: 'This is a prompt about take out scale,in T-Industry',
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

  /// `Confirmation`
  String get gTitleConfirm {
    return Intl.message(
      'Confirmation',
      name: 'gTitleConfirm',
      desc: 'This is the title of the confirmation.',
      args: [],
    );
  }

  /// `Please confirm the order of the printing formats.`
  String get gConfirmPrnFmtOrderTip {
    return Intl.message(
      'Please confirm the order of the printing formats.',
      name: 'gConfirmPrnFmtOrderTip',
      desc: 'This is the prompt to confirm the order of the printing format.',
      args: [],
    );
  }

  /// `Please confirm to go to the default print format page.`
  String get jump_confirm_info {
    return Intl.message(
      'Please confirm to go to the default print format page.',
      name: 'jump_confirm_info',
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

  /// `Basic Data`
  String get abnormal_data_title {
    return Intl.message(
      'Basic Data',
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

  /// `Please confirm the information.`
  String get gTipConfirmInfo {
    return Intl.message(
      'Please confirm the information.',
      name: 'gTipConfirmInfo',
      desc: 'This is the prompt asking you to confirm the information.',
      args: [],
    );
  }

  /// `Server Ip:`
  String get server_ip {
    return Intl.message(
      'Server Ip:',
      name: 'server_ip',
      desc: '',
      args: [],
    );
  }

  /// `Server Port:`
  String get server_port {
    return Intl.message(
      'Server Port:',
      name: 'server_port',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect address! e.g. xxx.xxx.xxx.xxx`
  String get error_ip_tip {
    return Intl.message(
      'Incorrect address! e.g. xxx.xxx.xxx.xxx',
      name: 'error_ip_tip',
      desc: '',
      args: [],
    );
  }

  /// `Ethernet IP Setting`
  String get set_ethernet_ip_title {
    return Intl.message(
      'Ethernet IP Setting',
      name: 'set_ethernet_ip_title',
      desc: '',
      args: [],
    );
  }

  /// `Confirm to return to hompage?`
  String get go_home {
    return Intl.message(
      'Confirm to return to hompage?',
      name: 'go_home',
      desc: '',
      args: [],
    );
  }

  /// `Receipt Format Download`
  String get gTitleReceiptDownload {
    return Intl.message(
      'Receipt Format Download',
      name: 'gTitleReceiptDownload',
      desc: 'This is a title about receipt format download.',
      args: [],
    );
  }

  /// `This application is used to download the print format of the receipt.`
  String get gTipReceiptDownload {
    return Intl.message(
      'This application is used to download the print format of the receipt.',
      name: 'gTipReceiptDownload',
      desc: 'This is a prompt about receipt format download.',
      args: [],
    );
  }

  /// `Information`
  String get about_title {
    return Intl.message(
      'Information',
      name: 'about_title',
      desc: '',
      args: [],
    );
  }

  /// `Version:`
  String get app_version_title {
    return Intl.message(
      'Version:',
      name: 'app_version_title',
      desc: '',
      args: [],
    );
  }

  /// `Company:`
  String get app_company_title {
    return Intl.message(
      'Company:',
      name: 'app_company_title',
      desc: '',
      args: [],
    );
  }

  /// `Tel:`
  String get app_tel_title {
    return Intl.message(
      'Tel:',
      name: 'app_tel_title',
      desc: '',
      args: [],
    );
  }

  /// `Email:`
  String get app_email_title {
    return Intl.message(
      'Email:',
      name: 'app_email_title',
      desc: '',
      args: [],
    );
  }

  /// `Address:`
  String get app_address_title {
    return Intl.message(
      'Address:',
      name: 'app_address_title',
      desc: '',
      args: [],
    );
  }

  /// `Website Address:`
  String get app_web_title {
    return Intl.message(
      'Website Address:',
      name: 'app_web_title',
      desc: '',
      args: [],
    );
  }

  /// `Applicable Models:`
  String get app_models {
    return Intl.message(
      'Applicable Models:',
      name: 'app_models',
      desc: '',
      args: [],
    );
  }

  /// `Free Text`
  String get p_text_title {
    return Intl.message(
      'Free Text',
      name: 'p_text_title',
      desc: '',
      args: [],
    );
  }

  /// `Dividing Line`
  String get p_line_title {
    return Intl.message(
      'Dividing Line',
      name: 'p_line_title',
      desc: '',
      args: [],
    );
  }

  /// `Price Variable`
  String get p_price_title {
    return Intl.message(
      'Price Variable',
      name: 'p_price_title',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get p_text_var {
    return Intl.message(
      'Text',
      name: 'p_text_var',
      desc: '',
      args: [],
    );
  }

  /// `Line`
  String get p_div_line_var {
    return Intl.message(
      'Line',
      name: 'p_div_line_var',
      desc: '',
      args: [],
    );
  }

  /// `NO.`
  String get p_no_var {
    return Intl.message(
      'NO.',
      name: 'p_no_var',
      desc: '',
      args: [],
    );
  }

  /// `Header1`
  String get p_header1_var {
    return Intl.message(
      'Header1',
      name: 'p_header1_var',
      desc: '',
      args: [],
    );
  }

  /// `Header2`
  String get p_Header2_var {
    return Intl.message(
      'Header2',
      name: 'p_Header2_var',
      desc: '',
      args: [],
    );
  }

  /// `Header3`
  String get p_header3_var {
    return Intl.message(
      'Header3',
      name: 'p_header3_var',
      desc: '',
      args: [],
    );
  }

  /// `Footer1`
  String get p_footer1_var {
    return Intl.message(
      'Footer1',
      name: 'p_footer1_var',
      desc: '',
      args: [],
    );
  }

  /// `Footer2`
  String get p_footer2_var {
    return Intl.message(
      'Footer2',
      name: 'p_footer2_var',
      desc: '',
      args: [],
    );
  }

  /// `Footer3`
  String get p_footer3_var {
    return Intl.message(
      'Footer3',
      name: 'p_footer3_var',
      desc: '',
      args: [],
    );
  }

  /// `PLU_ID`
  String get p_plu_id_var {
    return Intl.message(
      'PLU_ID',
      name: 'p_plu_id_var',
      desc: '',
      args: [],
    );
  }

  /// `PLU_Name`
  String get p_plu_name_var {
    return Intl.message(
      'PLU_Name',
      name: 'p_plu_name_var',
      desc: '',
      args: [],
    );
  }

  /// `Order Number`
  String get p_order_number_var {
    return Intl.message(
      'Order Number',
      name: 'p_order_number_var',
      desc: '',
      args: [],
    );
  }

  /// `Unit Price`
  String get p_unit_price_var {
    return Intl.message(
      'Unit Price',
      name: 'p_unit_price_var',
      desc: '',
      args: [],
    );
  }

  /// `Price Unit`
  String get p_price_unit_var {
    return Intl.message(
      'Price Unit',
      name: 'p_price_unit_var',
      desc: '',
      args: [],
    );
  }

  /// `PreTare`
  String get p_pre_tare_var {
    return Intl.message(
      'PreTare',
      name: 'p_pre_tare_var',
      desc: '',
      args: [],
    );
  }

  /// `Unit`
  String get p_unit_var {
    return Intl.message(
      'Unit',
      name: 'p_unit_var',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get p_date_var {
    return Intl.message(
      'Date',
      name: 'p_date_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type1`
  String get p_tax_type1_var {
    return Intl.message(
      'Tax Type1',
      name: 'p_tax_type1_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type2`
  String get p_tax_type2_var {
    return Intl.message(
      'Tax Type2',
      name: 'p_tax_type2_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type3`
  String get p_tax_type3_var {
    return Intl.message(
      'Tax Type3',
      name: 'p_tax_type3_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base1`
  String get p_tax_base1_var {
    return Intl.message(
      'Tax Base1',
      name: 'p_tax_base1_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base2`
  String get p_tax_base2_var {
    return Intl.message(
      'Tax Base2',
      name: 'p_tax_base2_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base3`
  String get p_tax_base3_var {
    return Intl.message(
      'Tax Base3',
      name: 'p_tax_base3_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount1`
  String get p_tax_amount1_var {
    return Intl.message(
      'Tax Amount1',
      name: 'p_tax_amount1_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount2`
  String get p_tax_amount2_var {
    return Intl.message(
      'Tax Amount2',
      name: 'p_tax_amount2_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount3`
  String get p_tax_amount3_var {
    return Intl.message(
      'Tax Amount3',
      name: 'p_tax_amount3_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Model`
  String get p_tax_model_var {
    return Intl.message(
      'Tax Model',
      name: 'p_tax_model_var',
      desc: '',
      args: [],
    );
  }

  /// `Total Tax Amount`
  String get p_total_tax_amount_var {
    return Intl.message(
      'Total Tax Amount',
      name: 'p_total_tax_amount_var',
      desc: '',
      args: [],
    );
  }

  /// `Payment Amount`
  String get p_payment_amount_P_var {
    return Intl.message(
      'Payment Amount',
      name: 'p_payment_amount_P_var',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get p_subtotal_var {
    return Intl.message(
      'Subtotal',
      name: 'p_subtotal_var',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get p_currency_var {
    return Intl.message(
      'Currency',
      name: 'p_currency_var',
      desc: '',
      args: [],
    );
  }

  /// `Copy Times`
  String get p_copy_times_var {
    return Intl.message(
      'Copy Times',
      name: 'p_copy_times_var',
      desc: '',
      args: [],
    );
  }

  /// `Model Name`
  String get p_model_name_var {
    return Intl.message(
      'Model Name',
      name: 'p_model_name_var',
      desc: '',
      args: [],
    );
  }

  /// `Scale Name`
  String get p_scale_name_var {
    return Intl.message(
      'Scale Name',
      name: 'p_scale_name_var',
      desc: '',
      args: [],
    );
  }

  /// `Tax Name.`
  String get p_tax_name_var {
    return Intl.message(
      'Tax Name.',
      name: 'p_tax_name_var',
      desc: '',
      args: [],
    );
  }

  /// `Settle Account Times.`
  String get p_settle_account_times_var {
    return Intl.message(
      'Settle Account Times.',
      name: 'p_settle_account_times_var',
      desc: '',
      args: [],
    );
  }

  /// `PLU Tax`
  String get p_plu_tax_var {
    return Intl.message(
      'PLU Tax',
      name: 'p_plu_tax_var',
      desc: '',
      args: [],
    );
  }

  /// `Total No Tax`
  String get p_total_no_tax_var {
    return Intl.message(
      'Total No Tax',
      name: 'p_total_no_tax_var',
      desc: '',
      args: [],
    );
  }

  /// `Weight Pcs`
  String get p_weight_pcs_var {
    return Intl.message(
      'Weight Pcs',
      name: 'p_weight_pcs_var',
      desc: '',
      args: [],
    );
  }

  /// `Tare`
  String get p_tare_var {
    return Intl.message(
      'Tare',
      name: 'p_tare_var',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get p_time_var {
    return Intl.message(
      'Time',
      name: 'p_time_var',
      desc: '',
      args: [],
    );
  }

  /// `Change Amount`
  String get p_change_amount_var {
    return Intl.message(
      'Change Amount',
      name: 'p_change_amount_var',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get p_price_var {
    return Intl.message(
      'Price',
      name: 'p_price_var',
      desc: '',
      args: [],
    );
  }

  /// `Free text.`
  String get p_text_expl {
    return Intl.message(
      'Free text.',
      name: 'p_text_expl',
      desc: '',
      args: [],
    );
  }

  /// `Loop divider line.`
  String get p_div_line_expl {
    return Intl.message(
      'Loop divider line.',
      name: 'p_div_line_expl',
      desc: '',
      args: [],
    );
  }

  /// `Sequence number value.`
  String get p_no_expl {
    return Intl.message(
      'Sequence number value.',
      name: 'p_no_expl',
      desc: '',
      args: [],
    );
  }

  /// `The first page header.`
  String get p_header1_expl {
    return Intl.message(
      'The first page header.',
      name: 'p_header1_expl',
      desc: '',
      args: [],
    );
  }

  /// `The secend page header.`
  String get p_Header2_expl {
    return Intl.message(
      'The secend page header.',
      name: 'p_Header2_expl',
      desc: '',
      args: [],
    );
  }

  /// `The third page header.`
  String get p_header3_expl {
    return Intl.message(
      'The third page header.',
      name: 'p_header3_expl',
      desc: '',
      args: [],
    );
  }

  /// `The first page footer.`
  String get p_footer1_expl {
    return Intl.message(
      'The first page footer.',
      name: 'p_footer1_expl',
      desc: '',
      args: [],
    );
  }

  /// `The secend page footer.`
  String get p_footer2_expl {
    return Intl.message(
      'The secend page footer.',
      name: 'p_footer2_expl',
      desc: '',
      args: [],
    );
  }

  /// `The third page footer.`
  String get p_footer3_expl {
    return Intl.message(
      'The third page footer.',
      name: 'p_footer3_expl',
      desc: '',
      args: [],
    );
  }

  /// `PLU_ID.`
  String get p_plu_id_expl {
    return Intl.message(
      'PLU_ID.',
      name: 'p_plu_id_expl',
      desc: '',
      args: [],
    );
  }

  /// `PLU_Name.`
  String get p_plu_name_expl {
    return Intl.message(
      'PLU_Name.',
      name: 'p_plu_name_expl',
      desc: '',
      args: [],
    );
  }

  /// `The serial number of the pending order.`
  String get p_order_number_expl {
    return Intl.message(
      'The serial number of the pending order.',
      name: 'p_order_number_expl',
      desc: '',
      args: [],
    );
  }

  /// `Unit Price.`
  String get p_unit_price_expl {
    return Intl.message(
      'Unit Price.',
      name: 'p_unit_price_expl',
      desc: '',
      args: [],
    );
  }

  /// `Price Unit.`
  String get p_price_unit_expl {
    return Intl.message(
      'Price Unit.',
      name: 'p_price_unit_expl',
      desc: '',
      args: [],
    );
  }

  /// `PreTare.`
  String get p_pre_tare_expl {
    return Intl.message(
      'PreTare.',
      name: 'p_pre_tare_expl',
      desc: '',
      args: [],
    );
  }

  /// `Weight Unit.`
  String get p_unit_expl {
    return Intl.message(
      'Weight Unit.',
      name: 'p_unit_expl',
      desc: '',
      args: [],
    );
  }

  /// `Date.`
  String get p_date_expl {
    return Intl.message(
      'Date.',
      name: 'p_date_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type 1.`
  String get p_tax_type1_expl {
    return Intl.message(
      'Tax Type 1.',
      name: 'p_tax_type1_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type 2.`
  String get p_tax_type2_expl {
    return Intl.message(
      'Tax Type 2.',
      name: 'p_tax_type2_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Type 3.`
  String get p_tax_type3_expl {
    return Intl.message(
      'Tax Type 3.',
      name: 'p_tax_type3_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base 1.`
  String get p_tax_base1_expl {
    return Intl.message(
      'Tax Base 1.',
      name: 'p_tax_base1_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base 2.`
  String get p_tax_base2_expl {
    return Intl.message(
      'Tax Base 2.',
      name: 'p_tax_base2_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Base 3.`
  String get p_tax_base3_expl {
    return Intl.message(
      'Tax Base 3.',
      name: 'p_tax_base3_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount 1.`
  String get p_tax_amount1_expl {
    return Intl.message(
      'Tax Amount 1.',
      name: 'p_tax_amount1_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount 2.`
  String get p_tax_amount2_expl {
    return Intl.message(
      'Tax Amount 2.',
      name: 'p_tax_amount2_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Amount 3.`
  String get p_tax_amount3_expl {
    return Intl.message(
      'Tax Amount 3.',
      name: 'p_tax_amount3_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Model,tax included or tax external.`
  String get p_tax_model_expl {
    return Intl.message(
      'Tax Model,tax included or tax external.',
      name: 'p_tax_model_expl',
      desc: '',
      args: [],
    );
  }

  /// `Total Tax Amount.`
  String get p_total_tax_amount_expl {
    return Intl.message(
      'Total Tax Amount.',
      name: 'p_total_tax_amount_expl',
      desc: '',
      args: [],
    );
  }

  /// `Payment Amount.`
  String get p_payment_amount_P_expl {
    return Intl.message(
      'Payment Amount.',
      name: 'p_payment_amount_P_expl',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal.`
  String get p_subtotal_expl {
    return Intl.message(
      'Subtotal.',
      name: 'p_subtotal_expl',
      desc: '',
      args: [],
    );
  }

  /// `Currency.`
  String get p_currency_expl {
    return Intl.message(
      'Currency.',
      name: 'p_currency_expl',
      desc: '',
      args: [],
    );
  }

  /// `Copy Times.`
  String get p_copy_times_expl {
    return Intl.message(
      'Copy Times.',
      name: 'p_copy_times_expl',
      desc: '',
      args: [],
    );
  }

  /// `Scale Model Name.`
  String get p_model_name_expl {
    return Intl.message(
      'Scale Model Name.',
      name: 'p_model_name_expl',
      desc: '',
      args: [],
    );
  }

  /// `Scale Name.`
  String get p_scale_name_expl {
    return Intl.message(
      'Scale Name.',
      name: 'p_scale_name_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tax Name.`
  String get p_tax_name_expl {
    return Intl.message(
      'Tax Name.',
      name: 'p_tax_name_expl',
      desc: '',
      args: [],
    );
  }

  /// `Settle Account Times.`
  String get p_settle_account_times_expl {
    return Intl.message(
      'Settle Account Times.',
      name: 'p_settle_account_times_expl',
      desc: '',
      args: [],
    );
  }

  /// `PLU Tax Value.`
  String get p_plu_tax_expl {
    return Intl.message(
      'PLU Tax Value.',
      name: 'p_plu_tax_expl',
      desc: '',
      args: [],
    );
  }

  /// `Total No Tax.`
  String get p_total_no_tax_expl {
    return Intl.message(
      'Total No Tax.',
      name: 'p_total_no_tax_expl',
      desc: '',
      args: [],
    );
  }

  /// `Weight or Pcs.`
  String get p_weight_pcs_expl {
    return Intl.message(
      'Weight or Pcs.',
      name: 'p_weight_pcs_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tare value.`
  String get p_tare_expl {
    return Intl.message(
      'Tare value.',
      name: 'p_tare_expl',
      desc: '',
      args: [],
    );
  }

  /// `Time.`
  String get p_time_expl {
    return Intl.message(
      'Time.',
      name: 'p_time_expl',
      desc: '',
      args: [],
    );
  }

  /// `Change Amount.`
  String get p_change_amount_expl {
    return Intl.message(
      'Change Amount.',
      name: 'p_change_amount_expl',
      desc: '',
      args: [],
    );
  }

  /// `Price value.`
  String get p_price_expl {
    return Intl.message(
      'Price value.',
      name: 'p_price_expl',
      desc: '',
      args: [],
    );
  }

  /// `Variable`
  String get l_var_title {
    return Intl.message(
      'Variable',
      name: 'l_var_title',
      desc: '',
      args: [],
    );
  }

  /// `Free Text`
  String get l_text_title {
    return Intl.message(
      'Free Text',
      name: 'l_text_title',
      desc: '',
      args: [],
    );
  }

  /// `BarCode Variable`
  String get l_barcode_title {
    return Intl.message(
      'BarCode Variable',
      name: 'l_barcode_title',
      desc: '',
      args: [],
    );
  }

  /// `Qrcode Variable`
  String get l_qrcode_title {
    return Intl.message(
      'Qrcode Variable',
      name: 'l_qrcode_title',
      desc: '',
      args: [],
    );
  }

  /// `Shape`
  String get l_shape_title {
    return Intl.message(
      'Shape',
      name: 'l_shape_title',
      desc: '',
      args: [],
    );
  }

  /// `Line`
  String get l_line_var {
    return Intl.message(
      'Line',
      name: 'l_line_var',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get l_text_var {
    return Intl.message(
      'Text',
      name: 'l_text_var',
      desc: '',
      args: [],
    );
  }

  /// `BarCode`
  String get l_barcode_var {
    return Intl.message(
      'BarCode',
      name: 'l_barcode_var',
      desc: '',
      args: [],
    );
  }

  /// `Qrcode`
  String get l_qrcode_var {
    return Intl.message(
      'Qrcode',
      name: 'l_qrcode_var',
      desc: '',
      args: [],
    );
  }

  /// `NO.`
  String get l_no_var {
    return Intl.message(
      'NO.',
      name: 'l_no_var',
      desc: '',
      args: [],
    );
  }

  /// `Gross`
  String get l_gross_var {
    return Intl.message(
      'Gross',
      name: 'l_gross_var',
      desc: '',
      args: [],
    );
  }

  /// `Tare`
  String get l_tare_var {
    return Intl.message(
      'Tare',
      name: 'l_tare_var',
      desc: '',
      args: [],
    );
  }

  /// `Net`
  String get l_net_var {
    return Intl.message(
      'Net',
      name: 'l_net_var',
      desc: '',
      args: [],
    );
  }

  /// `PCS`
  String get l_pcs_var {
    return Intl.message(
      'PCS',
      name: 'l_pcs_var',
      desc: '',
      args: [],
    );
  }

  /// `WeightUnit`
  String get l_wgt_unit_var {
    return Intl.message(
      'WeightUnit',
      name: 'l_wgt_unit_var',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get l_date_var {
    return Intl.message(
      'Date',
      name: 'l_date_var',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get l_time_var {
    return Intl.message(
      'Time',
      name: 'l_time_var',
      desc: '',
      args: [],
    );
  }

  /// `U.WGT`
  String get l_uwgt_var {
    return Intl.message(
      'U.WGT',
      name: 'l_uwgt_var',
      desc: '',
      args: [],
    );
  }

  /// `U.WU`
  String get l_uwu_var {
    return Intl.message(
      'U.WU',
      name: 'l_uwu_var',
      desc: '',
      args: [],
    );
  }

  /// `UnitWeight`
  String get l_unit_wgt_var {
    return Intl.message(
      'UnitWeight',
      name: 'l_unit_wgt_var',
      desc: '',
      args: [],
    );
  }

  /// `Percent`
  String get l_percent_var {
    return Intl.message(
      'Percent',
      name: 'l_percent_var',
      desc: '',
      args: [],
    );
  }

  /// `TotalWeight`
  String get l_total_wgt_var {
    return Intl.message(
      'TotalWeight',
      name: 'l_total_wgt_var',
      desc: '',
      args: [],
    );
  }

  /// `TotalCount`
  String get l_total_cnt_var {
    return Intl.message(
      'TotalCount',
      name: 'l_total_cnt_var',
      desc: '',
      args: [],
    );
  }

  /// `Line`
  String get l_line_expl {
    return Intl.message(
      'Line',
      name: 'l_line_expl',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get l_text_expl {
    return Intl.message(
      'Text',
      name: 'l_text_expl',
      desc: '',
      args: [],
    );
  }

  /// `BarCode`
  String get l_barcode_expl {
    return Intl.message(
      'BarCode',
      name: 'l_barcode_expl',
      desc: '',
      args: [],
    );
  }

  /// `Qrcode`
  String get l_qrcode_expl {
    return Intl.message(
      'Qrcode',
      name: 'l_qrcode_expl',
      desc: '',
      args: [],
    );
  }

  /// `NO.`
  String get l_no_expl {
    return Intl.message(
      'NO.',
      name: 'l_no_expl',
      desc: '',
      args: [],
    );
  }

  /// `Gross`
  String get l_gross_expl {
    return Intl.message(
      'Gross',
      name: 'l_gross_expl',
      desc: '',
      args: [],
    );
  }

  /// `Tare`
  String get l_tare_expl {
    return Intl.message(
      'Tare',
      name: 'l_tare_expl',
      desc: '',
      args: [],
    );
  }

  /// `Net`
  String get l_net_expl {
    return Intl.message(
      'Net',
      name: 'l_net_expl',
      desc: '',
      args: [],
    );
  }

  /// `PCS`
  String get l_pcs_expl {
    return Intl.message(
      'PCS',
      name: 'l_pcs_expl',
      desc: '',
      args: [],
    );
  }

  /// `WeightUnit`
  String get l_wgt_unit_expl {
    return Intl.message(
      'WeightUnit',
      name: 'l_wgt_unit_expl',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get l_date_expl {
    return Intl.message(
      'Date',
      name: 'l_date_expl',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get l_time_expl {
    return Intl.message(
      'Time',
      name: 'l_time_expl',
      desc: '',
      args: [],
    );
  }

  /// `Universal weight`
  String get l_uwgt_expl {
    return Intl.message(
      'Universal weight',
      name: 'l_uwgt_expl',
      desc: '',
      args: [],
    );
  }

  /// `Universal weight unit`
  String get l_uwu_expl {
    return Intl.message(
      'Universal weight unit',
      name: 'l_uwu_expl',
      desc: '',
      args: [],
    );
  }

  /// `UnitWeight`
  String get l_unit_wgt_expl {
    return Intl.message(
      'UnitWeight',
      name: 'l_unit_wgt_expl',
      desc: '',
      args: [],
    );
  }

  /// `Percent`
  String get l_percent_expl {
    return Intl.message(
      'Percent',
      name: 'l_percent_expl',
      desc: '',
      args: [],
    );
  }

  /// `TotalWeight`
  String get l_total_wgt_expl {
    return Intl.message(
      'TotalWeight',
      name: 'l_total_wgt_expl',
      desc: '',
      args: [],
    );
  }

  /// `TotalCount`
  String get l_total_cnt_expl {
    return Intl.message(
      'TotalCount',
      name: 'l_total_cnt_expl',
      desc: '',
      args: [],
    );
  }

  /// `Line Width`
  String get l_line_width_txt {
    return Intl.message(
      'Line Width',
      name: 'l_line_width_txt',
      desc: '',
      args: [],
    );
  }

  /// `Line Length`
  String get l_line_lenth_txt {
    return Intl.message(
      'Line Length',
      name: 'l_line_lenth_txt',
      desc: '',
      args: [],
    );
  }

  /// `Please select the correct print format`
  String get l_open_fmt_err {
    return Intl.message(
      'Please select the correct print format',
      name: 'l_open_fmt_err',
      desc: '',
      args: [],
    );
  }

  /// `Receipt Format`
  String get gReceiptFormat {
    return Intl.message(
      'Receipt Format',
      name: 'gReceiptFormat',
      desc: 'This is the prompt for receipt format.',
      args: [],
    );
  }

  /// `Export`
  String get batch_down_export {
    return Intl.message(
      'Export',
      name: 'batch_down_export',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get gBtnImport {
    return Intl.message(
      'Import',
      name: 'gBtnImport',
      desc: '',
      args: [],
    );
  }

  /// `Get Data From DB`
  String get gBtnGetDataFormDb {
    return Intl.message(
      'Get Data From DB',
      name: 'gBtnGetDataFormDb',
      desc: '',
      args: [],
    );
  }

  /// `Select Folder`
  String get batch_down_slt_folder {
    return Intl.message(
      'Select Folder',
      name: 'batch_down_slt_folder',
      desc: '',
      args: [],
    );
  }

  /// `Get Basic Data`
  String get abnormal_weight {
    return Intl.message(
      'Get Basic Data',
      name: 'abnormal_weight',
      desc: '',
      args: [],
    );
  }

  /// `Select Product Excel`
  String get gBtnSelectPluFile {
    return Intl.message(
      'Select Product Excel',
      name: 'gBtnSelectPluFile',
      desc: 'This is a button for selecting the PLU file.',
      args: [],
    );
  }

  /// `Get PLU Template`
  String get gBtnGetPluTemplate {
    return Intl.message(
      'Get PLU Template',
      name: 'gBtnGetPluTemplate',
      desc: 'This is a button for getting the product template.',
      args: [],
    );
  }

  /// `Only one PLU file can be selected`
  String get gTipSelectOnePluFile {
    return Intl.message(
      'Only one PLU file can be selected',
      name: 'gTipSelectOnePluFile',
      desc:
          'This is a prompt for only one PLU file can be selected for downloading',
      args: [],
    );
  }

  /// `Product name max length:`
  String get gPluNameLength {
    return Intl.message(
      'Product name max length:',
      name: 'gPluNameLength',
      desc: '',
      args: [],
    );
  }

  /// `Clear all then download`
  String get gTipDownloadAllPlu {
    return Intl.message(
      'Clear all then download',
      name: 'gTipDownloadAllPlu',
      desc: 'This is the prompt to clear all product data before issuing.',
      args: [],
    );
  }

  /// `Update Products`
  String get gTipUpdatePlu {
    return Intl.message(
      'Update Products',
      name: 'gTipUpdatePlu',
      desc: 'This is the prompt to update products.',
      args: [],
    );
  }

  /// `Select License File`
  String get btn_add_lic_file {
    return Intl.message(
      'Select License File',
      name: 'btn_add_lic_file',
      desc: '',
      args: [],
    );
  }

  /// `Resource Folder`
  String get output_res_folder {
    return Intl.message(
      'Resource Folder',
      name: 'output_res_folder',
      desc: '',
      args: [],
    );
  }

  /// `Select Folder`
  String get output_select_folder {
    return Intl.message(
      'Select Folder',
      name: 'output_select_folder',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm the folder name!`
  String get output_confirm_info {
    return Intl.message(
      'Please confirm the folder name!',
      name: 'output_confirm_info',
      desc: '',
      args: [],
    );
  }

  /// `No files were matched!`
  String get output_no_file {
    return Intl.message(
      'No files were matched!',
      name: 'output_no_file',
      desc: '',
      args: [],
    );
  }

  /// `Please select 1-10 print formats.`
  String get def_fmt_sel_tip {
    return Intl.message(
      'Please select 1-10 print formats.',
      name: 'def_fmt_sel_tip',
      desc: '',
      args: [],
    );
  }

  /// `Default Number`
  String get def_fmt_no_title {
    return Intl.message(
      'Default Number',
      name: 'def_fmt_no_title',
      desc: '',
      args: [],
    );
  }

  /// `File Path`
  String get def_fmt_file_title {
    return Intl.message(
      'File Path',
      name: 'def_fmt_file_title',
      desc: '',
      args: [],
    );
  }

  /// `No data yet`
  String get def_fmt_no_file_tip {
    return Intl.message(
      'No data yet',
      name: 'def_fmt_no_file_tip',
      desc: '',
      args: [],
    );
  }

  /// `The overall print format content is out of scope`
  String get def_fmt_out_range_tip {
    return Intl.message(
      'The overall print format content is out of scope',
      name: 'def_fmt_out_range_tip',
      desc: '',
      args: [],
    );
  }

  /// `Multi-scale Management`
  String get m_scale_title {
    return Intl.message(
      'Multi-scale Management',
      name: 'm_scale_title',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get scale_mgr_btn_add {
    return Intl.message(
      'Add',
      name: 'scale_mgr_btn_add',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get scale_mgr_btn_rename {
    return Intl.message(
      'Rename',
      name: 'scale_mgr_btn_rename',
      desc: '',
      args: [],
    );
  }

  /// `Set Default`
  String get scale_mgr_btn_def {
    return Intl.message(
      'Set Default',
      name: 'scale_mgr_btn_def',
      desc: '',
      args: [],
    );
  }

  /// `Test Connect`
  String get scale_mgr_btn_test {
    return Intl.message(
      'Test Connect',
      name: 'scale_mgr_btn_test',
      desc: '',
      args: [],
    );
  }

  /// `Scale Name`
  String get scale_mgr_scale_name {
    return Intl.message(
      'Scale Name',
      name: 'scale_mgr_scale_name',
      desc: '',
      args: [],
    );
  }

  /// `Scale Model:`
  String get scale_mgr_scale_model {
    return Intl.message(
      'Scale Model:',
      name: 'scale_mgr_scale_model',
      desc: '',
      args: [],
    );
  }

  /// `Retail Detail Report`
  String get rDetailRptTitle {
    return Intl.message(
      'Retail Detail Report',
      name: 'rDetailRptTitle',
      desc:
          'This is the title of the retail detail report page in the retail app.',
      args: [],
    );
  }

  /// `This app is used to display sales detail data.`
  String get rTipDetailRpt {
    return Intl.message(
      'This app is used to display sales detail data.',
      name: 'rTipDetailRpt',
      desc:
          'This is the prompt for the retail detail report in the retail app.',
      args: [],
    );
  }

  /// `PLU Edit`
  String get gTitlePluEdit {
    return Intl.message(
      'PLU Edit',
      name: 'gTitlePluEdit',
      desc: 'This is the title of the PLU edit page.',
      args: [],
    );
  }

  /// `Show Scales`
  String get rShowScaleListBtn {
    return Intl.message(
      'Show Scales',
      name: 'rShowScaleListBtn',
      desc:
          'This is the name of the button for displaying the list of scales in the retail app.',
      args: [],
    );
  }

  /// `Hide Scales`
  String get rHideScaleListBtn {
    return Intl.message(
      'Hide Scales',
      name: 'rHideScaleListBtn',
      desc:
          'This is the name of the button for hiding the list of scales in the retail app.',
      args: [],
    );
  }

  /// `Refresh List`
  String get rRefreshListBtn {
    return Intl.message(
      'Refresh List',
      name: 'rRefreshListBtn',
      desc:
          'This is the name of the button for refreshing the retail list in the retail app.',
      args: [],
    );
  }

  /// `online`
  String get gOnlineTip {
    return Intl.message(
      'online',
      name: 'gOnlineTip',
      desc: 'This is a prompt for online information.',
      args: [],
    );
  }

  /// `offline`
  String get gOfflineTip {
    return Intl.message(
      'offline',
      name: 'gOfflineTip',
      desc: 'This is a prompt for offline information.',
      args: [],
    );
  }

  /// `Whether to join the management`
  String get rJoinManagementTip {
    return Intl.message(
      'Whether to join the management',
      name: 'rJoinManagementTip',
      desc:
          'This is a prompt about whether to join the management in the retail app.',
      args: [],
    );
  }

  /// `Update Firmware`
  String get gTitleUpdateFirmware {
    return Intl.message(
      'Update Firmware',
      name: 'gTitleUpdateFirmware',
      desc: 'This is the title for updating the firmware.',
      args: [],
    );
  }

  /// `Firmware Zip:`
  String get gTipFirmwareZipFile {
    return Intl.message(
      'Firmware Zip:',
      name: 'gTipFirmwareZipFile',
      desc: 'This is the prompt for the Firmware zip file.',
      args: [],
    );
  }

  /// `Select Firmware Zip`
  String get gBtnSelectZipFirmware {
    return Intl.message(
      'Select Firmware Zip',
      name: 'gBtnSelectZipFirmware',
      desc: 'This is the button for selecting the Firmware zip file.',
      args: [],
    );
  }

  /// `Please confirm the file correct.`
  String get gConfirmFileTip {
    return Intl.message(
      'Please confirm the file correct.',
      name: 'gConfirmFileTip',
      desc:
          'This is the prompt to confirm whether the file is correct when downloading.',
      args: [],
    );
  }

  /// `Serial Port`
  String get gBtnViaSerialUpdate {
    return Intl.message(
      'Serial Port',
      name: 'gBtnViaSerialUpdate',
      desc:
          'This is the button for switching to serial port update when updating the firmware.',
      args: [],
    );
  }

  /// `Network`
  String get gBtnViaNetworkUpdate {
    return Intl.message(
      'Network',
      name: 'gBtnViaNetworkUpdate',
      desc:
          'This is the button for switching to network update when updating the firmware.',
      args: [],
    );
  }

  /// `Please select the way to update the firmware.`
  String get gTipSelectUpdateWay {
    return Intl.message(
      'Please select the way to update the firmware.',
      name: 'gTipSelectUpdateWay',
      desc: 'This is the prompt to select the way when update firmware.',
      args: [],
    );
  }

  /// `Please wait...`
  String get gTipWait {
    return Intl.message(
      'Please wait...',
      name: 'gTipWait',
      desc: 'This is the prompt for waiting.',
      args: [],
    );
  }

  /// `Please reboot the device to begin update...`
  String get gTipRebootForUpdate {
    return Intl.message(
      'Please reboot the device to begin update...',
      name: 'gTipRebootForUpdate',
      desc:
          'This is the prompt restarting the device for the automatic update.',
      args: [],
    );
  }

  /// `Variable Value Setting`
  String get rTitleSetVariableValues {
    return Intl.message(
      'Variable Value Setting',
      name: 'rTitleSetVariableValues',
      desc:
          'This is the title for setting the values of variables, such as the header and footer,in the retail app.',
      args: [],
    );
  }

  /// `This application is used to distribute various variable information, such as headers and footers.`
  String get rTipSetVariableValues {
    return Intl.message(
      'This application is used to distribute various variable information, such as headers and footers.',
      name: 'rTipSetVariableValues',
      desc:
          'This is the explanation for applying the setting of variable values.',
      args: [],
    );
  }

  /// `Header`
  String get rTipHeader {
    return Intl.message(
      'Header',
      name: 'rTipHeader',
      desc: 'This is the prompt for Header.',
      args: [],
    );
  }

  /// `Footer`
  String get rTipFooter {
    return Intl.message(
      'Footer',
      name: 'rTipFooter',
      desc: 'This is the prompt for Footer.',
      args: [],
    );
  }

  /// `Operator`
  String get rTipOperator {
    return Intl.message(
      'Operator',
      name: 'rTipOperator',
      desc: 'This is the prompt for Operator.',
      args: [],
    );
  }

  /// `Data Error !`
  String get gTipDataError {
    return Intl.message(
      'Data Error !',
      name: 'gTipDataError',
      desc: 'This is the prompt for data error.',
      args: [],
    );
  }

  /// `New Format`
  String get gBtnNewFormat {
    return Intl.message(
      'New Format',
      name: 'gBtnNewFormat',
      desc: 'This is a button for creating a new printing format.',
      args: [],
    );
  }

  /// `Type:`
  String get gTipItemType {
    return Intl.message(
      'Type:',
      name: 'gTipItemType',
      desc: 'This is the name of an item type,in the printing format page.',
      args: [],
    );
  }

  /// `No folder has been selected, so the file cannot be saved.`
  String get gTipFolderNoSelected {
    return Intl.message(
      'No folder has been selected, so the file cannot be saved.',
      name: 'gTipFolderNoSelected',
      desc: 'This is the prompt for saving flie.',
      args: [],
    );
  }

  /// `Save data failed !`
  String get gTipSaveFail {
    return Intl.message(
      'Save data failed !',
      name: 'gTipSaveFail',
      desc: 'This is the prompt for saving flie failed.',
      args: [],
    );
  }

  /// `Save successfully. The path is:`
  String get gTipSaveSuccess {
    return Intl.message(
      'Save successfully. The path is:',
      name: 'gTipSaveSuccess',
      desc: 'This is the prompt for flie saved ok.',
      args: [],
    );
  }

  /// `Save To Excel`
  String get gBtnSaveExcel {
    return Intl.message(
      'Save To Excel',
      name: 'gBtnSaveExcel',
      desc: 'This is the button to save excel.',
      args: [],
    );
  }

  /// `Save To DB`
  String get gBtnSaveDataBase {
    return Intl.message(
      'Save To DB',
      name: 'gBtnSaveDataBase',
      desc: 'This is the button to save database.',
      args: [],
    );
  }

  /// `PLU`
  String get gPluPlu {
    return Intl.message(
      'PLU',
      name: 'gPluPlu',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Product Code`
  String get gPluPluCode {
    return Intl.message(
      'Product Code',
      name: 'gPluPluCode',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Item Code`
  String get gPluItemCode {
    return Intl.message(
      'Item Code',
      name: 'gPluItemCode',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Category`
  String get gPluCategory {
    return Intl.message(
      'Category',
      name: 'gPluCategory',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Product Name`
  String get gPluPluName {
    return Intl.message(
      'Product Name',
      name: 'gPluPluName',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Unit`
  String get gPluWgtUnit {
    return Intl.message(
      'Unit',
      name: 'gPluWgtUnit',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Tax Type`
  String get gPluTaxType {
    return Intl.message(
      'Tax Type',
      name: 'gPluTaxType',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Price`
  String get gPluPrice {
    return Intl.message(
      'Price',
      name: 'gPluPrice',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Unit Wight`
  String get gPluUnitWgt {
    return Intl.message(
      'Unit Wight',
      name: 'gPluUnitWgt',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Pretare`
  String get gPluPretare {
    return Intl.message(
      'Pretare',
      name: 'gPluPretare',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Limit High`
  String get gPluLimitHigh {
    return Intl.message(
      'Limit High',
      name: 'gPluLimitHigh',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `Limit Low`
  String get gPluLimitLow {
    return Intl.message(
      'Limit Low',
      name: 'gPluLimitLow',
      desc: 'This is prompt for product edit.',
      args: [],
    );
  }

  /// `PLU Field`
  String get gPluField {
    return Intl.message(
      'PLU Field',
      name: 'gPluField',
      desc: 'This is prompt for PLU field select.',
      args: [],
    );
  }

  /// `Note: When the cell is empty, it will be written as 0 or - .`
  String get gTipImportPluOK {
    return Intl.message(
      'Note: When the cell is empty, it will be written as 0 or - .',
      name: 'gTipImportPluOK',
      desc: 'This is prompt for PLU import.',
      args: [],
    );
  }

  /// `No data`
  String get gTipNoData {
    return Intl.message(
      'No data',
      name: 'gTipNoData',
      desc: 'This is prompt for no data.',
      args: [],
    );
  }

  /// `No data selected.`
  String get gTipNoDataSelected {
    return Intl.message(
      'No data selected.',
      name: 'gTipNoDataSelected',
      desc: 'This is prompt for no data selected.',
      args: [],
    );
  }

  /// `Duplicated`
  String get gTipPluDuplicated {
    return Intl.message(
      'Duplicated',
      name: 'gTipPluDuplicated',
      desc: 'This is prompt for plu duplicated.',
      args: [],
    );
  }

  /// `Save Data OK.`
  String get gTipSaveDbOk {
    return Intl.message(
      'Save Data OK.',
      name: 'gTipSaveDbOk',
      desc: 'This is prompt for plu saved.',
      args: [],
    );
  }

  /// `The data is being saved. Please wait a moment.`
  String get gTipSavingData {
    return Intl.message(
      'The data is being saved. Please wait a moment.',
      name: 'gTipSavingData',
      desc: 'This is prompt for saving data.',
      args: [],
    );
  }

  /// `Install Service`
  String get gTipInstallService {
    return Intl.message(
      'Install Service',
      name: 'gTipInstallService',
      desc: 'This is prompt to install service.',
      args: [],
    );
  }

  /// `Start Service`
  String get gTipStartService {
    return Intl.message(
      'Start Service',
      name: 'gTipStartService',
      desc: 'This is prompt to start service.',
      args: [],
    );
  }

  /// `Stop Service`
  String get gTipStopService {
    return Intl.message(
      'Stop Service',
      name: 'gTipStopService',
      desc: 'This is prompt to stop service.',
      args: [],
    );
  }

  /// `Uninstall Service`
  String get gTipUninstallService {
    return Intl.message(
      'Uninstall Service',
      name: 'gTipUninstallService',
      desc: 'This is prompt to uninstall service.',
      args: [],
    );
  }

  /// `Scale List`
  String get gTipScaleList {
    return Intl.message(
      'Scale List',
      name: 'gTipScaleList',
      desc: 'This is prompt for scale list.',
      args: [],
    );
  }

  /// `Service`
  String get gTipService {
    return Intl.message(
      'Service',
      name: 'gTipService',
      desc: 'This is prompt for app service.',
      args: [],
    );
  }

  /// `Service not installed`
  String get gTipServiceUninstalled {
    return Intl.message(
      'Service not installed',
      name: 'gTipServiceUninstalled',
      desc: 'This is prompt for service status.',
      args: [],
    );
  }

  /// `Service Stoped`
  String get gTipServiceStoped {
    return Intl.message(
      'Service Stoped',
      name: 'gTipServiceStoped',
      desc: 'This is prompt for service status.',
      args: [],
    );
  }

  /// `Service is running`
  String get gTipServiceStarted {
    return Intl.message(
      'Service is running',
      name: 'gTipServiceStarted',
      desc: 'This is prompt for service status.',
      args: [],
    );
  }

  /// `Service stoped,please start service.`
  String get gTipServiceOff {
    return Intl.message(
      'Service stoped,please start service.',
      name: 'gTipServiceOff',
      desc: 'This is prompt for service stoped.',
      args: [],
    );
  }

  /// `Modify`
  String get gBtnModify {
    return Intl.message(
      'Modify',
      name: 'gBtnModify',
      desc:
          'This button is used for modifying serial ports or performing other operations.',
      args: [],
    );
  }

  /// `Are you sure to exit the system?`
  String get gTipExitApp {
    return Intl.message(
      'Are you sure to exit the system?',
      name: 'gTipExitApp',
      desc: 'This is prompt to exit the system.',
      args: [],
    );
  }

  /// `Close Port`
  String get gBtnCloseSerialPort {
    return Intl.message(
      'Close Port',
      name: 'gBtnCloseSerialPort',
      desc: 'This is a button to close serial port.',
      args: [],
    );
  }

  /// `Open Port`
  String get gBtnOpenSerialPort {
    return Intl.message(
      'Open Port',
      name: 'gBtnOpenSerialPort',
      desc: 'This is a button to open serial port.',
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
