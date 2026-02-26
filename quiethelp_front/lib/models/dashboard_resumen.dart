// Para recibir los contadores (QhDashboardResumenDto)
class DashboardResumen {
  final int pendientes;
  final int enRevision;
  final int resueltos;
  final int urgentes;

  DashboardResumen({
    required this.pendientes,
    required this.enRevision,
    required this.resueltos,
    required this.urgentes,
  });

  factory DashboardResumen.fromJson(Map<String, dynamic> json) {
    return DashboardResumen(
      pendientes: json['pendientes'] ?? 0,
      enRevision: json['enRevision'] ?? 0,
      resueltos: json['resueltos'] ?? 0,
      urgentes: json['urgentes'] ?? 0,
    );
  }
}