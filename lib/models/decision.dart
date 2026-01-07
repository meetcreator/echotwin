class Decision {
  final String id;
  final String userDilemma;
  final String echoTwinResponse;
  final DateTime createdAt;
  final String? audioUrl;
  final String status;

  Decision({
    required this.id,
    required this.userDilemma,
    required this.echoTwinResponse,
    required this.createdAt,
    this.audioUrl,
    this.status = 'open',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userDilemma': userDilemma,
    'echoTwinResponse': echoTwinResponse,
    'createdAt': createdAt.toIso8601String(),
    'audioUrl': audioUrl,
    'status': status,
  };

  factory Decision.fromJson(Map<String, dynamic> json) => Decision(
    id: json['id'] as String,
    userDilemma: json['userDilemma'] as String,
    echoTwinResponse: json['echoTwinResponse'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    audioUrl: json['audioUrl'] as String?,
    status: json['status'] as String? ?? 'open',
  );

  Decision copyWith({
    String? id,
    String? userDilemma,
    String? echoTwinResponse,
    DateTime? createdAt,
    String? audioUrl,
    String? status,
  }) => Decision(
    id: id ?? this.id,
    userDilemma: userDilemma ?? this.userDilemma,
    echoTwinResponse: echoTwinResponse ?? this.echoTwinResponse,
    createdAt: createdAt ?? this.createdAt,
    audioUrl: audioUrl ?? this.audioUrl,
    status: status ?? this.status,
  );
}
