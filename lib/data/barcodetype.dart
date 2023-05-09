class Barcodetypedata {
  String barcodetype;

  Barcodetypedata(
    this.barcodetype,
  );
  Barcodetypedata.fromJson(Map<String, dynamic> json)
      : barcodetype = json['Barcodetype'];

  Map<String, dynamic> toJson() {
    return {
      'Barcodetype': barcodetype,
    };
  }
}

Barcodetypedata myBarcodetypedata = Barcodetypedata(
  "",
);
