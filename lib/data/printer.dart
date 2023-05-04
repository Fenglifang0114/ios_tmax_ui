class Printer {
  String printer;

  Printer(this.printer);
  Printer.fromJson(Map<String, dynamic> json) : printer = json['Printer'];
  Map<String, dynamic> toJson() {
    return {
      'Printer': printer,
    };
  }
}

Printer myPrinter = Printer("");
