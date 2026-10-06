import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/catalog_models.dart';
import '../../models/youth_model.dart';

class ManualAttendanceScreen extends StatefulWidget { const ManualAttendanceScreen({super.key}); @override State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState(); }
class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final _api = ApiClient(SecureStorageService());
  final _search = TextEditingController();
  List<YouthModel> _youth = [];
  List<TribeModel> _tribes = [];
  final Set<String> _selected = {};
  String? _tribeId;
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final responses = await Future.wait([_api.dio.get('/api/youth'), _api.dio.get('/api/tribes')]);
      _youth = (responses[0].data as List).map((e) => YouthModel.fromJson(Map<String,dynamic>.from(e))).toList();
      _tribes = (responses[1].data as List).map((e) => TribeModel.fromJson(Map<String,dynamic>.from(e))).toList();
    } finally { if (mounted) setState(() => _loading = false); }
  }
  List<YouthModel> get _filtered => _youth.where((y) => (_tribeId == null || y.tribeId == _tribeId) && (y.fullName.toLowerCase().contains(_search.text.toLowerCase()) || y.phone.contains(_search.text))).toList();
  Future<void> _save() async {
    if (_selected.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona al menos un joven.'))); return; }
    try {
      final r = await _api.dio.post('/api/attendance/manual', data: {'youth_ids': _selected.toList()});
      if (!mounted) return;
      final registered = (r.data['registered'] as List?)?.length ?? 0;
      final duplicate = (r.data['already_registered'] as List?)?.length ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Se registraron $registered asistencias. $duplicate ya estaban registradas.')));
      setState(() => _selected.clear());
    } on DioException catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.response?.data?['detail']?.toString() ?? 'No se pudo guardar.'))); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Registrar asistencia')),
    body: _loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Buscar joven...', prefixIcon: Icon(Icons.search_rounded))),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(value: _tribeId, decoration: const InputDecoration(labelText: 'Tribu'), items: [const DropdownMenuItem(value: null, child: Text('Todas las tribus')), ..._tribes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))], onChanged: (v) => setState(() => _tribeId = v)),
      ])),
      Expanded(child: ListView.builder(itemCount: _filtered.length, itemBuilder: (_, i) { final y = _filtered[i]; return CheckboxListTile(activeColor: AppColors.red, value: _selected.contains(y.id), title: Text(y.fullName, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(y.phone), onChanged: (v) => setState(() { v == true ? _selected.add(y.id) : _selected.remove(y.id); })); })),
      SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white), onPressed: _save, icon: const Icon(Icons.check_rounded), label: Text('Guardar asistencia (${_selected.length})'))))),
    ]),
  );
}
