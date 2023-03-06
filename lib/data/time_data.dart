class Time {
  String time;
  Time(this.time);
  Time.fromJson(Map<String, dynamic> json) : time = json['time'];

  Map<String, dynamic> toJson() {
    return {
      'time': time,
    };
  }
}

Time myTime = Time(DateTime.now().toString().substring(10, 16));
