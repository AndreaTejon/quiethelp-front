class MessageRequest {
  final String topic;
  final String message;
  final String? curso;
  final String? grupo;

  MessageRequest({
    required this.topic,
    required this.message,
    this.curso,
    this.grupo,
  });

  Map<String, dynamic> toJson() => {
    "topic": topic,
    "message": message,
    "curso": curso,
    "grupo": grupo,
  };
}