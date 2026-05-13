class WeightParamData {
  String unit;
  String max1;
  String max2;
  String n1;
  String n2;
  String weightDecimal;
  String serialPort;
  String printer;
  String autoShutdown;
  String tax;
  String zeroTrack;
  String backlight;
  String baud;
  String language;
  String currency;
  String time;

  WeightParamData(
      this.unit,
      this.max1,
      this.max2,
      this.n1,
      this.n2,
      this.weightDecimal,
      this.serialPort,
      this.printer,
      this.autoShutdown,
      this.tax,
      this.zeroTrack,
      this.backlight,
      this.baud,
      this.language,
      this.currency,
      this.time);
  WeightParamData.fromJson(Map<String, dynamic> json)
      : unit = json['unit'],
        max1 = json['max1'],
        max2 = json['max2'],
        n1 = json['n1'],
        n2 = json['n2'],
        weightDecimal = json['weightDecimal'],
        serialPort = json['serialPort'],
        printer = json['printer'],
        autoShutdown = json['autoShutdown'],
        tax = json['tax'],
        zeroTrack = json['zeroTrack'],
        backlight = json['backlight'],
        baud = json['baud'],
        language = json['language'],
        currency = json['currency'],
        time = json['time'];

  Map<String, dynamic> toJson() {
    return {
      'unit': unit,
      'max1': max1,
      'max2': max2,
      'n1': n1,
      'n2': n2,
      'weightDecimal': weightDecimal,
      'serialPort': serialPort,
      'printer': printer,
      'autoShutdown': autoShutdown,
      'tax': tax,
      'zeroTrack': zeroTrack,
      'backlight': backlight,
      'baud': baud,
      'language': language,
      'currency': currency,
      'time': time,
    };
  }
}

WeightParamData myWeightParamData = WeightParamData(
    "unit",
    "max1",
    "max2",
    "n1",
    "n2",
    "weightDecimal",
    "serialPort",
    "printer",
    "autoShutdown",
    "tax",
    "zeroTrack",
    "backlight",
    "baud",
    "language",
    "currency",
    "time");
