class ReportData {
  final int id;
  final String reporter;
  final String description;
  final String location;
  final String evidenceLink;
  final bool verified;
  final int reward;
  final int timestamp;
  final bool visibility;

  ReportData({
    required this.id,
    required this.reporter,
    required this.description,
    required this.location,
    required this.evidenceLink,
    required this.verified,
    required this.reward,
    required this.timestamp,
    required this.visibility,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      id: json['id'] as int,
      reporter: json['reporter'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      evidenceLink: json['evidenceLink'] as String,
      verified: json['verified'] as bool,
      reward: json['reward'] as int,
      timestamp: json['timestamp'] as int,
      visibility: json['visibility'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter': reporter,
      'description': description,
      'location': location,
      'evidenceLink': evidenceLink,
      'verified': verified,
      'reward': reward,
      'timestamp': timestamp,
      'visibility': visibility,
    };
  }
} 