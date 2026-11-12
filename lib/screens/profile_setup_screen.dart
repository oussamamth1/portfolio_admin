import 'package:flutter/material.dart';
import '../models/field_spec.dart';
import '../services/api_client.dart';
import '../widgets/dynamic_form.dart';

/// Shown once, right after a new user's first sign-in, before they can see
/// the normal editor. Creates their `profile` row (and with it, their
/// public username) via `POST /me/profile`.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _fields = [
    FieldSpec(
      key: 'username',
      label: 'Username (your public URL: oussamamethnani.vercel.app/u/username)',
      type: FieldType.text,
      required: true,
    ),
    FieldSpec(key: 'name', label: 'Name', type: FieldType.text, required: true),
    FieldSpec(key: 'title', label: 'Title', type: FieldType.text, required: true),
  ];

  final _formController = DynamicFormController();
  bool _saving = false;
  String? _error;

  Future<void> _create() async {
    final data = _formController.collect();
    if (data == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ApiClient.instance.create('/me/profile', {
        'username': (data['username'] as String).toLowerCase(),
        'name': data['name'],
        'title': data['title'],
      });
      widget.onDone();
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your portfolio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DynamicForm(fields: _fields, initialValues: const {}, controller: _formController),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _create,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create my portfolio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
