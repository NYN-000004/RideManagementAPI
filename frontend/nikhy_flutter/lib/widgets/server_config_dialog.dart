import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_constants.dart';
import '../providers/auth_provider.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _controller = TextEditingController(text: authProvider.baseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AlertDialog(
      title: const Text('Backend API Server Config'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the ASP.NET Core Web API base URL consumed by this app:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://localhost:5231',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Windows / Localhost (5231)'),
                  onPressed: () {
                    _controller.text = ApiConstants.desktopLocalHost;
                  },
                ),
                ActionChip(
                  label: const Text('Android Emulator (10.0.2.2:5231)'),
                  onPressed: () {
                    _controller.text = ApiConstants.androidEmulatorHost;
                  },
                ),
                ActionChip(
                  label: const Text('HTTPS (7275)'),
                  onPressed: () {
                    _controller.text = 'https://localhost:7275';
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            authProvider.resetServerUrl();
            _controller.text = authProvider.baseUrl;
            Navigator.pop(context);
          },
          child: const Text('Reset Default'),
        ),
        ElevatedButton(
          onPressed: () {
            final val = _controller.text.trim();
            if (val.isNotEmpty) {
              authProvider.updateServerUrl(val);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
