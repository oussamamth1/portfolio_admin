import 'package:flutter/material.dart';
import '../models/field_spec.dart';
import '../widgets/dynamic_form.dart';

class ResourceFormScreen extends StatefulWidget {
  const ResourceFormScreen({
    super.key,
    required this.title,
    required this.fields,
    required this.initialValues,
    required this.onSave,
  });

  final String title;
  final List<FieldSpec> fields;
  final Map<String, dynamic> initialValues;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  @override
  State<ResourceFormScreen> createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends State<ResourceFormScreen> {
  final _formController = DynamicFormController();
  bool _saving = false;

  Future<void> _save() async {
    final data = _formController.collect();
    if (data == null) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(data);
      if (mounted) Navigator.of(context).pop(true);
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
        title: Text(widget.title),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: DynamicForm(
            fields: widget.fields,
            initialValues: widget.initialValues,
            controller: _formController,
          ),
        ),
      ),
    );
  }
}
