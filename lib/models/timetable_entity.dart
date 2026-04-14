class TimetableEntity {
  final int id;
  final int trainNumber;
  final String station;
  final String time;
  final int direction;
  final int ttid;
  final int runId;

  TimetableEntity({
    required this.id,
    required this.trainNumber,
    required this.station,
    required this.time,
    required this.direction,
    required this.ttid,
    required this.runId,
  });

  factory TimetableEntity.fromJson(Map<String, dynamic> json) {
    return TimetableEntity(
      id: json['id'] ?? 0,
      trainNumber: json['trainNumber'] ?? 0,
      station: json['station'] ?? '',
      time: json['time'] ?? '',
      direction: json['direction'] ?? 0,
      ttid: json['ttid'] ?? 1,
      runId: json['runId'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainNumber': trainNumber,
      'station': station,
      'time': time,
      'direction': direction,
      'ttid': ttid,
      'runId': runId,
    };
  }
}
