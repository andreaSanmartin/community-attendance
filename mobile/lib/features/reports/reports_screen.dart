import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _api = ApiClient(SecureStorageService());

  Map<String, dynamic>? _summary;
  List<dynamic> _weekly = [];
  List<dynamic> _absent = [];
  List<dynamic> _tribes = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final responses = await Future.wait([
        _api.dio.get('/api/reports/summary'),
        _api.dio.get('/api/reports/weekly'),
        _api.dio.get('/api/reports/absent'),
        _api.dio.get('/api/reports/by-tribe'),
      ]);

      final summaryData = responses[0].data;
      final weeklyData = responses[1].data;
      final absentData = responses[2].data;
      final tribesData = responses[3].data;

      _summary = Map<String, dynamic>.from(summaryData);

      if (weeklyData is Map && weeklyData['items'] is List) {
        _weekly = List<dynamic>.from(weeklyData['items']);
      } else if (weeklyData is List) {
        _weekly = List<dynamic>.from(weeklyData);
      } else {
        _weekly = [];
      }

      if (absentData is List) {
        _absent = List<dynamic>.from(absentData);
      } else {
        _absent = [];
      }

      if (tribesData is List) {
        _tribes = List<dynamic>.from(tribesData);
      } else {
        _tribes = [];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar los reportes: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _metric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.red,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      _metric(
                        context,
                        'Total de jóvenes',
                        '${_summary?['total_active_youth'] ?? 0}',
                        Icons.groups,
                      ),
                      const SizedBox(width: 10),
                      _metric(
                        context,
                        'Asistencias hoy',
                        '${_summary?['today_attendance'] ?? 0}',
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle(
                    context,
                    'Asistencias esta semana',
                  ),
                  const SizedBox(height: 8),
                  if (_weekly.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No hay asistencias registradas esta semana.',
                        ),
                      ),
                    )
                  else
                    ..._weekly.take(10).map(
                      (item) {
                        final x = Map<String, dynamic>.from(item);

                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.red,
                            ),
                            title: Text(
                              '${x['full_name'] ?? 'Sin nombre'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${x['tribe_name'] ?? 'Sin tribu'} · '
                              '${x['project_name'] ?? 'Sin proyecto'}',
                            ),
                            trailing: CircleAvatar(
                              child: Text(
                                '${x['attendance_count'] ?? 0}',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 18),
                  _sectionTitle(
                    context,
                    'Asistencia por tribu',
                  ),
                  const SizedBox(height: 8),
                  if (_tribes.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Todavía no hay información de asistencia por tribu.',
                        ),
                      ),
                    )
                  else
                    ..._tribes.map(
                      (item) {
                        final x = Map<String, dynamic>.from(item);

                        return ListTile(
                          leading: const Icon(
                            Icons.diversity_3,
                            color: AppColors.red,
                          ),
                          title: Text(
                            '${x['tribe_name'] ?? 'Sin tribu'}',
                          ),
                          trailing: Text(
                            '${x['attendance_count'] ?? 0}',
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 18),
                  _sectionTitle(
                    context,
                    'No han asistido esta semana',
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Útil para identificar jóvenes que necesitan seguimiento.',
                  ),
                  const SizedBox(height: 8),
                  if (_absent.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No hay jóvenes pendientes de asistencia.',
                        ),
                      ),
                    )
                  else
                    ..._absent.take(30).map(
                      (item) {
                        final x = Map<String, dynamic>.from(item);

                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.person_off_outlined,
                            ),
                            title: Text(
                              '${x['full_name'] ?? 'Sin nombre'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${x['tribe_name'] ?? 'Sin tribu'} · '
                              '${x['phone'] ?? 'Sin teléfono'}',
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
