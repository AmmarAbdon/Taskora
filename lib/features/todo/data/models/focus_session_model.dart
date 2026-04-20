class FocusSessionModel {
  final int? id;
  final String date; // YYYY-MM-DD
  final int duration; // in seconds

  FocusSessionModel({this.id, required this.date, required this.duration});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'duration': duration,
    };
  }

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'],
      date: json['date'],
      duration: json['duration'],
    );
  }
}
