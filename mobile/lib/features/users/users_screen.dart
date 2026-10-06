import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import 'user_form_screen.dart';
import 'user_permissions_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _api = ApiClient(SecureStorageService());

  List<UserModel> _items = [];
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
      final response = await _api.dio.get('/api/users');

      final data = response.data as List;

      _items = data
          .map(
            (e) => UserModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: $e'),
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

  Future<void> _openCreateUser() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const UserFormScreen(),
      ),
    );

    if (created == true) {
      await _load();
    }
  }

  Future<void> _openEditUser(UserModel user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(
          user: user,
        ),
      ),
    );

    await _load();
  }

  Future<void> _openPermissions(UserModel user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserPermissionsScreen(
          user: user,
        ),
      ),
    );

    await _load();
  }

  Future<void> _resetPassword(UserModel user) async {
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Restablecer contraseña'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nueva contraseña temporal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      controller.dispose();
      return;
    }

    final newPassword = controller.text.trim();

    if (newPassword.length < 8) {
      controller.dispose();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La contraseña debe tener al menos 8 caracteres.',
            ),
          ),
        );
      }

      return;
    }

    try {
      await _api.dio.post(
        '/api/users/${user.id}/reset-password',
        data: {
          'new_password': newPassword,
          'force_change': true,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña restablecida.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo restablecer la contraseña: $e',
            ),
          ),
        );
      }
    } finally {
      controller.dispose();
    }
  }

  String _getInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    return parts.map((part) => part[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        onPressed: _openCreateUser,
        icon: const Icon(
          Icons.person_add_alt_1,
        ),
        label: const Text(
          'Nuevo usuario',
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _items.isEmpty
              ? RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 180),
                      Icon(
                        Icons.people_outline,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No hay usuarios registrados.',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) {
                      return const SizedBox(
                        height: 8,
                      );
                    },
                    itemBuilder: (_, index) {
                      final user = _items[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.navy,
                            foregroundColor: Colors.white,
                            child: Text(
                              _getInitials(user.fullName),
                            ),
                          ),
                          title: Text(
                            user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Text(
                            user.isSuperAdmin
                                ? 'Super administrador'
                                : 'Coordinador',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              switch (value) {
                                case 'edit':
                                  await _openEditUser(user);
                                  break;

                                case 'permissions':
                                  await _openPermissions(user);
                                  break;

                                case 'reset':
                                  await _resetPassword(user);
                                  break;
                              }
                            },
                            itemBuilder: (_) {
                              return [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                if (!user.isSuperAdmin)
                                  const PopupMenuItem<String>(
                                    value: 'permissions',
                                    child: Text('Asignar menús'),
                                  ),
                                const PopupMenuItem<String>(
                                  value: 'reset',
                                  child: Text(
                                    'Restablecer contraseña',
                                  ),
                                ),
                              ];
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
