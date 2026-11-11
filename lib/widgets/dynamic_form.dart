import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/field_spec.dart';
import '../services/storage_service.dart';

/// Renders an editable form for a [ResourceConfig], seeded from [initialValues].
/// Calling [DynamicFormController.collect] returns the edited field map, ready
/// to send to the API.
class DynamicForm extends StatefulWidget {
  const DynamicForm({
    super.key,
    required this.fields,
    required this.initialValues,
    required this.controller,
  });

  final List<FieldSpec> fields;
  final Map<String, dynamic> initialValues;
  final DynamicFormController controller;

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class DynamicFormController {
  _DynamicFormState? _state;

  Map<String, dynamic>? collect() => _state?._collect();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final _textControllers = <String, TextEditingController>{};
  final _values = <String, dynamic>{};
  final _uploading = <String, bool>{};

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    for (final field in widget.fields) {
      final value = widget.initialValues[field.key];
      _values[field.key] = value;
      if (field.type == FieldType.stringList) {
        _textControllers[field.key] = TextEditingController(
          text: value is List ? value.join(', ') : '',
        );
      } else if (field.type != FieldType.boolean &&
          field.type != FieldType.image &&
          field.type != FieldType.date) {
        _textControllers[field.key] = TextEditingController(text: value?.toString() ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic>? _collect() {
    if (!_formKey.currentState!.validate()) return null;
    final result = <String, dynamic>{};
    for (final field in widget.fields) {
      switch (field.type) {
        case FieldType.number:
          final text = _textControllers[field.key]!.text.trim();
          result[field.key] = text.isEmpty ? null : num.tryParse(text);
        case FieldType.stringList:
          final text = _textControllers[field.key]!.text;
          result[field.key] = text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        case FieldType.boolean:
          result[field.key] = _values[field.key] ?? false;
        case FieldType.image:
        case FieldType.date:
          result[field.key] = _values[field.key];
        case FieldType.text:
        case FieldType.multilineText:
        case FieldType.url:
          final text = _textControllers[field.key]!.text.trim();
          result[field.key] = text.isEmpty ? null : text;
      }
    }
    return result;
  }

  Future<void> _pickAndUploadImage(FieldSpec field) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploading[field.key] = true);
    try {
      final bytes = await picked.readAsBytes();
      final url = await StorageService.instance.uploadBytes(
        bytes: bytes,
        fileName: picked.name,
      );
      setState(() => _values[field.key] = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading[field.key] = false);
    }
  }

  Future<void> _pickDate(FieldSpec field) async {
    final current = DateTime.tryParse(_values[field.key]?.toString() ?? '');
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _values[field.key] = picked.toIso8601String().split('T').first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.fields.map(_buildField).toList(),
      ),
    );
  }

  Widget _buildField(FieldSpec field) {
    switch (field.type) {
      case FieldType.text:
      case FieldType.url:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _textControllers[field.key],
            decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
            keyboardType: field.type == FieldType.url ? TextInputType.url : TextInputType.text,
            validator: field.required
                ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null
                : null,
          ),
        );
      case FieldType.multilineText:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _textControllers[field.key],
            decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
            minLines: 3,
            maxLines: 8,
          ),
        );
      case FieldType.number:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _textControllers[field.key],
            decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: field.required
                ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null
                : null,
          ),
        );
      case FieldType.stringList:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _textControllers[field.key],
            decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
          ),
        );
      case FieldType.boolean:
        return SwitchListTile(
          title: Text(field.label),
          value: _values[field.key] == true,
          onChanged: (value) => setState(() => _values[field.key] = value),
        );
      case FieldType.date:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: () => _pickDate(field),
            child: InputDecorator(
              decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
              child: Text(_values[field.key]?.toString() ?? 'Tap to select'),
            ),
          ),
        );
      case FieldType.image:
        final url = _values[field.key] as String?;
        final isUploading = _uploading[field.key] == true;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              if (url != null && url.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(url, width: 56, height: 56, fit: BoxFit.cover),
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image_outlined),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: isUploading ? null : () => _pickAndUploadImage(field),
                  child: Text(isUploading ? 'Uploading…' : '${field.label}: choose image'),
                ),
              ),
            ],
          ),
        );
    }
  }
}
