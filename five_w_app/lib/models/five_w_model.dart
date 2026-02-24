class FiveWOneH {
  final String what;
  final String why;
  final String who;
  final String where;
  final String when;
  final String how;

  FiveWOneH({
    required this.what,
    required this.why,
    required this.who,
    required this.where,
    required this.when,
    required this.how,
  });

  factory FiveWOneH.fromJson(Map<String, dynamic> json) {
    return FiveWOneH(
      what: json['what'] ?? '',
      why: json['why'] ?? '',
      who: json['who'] ?? '',
      where: json['where'] ?? '',
      when: json['when'] ?? '',
      how: json['how'] ?? '',
    );
  }
}

class AnalyzeResponse {
  final String complexity;
  final FiveWOneH answers;
  final bool cached;

  AnalyzeResponse({
    required this.complexity,
    required this.answers,
    required this.cached,
  });

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponse(
      complexity: json['complexity'] ?? 'Intermediate',
      answers: FiveWOneH.fromJson(json['answers'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      cached: json['cached'] ?? false,
    );
  }
}
