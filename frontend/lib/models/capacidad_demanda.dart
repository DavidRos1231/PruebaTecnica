class CapacidadDemanda {
  final int id;
  final String zonaPotencia;
  final String participante;
  final String subcuentaParticipante;
  final double capacidadDemanda;
  final double requisitoAnualPotencia;
  final double requisitoAnualPotenciaEficiente;

  CapacidadDemanda({
    required this.id,
    required this.zonaPotencia,
    required this.participante,
    required this.subcuentaParticipante,
    required this.capacidadDemanda,
    required this.requisitoAnualPotencia,
    required this.requisitoAnualPotenciaEficiente,
  });

  factory CapacidadDemanda.fromJson(Map<String, dynamic> json) {
    return CapacidadDemanda(
      id: json['id'],
      zonaPotencia: json['zonaPotencia'],
      participante: json['participante'],
      subcuentaParticipante: json['subcuentaParticipante'],
      capacidadDemanda: (json['capacidadDemanda'] as num).toDouble(),
      requisitoAnualPotencia: (json['requisitoAnualPotencia'] as num).toDouble(),
      requisitoAnualPotenciaEficiente: (json['requisitoAnualPotenciaEficiente'] as num).toDouble(),
    );
  }
}

class PageableResponse {
  final List<CapacidadDemanda> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;

  PageableResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
  });

  factory PageableResponse.fromJson(Map<String, dynamic> json) {
    return PageableResponse(
      content: (json['content'] as List)
          .map((item) => CapacidadDemanda.fromJson(item))
          .toList(),
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      size: json['size'],
      number: json['number'],
      first: json['first'],
      last: json['last'],
    );
  }
}

class ApiResponse<T> {
  final T? data;
  final String message;
  final bool success;

  ApiResponse({
    this.data,
    required this.message,
    required this.success,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'],
      success: json['success'],
    );
  }
}
