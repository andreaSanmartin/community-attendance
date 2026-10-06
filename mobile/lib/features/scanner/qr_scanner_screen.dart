import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});
  @override State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scanner = MobileScannerController(torchEnabled: false);
  bool _processing = false;

  Future<void> _handle(String value) async {
    if (_processing) return;
    setState(() => _processing = true);
    await _scanner.stop();
    final api = ApiClient(SecureStorageService());
    try {
      final response = await api.dio.post('/api/attendance/qr', data: {'qr_token': value.trim()});
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => QrResultScreen(success: true, data: Map<String, dynamic>.from(response.data))));
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final detail = data is Map ? data['detail']?.toString() : null;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => QrResultScreen(success: false, message: detail ?? 'No se pudo registrar la asistencia.')));
    } finally {
      if (mounted) {
        setState(() => _processing = false);
        await _scanner.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: AppColors.navy, foregroundColor: Colors.white, title: const Text('Escanear código')),
      body: Stack(
        children: [
          MobileScanner(controller: _scanner, onDetect: (capture) {
            final value = capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
            if (value != null) _handle(value);
          }),
          Center(child: Container(width: 250, height: 250, decoration: BoxDecoration(border: Border.all(color: AppColors.red, width: 4), borderRadius: BorderRadius.circular(24)))),
          Positioned(top: 28, left: 28, right: 28, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.navy.withValues(alpha: .92), borderRadius: BorderRadius.circular(16)), child: const Text('Ubica el código QR del joven dentro del recuadro', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
          if (_processing) const Center(child: Card(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 14), Text('Registrando asistencia...')])))),
        ],
      ),
    );
  }

  @override void dispose() { _scanner.dispose(); super.dispose(); }
}

class QrResultScreen extends StatelessWidget {
  const QrResultScreen({super.key, required this.success, this.data, this.message});
  final bool success;
  final Map<String, dynamic>? data;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(radius: 50, backgroundColor: success ? const Color(0xFFE4F8EB) : const Color(0xFFFFEAD9), child: Icon(success ? Icons.check_rounded : Icons.priority_high_rounded, size: 58, color: success ? AppColors.success : AppColors.warning)),
          const SizedBox(height: 24),
          Text(success ? '¡Asistencia registrada!' : (message?.contains('ya registró') == true ? 'Este joven ya registró su asistencia hoy' : 'No se pudo registrar'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          if (success && data != null) ...[
            const SizedBox(height: 24),
            Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
              Text(data!['full_name']?.toString() ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(data!['tribe_name']?.toString() ?? ''),
              if (data!['project_name'] != null) Text(data!['project_name'].toString()),
              const SizedBox(height: 12),
              Text(data!['attendance_date']?.toString() ?? ''),
            ]))),
          ] else if (!success) ...[
            const SizedBox(height: 16), Text(message ?? '', textAlign: TextAlign.center),
          ],
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.qr_code_scanner_rounded), label: const Text('Escanear otro'))),
        ]),
      ),
    );
  }
}
