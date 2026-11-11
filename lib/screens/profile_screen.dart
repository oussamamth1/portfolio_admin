import 'package:flutter/material.dart';
import '../models/field_spec.dart';
import '../services/api_client.dart';
import '../widgets/dynamic_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _future;
  final _formController = DynamicFormController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.instance.getOne(profileConfig.path);
  }

  Future<void> _save() async {
    final data = _formController.collect();
    if (data == null) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.update(profileConfig.path, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero / Intro'),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: DynamicForm(
                fields: profileConfig.fields,
                initialValues: snapshot.data!,
                controller: _formController,
              ),
            ),
          );
        },
      ),
    );
  }
}
