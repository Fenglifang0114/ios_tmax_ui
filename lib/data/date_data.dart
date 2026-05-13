class Date {
  String date;
  Date(this.date);
  Date.fromJson(Map<String, dynamic> json) : date = json['date'];

  Map<String, dynamic> toJson() {
    return {
      'date': date,
    };
  }
}

Date myDate = Date(DateTime.now().toString().split(" ")[0]);
